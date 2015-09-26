### Introduction

This is a fairly simple quasi-centralized gambling application which relies on an administrator to maintain and update a seed, but which uses a smart contract to heavily bind the administrator and force them to be honest.

At any point in time, the contract can be in one of the two states:

* Betting state: users are free to bet, the administrator cannot make any administrative actions (setting a new seed, withdrawing funds, changing the fee, etc)
* Administrative state: users should not bet (they can, but then they will be vulnerable to some kind of cheating attacks), and the administrator can make administrative actions

The administrator can switch the contract to the administrative state at any time, but with a 5 block waiting period; this means that the bettors can be reasonably confident that their bet will get in before any administrative actions can happen.

The administrator must, at minimum every 48 hours, generate a new seed (a random 32-byte value which should be kept secret) and call the `set_curseed` method, which takes two arguments:

* The old seed
* The hash of the new seed

If the old seed does not match the hash provided during the last round of this process, the method fails; hence, the administrator is forced to actually submit the correct value. If the administrator does not do this within 48 hours, then anyone can call `emergency_withdraw` to refund all bettors and donate the remaining deposit to the Ethereum Foundation.

A bet has three parameters: value (implicit in the ether value sent along with the bet), desired winning probability (expressed in multiples of 0.001), and a `bettor_key`, which will be hashed together with the administrator's seed in order to determine whether or not the bet wins. The ocontract keeps track of the maximum winnings that it would have to pay out from all current bets, and bets and withdrawal attempts fail if they lead to a maximum theoretical payout that would be higher than the contract's current reserves.

Bets are processed when the administrator supplies the seed; the hashes are all calculated and all payments are made within one transaction. A maximum of 100 bets is set to make sure that this will actually be possible, though at 3 million gas up to 300 bets can theoretically be processed.

### How to start an instance of serpent_gamble yourself:

1. Run `serpent gamble.py`, get the code, create a new contract containing the code. Get the contract address (eg. using `eth.getTransactionReceipt(<tx>).contractAddress` where `<tx>` should be replaced with the hash of the transaction creating the contract).
2. Suppose the contract address is `0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae` and the address you want to use to administer the contract is `0xaf5558b1b834be59b9ff94e05c17bae9257c9bf1`. Run `python prepare.py gamble=0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae admin=0xaf5558b1b834be59b9ff94e05c17bae9257c9bf1`. This will configure the config.js file to include the correct ABI for the contract plus the addresses.
3. Access `main.html` to play or administer. If you are setting the dapp up on a website, make sure all of the resources in the scripts, styles and images folders, as well as config.js, can be accessed.
