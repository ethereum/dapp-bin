This is a fairly simple quasi-centralized gambling application which has an administrator which must supply a seed, but which restricts the administrator's behavior in order for force honesty. Particularly:

1. All bets are processed by the contract automatically by hashing the administrator's seed with the bet nonce and checking if the result is lower than a threshold value.
2. The administrator _must_ choose the seed ahead of time and precommit to it by submitting the hash of the seed into the contract. Bets only process if the seed of the hash is present.
3. At least once every 48 hours, the administrator must submit the seed; the contract then checks if the seed matches the hash, and if it does processes payouts and sets the seed hash to a new value provided by the administrator.
4. If the administrator does not show up for 48 hours, anyone can ping the contract to get all of the funds out
5. The administrator must "unlock" the contract before performing any administrative actions, and wait for 5 blocks before doing anything. This prevents "ninja withdrawing" and other similar actions if the administrator detects that a bet has been sent into the network but not yet confirmed that the administrator sees will be highly lucrative for the bettor.
