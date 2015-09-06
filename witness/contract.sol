contract Witness {
	enum Phase {
		NA,
		Part
	}
	struct Part {
		Phase p;
		byte[64] pub;
		bytes32 evidence;
	}
	
	function Witness() {
		m_begin = now;
	}
	
	function participate(byte[64] _pub) {
		if (msg.value != c_stake)
			return;
		
		m_parts[msg.sender].pub = _pub;
	}
	
	function submit(bytes32 _evidence) {
	}
	
	mapping ( address => Part ) m_parts;
	uint constant c_stake = 1 ether;
	uint m_begin;
}
