package marketplace

import (
	"context"
	"database/sql"
	"duckdash-nakama/nkerror"
	"duckdash-nakama/user"
	"encoding/json"
	"fmt"
	"time"

	"duckdash-nakama/equipment"

	"github.com/heroiclabs/nakama-common/runtime"
)

const DEFAULT_SIZE = 10
const SUCCESS_RESPONSE = "{\"success\":true}"

type MarketListingItem struct {
	Id            int64     `json:"id"`
	UserID        string    `json:"user_id"`
	EquipmentHash string    `json:"equipment_hash"`
	Price         int64     `json:"price"`
	Tax           int64     `json:"tax"`
	CreatedAt     time.Time `json:"created_at"`
}

type GetListingItemPayloadInterface struct {
	OfCurrentUser bool `json:"ofCurrentUser"`
	FromPrice     int  `json:"fromPrice"`
	ToPrice       int  `json:"toPrice"`
}

type ListingAnItemPayloadInterface struct {
	EquipmentHash string `json:"equipmentHash"`
	Price         int    `json:"price"`
}

type BuyAnItemPayloadInterface struct {
	ListingId int64 `json:"listingId"`
}

type GetListingDetailPayloadInterface struct {
	ListingId int64 `json:"listingId"`
}

type DeleteAListingPayloadInterface struct {
	ListingId int64 `json:"listingId"`
}

type UpdateAListingPayloadInterface struct {
	ListingId int64 `json:"listingId"`
	Price     int64 `json:"price"`
}

func CreateMarketListingTable(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	_, err := db.Exec("CREATE TABLE IF NOT EXISTS market_listing (id serial PRIMARY KEY,user_id VARCHAR ( 100 ) NOT NULL,equipment_hash VARCHAR ( 100 ) NOT NULL,price INTEGER NOT NULL,tax FLOAT,created_at TIMESTAMP NOT NULL);")

	if err != nil {
		return "", runtime.NewError("Storage write error", nkerror.INTERNAL)
	}

	return SUCCESS_RESPONSE, nil
}

func UpdateAListing(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var value UpdateAListingPayloadInterface
	if err := json.Unmarshal([]byte(payload), &value); err != nil {
		return "", err
	}

	query := `UPDATE market_listing SET price = $1 WHERE id = $2`

	_, err := db.Exec(query, value.Price, value.ListingId)

	if err != nil {
		return "", err
	}

	return SUCCESS_RESPONSE, nil
}

func GetListingDetail(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var value GetListingDetailPayloadInterface
	if err := json.Unmarshal([]byte(payload), &value); err != nil {
		return "", err
	}

	item_detail := findListingItemByID(value.ListingId, db)

	response, err := json.Marshal(item_detail)

	if err != nil {
		return "", err
	}

	return string(response), nil
}

func DeleteAListing(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var value DeleteAListingPayloadInterface
	if err := json.Unmarshal([]byte(payload), &value); err != nil {
		return "", err
	}

	err := removeItemFromMarket(value.ListingId, db)

	if err != nil {
		return "", runtime.NewError("Unable to remove item from market", nkerror.INTERNAL)
	}

	return SUCCESS_RESPONSE, nil
}

func GetListingItem(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	uid, ok := context.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", runtime.NewError("Missing user id", 13)
	}

	logger.Info("Payload: %s", payload)

	var value GetListingItemPayloadInterface
	if err := json.Unmarshal([]byte(payload), &value); err != nil {
		return "", err
	}

	query_str := getListingItemQueryString(value, uid)
	print(query_str)
	row, err := db.Query(query_str)

	if err != nil {
		logger.WithField("err", err).Error("Storage write error.")
		return "", err
	}

	listing_items := make([]MarketListingItem, 0)
	for row.Next() {
		item := MarketListingItem{}

		row.Scan(&item.Id, &item.UserID, &item.EquipmentHash, &item.Price, &item.Tax, &item.CreatedAt)
		listing_items = append(listing_items, item)
	}

	response, err := json.Marshal(listing_items)

	if err != nil {
		return "", err
	}

	return string(response), nil
}

