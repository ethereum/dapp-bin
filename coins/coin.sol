//sol
// Simple coin registry.
// @authors:
//   Gav Wood <g@ethdev.com>

#require service, CoinReg

contract coin {
	function coin(string3 name, uint denom) {
		CoinReg(Config().lookup(3)).register(name, denom);
	}
}

