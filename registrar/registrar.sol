//sol Registrar
// Simple global registrar.
// @authors:
//   Gav Wood <g@ethdev.com>

contract NameRegister {
	function getAddress(string32 _name) constant returns (address o_owner) {}
	function getName(address _owner) constant returns (string32 o_name) {}
}

contract Register is NameRegister {
	function getOwner(string32 _name) constant returns (address o_owner) {}
	function getAddress(string32 _name) constant returns (address o_address) {}
	function getRegister(string32 _name) constant returns (Register o_register) {}
	function getContent(string32 _name) constant returns (hash o_content) {}
	
	function getName(address _owner) constant returns (string32 o_name) {}
}

#require named

contract Registrar is Register, named("Registrar") {
	struct Record {
		address owner;
		address primary;
		Register registrar;
		hash content;
	}

	function Registrar() {
		// TODO: Populate with hall-of-fame.
	}

	function reserve(string32 _name) {
		// Don't allow the same name to be overwritten.
		if (m_toRecord[_name].owner == 0) {
			m_toRecord[_name].primary = msg.sender;
			// TODO: Log
		}
	}

	function transfer(string32 _name, address _newOwner) {
		if (m_toRecord[_name].owner == msg.sender) {
			m_toRecord[_name].owner = _newOwner;
			// TODO: Log
		}
	}

	function unregister(string32 _name) {
		if (m_toRecord[_name].owner == msg.sender) {
			if (m_toName[m_toRecord[_name].primary] == _name)
				m_toName[m_toRecord[_name].primary] = "";
			delete m_toRecord[_name];
			// TODO: Log
		}
	}

	function setAddress(string32 _name, address _a, bool _primary) {
		if (m_toRecord[_name].owner == msg.sender) {
			m_toRecord[_name].primary = _a;
			if (_primary)
				m_toName[_a] = _name;
			// TODO: Log
		}
	}
	function setRegister(string32 _name, Register _registrar) {
		if (m_toRecord[_name].owner == msg.sender) {
			m_toRecord[_name].registrar = _registrar;
			// TODO: Log
		}
	}
	function setContent(string32 _name, hash _content) {
		if (m_toRecord[_name].owner == msg.sender) {
			m_toRecord[_name].content = _content;
			// TODO: Log
		}
	}
	
	// TODO....
	function getRecord(string32 _name) constant returns (address o_owner, address o_primary, Register o_registrar, hash o_content) {
		o_owner = m_toRecord[_name].owner;
		o_primary = m_toRecord[_name].primary;
		o_registrar = m_toRecord[_name].registrar;
		o_content = m_toRecord[_name].content;
	}
	function getOwner(string32 _name) constant returns (address o_owner) { o_owner = m_toRecord[_name].owner; }
	function getAddress(string32 _name) constant returns (address o_bene) { o_bene = m_toRecord[_name].primary; }
	function getRegister(string32 _name) constant returns (Register o_registrar) { o_registrar = m_toRecord[_name].registrar; }
	function getContent(string32 _name) constant returns (hash o_content) { o_content = m_toRecord[_name].content; }
	
	function getName(address _owner) constant returns (string32 o_name) { o_name = m_toName[_owner]; }
	
/*	event MoreLog {
		index uint l;
		index uint m;
		hash x;
		uint z;
	}*/
	
	mapping (address => string32) m_toName;
	mapping (string32 => Record) m_toRecord;
}

/*

[{"constant":false,"inputs":[{"name":"_name","type":"string32"}],"name":"reserve","outputs":[]},{"constant":true,"inputs":[{"name":"_name","type":"string32"}],"name":"getRecord","outputs":[{"name":"o_owner","type":"address"},{"name":"o_primary","type":"address"},{"name":"o_registrar","type":"contractRegister"},{"name":"o_content","type":"hash256"}]},{"constant":false,"inputs":[{"name":"_name","type":"string32"},{"name":"_content","type":"hash256"}],"name":"setContent","outputs":[]},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"getName","outputs":[{"name":"o_name","type":"string32"}]},{"constant":true,"inputs":[{"name":"_name","type":"string32"}],"name":"getBeneficiary","outputs":[{"name":"o_owner","type":"address"}]},{"constant":true,"inputs":[{"name":"_name","type":"string32"}],"name":"getRegister","outputs":[{"name":"o_registrar","type":"contractRegister"}]},{"constant":false,"inputs":[{"name":"_name","type":"string32"},{"name":"_registrar","type":"contractRegister"}],"name":"setRegister","outputs":[]},{"constant":false,"inputs":[{"name":"_name","type":"string32"},{"name":"_a","type":"address"},{"name":"_primary","type":"bool"}],"name":"setBeneficiary","outputs":[]},{"constant":false,"inputs":[{"name":"_name","type":"string32"},{"name":"_newOwner","type":"address"}],"name":"transfer","outputs":[]},{"constant":true,"inputs":[{"name":"_name","type":"string32"}],"name":"getContent","outputs":[{"name":"o_content","type":"hash256"}]},{"constant":false,"inputs":[{"name":"_name","type":"string32"}],"name":"unregister","outputs":[]},{"constant":true,"inputs":[{"name":"_name","type":"string32"}],"name":"getAddress","outputs":[{"name":"o_bene","type":"address"}]},{"constant":true,"inputs":[{"name":"_name","type":"string32"}],"name":"getOwner","outputs":[{"name":"o_owner","type":"address"}]}]

contract Registrar{function reserve(string32 _name){}function getRecord(string32 _name)constant returns(address o_owner,address o_primary,contract Register o_registrar,hash256 o_content){}function setContent(string32 _name,hash256 _content){}function getName(address _owner)constant returns(string32 o_name){}function getBeneficiary(string32 _name)constant returns(address o_owner){}function getRegister(string32 _name)constant returns(contract Register o_registrar){}function setRegister(string32 _name,contract Register _registrar){}function setBeneficiary(string32 _name,address _a,bool _primary){}function transfer(string32 _name,address _newOwner){}function getContent(string32 _name)constant returns(hash256 o_content){}function unregister(string32 _name){}function getAddress(string32 _name)constant returns(address o_bene){}function getOwner(string32 _name)constant returns(address o_owner){}}

*/