func ListAnItemToMarket(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	uid, ok := context.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", runtime.NewError("Missing user id", 13)
	}

	logger.Info("Payload: %s", payload)

	var value ListingAnItemPayloadInterface
	if err := json.Unmarshal([]byte(payload), &value); err != nil {
		return "", err
	}

	isExist := isThisItemExisted(db, value.EquipmentHash)
	print("isExist: ", isExist)
	if isExist {
		return "", runtime.NewError("This item already listed to market", nkerror.RESOURCE_EXHAUSTED)
	}

	query := `INSERT INTO market_listing (user_id, equipment_hash, price, tax, created_at) VALUES ($1, $2, $3, $4, NOW())`
	print(query)

	// To-do: handle tax caculation
	tax := 10
	_, err := db.Exec(query, uid, value.EquipmentHash, value.Price, tax)

	if err != nil {
		return "", err
	}

	return SUCCESS_RESPONSE, nil
}

func isThisItemExisted(db *sql.DB, equipment_hash string) bool {
	sqlStmt := `SELECT id FROM market_listing WHERE equipment_hash = $1`
	err := db.QueryRow(sqlStmt, equipment_hash).Scan(&equipment_hash)
	if err != nil {
		if err != sql.ErrNoRows {
			panic(err)
		}

		return false
	}

	return true
}

func BuyAnItemFromMarket(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	uid, ok := context.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", runtime.NewError("Missing user id", 13)
	}

	logger.Info("Payload: %s", payload)

	var value BuyAnItemPayloadInterface
	if err := json.Unmarshal([]byte(payload), &value); err != nil {
		return "", err
	}

	account, err := nk.AccountGetId(context, uid)
	if err != nil {
		logger.WithField("err", err).Error("Get accounts error.")
		return "", runtime.NewError("Unable to get account", nkerror.INTERNAL)
	}

	var wallet user.Wallet
	if err := json.Unmarshal([]byte(account.Wallet), &wallet); err != nil {
		return "", runtime.NewError("Unable to unmarshal wallet", nkerror.INTERNAL)
	}

	listing_item := findListingItemByID(value.ListingId, db)
	if wallet.Gold < listing_item.Price {
		return "", runtime.NewError("Not enough gold to buy this item", nkerror.RESOURCE_EXHAUSTED)
	}

	err = removeItemFromMarket(listing_item.Id, db)

	if err != nil {
		return "", runtime.NewError("Unable to remove item from market", nkerror.INTERNAL)
	}

	equipment.AddItemToUserInventory(listing_item.EquipmentHash, uid, db, context, nk)
	equipment.RemoveItemFromUserInventory(listing_item.EquipmentHash, listing_item.UserID, db, context, nk)

	subtractGoldFromBuyer(uid, listing_item.Price, context, nk)
	addGoldFromSeller(listing_item.UserID, listing_item.Price, context, nk)

	return SUCCESS_RESPONSE, nil
}

func subtractGoldFromBuyer(uid string, price int64, context context.Context, nk runtime.NakamaModule) {
	change_set := map[string]int64{
		"gold": -price,
	}
	nk.WalletUpdate(context, uid, change_set, nil, true)
}

func addGoldFromSeller(uid string, price int64, context context.Context, nk runtime.NakamaModule) {
	change_set := map[string]int64{
		"gold": price,
	}
	nk.WalletUpdate(context, uid, change_set, nil, true)
}

func findListingItemByID(listingId int64, db *sql.DB) (item MarketListingItem) {
	query := `SELECT * FROM market_listing WHERE id = $1;`

	row := db.QueryRow(query, listingId)

	switch err := row.Scan(&item.Id, &item.UserID, &item.EquipmentHash, &item.Price, &item.Tax, &item.CreatedAt); err {
	case nil:
		return
	default:
		return MarketListingItem{}
	}
}

// Utils
func removeItemFromMarket(item_id int64, db *sql.DB) error {
	query := `DELETE FROM market_listing WHERE id = $1;`
	_, err := db.Exec(query, item_id)

	if err != nil {
		return err
	}

	return nil
}

func getListingItemQueryString(payload GetListingItemPayloadInterface, uid string) string {
	base_query := "SELECT * FROM market_listing WHERE"

	if payload.OfCurrentUser {
		base_query += fmt.Sprintf(` user_id = '%s'`, uid)
	} else {
		base_query += fmt.Sprintf(` user_id != '%s'`, uid)
	}

	if payload.FromPrice > 0 && payload.ToPrice > 0 {
		base_query += fmt.Sprintf(" AND price >= %d AND price <= %d", payload.FromPrice, payload.ToPrice)
	} else {
		if payload.FromPrice > 0 {
			base_query += fmt.Sprintf(" AND price <= %d", payload.ToPrice)
		}

		if payload.ToPrice > 0 {
			base_query += fmt.Sprintf(" AND price >= %d", payload.FromPrice)
		}
	}

	return base_query
}
