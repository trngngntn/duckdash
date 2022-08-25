package equipment

import (
	"context"
	"database/sql"
	"duckdash-nakama/nkerror"
	"duckdash-nakama/nkperm"
	"duckdash-nakama/user"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/heroiclabs/nakama-common/runtime"
)

const (
	CraftPrice = 5000
)

var skillCasterInfo EquipmentWithSubTypeInfo
var enhancerInfo EquipmentInfo
var modifierList []StatInfo
var effectList []StatInfo
var typeList []EquipmentInterface
var statInfoList []StatInfo
var stypAtkList []SubTypeInfo

func InitEquipmentSystem() {
	/*Define modifier list*/
	modfAtkDmg := NewStatInfo("atk_damage", "%d%% attack damamge", 4, 33, stdIntensityCal, 1, stdRankCal)
	modfAtkDecay := NewStatInfo("atk_decay", "%d%% decay time", 4, 23, stdIntensityCal, 1, stdRankCal)
	modfAtkSpd := NewStatInfo("atk_speed", "%d%% attack speed", 4, 33, stdIntensityCal, 1, stdRankCal)
	modfFireRate := NewStatInfo("fire_rate", "%d%% fire rate", 4, 33, stdIntensityCal, 1, stdRankCal)
	modfCritChance := NewStatInfo("crit_chance", "%d%% critical chance", 4, 33, stdIntensityCal, 1, stdRankCal)
	modfCritMul := NewStatInfo("crit_mul", "%d%% critical damage", 4, 33, critMulIntensityCal, 2, linearRankCal)
	modfProjSpd := NewStatInfo("proj_speed", "%d%% projectile speed", 4, 33, linearIntensityCal, 1, linearRankCal)
	modfProjNum := NewStatInfo("proj_num", "+%d projectile(s)", 4, 4, linearIntensityCal, 5, linearRankCal)
	modfProjPierce := NewStatInfo("proj_pierce", "+%d pierce", 4, 7, linearIntensityCal, 2, linearRankCal)

	// modifierList = initStats(*modfAtkDmg, *modfAtkRange, *modfAtkSpd, *modfFireRate, *modfCritChance, *modfCritMul, *modfProjSpd, *modfProjNum, *modfProjPierce)

	/*Define effect list*/
	effBurn := NewStatInfo("burn", "+%d burn", 1, 3, linearIntensityCal, 3, linearRankCal)
	effFreeze := NewStatInfo("freeze", "+%d freeze", 1, 3, linearIntensityCal, 3, linearRankCal)
	effShock := NewStatInfo("shock", "+%d shock", 1, 3, linearIntensityCal, 3, linearRankCal)
	effKnockback := NewStatInfo("knockback", "+%d knockback", 1, 10, linearIntensityCal, 2, linearRankCal)
	effLifeSteal := NewStatInfo("life_steal", "+%d knockback", 1, 20, linearIntensityCal, 1, linearRankCal)

	effExplode := NewStatInfo("explode", "+%d explode", 1, 2, linearIntensityCal, 5, linearRankCal)
	effImplode := NewStatInfo("implode", "+%d implode", 1, 2, linearIntensityCal, 5, linearRankCal)

	modfEnlargement := NewStatInfo("enlargement", "%d enlargement", 1, 8, multiplyIntensityCal, 3, multiplyRankCal)
	modfAtkDir := NewStatInfo("atk_dir", "+%d direction", 1, 2, linearIntensityCal, 10, linearRankCal)
	modfAtkDirBullet := NewStatInfo("atk_dir", "+%d direction", 1, 6, linearIntensityCal, 10, linearRankCal)

	/**/
	modfMaxHP := NewStatInfo("max_hp", "%d%% maximum HP", 4, 33, stdIntensityCal, 1, stdRankCal)
	modfArmor := NewStatInfo("armor", "+%d armor", 4, 10, linearIntensityCal, 3, linearRankCal)
	modfRegen := NewStatInfo("regen", "+%d/s regen", 4, 10, linearIntensityCal, 4, linearRankCal)

	effAbsorption := NewStatInfo("absorption", "+%d absorption", 1, 10, linearIntensityCal, 2, linearRankCal)
	effReflection := NewStatInfo("reflection", "+%d reflection", 1, 10, linearIntensityCal, 2, linearRankCal)
	effProjBounce := NewStatInfo("proj_bounce", "%d projtile bounce", 1, 9, chanceIntensityCal, 8, linearRankCal)
	effBlock := NewStatInfo("block", "%d block", 1, 9, chanceIntensityCal, 7.5, linearRankCal)

	/**/

	modfMvSpeed := NewStatInfo("mv_speed", "%d%% movement speed", 4, 33, stdIntensityCal, 2, stdRankCal)
	modfDashRange := NewStatInfo("dash_range", "%d%% dash_range", 4, 28, stdIntensityCal, 3, stdRankCal)
	modfDashKin := NewStatInfo("dash_kin", "%d%% kinetic when dash", 4, 14, kineticIntensityCal, 3, kineticRankCal)
	modfKinRate := NewStatInfo("kin_rate", "%d%% kinetic decay", 4, 28, stdIntensityCal, -3, stdRankCal)

	effBlazing := NewStatInfo("blazing", "+%d blazing", 1, 5, linearIntensityCal, 5, linearRankCal)
	effFrosting := NewStatInfo("frosting", "+%d frosting", 1, 5, linearIntensityCal, 5, linearRankCal)
	effShifting := NewStatInfo("shifting", "+%d shifting", 1, 0, linearIntensityCal, 25, linearRankCal)

	// effectList = initStats(*effBurn, *effFreeze, *effShock)
	statInfoList = initStats(
		modfAtkDmg, modfAtkDecay, modfAtkSpd, modfFireRate, modfCritChance, modfCritMul, modfProjSpd, modfProjNum, modfProjPierce,
		effBurn, effFreeze, effShock, effKnockback, effLifeSteal, effExplode, effImplode, modfEnlargement, modfAtkDir, modfAtkDirBullet,
		modfMaxHP, modfArmor, modfRegen,
		effAbsorption, effReflection, effProjBounce, effBlock,
		modfMvSpeed, modfDashRange, modfDashKin, modfKinRate,
		effBlazing, effFrosting, effShifting,
	)

	/**/
	stypAtkPowerPunch := NewSubTypeInfo("POWER_PUNCH", []StatInfo{*modfAtkSpd, *modfEnlargement, *modfAtkDir}, []StatInfo{})
	stypAtkTerrorSlash := NewSubTypeInfo("TERROR_SLASH", []StatInfo{*modfAtkSpd, *modfEnlargement, *modfAtkDir}, []StatInfo{})
	stypAtkMagicBullet := NewSubTypeInfo("MAGIC_BULLET", []StatInfo{*modfAtkDecay, *modfFireRate, *modfProjSpd, *modfProjNum, *modfProjPierce, *modfAtkDirBullet}, []StatInfo{*effExplode, *effImplode})
	stypAtkEnergyBlade := NewSubTypeInfo("ENERGY_BLADE", []StatInfo{*modfAtkDecay, *modfFireRate, *modfEnlargement, *modfProjSpd, *modfAtkDir}, []StatInfo{})

	stypAtkList = initSubTypes(stypAtkPowerPunch, stypAtkTerrorSlash, stypAtkMagicBullet, stypAtkEnergyBlade)

	skillCasterInfo = NewEquipmentWithSubTypeInfo("skill_caster", stypAtkList, []StatInfo{*modfAtkDmg, *modfCritChance, *modfCritMul}, []StatInfo{*effBurn, *effFreeze, *effShock, *effKnockback, *effLifeSteal})
	skillCasterInfo.rawId = 1

	enhancerInfo = NewEquipmentInfo(
		"enhancer",
		[]StatInfo{*modfAtkDmg, *modfAtkSpd, *modfFireRate, *modfCritChance, *modfCritMul, *modfMaxHP, *modfArmor, *modfRegen, *modfMvSpeed, *modfDashRange, *modfDashKin, *modfKinRate},
		[]StatInfo{*effAbsorption, *effReflection, *effProjBounce, *effBlock, *effBlazing, *effFrosting, *effShifting},
	)
	typeList = append(typeList, skillCasterInfo)

	fmt.Println("Equipment System Initialized")
}

