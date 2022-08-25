package equipment

import (
	"context"
	"database/sql"
	"duckdash-nakama/nkperm"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"github.com/heroiclabs/nakama-common/runtime"
	"golang.org/x/exp/rand"
	"gonum.org/v1/gonum/stat/distuv"
)

const (
	TierCommon    = 1
	TierUncommon  = 2
	TierRare      = 3
	TierEpic      = 4
	TierLegendary = 5

	ChanceCommon    = 49
	ChanceUncommon  = 49 + 30
	ChanceRare      = 49 + 30 + 15
	ChanceEpic      = 49 + 30 + 15 + 5
	ChanceLegendary = 49 + 30 + 15 + 5 + 1
)

var TierStatCount = []float64{0, 2.0, 3.5, 5.0, 6.5, 8.0}
var TierCap = []float32{0, 30, 60, 85, 105, 125}
var TierName = []string{"", "COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY"}

var StatCountProb = [...]int{8, 16, 4, 1}

type EquipmentInterface interface {
	HasSubType() []SubTypeInfo
	RandEquipment() Equipment
	ToRawString(*Equipment) string
	GetTypeName() string
}

/*-----------------------------------------------------------------------------------------------*/
type EquipmentInfo struct {
	rawId        uint8
	typeName     string
	statInfoList []StatInfo
}

func NewEquipmentInfo(typeName string, modifierInfoList []StatInfo, effectInfoList []StatInfo) EquipmentInfo {
	statInfoList := append(modifierInfoList, effectInfoList...)
	// sort.SliceStable(statInfoList, func(i int, j int) bool {
	// 	return statInfoList[i].calculateRank(statInfoList[i].maxIntensity) > statInfoList[j].calculateRank(statInfoList[j].maxIntensity)
	// })
	res := EquipmentInfo{0, typeName, statInfoList}
	return res
}

func (info EquipmentInfo) RandEquipment() Equipment {
	tier := randTier()
	statCount := randStatCount(TierStatCount[tier])
	statList, tier := info.randStatNonRarity(statCount, tier)
	equipment := Equipment{"", info.typeName, "", TierName[tier], statList}
	equipment.Raw = info.ToRawString(&equipment)
	return equipment
}

func (info EquipmentInfo) ToRawString(equipment *Equipment) string {
	result := ""
	result += fmt.Sprintf("%01x", info.rawId)
	result += fmt.Sprintf("%02x", len(equipment.StatList))
	for _, stat := range equipment.StatList {
		result += fmt.Sprintf("%02x", stat.info.rawId)
		result += fmt.Sprintf("%02x", stat.intensity)
	}
	return result
}

func (info EquipmentInfo) HasSubType() []SubTypeInfo {
	return nil
}

func (info EquipmentInfo) GetTypeName() string {
	return info.typeName
}

/*-----------------------------------------------------------------------------------------------*/
type SubTypeInfo struct {
	rawId        uint8
	name         string
	statInfoList []StatInfo
}

func NewSubTypeInfo(name string, modifierInfoList []StatInfo, effectInfoList []StatInfo) SubTypeInfo {
	statInfoList := append(modifierInfoList, effectInfoList...)
	res := SubTypeInfo{0, name, statInfoList}
	return res
}

/*-----------------------------------------------------------------------------------------------*/
type EquipmentWithSubTypeInfo struct {
	EquipmentInfo
	subTypeList []SubTypeInfo
}

func NewEquipmentWithSubTypeInfo(typeName string, subTypeList []SubTypeInfo, modifierInfoList []StatInfo, effectInfoList []StatInfo) EquipmentWithSubTypeInfo {
	res := EquipmentWithSubTypeInfo{NewEquipmentInfo(typeName, modifierInfoList, effectInfoList), subTypeList}
	return res
}

func (eq *EquipmentWithSubTypeInfo) ConvertToEquipmentInfo(subType int) EquipmentInfo {
	statInfoList := append(eq.statInfoList, eq.subTypeList[subType].statInfoList...)
	return EquipmentInfo{eq.rawId, eq.typeName, statInfoList}
}

func (info EquipmentWithSubTypeInfo) RandEquipment() Equipment {
	tier := randTier()
	// fmt.Println("Tier: " + TierName[tier])
	statCount := randStatCount(TierStatCount[tier])
	subType := rand.Int() % len(info.subTypeList)
	statList, tier := info.ConvertToEquipmentInfo(subType).randStatNonRarity(statCount, tier)
	equipment := Equipment{"", info.typeName, info.subTypeList[subType].name, TierName[tier], statList}
	equipment.Raw = info.ToRawString(&equipment)
	return equipment
}

