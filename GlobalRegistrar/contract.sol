//sol

contract NameRegister {
	function addr(bytes32 _name) constant returns (address o_owner);
	function name(address _owner) constant returns (bytes32 o_name);
}

contract Registrar is NameRegister {
	event Changed(bytes32 indexed name);
	event PrimaryChanged(bytes32 indexed name, address indexed addr);

	function owner(bytes32 _name) constant returns (address o_owner);
	function addr(bytes32 _name) constant returns (address o_address);
	function subRegistrar(bytes32 _name) constant returns (address o_subRegistrar);
	function content(bytes32 _name) constant returns (bytes32 o_content);
	
	function name(address _owner) constant returns (bytes32 o_name);
}

contract AuctionSystem {
	struct Auction {
		address highestBidder;
		uint highestBid;
		uint secondHighestBid;
		uint sumOfBids;
		uint endDate;
	}
	uint constant c_biddingTime = 7 days;

	function auctionWinner(bytes32 _name, address currentOwner) internal returns (address) {
		var auction = m_auctions[_name];
		if (auction.endDate == 0)
		{
			// start auction
		}
		else if (now > auction.endDate)
		{
			// auction ended
			if (currentOwner != 0)
				currentOwner.send(auction.sumOfBids - auction.highestBid / 100);
			else
				auction.highestBidder.send(auction.highestBid - auction.secondHighestBid);
			address winner = auction.highestBidder;
			delete m_auctions[_name];
			return winner;
		}
		// new bid on auction
		if (msg.value > auction.highestBid)
		{
			auction.secondHighestBid = auction.highestBid;
			auction.sumOfBids += msg.value;
			auction.highestBid = msg.value;
			auction.highestBidder = msg.sender;
			auction.endDate = now + c_biddingTime;
		}
		return 0;
	}

	mapping (bytes32 => Auction) m_auctions;
}

contract GlobalRegistrar is Registrar, AuctionSystem {
	struct Record {
		address owner;
		address primary;
		address subRegistrar;
		bytes32 content;
		uint value;
		uint renewalDate;
	}

	uint constant c_renewalInterval = 1 years;
	uint constant c_freeBytes = 12;

	function Registrar() {
		// TODO: Populate with hall-of-fame.
	}

	function reserve(bytes32 _name) external {
		bool needAuction = requiresAuction(_name);
		if (needAuction && now < m_toRecord[_name].renewalDate)
			return;
		if (needAuction)
		{
			address winner = auctionWinner(_name, m_toRecord[_name].owner);
			if (winner == 0)
				return;
			m_toRecord[_name].owner = winner;
			Changed(_name);
		}
		else if (m_toRecord[_name].owner == 0)
		{
			m_toRecord[_name].owner = msg.sender;
			Changed(_name);
		}
	}

	function requiresAuction(bytes32 _name) internal returns (bool) {
		uint shift = 2**(32 - c_freeBytes);
		return (uint(_name) / shift) * shift == uint(_name);
	}

	modifier onlyrecordowner(bytes32 _name) { if (m_toRecord[_name].owner == msg.sender) _ }

	function transfer(bytes32 _name, address _newOwner) onlyrecordowner(_name) {
		m_toRecord[_name].owner = _newOwner;
		Changed(_name);
	}

	function disown(bytes32 _name) onlyrecordowner(_name) {
		if (m_toName[m_toRecord[_name].primary] == _name)
		{
			PrimaryChanged(_name, m_toRecord[_name].primary);
			m_toName[m_toRecord[_name].primary] = "";
		}
		delete m_toRecord[_name];
		Changed(_name);
	}

	function setAddress(bytes32 _name, address _a, bool _primary) onlyrecordowner(_name) {
		m_toRecord[_name].primary = _a;
		if (_primary)
		{
			PrimaryChanged(_name, _a);
			m_toName[_a] = _name;
		}
		Changed(_name);
	}
	function setSubRegistrar(bytes32 _name, address _registrar) onlyrecordowner(_name) {
		m_toRecord[_name].subRegistrar = _registrar;
		Changed(_name);
	}
	function setContent(bytes32 _name, bytes32 _content) onlyrecordowner(_name) {
		m_toRecord[_name].content = _content;
		Changed(_name);
	}

	function owner(bytes32 _name) constant returns (address) { return m_toRecord[_name].owner; }
	function addr(bytes32 _name) constant returns (address) { return m_toRecord[_name].primary; }
	function subRegistrar(bytes32 _name) constant returns (address) { return m_toRecord[_name].subRegistrar; }
	function content(bytes32 _name) constant returns (bytes32) { return m_toRecord[_name].content; }
	function name(address _owner) constant returns (bytes32 o_name) { return m_toName[_owner]; }

	mapping (address => bytes32) m_toName;
	mapping (bytes32 => Record)  m_toRecord;
}

