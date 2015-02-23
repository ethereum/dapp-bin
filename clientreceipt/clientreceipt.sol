import "owned";
contract lockedbox is owned {
  event NomineesChanged(address keyholder, address executive);
  event BoxOpened();
  function nominate(address _keyholder, address _executive) {
	keyholder = _keyholder;
	executive = _executive;
	NomineesChanged(keyholder, executive);
  }
  function open() {
	if (msg.sender == keyholder) {
	  openSince = block.number;
	  BoxOpened();
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

contract killswitch is owned {
  event NomineesChanged(address keyholder, address executive);
  event BoxOpened();
  event BoxClosed();
  function nominate(address _keyholder, address _executive) onlyowner {
	keyholder = _keyholder;
	executive = _executive;
	NomineesChanged(keyholder, executive);
  }
	
  function open() {
	if (msg.sender == owner || msg.sender == keyholder) {
	  isOpen = true;
	  BoxOpened();
	}
  }
  function close() {
	if (msg.sender == owner || msg.sender == keyholder) {
	  isOpen = false;
	  BoxClosed();
	}
  }
  modifier restricted {
	if (msg.sender == owner || (isOpen && msg.sender == executive)) {
	  _
	}
  }
							
  bool isOpen;
  address keyholder;
  address executive;
}

contract ClientReceipt is owned, killswitch {
  event AnonymousDeposit(address indexed _from, uint _value);
  event Deposit(address indexed _from, hash _id, uint _value);
  event Refill(address indexed _from, uint _value);
  event Transfer(address indexed _from, address indexed _to, uint _value);
  
  function() {
	AnonymousDeposit(msg.sender, msg.value);
  }
  function deposit(hash _id) {
	Deposit(msg.sender, _id, msg.value);
  }
  function refill() {
	Refill(msg.sender, msg.value);
  }
  function transfer(address _to, uint _value, bytes _data) restricted {
	Transfer(msg.sender, _to, _value);
	_to.call.value(_value)(_data);
  }
}