func (info EquipmentWithSubTypeInfo) ToRawString(equipment *Equipment) string {
	result := ""
	result += fmt.Sprintf("%01x", info.rawId)
	for _, subTypeInfo := range info.subTypeList {
		if subTypeInfo.name == equipment.SubType {
			result += fmt.Sprintf("%01x", subTypeInfo.rawId)
		}
	}
	result += fmt.Sprintf("%02x", len(equipment.StatList))
	for _, stat := range equipment.StatList {
		result += fmt.Sprintf("%02x", stat.info.rawId)
		result += fmt.Sprintf("%02x", stat.intensity)
	}
	return result
}

func (info EquipmentWithSubTypeInfo) HasSubType() []SubTypeInfo {
	return info.subTypeList
}

/*-----------------------------------------------------------------------------------------------*/
type Equipment struct {
	Raw      string `json:"raw"`
	TypeName string `json:"type_name"`
	SubType  string `json:"sub_type"`
	Tier     string `json:"tier"`
	StatList []Stat `json:"stat"`
}

func rankSum(statList []Stat) float32 {
	var rank float32
	for i := 0; i < len(statList); i++ {
		rank += statList[i].info.calculateRank(uint8(statList[i].intensity))
		// fmt.Println(statList[i].intensity, " : ", statList[i].info.calculateRank(uint8(statList[i].intensity)))
	}
	return rank
}

func getTier(rank float32) int {
	for i, cap := range TierCap {
		if rank < cap {
			return i
		}
	}
	return 0
}

func (eq *Equipment) GetTier() {
	if len(eq.StatList) == 0 {
		return
	}
	eq.Tier = TierName[getTier(rankSum(eq.StatList))]
}

func randStatVal(statInfoList []StatInfo, tier int) ([]Stat, float32) {
	statList := make([]Stat, len(statInfoList))
	for i := 0; i < len(statInfoList); i++ {
		statList[i] = statInfoList[i].RandStat()
	}
	rankSum := rankSum(statList)
	// raise the intensities if rankSum below meet tier cap
	for rankSum < TierCap[tier-1] {
		// fmt.Println("Fix below", rankSum)
		rankRaised := false
		for i, statInfo := range statInfoList {
			if statList[i].intensity < statInfo.maxIntensity {
				newRankSum := rankSum - statInfo.calculateRank(statList[i].intensity) + statInfo.calculateRank(statList[i].intensity+1)
				if newRankSum < TierCap[tier] {
					rankRaised = true
					rankSum = newRankSum
					statList[i].intensity++
					if newRankSum > TierCap[tier-1] {
						// fmt.Println("Fix Low Rank")
						// for _, stat := range statList {
						// 	fmt.Println(stat.info.id)
						// }
						return statList, rankSum
					}
				}
			}
		}
		if !rankRaised {
			// fmt.Println("Low Rank")
			// for _, stat := range statList {
			// 	fmt.Println(stat.info.id)
			// }
			return statList, rankSum
		}
	}
	// drop the intensities if rankSum below meet tier cap
	for rankSum > TierCap[tier] {
		// fmt.Println("Fix higher", rankSum)
		rankDropped := false
		for i, statInfo := range statInfoList {
			if statList[i].intensity > 0 {
				newRankSum := rankSum - statInfo.calculateRank(statList[i].intensity) + statInfo.calculateRank(statList[i].intensity-1)
				if newRankSum > TierCap[tier-1] {
					rankDropped = true
					rankSum = newRankSum
					statList[i].intensity--
					if newRankSum < TierCap[tier] {
						// fmt.Println("Fix High Rank")
						// for _, stat := range statList {
						// 	fmt.Println(stat.info.id)
						// }
						return statList, rankSum
					}
				}
			}
		}
		if !rankDropped {
			// fmt.Println("High Rank")
			// for _, stat := range statList {
			// 	fmt.Println(stat.info.id)
			// }
			return statList, rankSum
		}
	}
	// fmt.Println("Norm Rank")
	// for _, stat := range statList {
	// 	fmt.Println(stat.info.id)
	// }
	return statList, rankSum
}

func (eqInfo EquipmentInfo) randStatNonRarity(statCount int, tier int) ([]Stat, int) {
	// get rand position
	randPos := make([]int, len(eqInfo.statInfoList))
	for i := 0; i < len(randPos); i++ {
		randPos[i] = i
	}
	for i := len(randPos); i > 0; i-- {
		rPos := rand.Int() % i
		rVal := randPos[rPos]
		randPos = append(randPos[:rPos], randPos[rPos+1:]...)
		randPos = append(randPos, rVal)
	}

	var maxPossibleRank float32
	for i := 0; i < statCount; i++ {
		statInfo := eqInfo.statInfoList[randPos[i]]
		maxPossibleRank += statInfo.calculateRank(statInfo.maxIntensity)
	}
	//increase number of stat
	for maxPossibleRank < TierCap[tier-1] {
		statInfo := eqInfo.statInfoList[randPos[statCount]]
		maxPossibleRank += statInfo.calculateRank(statInfo.maxIntensity)
		statCount++
	}

	statInfoList := make([]StatInfo, statCount)
	for i := 0; i < statCount; i++ {
		statInfoList[i] = eqInfo.statInfoList[randPos[i]]
	}

	statList, rankSum := randStatVal(statInfoList, tier)
	return statList, getTier(rankSum)
}

