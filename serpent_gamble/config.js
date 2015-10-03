window.accounts = {
    "admin": {
        "address": "0x1db3439a222c519ab44bb1144fc28167b4fa6ee6"
    }, 
    "gamble": {
        "abi": [
            {
                "constant": false, 
                "type": "function", 
                "name": "bet(bytes32,int256)", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "bytes32", 
                        "name": "bettor_key"
                    }, 
                    {
                        "type": "int256", 
                        "name": "prob_milli"
                    }
                ]
            }, 
            {
                "constant": false, 
                "type": "function", 
                "name": "emergency_withdraw()", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": "out"
                    }
                ], 
                "inputs": []
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_administration_status()", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": []
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_available_funds()", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": []
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_bet(int256)", 
                "outputs": [
                    {
                        "type": "int256[]", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "betIndex"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_curseed()", 
                "outputs": [
                    {
                        "type": "bytes32", 
                        "name": "out"
                    }
                ], 
                "inputs": []
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_fee_millis()", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": []
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_num_bets()", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": []
            }, 
            {
                "constant": false, 
                "type": "function", 
                "name": "set_curseed(bytes32,bytes32)", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "bytes32", 
                        "name": "old_value"
                    }, 
                    {
                        "type": "bytes32", 
                        "name": "new_seed"
                    }
                ]
            }, 
            {
                "constant": false, 
                "type": "function", 
                "name": "set_fee_millis(int256)", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "millis"
                    }
                ]
            }, 
            {
                "constant": false, 
                "type": "function", 
                "name": "unlock_for_administration()", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": "out"
                    }
                ], 
                "inputs": []
            }, 
            {
                "constant": false, 
                "type": "function", 
                "name": "withdraw(int256)", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "amount"
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "address", 
                        "name": "bettor"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "value"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "prob_milli"
                    }
                ], 
                "type": "event", 
                "name": "Bet(address,uint256,uint256)"
            }, 
            {
                "inputs": [], 
                "type": "event", 
                "name": "LockForAdministration()"
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
                        "type": "address", 
                        "name": "bettor"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "potentialWinnings"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "prob_milli"
                    }
                ], 
                "type": "event", 
                "name": "Loss(uint256,address,uint256,uint256)"
            }, 
            {
                "inputs": [], 
                "type": "event", 
                "name": "NewSeed()"
            }, 
            {
                "inputs": [], 
                "type": "event", 
                "name": "UnlockForAdministration()"
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
                        "type": "address", 
                        "name": "bettor"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "potentialWinnings"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "prob_milli"
                    }
                ], 
                "type": "event", 
                "name": "Win(uint256,address,uint256,uint256)"
            }
        ], 
        "address": "0xd7993a6976ee91e89bc131e6e143d350ddad9a70"
    }
}