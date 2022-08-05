package equipment

import (
	"context"
	"database/sql"
	"duckdash-nakama/nkerror"
	"duckdash-nakama/user"
	"encoding/json"
	"fmt"

	"github.com/heroiclabs/nakama-common/runtime"
	"golang.org/x/exp/rand"
)

const (
	CraftPrice = 5000
)

var skillCasterInfo EquipmentWithSubTypeInfo
var shield EquipmentInfo
var atkEnhancer EquipmentInfo
var mvEnhancer EquipmentInfo
var modifierList []StatInfo
var effectList []StatInfo
var typeList []EquipmentInterface

func InitEquipmentSystem() {
	/*Define modifier list*/
	modfAtkDmg := NewStatInfo("ATTACK_DAMAGE", "%d%% attack damamge", 4, 34, stdIntensityCal, 1, stdRankCal)
	modfAtkRange := NewStatInfo("ATTACK_RANGE", "%d%% attack range", 4, 24, stdIntensityCal, 1, stdRankCal)
	modfAtkSpd := NewStatInfo("ATTACK_SPEED", "%d%% attack speed", 4, 34, stdIntensityCal, 1, stdRankCal)
	modfFireRate := NewStatInfo("FIRE_RATE", "%d%% fire rate", 4, 34, stdIntensityCal, 1, stdRankCal)
	modfCritChance := NewStatInfo("CRIT_CHANCE", "%d%% critical chance", 4, 34, stdIntensityCal, 1, stdRankCal)
	modfCritMul := NewStatInfo("CRIT_MULTIPLY", "%d%% critical damage", 4, 34, linearIntensityCal, 1, linearRankCal)
	modfProjSpd := NewStatInfo("PROJ_SPEED", "%d%% projectile speed", 4, 34, linearIntensityCal, 1, linearRankCal)
	modfProjNum := NewStatInfo("PROJ_NUMBER", "+%d projectile(s)", 4, 4, linearIntensityCal, 5, linearRankCal)
	modfProjPierce := NewStatInfo("PROJ_PIERCE", "+%d pierce", 4, 7, linearIntensityCal, 2, linearRankCal)

	modifierList = initStats(*modfAtkDmg, *modfAtkRange, *modfAtkSpd, *modfFireRate, *modfCritChance, *modfCritMul, *modfProjSpd, *modfProjNum, *modfProjPierce)

	/*Define effect list*/
	effBurn := NewStatInfo("BURN", "%d burn", 1, 3, linearIntensityCal, 3, linearRankCal)
	effFreeze := NewStatInfo("FREEZE", "%d freeze", 1, 3, linearIntensityCal, 3, linearRankCal)
	effShock := NewStatInfo("SHOCK", "%d shock", 1, 3, linearIntensityCal, 3, linearRankCal)

	effectList = initStats(*effBurn, *effFreeze, *effShock)

	/**/
	stypAtkPowerPunch := NewSubTypeInfo("POWER_PUNCH", []StatInfo{*modfAtkSpd}, []StatInfo{})
	stypAtkTerrorSlash := NewSubTypeInfo("TERROR_SLASH", []StatInfo{*modfAtkSpd}, []StatInfo{})
	stypAtkMagicBullet := NewSubTypeInfo("MAGIC_BULLET", []StatInfo{*modfFireRate, *modfProjSpd, *modfProjNum, *modfProjPierce}, []StatInfo{})
	stypAtkEnergyBlade := NewSubTypeInfo("ENERGY_BLADE", []StatInfo{*modfFireRate, *modfProjSpd, *modfProjNum}, []StatInfo{})

	stypAtkList := initSubTypes(stypAtkPowerPunch, stypAtkTerrorSlash, stypAtkMagicBullet, stypAtkEnergyBlade)

	skillCasterInfo = NewEquipmentWithSubTypeInfo("skill_caster", stypAtkList, []StatInfo{*modfAtkDmg, *modfCritChance, *modfCritMul}, []StatInfo{*effBurn, *effFreeze, *effShock})
	typeList = append(typeList, skillCasterInfo)
}

func stdIntensityCal(rawIntensity uint8) uint {
	var res uint
	if rawIntensity < 9 {
		res = 10 * uint(rawIntensity+1)
	} else {
		res = 10 * uint(rawIntensity+2)
	}
	return res
}

func linearIntensityCal(rawIntensity uint8) uint {
	return uint(rawIntensity) + 1
}

func stdRankCal(rawIntensity uint8) float32 {
	if rawIntensity < 9 {
		return float32(rawIntensity) - 9
	} else {
		return float32(rawIntensity) - 8
	}
}

func linearRankCal(rawIntensity uint8) float32 {
	return float32(rawIntensity) + 1
}

func initSubTypes(args ...SubTypeInfo) []SubTypeInfo {
	res := make([]SubTypeInfo, len(args))
	for i := 0; i < len(args); i++ {
		args[i].rawId = uint8(i)
		res[i] = args[i]
	}
	return res
}

func initStats(args ...StatInfo) []StatInfo {
	res := make([]StatInfo, len(args))
	for i := 0; i < len(args); i++ {
		args[i].SetStatInfoRawId(uint16(i))
		res[i] = args[i]
	}
	return res
}

func CustomRpcFunc(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	logger.Info("Payload: %s", payload)

	// "payload" is bytes sent by the client we'll JSON decode it.
	var value interface{}
	if err := json.Unmarshal([]byte(payload), &value); err != nil {
		return "", runtime.NewError("unable to unmarshal payload", 13)
	}

	response, err := json.Marshal(value)
	if err != nil {
		return "", runtime.NewError("unable to marshal payload", 13)
	}

	return string(response), nil
}

func Test() {
	equipment := skillCasterInfo.RandEquipment()
	fmt.Println(equipment)
	response, err := json.Marshal(equipment)
	if err != nil {
		fmt.Println("ERROR")
	} else {
		fmt.Println(string(response))
	}
}

func GetStatInfoList(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	statInfoList := append(modifierList, effectList...)
	response, err := json.Marshal(statInfoList)
	if err != nil {
		return "", runtime.NewError("unable to marshal payload", nkerror.INTERNAL)
	}
	return string(response), nil
}

func CraftEquipment(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	uid, ok := context.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", runtime.NewError("missing user id", 13)
	}

	account, err := nk.AccountGetId(context, uid)
	if err != nil {
		logger.WithField("err", err).Error("Get accounts error.")
		return "", runtime.NewError("unable to get account", nkerror.INTERNAL)
	}

	var wallet user.Wallet
	if err := json.Unmarshal([]byte(account.Wallet), &wallet); err != nil {
		return "", runtime.NewError("unable to unmarshal wallet", nkerror.INTERNAL)
	}

	if wallet.Soul < CraftPrice {
		return "", runtime.NewError("Not enough souls", nkerror.RESOURCE_EXHAUSTED)
	}

	typ := rand.Int() % len(typeList)

	equipment := typeList[typ].RandEquipment()

	response, err := json.Marshal(equipment)
	if err != nil {
		return "", runtime.NewError("unable to marshal payload", nkerror.INTERNAL)
	}

	return string(response), nil

	// objIds := []*runtime.StorageRead{
	// 	&runtime.StorageRead{Collection: "inventory", Key: "weapon", UserID: uid},
	// }

	// nk.StorageRead(context, objIds)

	// response, err := json.Marshal(value)
	// if err != nil {
	// 	return "", runtime.NewError("unable to marshal payload", 13)
	// }
}
