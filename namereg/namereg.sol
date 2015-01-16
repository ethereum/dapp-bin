//sol NameReg
// Simple global name registrar.
// @authors:
//   kobigurk (from #ethereum-dev)
//   Gav Wood <g@ethdev.com>

contract Config{function register(uint _,address __){}function unregister(uint _){}function lookup(uint _)constant returns(address __){}function kill(){}}

contract NameReg {
	function NameReg() {
		owner = msg.sender;
		address ca = 0x661005d2720d855f1d9976f88bb10c1a3398c77f;
		toName[ca] = "Config";
		toAddress["Config"] = ca;
		toName[address(this)] = "NameReg";
		toAddress["NameReg"] = this;
		Config(ca).register(1, this);
		log1(0, hash256(ca));
		log1(0, hash256(this));
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
		log1(0, hash256(msg.sender));
	}

	function unregister() {
		string32 n = toName[msg.sender];
		if (n == "")
			return;
		log1(0, hash256(toAddress[n]));
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

/*

// Solidity Interface:
contract NameReg{function register(string32 _){}function unregister(){}function addressOf(string32 _)constant returns(address _){}function nameOf(address _)constant returns(string32 _){}function kill(){}}

// Example Solidity use:
NameReg(addrNameReg).register("Some Contract");

// JS Interface:
var abiNameReg = [{"constant":true,"inputs":[{"name":"name","type":"string32"}],"name":"addressOf","outputs":[{"name":"addr","type":"address"}]},{"constant":false,"inputs":[],"name":"kill","outputs":[]},{"constant":true,"inputs":[{"name":"addr","type":"address"}],"name":"nameOf","outputs":[{"name":"name","type":"string32"}]},{"constant":false,"inputs":[{"name":"name","type":"string32"}],"name":"register","outputs":[]},{"constant":false,"inputs":[],"name":"unregister","outputs":[]}];

// Example JS use:
web3.eth.contract(addrNameReg, abiNameReg).register("My Name").transact();

*/
