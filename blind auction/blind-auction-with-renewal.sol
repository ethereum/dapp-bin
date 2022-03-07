//Sample contract
contract hashRegistry
{
    address public auction;
    address public election;
    address public executive;
    
    modifier onlyElection() {
        if (msg.sender != election) throw;
        _
    }   
    
    modifier onlyAuction() {
        if (msg.sender != auction) throw;
        _
    }
    
    function changeExecutive(address newExecutive) {
        executive = newExecutive;
    }
    
    struct Record {
        address owner;
        uint renewalDate;
        mapping (string => string) metadata;
    }
    
    mapping  (bytes32 => Record) public hashRegistry;
    
    function newRegistry(bytes32 hash, address owner, uint renewalDate) onlyAuction {
        hashRegistry[hash] = Record({owner: owner, renewalDate:renewalDate});
    }
    
}

//Sample contract
contract BlindAuction {
    // Structures and registries
    struct Record {
        address owner;
        uint renewalDate;
        uint previousPeriod;
    }
    
    struct Auction {
        uint deadline;
        uint priceOffered;
        uint priceToBePaid;
        uint bidPaid;
        address currentWinner;
        address currentTopBidder;
        uint period;
        uint firstRegistered;
        address previousOwner;
    }
    
    struct SealedBid {
        uint date;
        uint deposit;
        address bidder;
    }
    
    struct Bid {
        bytes32 hashedName;
        uint price;
        uint period;
        address owner;
        bytes32 salt;
    }
    
    mapping  (bytes32 => Record) public registry;
    mapping  (bytes32 => Auction) public auctions;
    mapping  (bytes32 => SealedBid) public sealedBids;
    
    // configurable parameters (REPLACE ALL MINUTES FOR DAYS)
    uint public refundForInvalidBids = 1;
    uint public refundForUnrevealedBids = 1000;
    uint public refundForLosingBids = 10;
    uint public refundForExtraBid = 1;
    uint public earlyRenewalFee = 10000 * 365 minutes;   
    uint public lateRenewalFee = (3 * earlyRenewalFee) / 2;
    uint public newAuctionLength = 7 minutes;
    uint public revealPeriod = 2 minutes;
    uint public renewalPeriod = 180 minutes;
    uint public minAmountOfTimeToRegister = 10 minutes + revealPeriod + renewalPeriod;
    uint public maxAmountOfTimeToRegister = 730 minutes;

    // public information
    uint public unspendabbleFunds;
    
    modifier noDeposits() {
        msg.sender.send(msg.value);     // give back any money sent automatically
        _
    }

    // New Auctions are created using one array, as this allows
    // someone to register a few fake auctions with the real ones
    // to obsfuscate the ones they actually want
    function newAuctions(bytes32[] newAuctions) noDeposits {
        for (uint i = 0; i < newAuctions.length; i++) {
            bytes32 newAuction = newAuctions[i];
            if(registry[newAuction].owner != 0) throw;  // Check if the name is taken, 
            Auction a = auctions[newAuction];           // and then check if there isn't an auction
            if (a.deadline == 0) {                        // if hasn't been registered yet
                a.deadline = now + newAuctionLength;       // then set the date to one week in the future
                a.firstRegistered = now;
            }
        }
    }
    
    // Sealed bids only register their hash, value and bid date
    function newBid(bytes32 sealedBid) {
        sealedBids[sealedBid] = SealedBid({date: now, deposit: msg.value, bidder: msg.sender});
    }
    
    function createBidSignature(bytes32 hashedName, uint price, uint period, address proposedOwner, bytes32 salt) constant returns (bytes32 signature) {
        return sha3(hashedName, price, period, proposedOwner, salt);
    }

    function revealBid(bytes32 hashedName, uint price, uint period, address proposedOwner, bytes32 salt) noDeposits {
        bytes32 sealed = sha3(hashedName, price, period, proposedOwner, salt);  // Create the bid signature
        SealedBid bid = sealedBids[sealed];                             // Loads from the sealed bids
        if (bid.date == 0) throw;                                       // and checks if it exists.
        
        
        uint refund = 0;
        Auction auction = auctions[hashedName];                         // load information about the auction
        if (bid.date > auction.deadline                                  // Check if bid was sent before deadline
            || (proposedOwner != auction.previousOwner && price + (price * period)/earlyRenewalFee > bid.deposit ) 
            || (proposedOwner == auction.previousOwner && (price * period)/earlyRenewalFee > bid.deposit ) 
            || period * 1 minutes < minAmountOfTimeToRegister                       // Check if above the minimum period of days
            || period * 1 minutes > maxAmountOfTimeToRegister                       // And below the maximum
         ) {                                                            // Bid is overall invalid
            refund = refundForInvalidBids;
        } else if (now > auction.deadline - revealPeriod - renewalPeriod) {             // Bid wasn't revealed in time
            refund = refundForUnrevealedBids;
                        
        } else if (price < auction.priceToBePaid) {                     // Bid is valid, but not high enough
            refund = refundForLosingBids;
        } else if (price > auction.priceToBePaid && price < auction.priceOffered ) {
            // Bid is valid, but only high enough to push the price
            refund = refundForLosingBids;
            auction.priceToBePaid = price;
        } else if (price > auction.priceOffered) {
            // Bid is the current top winner
            refund = 0;
            // refund the last top bidder
            auction.currentTopBidder.send(auction.bidPaid / refundForLosingBids);
            unspendabbleFunds += auction.bidPaid - auction.bidPaid / refund;   

            // save the information of the current winner
            auction.priceToBePaid = auction.priceOffered;
            auction.priceOffered = price;
            auction.currentWinner = proposedOwner;
            auction.currentTopBidder = bid.bidder;
            auction.bidPaid = bid.deposit;
            auction.period = period;
        }    else {
            refund = 100;
        }   
        
        if (refund > 0) {
            bid.bidder.send(bid.deposit/refund);                     // refund the bidder partially
            unspendabbleFunds += bid.deposit - bid.deposit / refund;  
        }   
        
         sealedBids[sealed] = SealedBid({date: 0, deposit: 0, bidder: 0});
    }
    
    function lateRenewal(bytes32 hashedName, uint period) {
        Auction auction = auctions[hashedName];
        
        if ( now < auction.deadline - renewalPeriod 
             || now > auction.deadline 
             || auction.currentWinner == registry[hashedName].owner 
             || msg.value < auction.priceOffered * period / lateRenewalFee
             || period < minAmountOfTimeToRegister                       
             || period > maxAmountOfTimeToRegister                       
             || period > (now - auction.firstRegistered) * 2  
           ) throw;               
        
        
        uint costWithFee = auction.priceOffered * period / lateRenewalFee; // calculate the fee
        msg.sender.send(msg.value - costWithFee);                        // refund any extra paid
        unspendabbleFunds += costWithFee - auction.priceOffered;
        
        //uint price = (msg.value * lateRenewalFee) / period;
        uint price =  auction.priceOffered * period / earlyRenewalFee;
        
        
        uint priceWithFee =  auction.priceOffered * period / lateRenewalFee;
        
        auction.priceToBePaid = auction.priceOffered;
        auction.priceOffered = auction.priceOffered;
        auction.currentWinner = registry[hashedName].owner;
        auction.currentTopBidder = msg.sender;
        auction.bidPaid = msg.value;
        auction.period = period;
        
        uint pricePaid = auction.priceToBePaid + (auction.priceToBePaid * period)/earlyRenewalFee;
        unspendabbleFunds += pricePaid;
        auction.currentTopBidder.send((auction.bidPaid - pricePaid)/refundForExtraBid);

    }
    
    function finalizeAuction(bytes32 hashedName) noDeposits {
        Auction auction = auctions[hashedName];                         // load information about the auction
        if (now < auction.deadline) throw;               // Is the auction ready to be executed?
        
        //Record record[hashedName]
        uint pricePaid;
        // Refund the bidder
        if (auction.currentWinner == registry[hashedName].owner ) {
            pricePaid = (auction.priceToBePaid * auction.period)/earlyRenewalFee;       
        } else {
            pricePaid = auction.priceToBePaid + (auction.priceToBePaid * auction.period)/earlyRenewalFee;       
        }
        unspendabbleFunds += pricePaid;
        auction.currentTopBidder.send((auction.bidPaid - pricePaid)/refundForExtraBid);

        // Change the Current Records
        registry[hashedName] = Record({
            owner: auction.currentWinner,
            renewalDate: now + auction.period * 1 minutes,
            previousPeriod: auction.period
        });
        
        // Change the next auction
        auctions[hashedName] = Auction({
            deadline: now + auction.period * 1 minutes, 
            priceOffered: 0, 
            priceToBePaid: 0,
            bidPaid: 0,
            currentWinner: 0,
            currentTopBidder: 0,
            period: 0,
            firstRegistered: auction.firstRegistered,
            previousOwner: auction.currentWinner
        }); 
    }
    
    function () {
        throw;
    }

}

