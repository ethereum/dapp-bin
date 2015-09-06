//sol
// Simple coin registry.
// @authors:
//   Gav Wood <g@ethdev.com>

#require service, named

contract CoinReg is service(3), named("CoinReg") {
	struct CoinInfo {
		address addr;
		string3 name;
		uint denom;
	}
	
	function register(string3 name, uint denom) {
		m_coins[m_count].addr = msg.sender;
		m_coins[m_count].name = name;
		m_coins[m_count].denom = denom;
		m_count++;
	}
	
	function unregister() {
		m_count--;
		for (uint i = 0; i < m_count; ++i)
			if (m_coins[i].addr == msg.sender) {
				if (i != m_count) {
					// TODO: should be m_coins[i] = m_coins[m_count];
					m_coins[i].addr = m_coins[m_count].addr;
					m_coins[i].name = m_coins[m_count].name;
					m_coins[i].denom = m_coins[m_count].denom;
				}
				break;
			}
		delete m_coins[m_count];
	}
	
	function count() constant returns (uint r) { r = m_count; }
	
	function info(uint i) constant returns (address addr, string3 name, uint denom) {
		addr = m_coins[i].addr;
		name = m_coins[i].name;
		denom = m_coins[i].denom;
	}
	
	uint m_count;
	mapping (uint => CoinInfo) m_coins;
}


