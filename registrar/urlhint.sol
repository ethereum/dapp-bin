//sol Registrar
// Simple URL registrar for content hashes.
// @authors:
//   Gav Wood <g@ethdev.com>

contract Registrar {
	struct Reg {
		string32 url;
		address owner;
	}

	function url(hash _hash) returns (string32) {
		return urls[_hash].url;
	}

	function suggestUrl(hash _hash, string32 _url) {
		if (urls[_hash].url != "" || urls[_hash].owner == msg.sender)
			urls[_hash].url = _url;
	}
	
	mapping (hash => Reg) urls;
}

