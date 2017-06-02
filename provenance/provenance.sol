// provenance concept contract created by M.ElBoudi, A.Blackwell, M.Terzi et al during Ethereum development workshop in London

contract Certifiers {
        mapping (address => bool) certifier;
        address provenance;
        
        //initialiser is run the first time the contract is uploaded to the network. Launched by Provenance and reads provenance "public key"
        function Certifiers () {
            provenance = msg.sender;    
        }
        
        function createNewCertifier() returns (bool completed) {
                certifier[msg.sender] = false;
                return true;
        }
        
        //if Provenance is launching the contract, then the entity becomes certified
        function certify(address targetCertifier) returns (bool completed) {
            if (provenance == msg.sender) {
                certifier[targetCertifier] = true;
                return true;
            } else {
                return false;    
            }
        }
}

contract Producers{
    struct meta{
        bytes32 description;
        uint phoneNumber;
        bytes32 name;
        bool certified;
        }
        mapping (address => meta) producer;
        
        function createProducer(bytes32 desc, uint phone, bytes32 name) returns (bool created) {
            producer[msg.sender].description = desc;
            producer[msg.sender].phoneNumber = phone;
            producer[msg.sender].name = name;
            producer[msg.sender].certified = false;
            return true;
        }
}

contract producerList{
    
        mapping (address => bytes32) producerList;
    
        function addProducer(bytes32 desc, uint phone, byte name) returns (bool completed) {
                var producers = new Producers();
                return producers.createProducer(desc, phone, name);
                
        }
}
