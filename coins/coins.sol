struct Coins {
	address addr;
	string3 name;
	uint256 denom;
}
contract CoinReg {
	function register(string3 name, uint256 denom) {
		m_coins[count].addr = msg.sender;
		m_coins[count].name = name;
		m_coins[count].denom = denom;
		m_count++;
	}
	function count() const returns (uint256 r) { r = m_count; }
	function denom(u256 i) const returns (uint256 r) { r = m_count; }
	uint256 m_count;
	mapping (uint256 => Coin) m_coins;
}
