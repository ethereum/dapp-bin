from ethereum import utils
from ethereum import tester as t
import random

def test():
    t.gas_price = 0
    s = t.state()
    c = s.abi_contract('randao.se')
    votes = []
    ids = []
    xor = 0
    for i in range(5):
        r = random.randrange(2**256)
        xor ^= r
        votes.append(utils.zpad(utils.encode_int(r), 32))
    f = c.getFee()
    for i in range(5):
        ids.append(c.submitHash(utils.sha3(votes[i]), value=f))
    while c.getPhase() == 0:
        s.mine(10)
    for i in range(5):
        c.submitValue(ids[i], votes[i])
    while c.getPhase() == 1:
        s.mine(10)
    c.claimResults()
    assert c.getNextResultPos() == 1
    assert c.getResult(0) == utils.zpad(utils.encode_int(xor), 32), (c.getResult(0), utils.zpad(utils.encode_int(xor), 32))

if __name__ == '__main__':
    test()
