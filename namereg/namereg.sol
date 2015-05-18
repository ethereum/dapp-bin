//sol NameReg
// Simple global name registrar.
// @authors:
//   Gav Wood <g@ethdev.com>

contract NameRegister {
	function getAddress(bytes32 _name) constant returns (address o_owner) {}
	function getName(address _owner) constant returns (bytes32 o_name) {}
}

import "service";
import "owned";
contract NameReg is service(1), owned, NameRegister {
  	event AddressRegistered(address indexed account);
  	event AddressDeregistered(address indexed account);

	function NameReg() {
		toName[this] = "NameReg";
		toAddress["NameReg"] = this;
		AddressRegistered(this);
	}

	function register(bytes32 name) {
		// Don't allow the same name to be overwritten.
		if (toAddress[name] != address(0))
			return;
		// Unregister previous name if there was one.
		if (toName[msg.sender] != "")
			toAddress[toName[msg.sender]] = 0;
			
		toName[msg.sender] = name;
		toAddress[name] = msg.sender;
		AddressRegistered(msg.sender);
	}

	function unregister() {
		bytes32 n = toName[msg.sender];
		if (n == "")
			return;
		AddressDeregistered(toAddress[n]);
		toName[msg.sender] = "";
		toAddress[n] = address(0);
	}

	function addressOf(bytes32 name) constant returns (address addr) {
		return toAddress[name];
	}

	function nameOf(address addr) constant returns (bytes32 name) {
		return toName[addr];
	}
	
	mapping (address => bytes32) toName;
	mapping (bytes32 => address) toAddress;
}


/*

// Solidity Interface:
contract NameReg{function kill(){}function register(bytes32 name){}function addressOf(bytes32 name)constant returns(address addr){}function unregister(){}function nameOf(address addr)constant returns(bytes32 name){}}

// Example Solidity use:
NameReg(addrNameReg).register("Some Contract");

// JS Interface:
var abi = [{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"getName","outputs":[{"name":"o_name","type":"bytes32"}],"type":"function"},{"constant":false,"inputs":[{"name":"name","type":"bytes32"}],"name":"register","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"name","type":"bytes32"}],"name":"addressOf","outputs":[{"name":"addr","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"bytes32"}],"name":"getAddress","outputs":[{"name":"o_owner","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"unregister","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"addr","type":"address"}],"name":"nameOf","outputs":[{"name":"name","type":"bytes32"}],"type":"function"},{"inputs":[{"indexed":true,"name":"account","type":"address"}],"name":"AddressRegistered","type":"event"},{"inputs":[{"indexed":true,"name":"account","type":"address"}],"name":"AddressDeregistered","type":"event"}];

// Example JS use:
web3.eth.contract(abi).at(address).register("My Name");

*/