func randStatCount(offset float64) int {
	norm := distuv.Normal{Mu: offset, Sigma: 0.75}
	value := int(math.Round(norm.Rand()))
	if value < 1 {
		value = 1
	}
	return value
}

func randTier() int {
	offset := rand.Int() % 100
	value := rand.Int() % 100
	randRank := (value+offset)%100 + 1
	switch {
	case randRank <= ChanceCommon:
		return TierCommon
	case randRank <= ChanceUncommon:
		return TierUncommon
	case randRank <= ChanceRare:
		return TierRare
	case randRank <= ChanceEpic:
		return TierEpic
	case randRank <= ChanceLegendary:
		return TierLegendary
	default:
		return 0
	}
}

func TestRandTier(times int) {
	result := []int{0, 0, 0, 0, 0, 0}
	rand.Seed(uint64(time.Now().UTC().UnixNano()))
	for i := 0; i < times; i++ {
		result[randTier()]++
	}
	fmt.Printf("Common: %f %%\n", float32(result[1]*100)/float32(times))
	fmt.Printf("Unommon: %f %%\n", float32(result[2]*100)/float32(times))
	fmt.Printf("Rare: %f %%\n", float32(result[3]*100)/float32(times))
	fmt.Printf("Epic: %f %%\n", float32(result[4]*100)/float32(times))
	fmt.Printf("Legendary: %f %%\n", float32(result[5]*100)/float32(times))
}

func TestRandStatCount(times int) {
	rand.Seed(uint64(time.Now().UTC().UnixNano()))
	m := make(map[int]int)
	for i := 0; i < times; i++ {
		val := randStatCount(8)
		_, e := m[val]
		if !e {
			m[val] = 1
		} else {
			m[val]++
		}
	}
	fmt.Println(m)
}

type StorageEquipmentList struct {
	List []StorageEquipment `json:"list"`
}

type StorageEquipment struct {
	Raw      string `json:"raw"`
	Sellable bool   `json:"sellable"`
}

func (equipment *Equipment) ToStorageObj(sellable bool) StorageEquipment {
	return StorageEquipment{equipment.Raw, sellable}
}

type StorageInventoryEquipmentList struct {
	SkillCaster    []StorageEquipment `json:"skill_caster"`
	Shield         []StorageEquipment `json:"shield"`
	MoveBooster    []StorageEquipment `json:"mv_booster"`
	AttackEnhancer []StorageEquipment `json:"atk_enhancer"`
}

func AddItemToUserInventory(equipment_hash string, uid string, db *sql.DB, context context.Context, nk runtime.NakamaModule) {
	//// READ INVENTORY LIST
	readObjIds := []*runtime.StorageRead{
		{Collection: "inventory", Key: "skill_caster", UserID: uid},
	}

	storage, err := nk.StorageRead(context, readObjIds)
	if err != nil {
		panic(err)
	}

	var list StorageEquipmentList
	if err := json.Unmarshal([]byte(storage[0].GetValue()), &list); err != nil {
		panic(err)
	}
	new_equipment := StorageEquipment{equipment_hash, true}
	list.List = append(list.List, new_equipment)

	//// WRITE BACK TO STORAGE
	storageList, err := json.Marshal(list)
	if err != nil {
		panic(err)
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
		panic(err)
	}
}

func RemoveItemFromUserInventory(equipment_hash string, uid string, db *sql.DB, context context.Context, nk runtime.NakamaModule) {
	//// READ INVENTORY LIST
	readObjIds := []*runtime.StorageRead{
		{Collection: "inventory", Key: "skill_caster", UserID: uid},
	}

	storage, err := nk.StorageRead(context, readObjIds)
	if err != nil {
		panic(err)
	}

	var list StorageEquipmentList
	if err := json.Unmarshal([]byte(storage[0].GetValue()), &list); err != nil {
		panic(err)
	}

	var new_list StorageEquipmentList
	for i := range list.List {
		if list.List[i].Raw != equipment_hash {
			new_list.List = append(new_list.List, list.List[i])
		}
	}

	//// WRITE BACK TO STORAGE
	storageList, err := json.Marshal(new_list)
	if err != nil {
		panic(err)
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
		panic(err)
	}
}
