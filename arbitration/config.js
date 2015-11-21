window.accounts = {
    "arbitration": {
        "abi": [
            {
                "constant": true, 
                "type": "function", 
                "name": "get_contract_arbiterFee(int256)", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "id"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_contract_arbiters(int256)", 
                "outputs": [
                    {
                        "type": "address[]", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "id"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_contract_description(int256)", 
                "outputs": [
                    {
                        "type": "bytes", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "id"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_contract_recipients(int256)", 
                "outputs": [
                    {
                        "type": "address[]", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "id"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_contract_value(int256)", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "id"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_number_of_contracts()", 
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
                "name": "mk_contract(address,address,address[],uint256,bytes)", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "address", 
                        "name": "recipientA"
                    }, 
                    {
                        "type": "address", 
                        "name": "recipientB"
                    }, 
                    {
                        "type": "address[]", 
                        "name": "arbiters"
                    }, 
                    {
                        "type": "uint256", 
                        "name": "arbiterFee"
                    }, 
                    {
                        "type": "bytes", 
                        "name": "description"
                    }
                ]
            }, 
            {
                "constant": false, 
                "type": "function", 
                "name": "vote(int256,bool)", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "id"
                    }, 
                    {
                        "type": "bool", 
                        "name": "voteForA"
                    }
                ]
            }, 
            {
                "inputs": [
                    {
                        "indexed": true, 
                        "type": "uint256", 
                        "name": "id"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "arbiter"
                    }
                ], 
                "type": "event", 
                "name": "ArbiterNotification(uint256,address)"
            }, 
            {
                "inputs": [
                    {
                        "indexed": true, 
                        "type": "uint256", 
                        "name": "id"
                    }, 
                    {
                        "indexed": false, 
                        "type": "address", 
                        "name": "recipient"
                    }
                ], 
                "type": "event", 
                "name": "ContractClosed(uint256,address)"
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "value"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "recipientA"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "recipientB"
                    }, 
                    {
                        "indexed": false, 
                        "type": "address[]", 
                        "name": "arbiters"
                    }, 
                    {
                        "indexed": false, 
                        "type": "uint256", 
                        "name": "arbiterFee"
                    }, 
                    {
                        "indexed": true, 
                        "type": "uint256", 
                        "name": "id"
                    }, 
                    {
                        "indexed": false, 
                        "type": "bytes", 
                        "name": "description"
                    }
                ], 
                "type": "event", 
                "name": "NewContract(uint256,address,address,address[],uint256,uint256,bytes)"
            }, 
            {
                "inputs": [
                    {
                        "indexed": true, 
                        "type": "uint256", 
                        "name": "id"
                    }, 
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "addr"
                    }, 
                    {
                        "indexed": false, 
                        "type": "bool", 
                        "name": "votingForA"
                    }
                ], 
                "type": "event", 
                "name": "Vote(uint256,address,bool)"
            }
        ], 
        "address": "0x7e2d0fe0ffdd78c264f8d40d19acb7d04390c6e8"
    }, 
    "arbiter_reg": {
        "abi": [
            {
                "constant": true, 
                "type": "function", 
                "name": "exp_decay(int256,int256)", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "val"
                    }, 
                    {
                        "type": "int256", 
                        "name": "i"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_addresses(int256)", 
                "outputs": [
                    {
                        "type": "address[]", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "int256", 
                        "name": "startIndex"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_description(address)", 
                "outputs": [
                    {
                        "type": "bytes", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "address", 
                        "name": "account"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "get_tot_fee(address)", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "address", 
                        "name": "account"
                    }
                ]
            }, 
            {
                "constant": false, 
                "type": "function", 
                "name": "register()", 
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
                "name": "set_description(bytes)", 
                "outputs": [
                    {
                        "type": "bool", 
                        "name": "out"
                    }
                ], 
                "inputs": [
                    {
                        "type": "bytes", 
                        "name": "description"
                    }
                ]
            }, 
            {
                "constant": false, 
                "type": "function", 
                "name": "withdraw()", 
                "outputs": [], 
                "inputs": []
            }, 
            {
                "inputs": [
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "addr"
                    }, 
                    {
                        "indexed": false, 
                        "type": "int256", 
                        "name": "amount"
                    }, 
                    {
                        "indexed": false, 
                        "type": "int256", 
                        "name": "newTotal"
                    }
                ], 
                "type": "event", 
                "name": "FeePaid(address,int256,int256)"
            }, 
            {
                "inputs": [
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "addr"
                    }, 
                    {
                        "indexed": false, 
                        "type": "bytes", 
                        "name": "description"
                    }
                ], 
                "type": "event", 
                "name": "NewDescription(address,bytes)"
            }, 
            {
                "inputs": [
                    {
                        "indexed": true, 
                        "type": "address", 
                        "name": "addr"
                    }, 
                    {
                        "indexed": false, 
                        "type": "int256", 
                        "name": "amount"
                    }
                ], 
                "type": "event", 
                "name": "NewRegistry(address,int256)"
            }
        ], 
        "address": "0x82afa2c4a686af9344e929f9821f3e8c6e9293ab"
    }
}