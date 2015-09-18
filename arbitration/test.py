from ethereum import tester as t
from ethereum import utils
import sys

def test():
    t.gas_price = 0
    t.gas_limit = 100000000
    s = t.state()
    c = s.abi_contract('arbitration.se')
    o = []
    s.block.log_listeners.append(lambda x: o.append(c._translator.listen(x)))
    x = c.mk_contract(t.a1, t.a2, [t.a3, t.a4, t.a5], 1000, value=100000)
    assert o[-1]["value"] == 99000
    assert o[-1]["arbiters"] == [utils.encode_hex(a) for a in [t.a3, t.a4, t.a5]]
    assert not c.vote(x, True, sender=t.k6)
    assert c.vote(x, False, sender=t.k5)
    assert not c.vote(x, True, sender=t.k5)
    prebals = [s.block.get_balance(y) for y in (t.a1, t.a2, t.a3, t.a4, t.a5, t.a6)]
    assert c.vote(x, False, sender=t.k4)
    assert o[-1]["_event_type"] == "PaidOut"
    assert o[-1]["recipient"] == utils.encode_hex(t.a2), (o[-1]["recipient"], utils.encode_hex(t.a1), utils.encode_hex(t.a2))
    postbals = [s.block.get_balance(x) for x in (t.a1, t.a2, t.a3, t.a4, t.a5, t.a6)]
    diffs = [b - a for a, b in zip(prebals, postbals)]
    assert diffs == [0, 99000, 0, 500, 500, 0]

if __name__ == '__main__':
    test()
