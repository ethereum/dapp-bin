window.accounts = {
    "main": {
        "abi": [
            {
                "constant": false, 
                "type": "function", 
                "name": "addBreak()", 
                "outputs": [], 
                "inputs": []
            }, 
            {
                "constant": false, 
                "type": "function", 
                "name": "addLog(bytes)", 
                "outputs": [], 
                "inputs": [
                    {
                        "type": "bytes", 
                        "name": "v"
                    }
                ]
            }, 
            {
                "constant": true, 
                "type": "function", 
                "name": "getLatestBreak()", 
                "outputs": [
                    {
                        "type": "int256", 
                        "name": "out"
                    }
                ], 
                "inputs": []
            }, 
            {
                "inputs": [
                    {
                        "indexed": false, 
                        "type": "string", 
                        "name": "value"
                    }
                ], 
                "type": "event", 
                "name": "Log(string)"
            }
        ], 
        "address": "0x8e96a2c65e9fa8ef3a620afb6737bc870adefeec"
    }
}