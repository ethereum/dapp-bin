//sol Registrar
// Simple global registrar.
// @authors:
//   Gav Wood <g@ethdev.com>

contract NameRegister {
	function getAddress(string32 _name) constant returns (address o_owner) {}
	function getName(address _owner) constant returns (string32 o_name) {}
}

contract Register is NameRegister {
	function owner(string32 _name) constant returns (address o_owner) {}
	function addr(string32 _name) constant returns (address o_address) {}
	function register(string32 _name) constant returns (Register o_register) {}
	function content(string32 _name) constant returns (hash o_content) {}
	
	function name(address _owner) constant returns (string32 o_name) {}
}

#require named

contract Registrar is Register, named("Registrar") {
	struct Record {
		address owner;
		address primary;
		Register registrar;
		hash content;
	}

	event Changed(string32 indexed name);

	function Registrar() {
		// TODO: Populate with hall-of-fame.
	}

	function reserve(string32 _name) {
		// Don't allow the same name to be overwritten.
		if (m_toRecord[_name].owner == 0) {
			m_toRecord[_name].primary = msg.sender;
			Changed(_name);
		}
	}

	function transfer(string32 _name, address _newOwner) {
		if (m_toRecord[_name].owner == msg.sender) {
			m_toRecord[_name].owner = _newOwner;
			Changed(_name);
		}
	}

	function unregister(string32 _name) {
		if (m_toRecord[_name].owner == msg.sender) {
			if (m_toName[m_toRecord[_name].primary] == _name)
				m_toName[m_toRecord[_name].primary] = "";
			delete m_toRecord[_name];
			Changed(_name);
		}
	}

	function setAddress(string32 _name, address _a, bool _primary) {
		if (m_toRecord[_name].owner == msg.sender) {
			m_toRecord[_name].primary = _a;
			if (_primary)
				m_toName[_a] = _name;
			Changed(_name);
		}
	}
	function setRegister(string32 _name, Register _registrar) {
		if (m_toRecord[_name].owner == msg.sender) {
			m_toRecord[_name].registrar = _registrar;
			Changed(_name);
		}
	}
	function setContent(string32 _name, hash _content) {
		if (m_toRecord[_name].owner == msg.sender) {
			m_toRecord[_name].content = _content;
			Changed(_name);
		}
	}
	
	// TODO....
	function record(string32 _name) constant returns (address o_owner, address o_primary, Register o_registrar, hash o_content, string32 o_distributor) {
		o_owner = m_toRecord[_name].owner;
		o_primary = m_toRecord[_name].primary;
		o_registrar = m_toRecord[_name].registrar;
		o_content = m_toRecord[_name].content;
	}
	function owner(string32 _name) constant returns (address) { return m_toRecord[_name].owner; }
	function addr(string32 _name) constant returns (address) { return m_toRecord[_name].primary; }
	function register(string32 _name) constant returns (Register) { return m_toRecord[_name].registrar; }
	function content(string32 _name) constant returns (hash) { return m_toRecord[_name].content; }
	
	function name(address _owner) constant returns (string32 o_name) { return m_toName[_owner]; }
	
/*	event MoreLog {
		index uint l;
		index uint m;
		hash x;
		uint z;
	}*/
	
	mapping (address => string32) m_toName;
	mapping (string32 => Record) m_toRecord;
}

