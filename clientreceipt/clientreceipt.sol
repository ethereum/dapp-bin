#require owned
contract lockedbox is owned {
  function nominate(address _keyholder, address _executive) {
	keyholder = _keyholder;
	executive = _executive;
  }
  function open() {
	if (msg.sender == keyholder) {
	  openSince = block.number;
	}
  }
  modifier restricted {
	// open for 256 blocks.
	if (openSince + 256 < block.number) {
	  openSince = 0;
	}
	if (msg.sender == owner || (msg.sender == executive && openSince > 0)) {
	  _
	  openSince = 0;
	}
  }
							
  uint openSince;
  address keyholder;
  address executive;
}

contract ClientReceipt is owned, lockedbox {
  event Deposit(address indexed _from, hash _id, uint _value);
  event Refill(address indexed _from, uint _value);
  event Drain(address indexed _from, address indexed _to, uint _value);
  
  function() {
	Deposit(msg.sender, 0, msg.value)
  }
  function deposit(hash _id) {
	Deposit(msg.sender, _id, msg.value)
  }
  function refill() {
	Refill(msg.sender, msg.value)
  }
  function drain(address _to, uint _value, byte[] _data) restricted {
	Drain(msg.sender, _to, _value);
	_to.send(_value, _data);
  }
}

