// NameReg
// Simple global name registrar.
// @authors:
//   kobigurk (from #ethereum-dev)
//   Gav Wood <g@ethdev.com>

contract Config {
	function register(uint id, address service) {}
	function unregister(uint id) {}
	function lookup(uint service) constant returns(address a) {}
	function kill() {}
}
contract NameReg {
	function NameReg() {
		owner = msg.sender;
		address ca = 0xd5f9d8d94886e70b06e474c3fb14fd43e2f23970;
		toName[ca] = "Config";
		toAddress["Config"] = ca;
		toName[address(this)] = "NameReg";
		toAddress["NameReg"] = address(this);
		Config(ca).register(1, address(this));
	}

	function register(string32 name) {
		// Don't allow the same name to be overwritten.
		if (toAddress[name] != address(0))
			return;
		// Unregister previous name if there was one.
		if (toName[msg.sender] != "")
			toAddress[toName[msg.sender]] = 0;
		toName[msg.sender] = name;
		toAddress[name] = msg.sender;
	}

	function unregister() {
		string32 n = toName[msg.sender];
		if (n == "")
			return;
		toName[msg.sender] = "";
		toAddress[n] = address(0);
	}

	function kill() {
		if (msg.sender == owner)
			suicide(owner);
	}

	function addressOf(string32 name) constant returns (address addr) {
		return toAddress[name];
	}

	function nameOf(address addr) constant returns (string32 name) {
		return toName[addr];
	}
	
	address owner;
	mapping (address => string32) toName;
	mapping (string32 => address) toAddress;
}

contract NameReg {
	function register(string32 name) {}
	function unregister() {}
	function addressOf(string32 name) constant returns (address addr) {}
	function nameOf(address addr) constant returns (string32 name) {}
	function kill() {}
}
