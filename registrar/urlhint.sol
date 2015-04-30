//sol Registrar
// Simple URL registrar for content hashes.
// @authors:
//   Gav Wood <g@ethdev.com>

import "GlobalRegistrar";

contract UrlHint {
	struct Reg {
		bytes32 url;
		address owner;
	}
	
	function UrlHint()
	{
		GlobalRegistrar reg = GlobalRegistrar(0xc6d9d2cd449a754c494264e1809c50e34d64562b);
		reg.reserve("UrlHint");
		reg.setAddress("UrlHint", this, true);
	}

	function url(bytes32 _hash) constant returns (bytes32) {
		return urls[_hash].url;
	}

	function suggestUrl(bytes32 _hash, bytes32 _url) {
		if (urls[_hash].url == "" || urls[_hash].owner == msg.sender) {
			urls[_hash].owner = msg.sender;
			urls[_hash].url = _url;
		}
	}
	
	mapping (bytes32 => Reg) urls;
}

