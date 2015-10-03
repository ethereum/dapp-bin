from ethereum import utils
from ethereum import tester as t
try:
    from ecdsa_recover import ecdsa_raw_sign, ecdsa_raw_recover
except ImportError:
    from bitcoin import ecdsa_raw_sign, ecdsa_raw_recover

def make_ticket(privkey, value):
    value_enc = utils.zpad(utils.encode_int(value), 32)
    h = utils.sha3(value_enc)
    v, r, s = ecdsa_raw_sign(h, privkey)
    return (value, v, r, s)

def test():
    t.gas_price = 0
    s = t.state()
    c = s.abi_contract('channel.se')
    a0_prebal = s.block.get_balance(t.a0)
    a1_prebal = s.block.get_balance(t.a1)
    cid = c.create_channel(t.a0, t.a1, 10**18, 3600, value=10**18)
    make_ticket(t.k0, 2)
    make_ticket(t.k0, 202)
    _value, _v, _r, _s = make_ticket(t.k0, 702)
    c.close_channel(cid, _value, _v, _r, _s, sender=t.k1)
    assert s.block.get_balance(t.a0) == a0_prebal - 702
    assert s.block.get_balance(t.a1) == a1_prebal + 702

if __name__ == '__main__':
    test()
