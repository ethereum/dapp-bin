//sol FixedFeeRegistrar
// Simple global registrar with fixed-fee reservations.
// @authors:
//   Gav Wood <g@ethdev.com>

contract NameRegister {
	function addr(string _name) constant returns (address o_owner);
	function name(address _owner) constant returns (string o_name);
}

contract Registrar is NameRegister {
	event Changed(string indexed name);
	event ReverseChanged(address indexed addr, string indexed name);

	function owner(string _name) constant returns (address o_owner);
	function addr(string _name) constant returns (address o_address);
	function subRegistrar(string _name) constant returns (address o_subRegistrar);
	function content(string _name) constant returns (bytes32 o_content);
	
	function name(address _owner) constant returns (string o_name);
}

contract FixedFeeRegistrar is Registrar {
	struct Record {
		address addr;
		address subRegistrar;
		bytes32 content;
		address owner;
	}

	modifier onlyrecordowner(string _name) { if (m_record(_name).owner == msg.sender) _ }

	function reserve(string _name) {
	    Record rec = m_record(_name);
		if (rec.owner == 0 && msg.value >= c_fee && bytes(_name).length >= 9) {
			rec.owner = msg.sender;
			Changed(_name);
		}
	}
	function disown(string _name, address _refund) onlyrecordowner(_name) {
		delete m_recordData[uint(sha3(_name)) / 8];
		_refund.send(c_fee);
		Changed(_name);
	}
	function setOwner(string _name, address _newOwner) onlyrecordowner(_name) {
		m_record(_name).owner = _newOwner;
		Changed(_name);
	}
	function setAddr(string _name, address _a) onlyrecordowner(_name) {
		m_record(_name).addr = _a;
		Changed(_name);
	}
	function setSubRegistrar(string _name, address _registrar) onlyrecordowner(_name) {
		m_record(_name).subRegistrar = _registrar;
		Changed(_name);
	}
	function setContent(string _name, bytes32 _content) onlyrecordowner(_name) {
		m_record(_name).content = _content;
		Changed(_name);
	}
	function setName(string _name) {
		if (m_record(_name).addr == msg.sender)
		{
			ReverseChanged(msg.sender, _name);
			m_toName[uint(msg.sender)] = _name;
		}
	}
	
	function record(string _name) constant returns (address o_addr, address o_subRegistrar, bytes32 o_content, address o_owner) {
	    Record rec = m_record(_name);
		o_addr = rec.addr;
		o_subRegistrar = rec.subRegistrar;
		o_content = rec.content;
		o_owner = rec.owner;
	}
	function addr(string _name) constant returns (address) { return m_record(_name).addr; }
	function subRegistrar(string _name) constant returns (address) { return m_record(_name).subRegistrar; }
	function content(string _name) constant returns (bytes32) { return m_record(_name).content; }
	function owner(string _name) constant returns (address) { return m_record(_name).owner; }
	function name(address _owner) constant returns (string) { return m_toName[uint(_owner)]; }

	Record[2**253] m_recordData;
	function m_record(string _name) constant internal returns (Record storage o_record) {
	    return m_recordData[uint(sha3(_name)) / 8];
	}
	string[2**160] m_toName;
	uint constant c_fee = 5 ether;
}

