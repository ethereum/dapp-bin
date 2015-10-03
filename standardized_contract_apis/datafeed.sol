contract datafeed {
    mapping ( bytes32 => int256 ) data;
    address owner;

    function datafeed() {
        owner = msg.sender;
    }

    function set(bytes32 k, int256 v) {
        if (owner == msg.sender)
            data[k] = v;
    }

    function get(bytes32 k) returns (int256 v) {
        v = data[k];
    }
}

