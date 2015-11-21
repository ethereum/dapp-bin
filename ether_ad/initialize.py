import sys

from ethereum import transactions as t
from ethereum.abi import ContractTranslator
from ethereum._solidity import get_solidity
import rlp
solidity = get_solidity()
key = '7942db5f27595d040231a44b95de331d45eaa78cfa3f21663c95d4bbc97afbe4'
addr = 'ce7fb4c38949d7c09bd95197c3981ec8bb0638e5'

args, kwargs = [], {}

i = 0
while i < len(sys.argv):
    if sys.argv[i][:2] == '--':
        kwargs[sys.argv[i][2:]] = sys.argv[i+1]
        i += 2
    else:
        args.append(sys.argv[i])
        i += 1

adStorer_abi = solidity.mk_full_signature(open('one_phase_auction.sol').read() + open('two_phase_auction.sol').read() + open('adStorer.sol').read(), contract_name='adStorer')
ct = ContractTranslator(adStorer_abi)
nonce = int(kwargs['nonce'])
data = ct.encode('initialize', [240, 240, 240, 120, 50, 10])
o = '['
for i in range(8):
    tx = t.Transaction(nonce, 60 * 10**9, 2500000, kwargs['address'], 0, data)
    o += '"0x' + rlp.encode(tx.sign(key)).encode('hex') + '",'
    nonce += 1

print o[:-1] + ']'
