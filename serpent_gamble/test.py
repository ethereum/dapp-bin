from ethereum import tester as t
from ethereum import utils
import os

def test():
    t.gas_price = 0
    s = t.state()
    c = s.abi_contract('gamble.se')
    rseed = os.urandom(32)
    seed1 = utils.sha3(rseed)
    c.set_curseed(seed1)
    s.block.set_balance(c.address, 27000)
    totbal = sum([s.block.get_balance(x) for x in t.accounts])
    assert c.get_fee_millis() == 0
    # 90 bets succeed (bet with 25% winning probability)
    for i in range(90):
        assert c.bet(utils.zpad(str(i), 32), 250, sender=t.keys[i % 10], value=100) >= 0
    # 10 bets fail due to not enough collateral
    for i in range(90, 100):
        assert c.bet(utils.zpad(str(i), 32), 250, sender=t.keys[i % 10], value=100) == -2
    # Add more collateral
    s.block.delta_balance(c.address, 3000)
    # 10 bets succeed
    for i in range(90, 100):
        assert c.bet(utils.zpad(str(i), 32), 250, sender=t.keys[i % 10], value=100) >= 0
    # 10 bets fail due to limit of 100
    for i in range(100, 110):
        assert c.bet(utils.zpad(str(i), 32), 250, sender=t.keys[i % 10], value=100) == -1
    mid_totbal = sum([s.block.get_balance(x) for x in t.accounts])
    assert c.get_administration_status() == -1
    c.unlock_for_administration()
    assert c.get_administration_status() == 5
    s.block.coinbase = '\x35' * 20
    s.mine(5, coinbase='\x35' * 20)
    s.block.set_balance('\x35' * 20, 0)
    assert c.get_administration_status() == 0
    assert c.set_curseed(rseed, os.urandom(32))
    assert c.get_administration_status() == -1
    # Check that a reasonable number of bets succeeded
    new_totbal = sum([s.block.get_balance(x) for x in t.accounts])
    print 'Profit: ', totbal - new_totbal
    assert -4000 < (new_totbal - totbal) < 7000
    assert 26000 < s.block.get_balance(c.address) < 37000
    assert not c.withdraw(20000)
    c.unlock_for_administration()
    s.mine(5)
    assert c.withdraw(20000)
    assert not c.withdraw(20000)

if __name__ == '__main__':
    test()
