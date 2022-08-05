package main

import (
	"context"
	"database/sql"
	"duckdash-nakama/equipment"
	"fmt"
	"time"

	"golang.org/x/exp/rand"

	"github.com/heroiclabs/nakama-common/runtime"
)

func main() {
	// equipment.TestRandTier(10000)
	// equipment.TestRandStatCount(1000)
	rand.Seed(uint64(time.Now().UTC().UnixNano()))
	equipment.InitEquipmentSystem()
	fmt.Println("Equipment System Initialized")
	equipment.Test()
}

func InitModule(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, initializer runtime.Initializer) error {
	logger.Info("Hello World!")
	rand.Seed(uint64(time.Now().UTC().UnixNano()))
	equipment.InitEquipmentSystem()
	if err := initializer.RegisterRpc("custom_rpc_func_id", equipment.CustomRpcFunc); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}
	if err := initializer.RegisterRpc("craft_equipment", equipment.CraftEquipment); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}
	if err := initializer.RegisterRpc("get_stat_info_list", equipment.GetStatInfoList); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}
	return nil
}
