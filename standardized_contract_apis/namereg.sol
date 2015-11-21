contract namereg {
    struct RegistryEntry {
        address owner;
        address addr;
        bytes32 content;
        address sub;
    }

    mapping ( string => RegistryEntry ) records;

    event Changed(string name, bytes32 indexed __hash_name);

    function reserve(string _name) returns (bool _success) {
        if (records[_name].owner == 0) {
            records[_name].owner = msg.sender;
            Changed(_name, sha3(_name));
            _success = true;
        }
        else _success = false;
    }

    function owner(string _name) returns (address _r) {
        _r = records[_name].owner;
    }

    function transfer(string _name, address _newOwner) {
        if (records[_name].owner == msg.sender) {
            records[_name].owner = _newOwner;
            Changed(_name, sha3(_name));
        }
    }

    function setAddr(string _name, address _addr) {
        if (records[_name].owner == msg.sender) {
            records[_name].addr = _addr;
            Changed(_name, sha3(_name));
        }
    }

    function addr(string _name) returns (address _r) {
        _r = records[_name].addr;
    }

    function setContent(string _name, bytes32 _content) {
        if (records[_name].owner == msg.sender) {
            records[_name].content = _content;
            Changed(_name, sha3(_name));
        }
    }

    function content(string _name) returns (bytes32 _r) {
        _r = records[_name].content;
    }

    function setSubRegistrar(string _name, address _subRegistrar) {
        if (records[_name].owner == msg.sender) {
            records[_name].sub = _subRegistrar;
            Changed(_name, sha3(_name));
        }
    }

    function subRegistrar(string _name) returns (address _r) {
        _r = records[_name].sub;
    }

    function disown(string _name) {
        if (records[_name].owner == msg.sender) {
            records[_name].owner = 0;
            Changed(_name, sha3(_name));
        }
    }
}

