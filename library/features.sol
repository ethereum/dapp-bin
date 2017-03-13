contract owned {
    function owned() {
        owner = msg.sender;
    }
    modifier onlyowner() { 
        if (msg.sender == owner)
            _;
    }
    address owner;
}

contract mortal is owned {
    function kill() {
        if (msg.sender == owner) suicide(owner);
    }
}

