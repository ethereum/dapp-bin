import sys

from ethereum import transactions as t
from ethereum.abi import ContractTranslator
from ethereum._solidity import get_solidity
import rlp
solidity = get_solidity()

print 'opa', solidity.mk_full_signature(open('one_phase_auction.sol').read() + open('two_phase_auction.sol').read() + open('adStorer.sol').read(), contract_name='OnePhaseAuction')
print 'tpa', solidity.mk_full_signature(open('one_phase_auction.sol').read() + open('two_phase_auction.sol').read() + open('adStorer.sol').read(), contract_name='TwoPhaseAuction')
print 'ads', solidity.mk_full_signature(open('one_phase_auction.sol').read() + open('two_phase_auction.sol').read() + open('adStorer.sol').read(), contract_name='adStorer')
