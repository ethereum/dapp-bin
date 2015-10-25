window.accounts = {
    "adStorer": {
        "abi": [
            {
                "inputs": [
                    {
                        "type": "uint256", 
                        "name": "id"
                    }
                ], 
                "constant": true, 
                "type": "function", 
                "name": "getWinnerUrl", 
                "outputs": [
                    {
                        "type": "string", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "uint256", 
                        "name": "_hsp"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_hrp"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_bdur"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_dbt"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_mim"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_vssm"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "initialize", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "uint256", 
                        "name": "id"
                    }
                ], 
                "constant": true, 
                "type": "function", 
                "name": "getWinnerAddress", 
                "outputs": [
                    {
                        "type": "address", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "address", 
                        "name": "winner"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "value"
                    }, 
                    {
                        "type": "string", 
                        "name": "metadata"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "acceptAuctionResult", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "uint256", 
                        "name": "id"
                    }
                ], 
                "constant": true, 
                "type": "function", 
                "name": "getAuctionAddress", 
                "outputs": [
                    {
                        "type": "address", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "g"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "i"
                    }
                ], 
                "type": "event", 
                "name": "GasRemaining", 
                "anonymous": false
            }
        ], 
        "address": "0xaf0334bf30c401b7e3afafbac1dbcdc712be8b9e"
    }, 
    "TwoPhaseAuction": {
        "abi": [
            {
                "inputs": [], 
                "constant": true, 
                "type": "function", 
                "name": "getHashSubmissionEnd", 
                "outputs": [
                    {
                        "type": "uint256", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [], 
                "constant": true, 
                "type": "function", 
                "name": "getHashRevealEnd", 
                "outputs": [
                    {
                        "type": "uint256", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "address", 
                        "name": "newOwner"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "setOwner", 
                "outputs": []
            }, 
            {
                "inputs": [], 
                "constant": false, 
                "type": "function", 
                "name": "withdraw", 
                "outputs": []
            }, 
            {
                "inputs": [
                    {
                        "type": "uint256", 
                        "name": "index"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "bidValue"
                    }, 
                    {
                        "type": "bytes32", 
                        "name": "nonce"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "revealBid", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [], 
                "constant": false, 
                "type": "function", 
                "name": "ping", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "bytes32", 
                        "name": "bidValueHash"
                    }, 
                    {
                        "type": "string", 
                        "name": "metadata"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "commitBid", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [], 
                "constant": true, 
                "type": "function", 
                "name": "getPhase", 
                "outputs": [
                    {
                        "type": "uint256", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [], 
                "constant": true, 
                "type": "function", 
                "name": "getMostRecentAuctionStart", 
                "outputs": [
                    {
                        "type": "uint256", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "address", 
                        "name": "_t"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_hsp"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_hrp"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_vssm"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_tp"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "initialize", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [], 
                "type": "constructor"
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "index"
                    }, 
                    {
                        "indexed": false, 
                        "type": "bytes32", 
                        "name": "bidValueHash"
                    }, 
                    {
                        "indexed": false, 
                        "type": "string", 
                        "name": "metadata"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "bidder"
                    }
                ], 
                "type": "event", 
                "name": "BidCommitted", 
                "anonymous": false
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "index"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "bidValue"
                    }, 
                    {
                        "indexed": false, 
                        "type": "string", 
                        "name": "metadata"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "bidder"
                    }
                ], 
                "type": "event", 
                "name": "BidRevealed", 
                "anonymous": false
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "index"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "bidValue"
                    }, 
                    {
                        "indexed": false, 
                        "type": "string", 
                        "name": "metadata"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "bidder"
                    }
                ], 
                "type": "event", 
                "name": "AuctionWinner", 
                "anonymous": false
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "revenue"
                    }
                ], 
                "type": "event", 
                "name": "AuctionFinalized", 
                "anonymous": false
            }, 
            {
                "inputs": [], 
                "type": "event", 
                "name": "AuctionInitialized", 
                "anonymous": false
            }
        ]
    }, 
    "AuctionResultAcceptor": {
        "abi": [
            {
                "inputs": [
                    {
                        "type": "address", 
                        "name": "winner"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "value"
                    }, 
                    {
                        "type": "string", 
                        "name": "metadata"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "acceptAuctionResult", 
                "outputs": []
            }
        ]
    }, 
    "OnePhaseAuction": {
        "abi": [
            {
                "inputs": [
                    {
                        "type": "uint256", 
                        "name": "index"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "increaseBid", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "address", 
                        "name": "newOwner"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "setOwner", 
                "outputs": []
            }, 
            {
                "inputs": [], 
                "constant": false, 
                "type": "function", 
                "name": "withdraw", 
                "outputs": []
            }, 
            {
                "inputs": [], 
                "constant": false, 
                "type": "function", 
                "name": "ping", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [], 
                "constant": true, 
                "type": "function", 
                "name": "getPhaseExpiry", 
                "outputs": [
                    {
                        "type": "uint256", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "string", 
                        "name": "metadata"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "bid", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [], 
                "constant": true, 
                "type": "function", 
                "name": "getPhase", 
                "outputs": [
                    {
                        "type": "uint256", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [], 
                "constant": true, 
                "type": "function", 
                "name": "getMostRecentAuctionStart", 
                "outputs": [
                    {
                        "type": "uint256", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "type": "address", 
                        "name": "_t"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_baseDuration"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_durationBumpTo"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_minIncrementMillis"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "_tp"
                    }
                ], 
                "constant": false, 
                "type": "function", 
                "name": "initialize", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": ""
                    }
                ]
            }, 
            {
                "inputs": [], 
                "type": "constructor"
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "index"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "bidValue"
                    }, 
                    {
                        "indexed": false, 
                        "type": "string", 
                        "name": "metadata"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "bidder"
                    }
                ], 
                "type": "event", 
                "name": "BidSubmitted", 
                "anonymous": false
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "index"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "bidValue"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "cumValue"
                    }, 
                    {
                        "indexed": false, 
                        "type": "string", 
                        "name": "metadata"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "bidder"
                    }
                ], 
                "type": "event", 
                "name": "BidIncreased", 
                "anonymous": false
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "index"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "bidValue"
                    }, 
                    {
                        "indexed": false, 
                        "type": "string", 
                        "name": "metadata"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "bidder"
                    }
                ], 
                "type": "event", 
                "name": "AuctionWinner", 
                "anonymous": false
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "revenue"
                    }
                ], 
                "type": "event", 
                "name": "AuctionFinalized", 
                "anonymous": false
            }, 
            {
                "inputs": [], 
                "type": "event", 
                "name": "AuctionInitialized", 
                "anonymous": false
            }
        ]
    }
}