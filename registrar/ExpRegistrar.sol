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
}

contract ExpRegistrar is Registrar {
	struct Record {
		address addr;
		address subRegistrar;
		bytes32 content;
		address owner;
		uint price;
	}

	modifier onlyrecordowner(string _name) { if (m_record[_name].owner == msg.sender) _ }

	function reserve(string _name) {
	    Record rec = m_record[_name];
		if ((rec.owner == 0 && msg.value >= 1 ether) || msg.value >= rec.price) {
			if (rec.price > 0)
				rec.owner.send(rec.price);
			else
				rec.price = msg.value;
			rec.price *= 2;
			rec.owner = msg.sender;
			Changed(_name);
		}
	}
	function transfer(string _name, address _newOwner) onlyrecordowner(_name) {
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

	mapping (string => Record) m_record;
}





var ExpRegistrar = web3.eth.contract([{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_a","type":"address"}],"name":"setAddr","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"string"}],"name":"addr","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"string"}],"name":"subRegistrar","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"}],"name":"reserve","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_registrar","type":"address"}],"name":"setSubRegistrar","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"string"}],"name":"content","outputs":[{"name":"","type":"bytes32"}],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"string"}],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"string"}],"name":"record","outputs":[{"name":"o_addr","type":"address"},{"name":"o_subRegistrar","type":"address"},{"name":"o_content","type":"bytes32"},{"name":"o_owner","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_newOwner","type":"address"}],"name":"transfer","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_content","type":"bytes32"}],"name":"setContent","outputs":[],"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"name","type":"string"}],"name":"Changed","type":"event"}]);
contract ExpRegistrar{function setAddr(string _name,address _a);function addr(string _name)constant returns(address );function subRegistrar(string _name)constant returns(address );function reserve(string _name);function setSubRegistrar(string _name,address _registrar);function content(string _name)constant returns(bytes32 );function owner(string _name)constant returns(address );function record(string _name)constant returns(address o_addr,address o_subRegistrar,bytes32 o_content,address o_owner);function transfer(string _name,address _newOwner);function setContent(string _name,bytes32 _content);}
213b9eb8… :setAddr
511b1df9… :addr
7f445c24… :subRegistrar
ae999ece… :reserve
ccf4f413… :setSubRegistrar
dd54a62f… :content
df55b41a… :owner
e51ace16… :record
fbf58b3e… :transfer
fd6f5430… :setContent
