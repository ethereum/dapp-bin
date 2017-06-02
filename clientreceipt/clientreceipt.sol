pragma solidity ^0.4.10;
import "owned";
contract killswitch is owned {
          /* State variables */
  bool isOpen;
  address keyholder;
  address executive;
        /* Modifiers */
  modifier restricted {
  require(msg.sender == owner || (isOpen && msg.sender == executive));
  _;
  }
        /* Events */
  event NomineesChanged(address keyholder, address executive);
  event BoxOpened();
  event BoxClosed();
        /* Methods */
  function nominate(address _keyholder, address _executive) onlyowner {
  keyholder = _keyholder;
  executive = _executive;
  NomineesChanged(keyholder, executive);
  }
  function open() {
    require(msg.sender == owner || msg.sender == keyholder) {
      isOpen = true;
      BoxOpened();
    }
  }
  function close() {
    require(msg.sender == owner || msg.sender == keyholder) {
      isOpen = false;
      BoxClosed();
    }
  }

}

contract ClientReceipt is owned, killswitch {
        /* Events */
  event AnonymousDeposit(address indexed _from, uint _value);
  event Deposit(address indexed _from, bytes32 _id, uint _value);
  event Refill(address indexed _from, uint _value);
  event Withdraw(address indexed _from, address indexed _to, uint _value);
  event Drain(address indexed _from, address indexed _to, uint _value);
        /* fallback function */
  function() payable {
    AnonymousDeposit(msg.sender, msg.value);
  }
        /* Methods */
  function deposit(bytes32 _id) {
    Deposit(msg.sender, _id, msg.value);
  }
  function refill() {
    Refill(msg.sender, msg.value);
  }
  function withdraw(address _to, uint _value) restricted {
    _to.send(_value);
    Withdraw(msg.sender, _to, _value);
  }
  function drain(address _to, uint _value) restricted {
    _to.send(_value);
    Drain(msg.sender, _to, _value);
  }
}
