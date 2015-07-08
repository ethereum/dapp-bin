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
	event AuctionEnded(bytes32 indexed _name, address _winner);
	event NewBid(bytes32 indexed _name, address _bidder, uint _value);

	/// Function that is called once an auction ends.
	function onAuctionEnd(bytes32 _name) internal;

	function bid(bytes32 _name, address _bidder, uint _value) internal {
		var auction = m_auctions[_name];
		if (auction.endDate > 0 && now > auction.endDate)
		{
			AuctionEnded(_name, auction.highestBidder);
			onAuctionEnd(_name);
			delete m_auctions[_name];
			return;
		}
		if (msg.value > auction.highestBid)
		{
			// new bid on auction
			auction.secondHighestBid = auction.highestBid;
			auction.sumOfBids += _value;
			auction.highestBid = _value;
			auction.highestBidder = _bidder;
			auction.endDate = now + c_biddingTime;

			NewBid(_name, _bidder, _value);
		}
	}

	uint constant c_biddingTime = 7 days;

	struct Auction {
		address highestBidder;
		uint highestBid;
		uint secondHighestBid;
		uint sumOfBids;
		uint endDate;
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

	function onAuctionEnd(bytes32 _name) internal {
		var auction = m_auctions[_name];
		var record = m_toRecord[_name];
		if (record.owner != 0)
			record.owner.send(auction.sumOfBids - auction.highestBid / 100);
		else
			auction.highestBidder.send(auction.highestBid - auction.secondHighestBid);
		record.owner = auction.highestBidder;
		Changed(_name);
	}

	function reserve(bytes32 _name) external {
		bool needAuction = requiresAuction(_name);
		if (needAuction && now < m_toRecord[_name].renewalDate)
			return;
		if (needAuction)
			bid(_name, msg.sender, msg.value);
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
	mapping (bytes32 => Record) m_toRecord;
}
