//sol Registrar
// Simple global registrar.
// @authors:
//   Gav Wood <g@ethdev.com>

import "owned";

contract NameRegistrar {
	function getAddress(bytes32 _name) constant returns (address o_owner) {}
	function getName(address _owner) constant returns (bytes32 o_name) {}
}

contract Registrar is NameRegistrar {
	event Changed(bytes32 indexed name);
	event PrimaryChanged(bytes32 indexed name, address indexed addr);

	function owner(bytes32 _name) constant returns (address o_owner) {}
	function addr(bytes32 _name) constant returns (address o_address) {}
	function subRegistrar(bytes32 _name) constant returns (address o_subRegistrar) {}
	function content(bytes32 _name) constant returns (bytes32 o_content) {}
	
	function name(address _owner) constant returns (bytes32 o_name) {}
}

contract OwnedRegistrar is Registrar, owned {
	struct Record {
		address primary;
		address subRegistrar;
		bytes32 content;
	}

	function disown(bytes32 _name) onlyowner {
		if (m_toName[m_toRecord[_name].primary] == _name)
		{
			PrimaryChanged(_name, m_toRecord[_name].primary);
			m_toName[m_toRecord[_name].primary] = "";
		}
		delete m_toRecord[_name];
		Changed(_name);
	}

	function setAddress(bytes32 _name, address _a, bool _primary) onlyowner {
		m_toRecord[_name].primary = _a;
		if (_primary)
		{
			PrimaryChanged(_name, _a);
			m_toName[_a] = _name;
		}
		else
			Changed(_name);
	}
	function setSubRegistrar(bytes32 _name, address _registrar) onlyowner {
		m_toRecord[_name].subRegistrar = _registrar;
		Changed(_name);
	}
	function setContent(bytes32 _name, bytes32 _content) onlyowner {
		m_toRecord[_name].content = _content;
		Changed(_name);
	}
	function record(bytes32 _name) constant returns (address o_primary, address o_subRegistrar, bytes32 o_content) {
		o_primary = m_toRecord[_name].primary;
		o_subRegistrar = m_toRecord[_name].subRegistrar;
		o_content = m_toRecord[_name].content;
	}
	function addr(bytes32 _name) constant returns (address) { return m_toRecord[_name].primary; }
	function subRegistrar(bytes32 _name) constant returns (address) { return m_toRecord[_name].subRegistrar; }
	function content(bytes32 _name) constant returns (bytes32) { return m_toRecord[_name].content; }

	function name(address _owner) constant returns (bytes32 o_name) { return m_toName[_owner]; }

	mapping (address => bytes32) m_toName;
	mapping (bytes32 => Record) m_toRecord;
}

