//sol FixedFeeRegistrar
// Simple global registrar with fixed-fee reservations.
// @authors:
//   Gav Wood <g@ethdev.com>

import "Registrar";

contract FixedFeeRegistrar is Registrar {
	struct Record {
		address addr;
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
	function disown(string _name, address _refund) onlyrecordowner(_name) {
		delete m_toRecord[_name];
		_refund.send(c_fee);
		Changed(_name);
	}
	function transfer(string _name, address _newOwner) onlyrecordowner(_name) {
		m_toRecord[_name].owner = _newOwner;
		Changed(_name);
	}
	function setAddr(string _name, address _a) onlyrecordowner(_name) {
		m_toRecord[_name].addr = _a;
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
	
	function record(string _name) constant returns (address o_addr, address o_subRegistrar, bytes32 o_content) {
		o_addr = m_toRecord[_name].addr;
		o_subRegistrar = m_toRecord[_name].subRegistrar;
		o_content = m_toRecord[_name].content;
	}
	function addr(string _name) constant returns (address) { return m_toRecord[_name].addr; }
	function subRegistrar(string _name) constant returns (address) { return m_toRecord[_name].subRegistrar; }
	function content(string _name) constant returns (bytes32) { return m_toRecord[_name].content; }
	function owner(string _name) constant returns (address) { return m_toRecord[_name].owner; }

	mapping (string => Record) m_toRecord;
	int c_fee = 69 ether;
}

