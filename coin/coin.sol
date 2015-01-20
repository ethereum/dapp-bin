//sol Coin

contract Config{function register(uint _,address __){}function unregister(uint _){}function lookup(uint _)constant returns(address __){}function kill(){}}
contract NameReg{function register(string32 _){}function unregister(){}function addressOf(string32 _)constant returns(address __){}function nameOf(address _)constant returns(string32 __){}function kill(){}}

contract GavCoin {
	function GavCoin() {
		m_owner = msg.sender;
		address addrConfig = 0x661005d2720d855f1d9976f88bb10c1a3398c77f;
		Config(addrConfig).register(4, this);
		address addrNameReg = Config(addrConfig).lookup(1);
		NameReg(addrNameReg).register("GavCoin");
		m_balances[m_owner] = 1000000000;
		m_lastNumberMined = block.number;
	}
	
	function sendCoinFrom(address _from, uint _val, address _to) {
		if (m_balances[_from] >= _val && m_approved[_from][msg.sender]) {
			m_balances[_from] -= _val;
			m_balances[_to] += _val;
			log3(hash(_val), 0, hash(_from), hash(_to));
		}
	}
	
	function sendCoin(uint _val, address _to) {
		if (m_balances[msg.sender] >= _val) {
			m_balances[msg.sender] -= _val;
			m_balances[_to] += _val;
			log3(hash(_val), 0, hash(msg.sender), hash(_to));
		}
	}
	
	function coinBalance() constant returns (uint _r) {
		return m_balances[msg.sender];
	}
	
	function coinBalanceOf(address _a) constant returns (uint _r) {
		return m_balances[_a];
	}
	
	function approve(address _a) {
		m_approved[msg.sender][_a] = true;
		log3(0, 1, hash(msg.sender), hash(_a));
	}
	
	function isApproved(address _proxy) constant returns (bool _r) {
		return m_approved[msg.sender][_proxy];
	}
	
	function isApprovedFor(address _target, address _proxy) constant returns (bool _r) {
		return m_approved[_target][_proxy];
	}
	
	function mine() {
		uint r = block.number - m_lastNumberMined;
		if (r > 0) {
			log2(hash(r * 1000), 2, hash(msg.sender));
			log2(hash(r * 1000), 3, hash(block.coinbase));
			m_balances[msg.sender] += 1000 * r;
			m_balances[block.coinbase] += 1000 * r;
			m_lastNumberMined = block.number;
		}
	}
	
	address m_owner;
	mapping (address => uint) m_balances;
	mapping (address => mapping (address => bool)) m_approved;
	uint m_lastNumberMined;
}


/*

[{"constant":true,"inputs":[{"name":"_target","type":"address"},{"name":"_proxy","type":"address"}],"name":"isApprovedFor","outputs":[{"name":"_r","type":"bool"}]},{"constant":true,"inputs":[{"name":"_proxy","type":"address"}],"name":"isApproved","outputs":[{"name":"_r","type":"bool"}]},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_val","type":"uint256"},{"name":"_to","type":"address"}],"name":"sendCoinFrom","outputs":[]},{"constant":false,"inputs":[],"name":"mine","outputs":[]},{"constant":true,"inputs":[{"name":"_a","type":"address"}],"name":"coinBalanceOf","outputs":[{"name":"_r","type":"uint256"}]},{"constant":false,"inputs":[{"name":"_val","type":"uint256"},{"name":"_to","type":"address"}],"name":"sendCoin","outputs":[]},{"constant":true,"inputs":[],"name":"coinBalance","outputs":[{"name":"_r","type":"uint256"}]},{"constant":false,"inputs":[{"name":"_a","type":"address"}],"name":"approve","outputs":[]}]


contract Coin{function isApprovedFor(address _target,address _proxy)constant returns(bool _r){}function isApproved(address _proxy)constant returns(bool _r){}function sendCoinFrom(address _from,uint256 _val,address _to){}function mine(){}function coinBalanceOf(address _a)constant returns(uint256 _r){}function sendCoin(uint256 _val,address _to){}function coinBalance()constant returns(uint256 _r){}function approve(address _a){}}

*/
