from ethereum import tester as t
from ethereum import utils

def test():
    s = t.state()
    test_company = s.abi_contract('company.se', ADMIN_ACCOUNT=utils.decode_int(t.a0))
    order_book = s.abi_contract('orders.se')
    test_currency = s.abi_contract('currency.se', sender=t.k0)
    assert test_company.getAdmin() == t.a0.encode('hex')
    # Issue 1000 shares to user a1
    test_company.issueShares(1000, t.a1, sender=t.k0)
    # Issue 50000 coins to users a2 and a3
    test_currency.sendCoin(50000, t.a2, sender=t.k0)
    test_currency.sendCoin(50000, t.a3, sender=t.k0)
    # User a1 can have as many shares as he wants, but must retain at
    # least 800
    test_company.setShareholderMaxShares(t.a1, 2**100, sender=t.k0)
    test_company.setShareholderMinShares(t.a1, 800, sender=t.k0)
    # User a2 can have up to 500 shares
    test_company.setShareholderMaxShares(t.a2, 500, sender=t.k0)
    # User a2 tries to give himself the right to unlimited shares,
    # fails because he is not the admin
    test_company.setShareholderMaxShares(t.a2, 2**100, sender=t.k2)
    # A few sanity checks
    assert test_company.getCurrentShareholdingsOf(t.a1) == 1000
    assert test_company.getShareholderMinShares(t.a1) == 800
    assert test_company.getShareholderMaxShares(t.a2) == 500
    # User a1 transfers 150 shares to a2
    assert test_company.sendCoin(150, t.a2, sender=t.k1) is True
    # User a1 tries to transfer 150 shares to a2 again, fails because
    # such a transaction would result a1 having 700 shares, which is
    # below his limit
    assert test_company.sendCoin(150, t.a2, sender=t.k1) is False
    # Check shareholdings
    assert test_company.getCurrentShareholdingsOf(t.a1) == 850
    assert test_company.getCurrentShareholdingsOf(t.a2) == 150
    # Authorize the order book contract to accept lockups
    test_company.setContractAuthorized(order_book.address, True)
    # User a1 puts up 50 shares for sale; however, he tries to do
    # this without first authorizing the order book to withdraw so
    # the operation fails
    assert order_book.mkSellOrder(test_company.address, 50,
                                  test_currency.address, 10000,
                                  sender=t.k1) == -1
    # Now, try to create the order properly
    test_company.authorizeLockup(order_book.address, 50, sender=t.k1)
    _id = order_book.mkSellOrder(test_company.address, 50,
                                 test_currency.address, 10000, sender=t.k1)
    assert _id >= 0
    assert test_company.getLockedShareholdingsOf(t.a1) == 50
    # Accept the order by a3. This should fail because a3 has not
    # authorized the order_book to withdraw coins
    assert order_book.claimSellOrder(_id, sender=t.k3) is False
    # Do the authorization
    test_currency.approveOnce(order_book.address, 10000, sender=t.k3)
    # It should still fail because a3 is not authorized to hold shares
    assert order_book.claimSellOrder(_id, sender=t.k3) is False
    # Now do it properly
    test_currency.approveOnce(order_book.address, 10000, sender=t.k2)
    assert order_book.claimSellOrder(_id, sender=t.k2) is True
    # Check shareholdings and balances
    assert test_company.getCurrentShareholdingsOf(t.a1) == 800
    assert test_company.getCurrentShareholdingsOf(t.a2) == 200
    assert test_company.getLockedShareholdingsOf(t.a1) == 0
    assert test_currency.coinBalanceOf(t.a1) == 10000
    assert test_currency.coinBalanceOf(t.a2) == 40000
    assert test_currency.coinBalanceOf(t.a3) == 50000
    # Authorize a3 to hold shares
    test_company.setShareholderMaxShares(t.a3, 500)
    # A3 buys shares
    test_currency.approveOnce(order_book.address, 20000, sender=t.k3)
    _id2 = order_book.mkBuyOrder(test_company.address, 100,
                                 test_currency.address, 20000, sender=t.k3)
    assert _id2 >= 0, _id2
    test_company.authorizeLockup(order_book.address, 100, sender=t.k2)
    assert order_book.claimBuyOrder(_id2, sender=t.k2) is True
    # Check shareholdings and balances
    assert test_company.getCurrentShareholdingsOf(t.a1) == 800
    assert test_company.getCurrentShareholdingsOf(t.a2) == 100
    assert test_company.getCurrentShareholdingsOf(t.a3) == 100
    assert test_company.getLockedShareholdingsOf(t.a1) == 0
    assert test_currency.coinBalanceOf(t.a1) == 10000
    assert test_currency.coinBalanceOf(t.a2) == 60000
    assert test_currency.coinBalanceOf(t.a3) == 30000

if __name__ == '__main__':
    test()
