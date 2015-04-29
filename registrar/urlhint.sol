//sol Registrar
// Simple URL registrar for content hashes.
// @authors:
//   Gav Wood <g@ethdev.com>

contract UrlHint {
	struct Reg {
		bytes32 url;
		address owner;
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

