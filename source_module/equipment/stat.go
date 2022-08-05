package equipment

import (
	"encoding/json"

	"golang.org/x/exp/rand"
)

type StatInfo struct {
	rawId        uint16
	Id           string `json:"id"`
	Desc         string `json:"format"`
	rarity       uint8
	maxIntensity uint8
	intensityCal func(uint8) uint
	rankWeight   int8
	rankCal      func(uint8) float32
}

func NewStatInfo(id string, desc string, rarity uint8, maxIntensity uint8, intensityCal func(uint8) uint, rankWeight int8, rankCal func(uint8) float32) *StatInfo {
	res := StatInfo{0, id, desc, rarity, maxIntensity, intensityCal, rankWeight, rankCal}
	return &res
}

func (stat *StatInfo) calculateIntensity(rawIntensity uint8) uint {
	return stat.intensityCal(rawIntensity)
}

func (stat *StatInfo) calculateRank(rawIntensity uint8) float32 {
	return stat.rankCal(rawIntensity) * float32(stat.rankWeight)
}

func (stat *StatInfo) SetStatInfoRawId(rawId uint16) {
	stat.rawId = rawId
}

func (statInfo *StatInfo) RandStat() Stat {
	return Stat{statInfo, uint8(rand.Int() % int(statInfo.maxIntensity+1))}
}

/*-----------------------------------------------------------------------------------------------*/
type Stat struct {
	info      *StatInfo
	intensity uint8
}

func (stat *Stat) MarshalJSON() ([]byte, error) {
	type Alias Stat
	return json.Marshal(&struct {
		*Alias
		Name  string `json:"name"`
		Value uint   `json:"value"`
	}{
		Alias: (*Alias)(stat),
		Name:  stat.info.Id,
		Value: stat.info.calculateIntensity(stat.intensity),
	})
}
