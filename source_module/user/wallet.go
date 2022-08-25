package user

type Wallet struct {
	Gold int64 `json:"gold"`
	Soul int64 `json:"soul"`
	Exp  int64 `json:"exp"`
	Skp  int64 `json:"skp"`
}

func (wallet Wallet) ToInterface() map[string]int64 {
	return map[string]int64{
		"gold": wallet.Gold,
		"soul": wallet.Soul,
		"exp":  wallet.Exp,
		"skp":  wallet.Skp,
	}
}
