//sol Gavsino
// Simple casino proto-DAO.
// @authors:
//   Gav Wood <g@ethdev.com>

#require service, named, owned
contract Gavsino is service(2), named("Gavsino"), owned {
	struct Order {
		uint amount;
		uint pIn256;
		uint number;
	} 

	// Create a Gavmble contract.
	function Gavsino() {
		if (msg.value > 0)
			m_totalShares = msg.value / 1000000000000000;
		else
			m_totalShares = 1;
		m_shares[msg.sender] = m_totalShares;
	}

	// TODO: allow giving a dead hash.
	// Provide a chance of `pIn256` in 256 (approx `floor(pIn256/256.0*100)`%) that one later claim from
	// `msg.caller` which provides the inverse Keccak hash of `key` will result in a transfer of
	// `web3.toEth(floor(floor(msg.value * 99 / 100) * 256 / pIn256))` back to them.
	function bet(uint pIn256, hash key) {
		m_owing += msg.value;
		m_orders[key].amount = msg.value;
		m_orders[key].pIn256 = pIn256;
		m_orders[key].number = block.number;
		log1(0, key);
	}

	// Send `web3.toEth(winningsWithKey(sha3(bet), bet))` to `msg.sender` if and only if they are
	// `orders[sha3(bet)].owner`.
	function claim(hash bet) {
		hash key = sha3(bet);
		if (m_orders[key].amount > 0) {
			uint refund = (m_orders[key].amount * 1 / 200);
			uint w = winningsWithKey(key, bet) + refund;
			msg.sender.send(w);
			m_owing -= m_orders[key].amount;
			delete m_orders[key];
			log1(0, key);
		}
	}
	
	function recycle(hash key) {
		if (m_orders[key].amount > 0 && block.number >= m_orders[key].number + 256) {
			// out of date: sender gets the deposit.
			msg.sender.send(m_orders[key].amount * 1 / 200);	// 0.5% refund for cleanup
			m_owing -= m_orders[key].amount;
			delete m_orders[key];
		}			
	}

	function winningsWithKey(hash key, hash bet) constant returns(uint r) {	// payout is on 99% of original value. house keeps 0.5%, 0.5% refunded in claim.
		if (block.number <= m_orders[key].number + 255 &&
			uint(sha3(hash(block.blockhash(m_orders[key].number))) ^ bet) & 0xff < m_orders[key].pIn256)
		    r = (m_orders[key].amount * 99 / 100) * 256 / m_orders[key].pIn256;
	}

	function winnings(hash bet) constant returns(uint r) {
		return winningsWithKey(sha3(bet), bet);
	}

	function empty() {
		owner.send(address(this).balance);
	}
	
	function buyIn() {
		uint s = sharesValue(msg.value);
		m_shares[msg.sender] += s;
		m_totalShares += s;
		log0(s);
	}
	
	function cashOut(uint shares) {
		if (shares <= m_shares[msg.sender]) {
			uint v = valueOf(shares);
			msg.sender.send(v);
			m_totalShares -= shares;
			m_shares[msg.sender] -= shares;
			log0(v);
		}
	}
	
	function sharesHeld() constant returns(uint r) {
		return m_shares[msg.sender];
	}
	
	function equity() constant returns (uint r) {
		return this.balance - msg.value - m_owing;
	}
	
	function valueOfShares() constant returns(uint r) {
		r = equity() * m_shares[msg.sender] / m_totalShares;
	}
	
	function valueOf(uint s) constant returns(uint r) {
		r = equity() * s / m_totalShares;
	}
	
	function sharesValue(uint v) constant returns(uint shares) {
		shares = v * m_totalShares / equity();
	}
	
	function totalShares() constant returns(uint r) {
		r = m_totalShares;
	}

	mapping(hash => Order) m_orders;
	uint m_owing;
	
	mapping(address => uint) m_shares;
	uint m_totalShares;
}

/*

// Solidity Interface:
contract Gavsino{function totalShares()constant returns(uint256 r){}function sharesValue(uint256 wei)constant returns(uint256 shares){}function buyIn(){}function cashOut(uint256 shares){}function winningsWithKey(hash256 key,hash256 bet)constant returns(uint256 r){}function sharesHeld()constant returns(uint256 r){}function valueOfShares()constant returns(uint256 r){}function winnings(hash256 bet)constant returns(uint256 r){}function claim(hash256 bet){}function bet(uint8 pIn256,hash256 key){}function empty(){}}

// Example Solidity use:
hash myBet = getRandomHash();
Gavsino(addrGavsino).bet(128, sha3(myBet));
// wait for block
Gavsino(addrGavsino).claim(myBet);

// JS Interface:
var abiGavsino = [{"constant":true,"inputs":[],"name":"totalShares","outputs":[{"name":"r","type":"uint256"}]},{"constant":true,"inputs":[{"name":"wei","type":"uint256"}],"name":"sharesValue","outputs":[{"name":"shares","type":"uint256"}]},{"constant":false,"inputs":[],"name":"buyIn","outputs":[]},{"constant":false,"inputs":[{"name":"shares","type":"uint256"}],"name":"cashOut","outputs":[]},{"constant":true,"inputs":[{"name":"key","type":"hash256"},{"name":"bet","type":"hash256"}],"name":"winningsWithKey","outputs":[{"name":"r","type":"uint256"}]},{"constant":true,"inputs":[],"name":"sharesHeld","outputs":[{"name":"r","type":"uint256"}]},{"constant":true,"inputs":[],"name":"valueOfShares","outputs":[{"name":"r","type":"uint256"}]},{"constant":true,"inputs":[{"name":"bet","type":"hash256"}],"name":"winnings","outputs":[{"name":"r","type":"uint256"}]},{"constant":false,"inputs":[{"name":"bet","type":"hash256"}],"name":"claim","outputs":[]},{"constant":false,"inputs":[{"name":"pIn256","type":"uint8"},{"name":"key","type":"hash256"}],"name":"bet","outputs":[]},{"constant":false,"inputs":[],"name":"empty","outputs":[]}];

// Example JS use:

*/

