package util

import (
	"math/rand"
	"strings"
	"time"
)

const alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func init() {
	rand.Seed(time.Now().UnixNano())
}

// generateRandomInt generates a random integer between min and max (inclusive).
func GenerateRandomInt(min, max int64) int64 {
	if min >= max {
		panic("min should be less than max")
	}
	return min + rand.Int63n(max-min+1)
}

// generateRandomString generates a random string of length n using the package-level alphabet.
func GenerateRandomString(n int) string {
	var sb strings.Builder
	k := len(alphabet)

	for i := 0; i < n; i++ {
		c := alphabet[rand.Intn(k)]
		sb.WriteByte(c)
	}

	return sb.String()
}

// generateRandomOwner generates a random owner name.
func GenerateRandomOwner() string {
	return GenerateRandomString(6)
}

// generateRandomMoney generates a random amount of money.
func GenerateRandomMoney() int64 {
	return GenerateRandomInt(0, 1000)
}

// generateRandomCurrency generates a random currency code.
func GenerateRandomCurrency() string {
	currencies := []string{USD, EUR}
	n := len(currencies)
	return currencies[rand.Intn(n)]
}
