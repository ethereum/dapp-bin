// inheritable "property" contract that enables methods to be protected by requiring the acquiescence of either a
// single, or, crucially, each of a number of, designated owners.
// usage:
// use modifiers onlyowner (just own owned) or onlymanyowners(hash), whereby the same hash must be provided by
// some number (specified in constructor) of the set of owners (specified in the constructor, modifiable) before the
// interior is executed.
contract multiowned {
	// struct for the status of a pending operation.
	struct PendingState {
		uint yetNeeded;
		uint ownersDone;
	}

	// this contract only has two types of events: it can accept a confirmation, in which case
	// we record owner and operation (hash) alongside it.
	event Confirmation(address owner, hash operation);
	// the other is in the case of an owner changing. here we record the old and new owners.
	event OwnerChanged(address oldOwner, address newOwner);

	// constructor is given number of sigs required to do protected "onlyowners" transactions
	// as well as the selection of addresses capable of confirming them. 
	function multiowned(uint _required, address[] _owners) {
		m_required = _required;
		m_owners = _owners;
	}
	
	// simple single-sig function modifier.
	modifier onlyowner {
		if (m_owners.find(msg.sender) != notfound)
			_
	}

	// multi-sig function modifier: the operation must have an intrinsic hash in order
	// that later attempts can be realised as the same underlying operation and
	// thus count as confirmations.
	modifier onlymanyowners(hash _operation) {
		if (confirm(_operation))
			_
	}
	
	function confirm(hash _operation) protected returns (bool _r) {
		// determine what index the present sender is:
		uint ownerIndex = m_owners.find(msg.sender);
		
		// make sure they're an owner
		if (ownerIndex != notfound) {
			// if we're not yet working on this operation, switch over and reset the confirmation status.
			if (!m_pending[_operation].yetNeeded) {
				// reset count of confirmations needed.
				m_pending[_operation].yetNeeded = _sigs.size();
				// reset which owners have confirmed (none) - set our bitmap to 0.
				m_pending[_operation].ownersDone = 0;
			}
			// determine the bit to set for this owner.
			uint ownerIndexBit = 1 << ownerIndex;
			
			// make sure we (the message sender) haven't confirmed this operation previously.
			assert(m_pending[_operation].yetNeeded > 0);
			if (!(m_pending[_operation].ownersDone & ownerIndexBit)) {
				Confirmation(msg.sender, _operation);
				// ok - check if count is enough to go ahead.
				if (m_pending[_operation].yetNeeded == 1) {
					// enough confirmations: reset and run interior.
					delete m_pending[_operation];
					_r = true;
				}
				else
				{
					// not enough: record that this owner in particular confirmed.
					m_pending[_operation].yetNeeded--;
					m_pending[_operation].ownersDone |= ownerIndexBit;
				}
			}
		}
	}
	
	// replaces an owner `_from` with another `_to`.
	function changeOwner(address _from, address _to) external multiowned(sha3(msg.sig, _from, _to)) {
		uint ownerIndex = m_owners.find(_from);
		if (ownerIndex != notfound)
		{
			m_owners[ownerIndex] = _to;
			OwnerChanged(_from, _to);
		}
	}
	
	// the number of owners that must confirm the same operation before it is run.
	uint constant m_required;

	//stateset owners {
	set address[] m_owners;	
	// set meaning you can do a fast look up into it to get the index.
	// suggested impl as combination of count-prefixed contiguous series and normal mapping for the reverse lookup:
	// sha3(BASE + 0) => N,
	// sha3(BASE + 1) => address[0],
	// ...
	// sha3(BASE + N) => address[N-1],
	// sha3(BASE ++ address[0]) => 0,
	// ...
	// sha3(BASE ++ address[N-1]) -> N-1
	//
	// provides:
	// size: m_owners.size()
	// dereference: m_owners[0], ..., m_owners[m_owners.size() - 1]
	// alteration: m_owners[2] = newValue; (original m_owners[2] is removed)
	// find: m_owners.find(m_owners[0]) == 0, ..., m_owners.find(m_owners[m_owners.size() - 1]) == m_owners.size() - 1,  m_owners.find(...) == (uint)-1 == notfound
	// append: m_owners.insert(n): m_owners[m_owners.size() - 1] == n, m_owners.lookup(n) == m_owners.size() - 1
	// delete: delete m_owners[n]
	// clear: m_owners.clear(): m_owners.size() == 0
	//}

	/*	
	// for now could just be:
	uint m_ownersCount;
	mapping (uint => address) m_owners;
	mapping (address => uint) m_ownersFind;
	*/
	
	// the ongoing operations.
	mapping { hash => PendingState } m_pending;
}

