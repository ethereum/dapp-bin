# This is an ultra-minimal "dapp framework" that simplifies the deployment
# process by generating a config.js file that specifies the ABI for all of
# the contracts that you need and also includes the ability to update
# addresses. By default, it simply scans through every .se and .sol file in
# the current directory and adds and ABI object for each one into a JS
# object stored under window.accounts, with the key of each ABI object being
# the filename noc including the .se/.sol ending. For example, wallet.sol
# will create window.accounts.wallet = { abi: ... }
#
# You can also use the x=y syntax to set an address. For example, if you
# call python prepare.py admin=0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae,
# then in the JS object you will get window.accounts.admin =
# '0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae'; this persists if you call
# python prepare.py after without setting the argument again as the script
# always tries to read the value set from the previous time the config.js
# file was created.
#
# Example use:
#
# Step 1: serpent compile currency.se
# Step 2: in eth/geth/pyeth, send a transaction to create a contract whose
# code is the output of the previous line
# Step 3: get the contract address of the contract you created. Suppose that
# this address is 0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae
# Step 4: run
# python prepare.py currency=0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae
# Step 5: make sure to include config.js as a javascript file in your
# application.

import sys
import json
import serpent
import os
solidity = None
accounts = {}
# Fill in contract ABI declarations
for f in os.listdir(os.getcwd()):
    if f[-3:] == ".se":
        accounts[f[:-3]] = {"abi": serpent.mk_full_signature(f)}
solidity_files = [f for f in os.listdir(os.getcwd()) if f[-4:] == ".sol"]
if len(solidity_files):
    from ethereum import _solidity
    solidity = _solidity.get_solidity()
    code = '\n'.join([open(f).read() for f in solidity_files])
    contracts = solidity.contract_names(code)
    for c in contracts:
        accounts[c] = {"abi": solidity.mk_full_signature(code, contract_name=c)}
# Fill in previously known addresses
if 'config.js' in os.listdir(os.getcwd()):
    data = open('config.js').read()
    code = json.loads(data[data.find('{'):])
    # For contracts (ie. objects that contain an 'abi' parameter), if
    # we detect a .se or .sol file removed then we do not add the
    # associated address from the registry. For regular accounts, we
    # transfer all of them over
    for k, v in code.items():
        if 'address' in v and (k in accounts or 'abi' not in v):
            if k not in accounts:
                accounts[k] = {}
            accounts[k]["address"] = v['address']
# Fill in addresses from sys.argv
for arg in sys.argv:
    if '=' in arg:
        k, v = arg.split('=')
        if len(v) == 40:
            v = '0x' + v
        if k not in accounts:
            accounts[k] = {}
        accounts[k]["address"] = v
    
open('config.js', 'w').write("window.accounts = " + json.dumps(accounts, indent=4))
