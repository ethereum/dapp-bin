

contract adStorer {
    string[8] urls;
    address[8] winners;
    address owner;
    address[8] auctions;
    uint256 hashSubmissionPeriod;
    uint256 hashRevealPeriod;
    uint256 baseDuration;
    uint256 durationBumpTo;
    uint256 minIncrementMillis;
    uint256 initializedTo;
    uint256 valueSubmissionSubsidyMillis;
    event GasRemaining(uint256 g, uint256 i);

    // Recommend: 86400 86400 86400 3600 50 10 live
    // Recommend: 240 240 240 120 50 10 test
    function initialize(uint256 _hsp, uint256 _hrp, uint256 _bdur, uint256 _dbt, uint256 _mim, uint256 _vssm) returns (bool) {
        if (initializedTo < 8) {
            if (owner == 0) owner = msg.sender;
            hashSubmissionPeriod = _hsp;
            hashRevealPeriod = _hrp;
            baseDuration = _bdur;
            durationBumpTo = _dbt;
            minIncrementMillis = _mim;
            valueSubmissionSubsidyMillis = _vssm;
            for (uint256 i = initializedTo; i < 8 && msg.gas > 1100000; i++) {
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
            if (initializedTo == 8) return true;
            else return false;
        }
        return true;
    }

    function isInitialized() returns (bool) { return initializedTo == 8; }

    function acceptAuctionResult(address winner, uint256 value, string metadata) returns (bool) {
        for (uint256 i = 0; i < 8; i++) {
            if (msg.sender == auctions[i]) {
                if (winner != 0) {
                    urls[i] = metadata;
                    winners[i] = winner;
                }
                if (i < 4) OnePhaseAuction(msg.sender).initialize(this, baseDuration, durationBumpTo, minIncrementMillis, i);
                else TwoPhaseAuction(msg.sender).initialize(this, hashSubmissionPeriod, hashRevealPeriod, valueSubmissionSubsidyMillis, i - 3);
                owner.send(this.balance);
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
