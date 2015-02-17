//sol Config
// Simple global configuration registrar.
// @authors:
//   Gav Wood <g@ethdev.com>
#require owned, mortal
contract Config is owned, mortal {
	event ServiceChanged(uint indexed id);
	function register(uint id, address service) {
		if (tx.origin != owner)
			return;
		services[id] = service;
		ServiceChanged(id);
	}

	function unregister(uint id) {
		if (msg.sender != owner && services[id] != msg.sender)
			return;
		services[id] = address(0);
		ServiceChanged(id);
	}

	function lookup(uint service) constant returns(address a) {
		return services[service];
	}

	mapping (uint => address) services;
}

/*

// Solidity Interface:
contract Config{function lookup(uint256 service)constant returns(address a){}function kill(){}function unregister(uint256 id){}function register(uint256 id,address service){}}

// Example Solidity use:
address addrConfig = 0x661005d2720d855f1d9976f88bb10c1a3398c77f;
address addrNameReg = Config(addrConfig).lookup(1);

// JS Interface:
var Config = web3.eth.contractFromAbi([{"constant":true,"inputs":[{"name":"service","type":"uint256"}],"name":"lookup","outputs":[{"name":"a","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"id","type":"uint256"}],"name":"unregister","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"id","type":"uint256"},{"name":"service","type":"address"}],"name":"register","outputs":[],"type":"function"},{"inputs":[{"indexed":true,"name":"id","type":"uint256"}],"name":"ServiceChanged","type":"event"}]);

// Example JS use:
var addrConfig = "0x661005d2720d855f1d9976f88bb10c1a3398c77f";
var addrNameReg;
web3.eth.contract(addrConfig, abiConfig).lookup(1).call().then(function(r){ addrNameReg = r; })

*/
