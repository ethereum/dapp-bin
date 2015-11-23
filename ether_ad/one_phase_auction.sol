

contract OnePhaseAuction {
    adStorer target;
    address owner;
    uint256 phase;
    uint256 auctionEnd;
    uint256 durationBumpTo;
    uint256 minIncrementMillis;
    uint256 mostRecentAuctionStart;
    struct Bid {
        uint256 bidValue;
        string metadata;
        address bidder;
    }
    Bid[999999999999999999999] bids;
    uint256 bestBidIndex;
    uint256 bestBidValue;
    uint256 secondBestBidValue;
    uint256 nextBidIndex;
    uint256 totalRevenue;
    // Bitmask: +1 if bids cumulative +0 if independent, +2 if all-pay +0 if lead pays
    uint256 auctionType;
    event BidSubmitted(uint256 index, uint256 bidValue, string metadata, address indexed bidder);
    event BidIncreased(uint256 index, uint256 bidValue, uint256 cumValue, string metadata, address indexed bidder);
    event AuctionWinner(uint256 index, uint256 bidValue, string metadata, address indexed bidder);
    event AuctionFinalized(uint256 revenue);
    event AuctionInitialized();

    function OnePhaseAuction() {
        owner = msg.sender;
    }
    
    // Initialize the auction
    function initialize(address _t, uint256 _baseDuration, uint256 _durationBumpTo, uint256 _minIncrementMillis, uint256 _tp) returns (bool) {
        if (msg.sender != owner) return false;
        if (phase == 1 || phase == 2) return false;
        phase = 1;
        target = adStorer(_t);
        auctionEnd = block.timestamp + _baseDuration;
        durationBumpTo = _durationBumpTo;
        minIncrementMillis = _minIncrementMillis;
        nextBidIndex = 0;
        bestBidValue = 0;
        bestBidIndex = 0;
        auctionType = _tp;
        mostRecentAuctionStart = block.number;
        AuctionInitialized();
        return true;
    }

    // Place one's bid
    function bid(string metadata) returns (int256) {
        if (phase != 1) {
            msg.sender.send(msg.value);
            return (-1);
        }
        if (phase == 1 && block.timestamp >= auctionEnd) {
            phase = 2;
            msg.sender.send(msg.value);
            return (-1);
        }
        if (msg.value * 1000 < bestBidValue * (1000 + minIncrementMillis)) {
            msg.sender.send(msg.value);
            return (-1);
        }
        if (msg.value > bestBidValue) {
            bestBidValue = msg.value;
            bestBidIndex = nextBidIndex;
        }
        bids[nextBidIndex].bidValue = msg.value;
        bids[nextBidIndex].metadata = metadata;
        bids[nextBidIndex].bidder = msg.sender;
        BidSubmitted(nextBidIndex, msg.value, metadata, msg.sender);
        nextBidIndex = nextBidIndex + 1;
        if (auctionEnd - block.timestamp < durationBumpTo)
            auctionEnd = block.timestamp + durationBumpTo;
        if ((auctionType & 2) == 2)
            totalRevenue += msg.value;
        return int256(nextBidIndex) - 1;
    }

    // Increase one's bid
    function increaseBid(uint256 index) returns (bool) {
        if ((auctionType & 1) == 0) {
            msg.sender.send(msg.value);
            return (false);
        }
        if (phase != 1) {
            msg.sender.send(msg.value);
            return (false);
        }
        if (phase == 1 && block.timestamp >= auctionEnd) {
            msg.sender.send(msg.value);
            phase = 2;
            return (false);
        }
        if ((bids[index].bidValue + msg.value) * 1000 < bestBidValue * (1000 + minIncrementMillis)) {
            msg.sender.send(msg.value);
            return(false);
        }
        if (index >= nextBidIndex) {
            msg.sender.send(msg.value);
            return false;
        }
        if (bids[index].bidder != msg.sender) {
            msg.sender.send(msg.value);
            return false;
        }
        bids[index].bidValue += msg.value;
        if (bids[index].bidValue > bestBidValue) {
            bestBidValue = bids[index].bidValue;
            bestBidIndex = index;
        }
        if ((auctionType & 2) == 2)
            totalRevenue += msg.value;
        BidIncreased(index, msg.value, bids[index].bidValue, bids[index].metadata, bids[index].bidder);
        if (auctionEnd - block.timestamp < durationBumpTo)
            auctionEnd = block.timestamp + durationBumpTo;
        return(true);
    }

    // Clean up during phase 3
    function ping() returns(bool) {
        if (phase == 1 && block.timestamp >= auctionEnd)
            phase = 2;
        if (phase != 2) return(false);
        uint _nbi = nextBidIndex;
        while (msg.gas > 100000 && _nbi > 0) {
            _nbi -= 1;
            if (_nbi == bestBidIndex) {
            }
            else {
                if ((auctionType & 2) == 0)
                    bids[_nbi].bidder.send(bids[_nbi].bidValue);
                bids[_nbi].bidValue = 0;
            }
        }
        nextBidIndex = _nbi;
        if (_nbi == 0) {
            phase = 0;
            bool success;
            if (bestBidValue > 0) {
                AuctionWinner(bestBidIndex, bestBidValue, bids[bestBidIndex].metadata, bids[bestBidIndex].bidder);
                success = target.acceptAuctionResult(bids[bestBidIndex].bidder, bestBidValue, bids[bestBidIndex].metadata);
            }
            else {
                success = target.acceptAuctionResult(0, 0, "");
            }
            if ((auctionType & 2) == 2)
                AuctionFinalized(totalRevenue);
            else
                AuctionFinalized(bestBidValue);
            owner.send(this.balance);
            if (!success) { while (1 == 1) { _nbi = _nbi; } }
            return(true);
        }
        return(false);
    }

    function setOwner(address newOwner) {
        if (owner == msg.sender) owner = newOwner;
    }

    function withdraw() {
        if (msg.sender == owner) msg.sender.send(this.balance);
    }
    
    function getPhase() constant returns (uint256) {
        return phase;
    }

    function getMostRecentAuctionStart() constant returns (uint256) {
        return mostRecentAuctionStart;
    }

    function getPhaseExpiry() constant returns (uint256) {
        return auctionEnd;
    }
}
