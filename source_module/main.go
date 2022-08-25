package main

import (
	"context"
	"database/sql"
	"duckdash-nakama/equipment"
	"duckdash-nakama/marketplace"
	"duckdash-nakama/nkerror"
	"duckdash-nakama/nkperm"
	"duckdash-nakama/user"
	"encoding/json"
	"time"

	"golang.org/x/exp/rand"

	"github.com/heroiclabs/nakama-common/api"
	"github.com/heroiclabs/nakama-common/runtime"
)

func main() {
	equipment.InitEquipmentSystem()
	// equipment.TestRandTier(10000)
	equipment.TestParseEquipment("12020b00060c")
	rand.Seed(uint64(time.Now().UTC().UnixNano()))
	// equipment.Test()
}

func InitUser(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, out *api.Session, in *api.AuthenticateEmailRequest) error {
	uid, ok := context.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return runtime.NewError("Missing user id", nkerror.INTERNAL)
	}
	if !in.Create.Value {
		account, err := nk.AccountGetId(context, uid)
		if err != nil {
			return runtime.NewError("Missing user id", nkerror.INTERNAL)
		}
		for _, device := range account.Devices {
			_ = nk.UnlinkDevice(context, uid, device.Id)
		}
		return nil
	}

	logger.Info("New user registered!")

	storageList, err := json.Marshal(equipment.GetDefaultEquipmentList())
	if err != nil {
		logger.WithField("err", err).Error("unable to marshal payload.")
		return runtime.NewError("unable to marshal payload", nkerror.INTERNAL)
	}

	writeObjIds := []*runtime.StorageWrite{
		{
			Collection:      "stats",
			Key:             "lvl",
			UserID:          uid,
			Value:           `{ "value": 0 }`,
			PermissionRead:  nkperm.PERM_PUBLIC_READ,
			PermissionWrite: nkperm.PERM_NO_WRITE,
		},
		{
			Collection:      "inventory",
			Key:             "skill_caster",
			UserID:          uid,
			Value:           string(storageList),
			PermissionRead:  nkperm.PERM_OWNER_READ,
			PermissionWrite: nkperm.PERM_NO_WRITE,
		},
		{
			Collection:      "inventory",
			Key:             "enhancer",
			UserID:          uid,
			Value:           `{ "list": [] }`,
			PermissionRead:  nkperm.PERM_OWNER_READ,
			PermissionWrite: nkperm.PERM_NO_WRITE,
		},
		{
			Collection:      "equipped",
			Key:             "skill_caster",
			UserID:          uid,
			Value:           `{ "list": [] }`,
			PermissionRead:  nkperm.PERM_OWNER_READ,
			PermissionWrite: nkperm.PERM_NO_WRITE,
		},
		{
			Collection:      "equipped",
			Key:             "enhancer",
			UserID:          uid,
			Value:           `{ "list": [] }`,
			PermissionRead:  nkperm.PERM_OWNER_READ,
			PermissionWrite: nkperm.PERM_NO_WRITE,
		},
		// {
		// 	Collection:      "inventory",
		// 	Key:             "mv_booster",
		// 	UserID:          uid,
		// 	Value:           `{ "list": [] }`,
		// 	PermissionRead:  nkperm.PERM_OWNER_READ,
		// 	PermissionWrite: nkperm.PERM_NO_WRITE,
		// },
		// {
		// 	Collection:      "inventory",
		// 	Key:             "atk_enhancer",
		// 	UserID:          uid,
		// 	Value:           `{ "list": [] }`,
		// 	PermissionRead:  nkperm.PERM_OWNER_READ,
		// 	PermissionWrite: nkperm.PERM_NO_WRITE,
		// },
	}

	_, err = nk.StorageWrite(context, writeObjIds)
	if err != nil {
		logger.WithField("err", err).Error("Storage write error.")
		return runtime.NewError("Storage write error", nkerror.INTERNAL)
	}

	changeset := user.Wallet{
		Gold: 0,
		Soul: 0,
		Exp:  0,
		Skp:  5,
	}.ToInterface()

	metadata := map[string]interface{}{
		"action": "account_creation",
	}

	_, _, err = nk.WalletUpdate(context, uid, changeset, metadata, true)
	if err != nil {
		logger.WithField("err", err).Error("Wallet update error.")
		return runtime.NewError("Wallet update error.", nkerror.INTERNAL)
	}

	logger.Info("New user initialized!")

	return nil
}

func InitModule(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, initializer runtime.Initializer) error {
	logger.Info("Hello World!")
	rand.Seed(uint64(time.Now().UTC().UnixNano()))
	equipment.InitEquipmentSystem()
	if err := initializer.RegisterRpc("custom_rpc_func_id", equipment.CustomRpcFunc); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}
	if err := initializer.RegisterRpc("update_wallet", user.UpdateWallet); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}
	// if err := initializer.RegisterBeforeAuthenticateEmail(user.AutoUnlink); err != nil {
	// 	logger.Error("Unable to register: %v", err)
	// 	return err
	// }
	if err := initializer.RegisterRpc("craft_equipment", equipment.CraftEquipment); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}
	if err := initializer.RegisterRpc("get_stat_info_list", equipment.GetStatInfoList); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}
	if err := initializer.RegisterRpc("get_inventory", equipment.GetInventory); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}

	if err := initializer.RegisterAfterAuthenticateEmail(InitUser); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}

	if err := initializer.RegisterRpc("update_a_listing", marketplace.UpdateAListing); err != nil {
		logger.Error("Unable to UpdateAListing: %v", err)
		return err
	}

	if err := initializer.RegisterRpc("delete_a_listing", marketplace.DeleteAListing); err != nil {
		logger.Error("Unable to DeleteAListing: %v", err)
		return err
	}

	if err := initializer.RegisterRpc("get_listing_item", marketplace.GetListingItem); err != nil {
		logger.Error("Unable to GetListingItem: %v", err)
		return err
	}

	if err := initializer.RegisterRpc("list_an_item_to_market", marketplace.ListAnItemToMarket); err != nil {
		logger.Error("Unable to ListAnItemToMarket: %v", err)
		return err
	}

	if err := initializer.RegisterRpc("by_item_from_market", marketplace.BuyAnItemFromMarket); err != nil {
		logger.Error("Unable to BuyAnItemFromMarket: %v", err)
		return err
	}

	return nil
}