// inheritable "property" contract that enables methods to be protected by placing a linear limit (specifiable)
// on a particular resource per calendar day. is multiowned to allow the limit to be altered. resource that method
// uses is specified in the modifier.
contract daylimit is multiowned {
	// constructor - just records the present day's index.
	function daylimit() {
		m_lastDay = today();
	}

	// (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
	function setDailyLimit(uint _newLimit) external onlyowners(sha3(msg.sig, _newLimit)) {
		m_dailyLimit = _newLimit;
	}
	
	// (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.
	function resetSpentToday() external onlyowners(sha3(msg.sig)) {
		m_dailyLimit = _newLimit;
	}
	
	// checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and
	// returns true. otherwise just returns false.
	function underLimit(uint _value) protected onlyowner {
		// reset the spend limit if we're on a different day to last time.
		if (today() > m_lastDay) {
			m_spentToday = 0;
			m_lastDay = today();
		}
		// check to see if there's enough left - if so, subtract and return true.
		if (m_spentToday + _value <= m_dailyLimit) {
			m_spendToday += _value;
			return true;
		}
		return false;
	}
	
	// simple modifier for daily limit.
	modifier limitedDaily(uint _value) {
		if (underLimit(_value))
			_
	}

	// determines today's index.
	function today() private constant returns (uint r) { r = block.timestamp / (60 * 60 * 24); }
	
	uint m_spentToday;
	uint m_dailyLimit;
	uint m_lastDay;
}

// interface contract for multisig proxy contracts.
contract multisig {
	function changeOwner(address _from, address _to);
	function transact(address _to, uint _value) returns (hash _r);
	function confirm(hash _h);
}

// usage:
// hash h = Wallet(w).from(oneOwner).transact(to, value, data);
// Wallet(w).from(anotherOwner).confirm(h);
contract Wallet is multisig multiowned daylimit {
	// Transaction structure to remember details of transaction lest it need be saved for a later call.
	structure Transaction {
		address to;
		uint value;
		byte[] data;
	}
	
	// logged events:
	// Funds has arrived into the wallet (record how much).
	event CashIn(uint value);
	// Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).
	event SingleTransact(indexed string32 = "out", address owner, uint value, address to);
	// Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).
	event MultiTransact(indexed string32 = "out", address owner, hash operation, uint value, address to);
	
	// constructor - just pass on the owner arra to the multiowned.
	function Wallet(address[] _owners) multiowned(2, _owners) {}
	
	// kills the contract sending everything to `_to`.
	function kill(address _to) external onlyowners(sha3("kill", _to)) {
		this.suicide(_to);
	}
	
	// gets called when no other function matches
	function() {
		// just being sent some cash?
		if (msg.value) {
			CashIn(msg.value);
		}
	}

	// Outside-visible transact entry point. Executes transacion immediately if below daily spend limit.
	// If not, goes into multisig process. We provide a hash on return to allow the sender to provide
	// shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
	// and _data arguments). They still get the option of using them if they want, anyways.
	function transact(address _to, uint _value, bytes[] _data) external returns (hash _r) {
		// first, take the opportunity to check that we're under the daily limit.
		if (underLimit(_value)) {
			log SingleTransact(_value, _to);
			// yes - just execute the call.
			_to.call(_value, _data);
			return 0;
		}
		
		// determine our operation hash.
		_r = sha3("transact", _to, _value, _data);
		if (!confirm(_r) && m_txs[_r].to == 0) {
			m_txs[_r].to = _to;
			m_txs[_r].value = _value;
			m_txs[_r].data = _data;
		}
	}
	
	// confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order
	// to determine the body of the transaction from the hash provided.
	function confirm(hash _h) external onlyowners(_h) {
		if (m_txs[_h].to != 0) {
			m_txs[_h].to.call(m_txs[_h].value, m_txs[_h].data);
			MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to);
			delete m_txs[_h];
		}
	}
	
	// internally confirm transaction with all of the info. returns true iff confirmed good and executed.
	function confirm(hash _h, address _to, uint _value, bytes[] _data) private onlyowners(_h) returns (bool _r) {
		_to.call(_value, _data);
		MultiTransact(msg.sender, _h, _value, _to);
		_r = true;
	}

	// pending transactions we have at present.
	mapping (hash => Transaction) m_txs;
}
