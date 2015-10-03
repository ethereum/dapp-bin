//sol FixedFeeRegistrar
// Simple global registrar with fixed-fee reservations.
// @authors:
//   Gav Wood <g@ethdev.com>

contract Registrar {
	event Changed(string indexed name);

	function owner(string _name) constant returns (address o_owner);
	function addr(string _name) constant returns (address o_address);
	function subRegistrar(string _name) constant returns (address o_subRegistrar);
	function content(string _name) constant returns (bytes32 o_content);
	function name(address _addr) constant returns (string o_name);
}

contract ExpRegistrar is Registrar {
	struct Record {
		address addr;
		address subRegistrar;
		bytes32 content;
		address owner;
		uint8 phase;
		uint32 deadline;
		uint price;
	}

	event OwnerChanged(string indexed name);
	event LockBegin(string indexed name);
	event Locked(string indexed name);
	event Unlocked(string indexed name);
	event AddressChanged(address indexed name);

	modifier onlyrecordowner(string _name) { if (m_record[_name].owner == msg.sender) _ }

	function ExpRegistrar() {
		m_record["gavofyork"].owner = 0x00fc9b9fd6ae40fd47941399915b9ce4fd5e1f28;
		m_record["gavofyork"].price = 2**200;
		m_reverse[0x00fc9b9fd6ae40fd47941399915b9ce4fd5e1f28] = "gavofyork";
		m_record["NameReg"].owner = this;
		m_record["NameReg"].price = 2**200;
		m_reverse[uint160(this)] = "NameReg";
	}
	
	function initLock() {
		if (rec.phase == 0 && msg.sender == rec.owner) {
			rec.phase = 1;
			rec.deadline = now + 7 days;
		}
	}
	function lock(string _name) {
		Record rec = m_record[_name];
		if (rec.phase == 1 && now > rec.deadline) {
			rec.phase = 2;
		}
	}
	function unlock(string _name) {
		Record rec = m_record[_name];
		if (rec.phase == 2 && msg.sender == rec.owner) {
			rec.phase = 0;
		}
	}

	function reserve(string _name) {
		Record rec = m_record[_name];
		if (rec.owner == msg.sender) {
			rec.price += 10 * msg.value;
		}
		else if (rec.owner == 0 && msg.value >= 100 finney) {
			rec.price = 10 * msg.value;
			rec.owner = msg.sender;
			OwnerChanged(_name);
		}
		else if (rec.phase != 2 && rec.owner != 0 && msg.value >= rec.price) {
			rec.owner.send(rec.price * 50 / 100);
			rec.price = 10 * msg.value;
			rec.owner = msg.sender;
			rec.phase = 0;
			OwnerChanged(_name);
		}
	}
	function setOwner(string _name, address _newOwner) onlyrecordowner(_name) {
		m_record[_name].owner = _newOwner;
		Changed(_name);
	}
	function setAddr(string _name, address _a) onlyrecordowner(_name) {
		m_record[_name].addr = _a;
		Changed(_name);
	}
	function setSubRegistrar(string _name, address _registrar) onlyrecordowner(_name) {
		m_record[_name].subRegistrar = _registrar;
		Changed(_name);
	}
	function setContent(string _name, bytes32 _content) onlyrecordowner(_name) {
		m_record[_name].content = _content;
		Changed(_name);
	}
	function setName(string _name) {
		m_reverse[uint160(msg.sender)] = _name;
		AddressChanged(msg.sender);
	}
	
	function record(string _name) constant returns (address o_addr, address o_subRegistrar, bytes32 o_content, address o_owner) {
	    Record rec = m_record[_name];
		o_addr = rec.addr;
		o_subRegistrar = rec.subRegistrar;
		o_content = rec.content;
		o_owner = rec.owner;
	}
	function addr(string _name) constant returns (address) { return m_record[_name].addr; }
	function subRegistrar(string _name) constant returns (address) { return m_record[_name].subRegistrar; }
	function content(string _name) constant returns (bytes32) { return m_record[_name].content; }
	function owner(string _name) constant returns (address) { return m_record[_name].owner; }
	function price(string _name) constant returns (uint) { return m_record[_name].price; }
	function name(address _addr) constant returns (string) { return m_reverse[uint160(_addr)]; }

	string[2**160] m_reverse;
	mapping (string => Record) m_record;
}
