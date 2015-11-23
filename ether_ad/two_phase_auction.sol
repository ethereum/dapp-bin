contract AuctionResultAcceptor {
    function acceptAuctionResult(address winner, uint256 value, string metadata) { }
}

contract TwoPhaseAuction {
    adStorer target;
    address owner;
    uint256 phase;
    uint256 hashSubmissionEnd;
    uint256 hashRevealEnd;
    uint256 mostRecentAuctionStart;
    uint256 valueSubmissionSubsidyMillis;
    struct Bid {
        bytes32 bidValueHash;
        uint256 bidValue;
        uint256 valueSubmitted;
        string metadata;
        address bidder;
    }
    Bid[999999999999999999999] bids;
    uint256 bestBidIndex;
    uint256 bestBidValue;
    uint256 secondBestBidValue;
    uint256 nextBidIndex;
    uint256 totalValueSubmitted;
    uint256 auctionRevenue;
    // 1 = first price, 2 == second price, 3 == all pay, 4 == all pay + second price
    uint256 auctionType;
    event BidCommitted(uint256 index, bytes32 bidValueHash, string metadata, address indexed bidder);
    event BidRevealed(uint256 index, uint256 bidValue, string metadata, address indexed bidder);
    event AuctionWinner(uint256 index, uint256 bidValue, string metadata, address indexed bidder);
    event AuctionFinalized(uint256 revenue);
    event AuctionInitialized();

    function TwoPhaseAuction() {
        owner = msg.sender;
    }
    
    // Initialize the auction
    function initialize(address _t, uint256 _hsp, uint256 _hrp, uint256 _vssm, uint256 _tp) returns (bool) {
        if (msg.sender != owner) return false;
        if (phase == 1 || phase == 2) return false;
        phase = 1;
        target = adStorer(_t);
        hashSubmissionEnd = block.timestamp + _hsp;
        hashRevealEnd = block.timestamp + _hsp + _hrp;
        valueSubmissionSubsidyMillis = _vssm;
        nextBidIndex = 0;
        bestBidValue = 0;
        secondBestBidValue = 0;
        totalValueSubmitted = 0;
        auctionRevenue = 0;
        auctionType = _tp;
        mostRecentAuctionStart = block.number;
        AuctionInitialized();
        return true;
    }

    // Commit one's bid. This also entails sending an amount of ether at least
    // equal to, but potentially more than, one's bid; if you send a greater
    // amount than the difference between the submission and your actual bid
    // will be refunded to you (even in all-pay auctions). This protects bid
    // privacy.
    function commitBid(bytes32 bidValueHash, string metadata) returns (int256) {
        if (phase != 1) {
            msg.sender.send(msg.value);
            return (-1);
        }
        if (phase == 1 && block.timestamp >= hashSubmissionEnd) {
            msg.sender.send(msg.value);
            return (-1);
        }
        bids[nextBidIndex].bidValueHash = bidValueHash;
        bids[nextBidIndex].valueSubmitted = msg.value;
        bids[nextBidIndex].metadata = metadata;
        bids[nextBidIndex].bidder = msg.sender;
        BidCommitted(nextBidIndex, bidValueHash, metadata, msg.sender);
        nextBidIndex = nextBidIndex + 1;
        totalValueSubmitted += msg.value;
        return int256(nextBidIndex) - 1;
    }
    // Reveal one's bid
    function revealBid(uint256 index, uint256 bidValue, bytes32 nonce) returns (bool) {
        if (phase == 1 && block.timestamp >= hashRevealEnd) {
            phase = 2;
        }
        if (phase != 1) {
            return (false);
        }
        if (phase == 1 && block.timestamp < hashSubmissionEnd) {
            return (false);
        }
        if (index >= nextBidIndex)
            return false;
        if (bidValue > bids[index].valueSubmitted)
            return false;
        if (sha3(bidValue, nonce) != bids[index].bidValueHash)
            return false;
        if (bidValue > bestBidValue) {
            secondBestBidValue = bestBidValue;
            bestBidValue = bidValue;
            bestBidIndex = index;
        }
        else if (bidValue > secondBestBidValue) {
            secondBestBidValue = bidValue;
        }
        // Only need to keep track of bid values for all-pay auctions
        if (auctionType == 3 || auctionType == 4) {
            bids[index].bidValue = bidValue;
            auctionRevenue += bidValue;
        }
        BidRevealed(index, bidValue, bids[index].metadata, bids[index].bidder);
        return true;
    }
    // Clean up during phase 2
    function ping() returns(bool) {
        if (phase == 1 && block.timestamp >= hashRevealEnd)
            phase = 2;
        if (phase != 2) return(false);
        uint _nbi = nextBidIndex;
        uint _ar;
        if (auctionType == 1) _ar = bestBidValue;
        else if (auctionType == 2) _ar = secondBestBidValue;
        else if (auctionType == 3) _ar = auctionRevenue;
        else if (auctionType == 4) _ar = auctionRevenue + secondBestBidValue - bestBidValue;
        while (msg.gas > 500000 && _nbi > 0) {
            _nbi -= 1;
            uint256 subsidy = bids[_nbi].valueSubmitted * _ar * valueSubmissionSubsidyMillis / totalValueSubmitted / 1000; 
            if (_nbi == bestBidIndex) {
                // First price auction or all-pay auction: take winner's bid at its own value
                if (auctionType == 1 || auctionType == 3)
                    bids[_nbi].bidder.send(bids[_nbi].valueSubmitted - bestBidValue + subsidy);
                // Second price auction: take winner's bid at second highest value
                else if (auctionType == 2 || auctionType == 4)
                    bids[_nbi].bidder.send(bids[_nbi].valueSubmitted - secondBestBidValue + subsidy);
            }
            else {
                // First price or second price auction: refund everyone else's bids
                if (auctionType == 1 || auctionType == 2)
                    bids[_nbi].bidder.send(bids[_nbi].valueSubmitted + subsidy);
                // All-pay auction: don't refund everyone else's bids
                else 
                    bids[_nbi].bidder.send(bids[_nbi].valueSubmitted - bids[_nbi].bidValue + subsidy);
                bids[_nbi].bidValueHash = 0;
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
            AuctionFinalized(_ar);
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

    function getHashSubmissionEnd() constant returns (uint256) {
        return hashSubmissionEnd;
    }

    function getHashRevealEnd() constant returns (uint256) {
        return hashRevealEnd;
    }
}