func GetDefaultEquipmentList() StorageEquipmentList {
	list := make([]StorageEquipment, len(stypAtkList))
	for i, styp := range stypAtkList {
		eq := Equipment{"", skillCasterInfo.typeName, styp.name, "", nil}
		eq.Raw = skillCasterInfo.ToRawString(&eq)
		list[i] = eq.ToStorageObj(false)
	}
	return StorageEquipmentList{list}
}

// -50 -25 50 150
func kineticIntensityCal(rawIntensity uint8) uint {
	var res uint
	if rawIntensity < 5 {
		res = 10 * uint(rawIntensity+5)
	} else {
		res = 10 * uint(rawIntensity+6)
	}
	return res
}

// 0.25x to 2.5x step 0.25x // raw 0 ->8
func multiplyIntensityCal(rawIntensity uint8) uint {
	var res uint
	if rawIntensity < 3 {
		res = 25 * uint(rawIntensity+1)
	} else {
		res = 25 * uint(rawIntensity+2)
	}
	return res
}

// 5% to 100% step 5% // raw 0 -> 19
func chanceIntensityCal(rawIntensity uint8) uint {
	return uint((rawIntensity + 1) * 5)
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

func critMulIntensityCal(rawIntensity uint8) uint {
	return 110 + uint(rawIntensity)*10
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

func multiplyRankCal(rawIntensity uint8) float32 {
	if rawIntensity < 3 {
		return float32(rawIntensity) - 3
	} else {
		return float32(rawIntensity) - 2
	}
}

func kineticRankCal(rawIntensity uint8) float32 {
	if rawIntensity < 5 {
		return 5 - float32(rawIntensity)
	} else {
		return 4 - float32(rawIntensity)
	}
}

func initSubTypes(args ...SubTypeInfo) []SubTypeInfo {
	res := make([]SubTypeInfo, len(args))
	for i := 0; i < len(args); i++ {
		args[i].rawId = uint8(i + 1)
		res[i] = args[i]
	}
	return res
}

func initStats(args ...*StatInfo) []StatInfo {
	res := make([]StatInfo, len(args))
	for i := 0; i < len(args); i++ {
		args[i].rawId = (uint16(i + 1))
		res[i] = *args[i]
		// fmt.Println("SUBTYPERAW", res[i].rawId)
	}
	return res
}

func ParseEquipment(raw string) (*Equipment, error) {
	idx := 1
	typeIdx, err := strconv.ParseInt(raw[:idx], 16, 8)
	if err != nil {
		return nil, runtime.NewError("error parsing equipment", nkerror.INTERNAL)
	}
	sTypList := typeList[typeIdx-1].HasSubType()
	subType := ""
	if sTypList != nil {
		sTypIdx, err := strconv.ParseInt(raw[idx:idx+1], 16, 8)
		if err != nil {
			return nil, runtime.NewError("error parsing equipment", nkerror.INTERNAL)
		}
		idx++
		subType = sTypList[sTypIdx-1].name
	}
	statCount, err := strconv.ParseInt(raw[idx:idx+2], 16, 8)
	if err != nil {
		return nil, runtime.NewError("error parsing equipment", nkerror.INTERNAL)
	}
	idx += 2
	statList := make([]Stat, statCount)
	for i := 0; i < int(statCount); i++ {
		statIdx, err := strconv.ParseInt(raw[idx:idx+2], 16, 8)
		if err != nil {
			return nil, runtime.NewError("error parsing equipment", nkerror.INTERNAL)
		}
		idx += 2
		statVal, err := strconv.ParseInt(raw[idx:idx+2], 16, 8)
		if err != nil {
			return nil, runtime.NewError("error parsing equipment", nkerror.INTERNAL)
		}
		idx += 2
		statList[i] = Stat{&statInfoList[statIdx-1], uint8(statVal)}
	}

	res := Equipment{"", typeList[typeIdx-1].GetTypeName(), subType, "", statList}
	res.GetTier()
	res.Raw = typeList[typeIdx-1].ToRawString(&res)
	return &res, nil
}

func TestParseEquipment(raw string) {
	eq, err := ParseEquipment(raw)
	if err != nil {
		fmt.Println("Invalid format, unable to parse")
		return
	}
	response, err := json.Marshal(eq)
	if err != nil {
		fmt.Println("JSON Marshalling error")
		return
	}
	fmt.Println(string(response))
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
	// statInfoList = append(modifierList, effectList...)
	response, err := json.Marshal(statInfoList)
	if err != nil {
		return "", runtime.NewError("unable to marshal payload", nkerror.INTERNAL)
	}
	return string(response), nil
}

func CraftEquipment(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	uid, ok := context.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", runtime.NewError("Missing user id", 13)
	}

	logger.Info("Payload: %s", payload)

	account, err := nk.AccountGetId(context, uid)
	if err != nil {
		logger.WithField("err", err).Error("Get accounts error.")
		return "", runtime.NewError("Unable to get account", nkerror.INTERNAL)
	}

	var wallet user.Wallet
	if err := json.Unmarshal([]byte(account.Wallet), &wallet); err != nil {
		return "", runtime.NewError("Unable to unmarshal wallet", nkerror.INTERNAL)
	}

	if wallet.Soul < CraftPrice {
		return "", runtime.NewError("Not enough souls", nkerror.RESOURCE_EXHAUSTED)
	}

	// "payload" is bytes sent by the client we'll JSON decode it.
	var value map[string]string
	if err := json.Unmarshal([]byte(payload), &value); err != nil {
		return "", runtime.NewError("unable to unmarshal payload", 13)
	}

	// typ := rand.Int() % len(typeList)
	var typ EquipmentInterface

	switch {
	case value["type"] == "skill_caster":
		typ = skillCasterInfo
	default:
		typ = enhancerInfo
	}

	equipment := typ.RandEquipment()

	//// READ INVENTORY LIST
	readObjIds := []*runtime.StorageRead{
		{Collection: "inventory", Key: "skill_caster", UserID: uid},
	}

	storage, err := nk.StorageRead(context, readObjIds)
	if err != nil {
		return "", runtime.NewError("unable to read storage", nkerror.INTERNAL)
	}

	var list StorageEquipmentList
	if err := json.Unmarshal([]byte(storage[0].GetValue()), &list); err != nil {
		return "", runtime.NewError("unable to unmarshal payload", 13)
	}
	list.List = append(list.List, equipment.ToStorageObj(true))

	//// WRITE BACK TO STORAGE
	storageList, err := json.Marshal(list)
	if err != nil {
		return "", runtime.NewError("unable to marshal payload", nkerror.INTERNAL)
	}
	writeObjIds := []*runtime.StorageWrite{
		{
			Collection:      "inventory",
			Key:             "skill_caster",
			UserID:          uid,
			Value:           string(storageList),
			PermissionRead:  nkperm.PERM_OWNER_READ,
			PermissionWrite: nkperm.PERM_NO_WRITE,
		},
	}

	_, err = nk.StorageWrite(context, writeObjIds)
	if err != nil {
		// logger.WithField("err", err).Error("Storage write error.")
		return "", runtime.NewError("Storage write error", nkerror.INTERNAL)
	}

	//// RES

	response, err := json.Marshal(equipment)
	if err != nil {
		return "", runtime.NewError("unable to marshal payload", nkerror.INTERNAL)
	}
	return string(response), nil
}

func GetInventory(context context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	uid, ok := context.Value(runtime.RUNTIME_CTX_USER_ID).(string)
	if !ok {
		return "", runtime.NewError("Missing user id", 13)
	}

	readObjIds := []*runtime.StorageRead{
		{Collection: "inventory", Key: "skill_caster", UserID: uid},
		{Collection: "inventory", Key: "shield", UserID: uid},
		{Collection: "inventory", Key: "mv_booster", UserID: uid},
		{Collection: "inventory", Key: "atk_enhancer", UserID: uid},
	}

	storage, err := nk.StorageRead(context, readObjIds)
	if err != nil {
		return "", runtime.NewError("unable to read storage", nkerror.INTERNAL)
	}

	result := make(map[string][]*Equipment)

	for _, st := range storage {
		var list StorageEquipmentList
		if err := json.Unmarshal([]byte(st.GetValue()), &list); err != nil {
			return "", runtime.NewError("unable to unmarshal payload", nkerror.INTERNAL)
		}
		result[st.Key] = make([]*Equipment, len(list.List))
		for i, steq := range list.List {
			result[st.Key][i], err = ParseEquipment(steq.Raw)
			if err != nil {
				return "", runtime.NewError("error parsing equipment", nkerror.INTERNAL)
			}
		}
	}

	response, err := json.Marshal(result)
	if err != nil {
		return "", runtime.NewError("unable to marshal payload", nkerror.INTERNAL)
	}
	return string(response), nil
}
