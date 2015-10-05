

contract adStorer {
    string[7] urls;
    address[7] winners;
    address owner;
    address[7] auctions;
    uint256 hashSubmissionPeriod;
    uint256 hashRevealPeriod;
    uint256 baseDuration;
    uint256 durationBumpTo;
    uint256 minIncrementMillis;
    uint256 initializedTo;
    uint256 valueSubmissionSubsidyMillis;
    event GasRemaining(uint256 g, uint256 i);

    function initialize() returns (bool) {
        if (initializedTo < 7) {
            if (owner == 0) owner = msg.sender;
            hashSubmissionPeriod = 86400;
            hashRevealPeriod = 86400;
            baseDuration = 86400;
            durationBumpTo = 3600;
            minIncrementMillis = 50;
            valueSubmissionSubsidyMillis = 10;
            for (uint256 i = initializedTo; i < 7 && msg.gas > 1100000; i++) {
                GasRemaining(msg.gas, i);
                if (i < 4) {
                    auctions[i] = new OnePhaseAuction();
                    OnePhaseAuction(auctions[i]).initialize(this, baseDuration, durationBumpTo, minIncrementMillis, i);
                }
                else {
                    auctions[i] = new TwoPhaseAuction();
                    TwoPhaseAuction(auctions[i]).initialize(this, hashSubmissionPeriod, hashRevealPeriod, valueSubmissionSubsidyMillis, i - 3);
                }
            }
            initializedTo = i;
            if (initializedTo == 7) return true;
            else return false;
        }
    }

    function acceptAuctionResult(address winner, uint256 value, string metadata) returns (bool) {
        for (uint256 i = 0; i < 7; i++) {
            if (msg.sender == auctions[i]) {
                if (winner != 0) {
                    urls[i] = metadata;
                    winners[i] = winner;
                }
                if (i < 4) OnePhaseAuction(msg.sender).initialize(this, baseDuration, durationBumpTo, minIncrementMillis, i);
                else TwoPhaseAuction(msg.sender).initialize(this, hashSubmissionPeriod, hashRevealPeriod, valueSubmissionSubsidyMillis, i - 3);
                return true;
            }
        }
        return false;
    }

    function getAuctionAddress(uint256 id) constant returns (address) {
        return auctions[id];
    }

    function getWinnerUrl(uint256 id) constant returns (string) {
        return urls[id];
    }

    function getWinnerAddress(uint256 id) constant returns (address) {
        return winners[id];
    }
}
