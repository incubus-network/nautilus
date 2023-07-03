package types

import (
	"math/big"

	sdkmath "cosmossdk.io/math"

	sdk "github.com/cosmos/cosmos-sdk/types"
)

const (
	// AttovBlack defines the default coin denomination used in Ethermint in:
	//
	// - Staking parameters: denomination used as stake in the dPoS chain
	// - Mint parameters: denomination minted due to fee distribution rewards
	// - Governance parameters: denomination used for spam prevention in proposal deposits
	// - Crisis parameters: constant fee denomination used for spam prevention to check broken invariant
	// - EVM parameters: denomination used for running EVM state transitions in Ethermint.
	AttovBlack string = "axfury"

	// BaseDenomUnit defines the base denomination unit for vBlacks.
	// 1 vblack = 1x10^{BaseDenomUnit} axfury
	BaseDenomUnit = 18

	// DefaultGasPrice is default gas price for evm transactions
	DefaultGasPrice = 20
)

// PowerReduction defines the default power reduction value for staking
var PowerReduction = sdkmath.NewIntFromBigInt(new(big.Int).Exp(big.NewInt(10), big.NewInt(BaseDenomUnit), nil))

// NewvBlackCoin is a utility function that returns an "axfury" coin with the given sdkmath.Int amount.
// The function will panic if the provided amount is negative.
func NewvBlackCoin(amount sdkmath.Int) sdk.Coin {
	return sdk.NewCoin(AttovBlack, amount)
}

// NewvBlackDecCoin is a utility function that returns an "axfury" decimal coin with the given sdkmath.Int amount.
// The function will panic if the provided amount is negative.
func NewvBlackDecCoin(amount sdkmath.Int) sdk.DecCoin {
	return sdk.NewDecCoin(AttovBlack, amount)
}

// NewvBlackCoinInt64 is a utility function that returns an "axfury" coin with the given int64 amount.
// The function will panic if the provided amount is negative.
func NewvBlackCoinInt64(amount int64) sdk.Coin {
	return sdk.NewInt64Coin(AttovBlack, amount)
}
