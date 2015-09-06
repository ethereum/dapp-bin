contract datafeed {
    mapping ( bytes32 => int256 ) data;
    address owner;
    uint256 fee;

    function datafeed() {
        owner = msg.sender;
    }

    function set(bytes32 k, int256 v) {
        if (owner == msg.sender)
            data[k] = v;
    }

    function setFee(uint256 f) {
        if (owner == msg.sender)
            fee = f;
    }

    function get(bytes32 k) returns (int256 v) {
        if (msg.value >= fee)
            v = data[k];
        else
            v = 0;
    }

    function getFee() returns (uint256 f) {
        f = fee;
    }
}

