//sol

contract NameRegister {
	function addr(string _name) constant returns (address o_owner);
	function name(address _owner) constant returns (string o_name);
}

contract Registrar is NameRegister {
	event Changed(string indexed name);
	event ReverseChanged(address indexed addr, string indexed name);

	function owner(string _name) constant returns (address o_owner);
	function addr(string _name) constant returns (address o_address);
	function subRegistrar(string _name) constant returns (address o_subRegistrar);
	function content(string _name) constant returns (bytes32 o_content);
	
	function name(address _owner) constant returns (string o_name);
}

contract AuctionSystem {
	event AuctionEnded(string indexed _name, address _winner);
	event NewBid(string indexed _name, address _bidder, uint _value);

	/// Function that is called once an auction ends.
	function onAuctionEnd(string _name) internal;

	function bid(string _name, address _bidder, uint _value) internal {
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
	mapping(string => Auction) m_auctions;
}

contract GlobalRegistrar is Registrar, AuctionSystem {
	struct Record {
		address owner;
		address primary;
		address subRegistrar;
		bytes32 content;
		uint renewalDate;
	}

	uint constant c_renewalInterval = 1 years;
	uint constant c_freeBytes = 12;

	function Registrar() {
		// TODO: Populate with hall-of-fame.
	}

	function() {
		// prevent people from just sending funds to the registrar
		throw;
	}

	function onAuctionEnd(string _name) internal {
		var auction = m_auctions[_name];
		var record = m_toRecord[_name];
		if (record.owner != 0)
			record.owner.send(auction.sumOfBids - auction.highestBid / 100);
		else
			auction.highestBidder.send(auction.highestBid - auction.secondHighestBid);
		record.renewalDate = now + c_renewalInterval;
		record.owner = auction.highestBidder;
		Changed(_name);
	}

	function reserve(string _name) external {
		if (bytes(_name).length == 0)
			throw;
		bool needAuction = requiresAuction(_name);
		if (needAuction)
		{
			if (now < m_toRecord[_name].renewalDate)
				throw;
			bid(_name, msg.sender, msg.value);
		}
		else
		{
			Record record = m_toRecord[_name];
			if (record.owner != 0)
				throw;
			m_toRecord[_name].owner = msg.sender;
			Changed(_name);
		}
	}

	function requiresAuction(string _name) internal returns (bool) {
		return bytes(_name).length < c_freeBytes;
	}

	modifier onlyrecordowner(string _name) { if (m_toRecord[_name].owner == msg.sender) _ }

	function setOwner(string _name, address _newOwner) onlyrecordowner(_name) {
		m_toRecord[_name].owner = _newOwner;
		Changed(_name);
	}

	function disown(string _name) onlyrecordowner(_name) {
		if (stringsEqual(m_toName[m_toRecord[_name].primary], _name))
		{
			ReverseChanged(m_toRecord[_name].primary, "");
			m_toName[m_toRecord[_name].primary] = "";
		}
		delete m_toRecord[_name];
		Changed(_name);
	}

	function setName(string _name) {
		if (m_toRecord[_name].primary == msg.sender)
		{
			ReverseChanged(msg.sender, _name);
			m_toName[msg.sender] = _name;
		}
	}
	function setAddress(string _name, address _a) onlyrecordowner(_name) {
		m_toRecord[_name].primary = _a;
		Changed(_name);
	}
	function setSubRegistrar(string _name, address _registrar) onlyrecordowner(_name) {
		m_toRecord[_name].subRegistrar = _registrar;
		Changed(_name);
	}
	function setContent(string _name, bytes32 _content) onlyrecordowner(_name) {
		m_toRecord[_name].content = _content;
		Changed(_name);
	}

	function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
		bytes storage a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}

	function owner(string _name) constant returns (address) { return m_toRecord[_name].owner; }
	function addr(string _name) constant returns (address) { return m_toRecord[_name].primary; }
	function subRegistrar(string _name) constant returns (address) { return m_toRecord[_name].subRegistrar; }
	function content(string _name) constant returns (bytes32) { return m_toRecord[_name].content; }
	function name(address _addr) constant returns (string o_name) { return m_toName[_addr]; }

	mapping (address => string) m_toName;
	mapping (string => Record) m_toRecord;
}
