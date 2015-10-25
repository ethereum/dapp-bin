import sys
import json
import serpent
import os
solidity = None
# Fill in contract ABI declarations
solidity_files = [f for f in os.listdir(os.getcwd()) if f[-4:] == ".sol"]
if len(solidity_files):
    from ethereum import _solidity
    solidity = _solidity.get_solidity()
    code = '\n'.join([open(f).read() for f in solidity_files])
    contracts = solidity.contract_names(code)
    for c in contracts:
        print c, solidity.compile(code, contract_name=c).encode('hex')
