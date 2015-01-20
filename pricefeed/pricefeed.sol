contract Config {
	function register(uint id, address service) {}
	function unregister(uint id) {}
	function lookup(uint service) constant returns(address a) {}
	function kill() {}
}
contract NameReg {
	function register(string32 name) {}
	function unregister() {}
	function addressOf(string32 name) constant returns (address addr) {}
	function nameOf(address addr) constant returns (string32 name) {}
	function kill() {}
}
/*
 * Use with:
 * wget -S -O - http://bullionsupermarket.com/GOLD/ 2> /dev/null | \
 * grep '&nbsp;GOLD' | sed 's/\s*<td.*>&nbsp;GOLD<.td><td.*>\(.*\)<.td><td.*>.*<.td>/\1/' | sed s/,//
 */
contract PriceFeed {
	function PriceFeed() {
		owner = msg.sender;
		address ConfigAddress = 0xd5f9d8d94886e70b06e474c3fb14fd43e2f23970;
		uint NameRegId = 1;
		address nameregAddress = Config(ConfigAddress).lookup(NameRegId);
		NameReg(nameregAddress).register("GoldFeed");
	}
	
	function updateInfo(uint newInfo) {
		if (msg.sender == owner)
			info = newInfo;
	}

	function setPrice(uint newPrice) {
		if (msg.sender == owner)
			price = newPrice;
	}
	
	function get() constant returns(uint r) {
		if (msg.value >= price)
			r = info;
	}
	
	function kill() {
		if (msg.sender == owner) {
			uint NameRegId = 1;
			address nameregAddress = Config(ConfigAddress).lookup(NameRegId);
			NameReg(nameregAddress).unregister();
			suicide(owner);
		}
	}
	
	address owner;
	uint price;
	uint info;
}
/*
// TODO: should be:
contract PriceFeed: owned, mortal {
	function updateInfo(uint newInfo) restrict {
		NameReg(service(1)).register("GoldFeed");
		info = newInfo;
	}
	
	function setPrice(uint newPrice) restrict {
		price = newPrice;
	}
	
	function get() constant returns(uint r) {
		if (msg.value >= price)
			r = info;
	}
	
	uint price;
	uint info;
}

contract owned {
	modifier onlyowner { if (msg.sender == owner) _ }
	address owner = msg.sender;
}

contract mortal extends owned {
	function kill() onlyowner {
		suicide(owner);
	}
}

contract named extends owned, mortal {
	function named(string name) {
		address ConfigAddress = 0xd5f9d8d94886e70b06e474c3fb14fd43e2f23970;
		uint NameRegId = 1;
		address nameregAddress = Config(ConfigAddress).lookup(NameRegId);
		NameReg(nameregAddress).register(name);
	}
	
	function kill() onlyowner {
		uint NameRegId = 1;
		address nameregAddress = Config(ConfigAddress).lookup(NameRegId);
		NameReg(nameregAddress).unregister();
		mortal.kill();
	}
}

contract costs extends owned {
	modifier costs { if (msg.value >= price) _ }
	function setPrice(uint newPrice) onlyowned {
		price = newPrice;
	}
	
	uint price = 0;
}

// TODO: or better:
contract PriceFeed extends owned, mortal, costs, named("GoldFeed") {
	function updateInfo(uint newInfo) onlyowner {
		info = newInfo;
	}
	
	function get() constant costs returns(uint r) {
		r = info;
	}
	
	uint info;
}
*/


