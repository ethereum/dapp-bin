contract Gavmble {
    struct Order {
        address coinbase;
        address owner;
        uint amount;
        uint8 pIn256;
    } 

    // Create a Gavmble contract.
    function Gavmble() {
        address(0x72ba7d8e73fe8eb666ea66babc8116a41bfb10e2).callstring32string32("register", "Gavmble4");
        owner = msg.sender;
    }

    // TODO: allow giving a dead hash.
    // Provide a chance of `pIn256` in 256 (approx `floor(pIn256/256.0*100)`%) that one later claim from
    // `msg.caller` which provides the inverse Keccak hash of `key` will result in a transfer of
    // `web3.toEth(floor(floor(msg.value * 99 / 100) * 256 / pIn256))` back to them.
    function bet(uint8 pIn256, hash key) {
        orders[key].coinbase = block.prevhash;
        orders[key].owner = msg.sender;
        orders[key].amount = msg.value * 99 / 100;
        orders[key].pIn256 = pIn256;
    }

	// Send `web3.toEth(winningsWithKey(sha3(bet), bet))` to `msg.sender` if and only if they are
	// `orders[sha3(bet)].owner`.
    function claim(hash bet) {
        hash key = sha3(bet);
        if (orders[key].owner == msg.sender) {
			uint w = winningsWithKey(key, bet);
			msg.sender.send(w);
			//delete orders[key];
			orders[key].coinbase = 0;
			orders[key].owner = 0;
			orders[key].amount = 0;
			orders[key].pIn256 = 0;
		}
    }

    function winningsWithKey(hash key, hash bet) constant returns(uint r) {
        if (uint8(sha3(hash(orders[key].coinbase)) ^ bet) < orders[key].pIn256)
            return orders[key].amount * 256 / orders[key].pIn256;
        else
            return 0;
    }
    
    function winnings(hash bet) constant returns(uint r) {
        return winningsWithKey(sha3(bet), bet);
    }
    
    function empty() {
        owner.send(address(this).balance);
    }

    address owner;
    mapping(hash => Order) orders;
}

