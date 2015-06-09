//sol Registrar
// Simple global registrar.
// @authors:
//   Gav Wood <g@ethdev.com>

import "owned";

contract NameRegistrar {
	function addr(string _name) constant returns (address o_owner) {}
	function name(address _owner) constant returns (string o_name) {}
}

contract Registrar is NameRegistrar {
	event Changed(string indexed name);
	event PrimaryChanged(string indexed name, address indexed addr);

	function owner(string _name) constant returns (address o_owner) {}
	function addr(string _name) constant returns (address o_address) {}
	function subRegistrar(string _name) constant returns (address o_subRegistrar) {}
	function content(string _name) constant returns (bytes32 o_content) {}
	
	function name(address _owner) constant returns (bytes32 o_name) {}
}

contract OwnedRegistrar is Registrar, owned {
	struct Record {
		address primary;
		address subRegistrar;
		bytes32 content;
	}

	function currentOwner() returns (address) {
		return owner;
	}

	function disown(string _name) onlyowner {
		if (m_toName[m_toRecord[_name].primary] == _name)
		{
			PrimaryChanged(_name, m_toRecord[_name].primary);
			m_toName[m_toRecord[_name].primary] = "";
		}
		delete m_toRecord[_name];
		Changed(_name);
	}

	function setAddress(string _name, address _a, bool _primary) onlyowner {
		m_toRecord[_name].primary = _a;
		if (_primary)
		{
			PrimaryChanged(_name, _a);
			m_toName[_a] = _name;
		}
		else
			Changed(_name);
	}
	function setSubRegistrar(string _name, address _registrar) onlyowner {
		m_toRecord[_name].subRegistrar = _registrar;
		Changed(_name);
	}
	function setContent(string _name, bytes32 _content) onlyowner {
		m_toRecord[_name].content = _content;
		Changed(_name);
	}
	function record(string _name) constant returns (address o_primary, address o_subRegistrar, bytes32 o_content) {
		o_primary = m_toRecord[_name].primary;
		o_subRegistrar = m_toRecord[_name].subRegistrar;
		o_content = m_toRecord[_name].content;
	}
	function addr(string _name) constant returns (address) { return m_toRecord[_name].primary; }
	function subRegistrar(string _name) constant returns (address) { return m_toRecord[_name].subRegistrar; }
	function content(string _name) constant returns (bytes32) { return m_toRecord[_name].content; }

	function name(address _owner) constant returns (string o_name) { return m_toName[_owner]; }

	mapping (address => string) m_toName;
	mapping (string => Record) m_toRecord;
}

contract FixedFeeRegistrar is Registrar {
	struct Record {
		address primary;
		address subRegistrar;
		bytes32 content;
		address owner;
	}

	modifier onlyrecordowner(string _name) { if (m_toRecord[_name].owner == msg.sender) _ }

	function reserve(string _name) {
		if (m_toRecord[_name].owner == 0 && msg.value == c_fee) {
			m_toRecord[_name].owner = msg.sender;
			Changed(_name);
		}
	}
	
	function transfer(string _name, address _newOwner) onlyrecordowner(_name) {
		m_toRecord[_name].owner = _newOwner;
		Changed(_name);
	}

	function disown(string _name, address _refund) onlyrecordowner(_name) {
		if (m_toName[m_toRecord[_name].primary] == _name)
		{
			PrimaryChanged(_name, m_toRecord[_name].primary);
			delete m_toName[m_toRecord[_name].primary];
		}
		delete m_toRecord[_name];
		_refund.send(c_fee);
		Changed(_name);
	}

	function setAddress(string _name, address _a, bool _primary) onlyrecordowner(_name) {
		m_toRecord[_name].primary = _a;
		if (_primary)
		{
			PrimaryChanged(_name, _a);
			m_toName[_a] = _name;
		}
		else
			Changed(_name);
	}
	function setSubRegistrar(string _name, address _registrar) onlyrecordowner(_name) {
		m_toRecord[_name].subRegistrar = _registrar;
		Changed(_name);
	}
	function setContent(string _name, bytes32 _content) onlyrecordowner(_name) {
		m_toRecord[_name].content = _content;
		Changed(_name);
	}
	
	function record(string _name) constant returns (address o_primary, address o_subRegistrar, bytes32 o_content) {
		o_primary = m_toRecord[_name].primary;
		o_subRegistrar = m_toRecord[_name].subRegistrar;
		o_content = m_toRecord[_name].content;
	}
	function addr(string _name) constant returns (address) { return m_toRecord[_name].primary; }
	function subRegistrar(string _name) constant returns (address) { return m_toRecord[_name].subRegistrar; }
	function content(string _name) constant returns (bytes32) { return m_toRecord[_name].content; }
	function owner(string _name) constant returns (address) { return m_toRecord[_name].owner; }

	function name(address _owner) constant returns (string o_name) { return m_toName[_owner]; }

	mapping (address => string) m_toName;
	mapping (string => Record) m_toRecord;
	int c_fee = 69 ether;
}

