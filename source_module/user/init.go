package user

import (
	"context"
	"database/sql"
	"duckdash-nakama/nkerror"
	"encoding/json"

	"github.com/heroiclabs/nakama-common/runtime"
)

func UpdateWallet(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	uid, ok := context.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", runtime.NewError("Missing user id", 13)
	}

	// "payload" is bytes sent by the client we'll JSON decode it.
	var changeset map[string]int64
	if err := json.Unmarshal([]byte(payload), &changeset); err != nil {
		return "", runtime.NewError("unable to unmarshal payload", nkerror.INTERNAL)
	}

	metadata := map[string]interface{}{
		"action": "game_finished",
	}

	_, _, err := nk.WalletUpdate(context, uid, changeset, metadata, true)
	if err != nil {
		logger.WithField("err", err).Error("Wallet update error.")
		return "", runtime.NewError("Wallet update error.", nkerror.INTERNAL)
	}

	return "", nil
}

// func InitUser(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, out *api.Session, in *api.AuthenticateEmailRequest) error {
// 	uid, ok := context.Value(runtime.RUNTIME_CTX_USER_ID).(string)
// 	if !ok {
// 		return runtime.NewError("Missing user id", 13)
// 	}

// 	logger.Info("New user registered!")

// 	storageList, err := json.Marshal(equipment.GetDefaultEquipmentList)
// 	if err != nil {
// 		return runtime.NewError("unable to marshal payload", nkerror.INTERNAL)
// 	}

// 	writeObjIds := []*runtime.StorageWrite{
// 		{
// 			Collection:      "stats",
// 			Key:             "lvl",
// 			UserID:          uid,
// 			Value:           `{ "value": 0 }`,
// 			PermissionRead:  nkperm.PERM_PUBLIC_READ,
// 			PermissionWrite: nkperm.PERM_NO_WRITE,
// 		},
// 		{
// 			Collection:      "inventory",
// 			Key:             "skill_caster",
// 			UserID:          uid,
// 			Value:           string(storageList),
// 			PermissionRead:  nkperm.PERM_OWNER_READ,
// 			PermissionWrite: nkperm.PERM_NO_WRITE,
// 		},
// 	}

// 	_, err = nk.StorageWrite(context, writeObjIds)
// 	if err != nil {
// 		logger.WithField("err", err).Error("Storage write error.")
// 		return runtime.NewError("Storage write error", nkerror.INTERNAL)
// 	}

// 	changeset := Wallet{
// 		Gold: 0,
// 		Soul: 0,
// 		Exp:  0,
// 		Skp:  5,
// 	}.ToInterface()

// 	metadata := map[string]interface{}{
// 		"action": "account_creation",
// 	}

// 	_, _, err = nk.WalletUpdate(context, uid, changeset, metadata, true)
// 	if err != nil {
// 		logger.WithField("err", err).Error("Wallet update error.")
// 		return runtime.NewError("Wallet update error.", nkerror.INTERNAL)
// 	}

// 	logger.Info("New user initialized!")

// 	return nil
// }
