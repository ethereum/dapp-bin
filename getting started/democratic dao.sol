contract token { mapping (address => uint) public balances;   function token() { }   function sendToken(address receiver, uint amount) returns(bool sufficient) {  } }

contract Democracy {
    
    uint public minimumQuorum = 10;
    uint public debatingPeriod = 7 days;
    token voterShare;
    uint public numProposals = 0;
    address public founder;
    
    mapping (uint => Proposal) public proposals;
        
    struct Proposal {
        address recipient;
        uint amount;
        bytes32 data;
        bytes32 descriptionHash;
        uint creationDate;
        uint numVotes;
        uint quorum;
        bool active;
        mapping (uint => Vote) votes;
        mapping (address => bool) voted;
    }
    
    struct Vote {
        int position;
        address voter;
    }
    
    function Democracy() {
        founder = msg.sender;   
    }
    
    function setup(address _voterShareAddress){
        if (msg.sender == founder && numProposals == 0) {
            voterShare = token(_voterShareAddress);
        }       
    }
    
    function newProposal(address _recipient, uint _amount, bytes32 _data, bytes32 _descriptionHash) returns (uint proposalID) {
        if (voterShare.balances(msg.sender)>0) {
            proposalID = numProposals++;
            Proposal p = proposals[proposalID];
            p.recipient = _recipient;
            p.amount = _amount;
            p.data = _data;
            p.descriptionHash = _descriptionHash;
            p.creationDate = now;
            p.numVotes = 0; 
            p.active = true;
        } else {
            return 0;
        }
    }
    
    function vote(uint _proposalID, int _position) returns (uint voteID){
        if (voterShare.balances(msg.sender)>0 && (_position >= -1 || _position <= 1 )) {
            Proposal p = proposals[_proposalID];
            if (!p.voted[msg.sender]) {
                voteID = p.numVotes++;
                Vote v = p.votes[voteID];
                v.position = _position;
                v.voter = msg.sender;   
                p.voted[msg.sender] = true;
            }
        } else {
            return 0;
        }
    }
    
    function executeProposal(uint _proposalID) returns (uint result) {
        Proposal p = proposals[_proposalID];
        /* Check if debating period is over */
        if (now > p.creationDate + debatingPeriod && p.active){     
            uint yea = 0;
            uint nay = 0;
            /* tally the votes */
            for (uint i = 0; i <=  p.numVotes; i++) {
                Vote v = p.votes[i];
                uint voteWeight = voterShare.balances(v.voter); 
                p.quorum += voteWeight;

                if (v.position > 0) {
                    yea += voteWeight;
                } if (v.position < 0) {
                    nay += voteWeight;
                }
            }
            /* execute result */
            if (p.quorum > minimumQuorum && yea > nay ) {
                p.recipient.call.value(p.amount)(p.data);
                p.active = false;
            } else if (p.quorum > minimumQuorum && nay > yea) {
                p.active = false;
            }
            return yea - nay;
        }
    }
}