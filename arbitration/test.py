from ethereum import tester as t
from ethereum import utils
import sys

def test():
    # Test the arbiter mechanism
    t.gas_price = 0
    t.gas_limit = 100000000
    s = t.state()
    c = s.abi_contract('arbitration.se')
    o = []
    s.block.log_listeners.append(lambda x: o.append(c._translator.listen(x)))
    x = c.mk_contract(t.a1, t.a2, [t.a3, t.a4, t.a5], 1000, "horse" * 10, value=100000)
    assert c.get_contract_value(x) == 99000
    assert c.get_contract_recipients(x) == [t.a1.encode('hex'), t.a2.encode('hex')]
    assert c.get_contract_arbiters(x) == [utils.encode_hex(a) for a in [t.a3, t.a4, t.a5]]
    assert c.get_contract_arbiterFee(x) == 1000
    assert c.get_contract_description(x) == "horse" * 10
    assert o[-1]["value"] == 99000
    assert o[-1]["arbiters"] == [utils.encode_hex(a) for a in [t.a3, t.a4, t.a5]]
    assert not c.vote(x, True, sender=t.k6)
    assert c.vote(x, False, sender=t.k5)
    assert not c.vote(x, True, sender=t.k5)
    prebals = [s.block.get_balance(y) for y in (t.a1, t.a2, t.a3, t.a4, t.a5, t.a6)]
    assert c.vote(x, False, sender=t.k4)
    assert o[-1]["_event_type"] == "ContractClosed"
    assert o[-1]["recipient"] == utils.encode_hex(t.a2)
    postbals = [s.block.get_balance(x) for x in (t.a1, t.a2, t.a3, t.a4, t.a5, t.a6)]
    diffs = [b - a for a, b in zip(prebals, postbals)]
    assert diffs == [0, 99000, 0, 500, 500, 0]
    # Test voluntary surrender of funds
    x2 = c.mk_contract(t.a1, t.a2, [t.a3, t.a4, t.a5, t.a6, t.a7], 1000, "horse" * 5, value=100000)
    prebals = [s.block.get_balance(y) for y in (t.a1, t.a2, t.a3, t.a4, t.a5, t.a6, t.a7)]
    assert not c.vote(x2, True, sender=t.k1)
    assert c.vote(x2, False, sender=t.k1)
    assert o[-1]["_event_type"] == "ContractClosed"
    assert o[-1]["recipient"] == utils.encode_hex(t.a2)
    postbals = [s.block.get_balance(x) for x in (t.a1, t.a2, t.a3, t.a4, t.a5, t.a6, t.a7)]
    diffs = [b - a for a, b in zip(prebals, postbals)]
    assert diffs == [0, 100000, 0, 0, 0, 0, 0], diffs
    x3 = c.mk_contract(t.a1, t.a2, [t.a3, t.a4, t.a5, t.a6, t.a7], 1000, "horse" * 5, value=100000)
    prebals = [s.block.get_balance(y) for y in (t.a1, t.a2, t.a3, t.a4, t.a5, t.a6, t.a7)]
    assert not c.vote(x3, False, sender=t.k2)
    assert c.vote(x3, True, sender=t.k5)
    assert c.vote(x3, True, sender=t.k2)
    assert o[-1]["_event_type"] == "ContractClosed"
    assert o[-1]["recipient"] == utils.encode_hex(t.a1)
    postbals = [s.block.get_balance(x) for x in (t.a1, t.a2, t.a3, t.a4, t.a5, t.a6, t.a7)]
    diffs = [b - a for a, b in zip(prebals, postbals)]
    assert diffs == [99000, 0, 0, 0, 1000, 0, 0]
    # Test the arbiter registry
    c = s.abi_contract('arbiter_reg.se')
    assert not c.register(sender=t.k1, value=10**14)
    assert c.register(sender=t.k1, value=10**16)
    assert c.register(sender=t.k2, value=10**17)
    assert c.get_addresses(0) == [t.a1.encode('hex'), t.a2.encode('hex')]
    assert c.get_addresses(1) == [t.a2.encode('hex')]
    assert c.get_addresses(50) == []
    assert c.get_tot_fee(t.a1) == 10**16, c.get_tot_fee(t.a1)
    assert c.get_tot_fee(t.a2) == 10**17
    s.mine(100)
    f1 = c.get_tot_fee(t.a1)
    f2 = c.get_tot_fee(t.a2)
    assert f1 < 10**16 and f2 < 10**17
    assert -1 <= f1 - f2 / 10 <= 1 # Accomodate a very small difference
    assert c.register(sender=t.k1, value=10**16)
    assert c.register(sender=t.k2, value=10**15)
    assert c.register(sender=t.k2, value=10**16)
    assert c.register(sender=t.k2, value=10**17 - 10**16 - 10**15)
    new_f1 = c.get_tot_fee(t.a1)
    new_f2 = c.get_tot_fee(t.a2)
    assert new_f1 - f1 == 10**16
    assert new_f2 - f2 == 10**17
    assert not c.set_description("The quick brown fox jumps over t", sender=t.k3)
    assert c.set_description("The quick brown fox jumps over t", sender=t.k1)
    assert c.get_description(t.a1) == "The quick brown fox jumps over t", c.get_description(t.a1)
    assert c.set_description("The quick brown fox jumps over the yellow doge", sender=t.k1)
    assert c.get_description(t.a1) == "The quick brown fox jumps over the yellow doge"

    

if __name__ == '__main__':
    test()
