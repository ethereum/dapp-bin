import pytest
from ethereum import tester
from ethereum import utils
from ethereum._solidity import get_solidity

solidity_currency = open('currency.sol').read()
serpent_currency = open('currency.se').read()


@pytest.mark.skipif(get_solidity() is None, reason="'solc' compiler not available")
def test_currency_apis():
    s = tester.state()
    c1 = s.abi_contract(serpent_currency, sender=tester.k0)
    c2 = s.abi_contract(solidity_currency, language='solidity', sender=tester.k0)
    o = []
    s.block.log_listeners.append(lambda x: o.append(c._translator.listen(x)))
    for c in (c1, c2):
        o = []
        assert c.coinBalanceOf(tester.a0) == 1000000
        assert c.sendCoin(1000, tester.a2, sender=tester.k0) is True
        assert c.sendCoin(999001, tester.a2, sender=tester.k0) is False
        assert c.sendCoinFrom(tester.a2, 500, tester.a3, sender=tester.k0) is False
        c.approveOnce(tester.a0, 500, sender=tester.k2)
        assert c.sendCoinFrom(tester.a2, 400, tester.a3, sender=tester.k0) is True
        assert c.sendCoinFrom(tester.a2, 400, tester.a3, sender=tester.k0) is False
        assert c.sendCoinFrom(tester.a2, 100, tester.a3, sender=tester.k0) is True
        assert c.sendCoinFrom(tester.a2, 100, tester.a3, sender=tester.k0) is False
        c.approve(tester.a0, sender=tester.k2)
        assert c.sendCoinFrom(tester.a2, 100, tester.a3, sender=tester.k0) is True
        c.disapprove(tester.a0, sender=tester.k2)
        print s.block.gas_used / len(s.block.transaction_list)
        assert c.sendCoinFrom(tester.a2, 100, tester.a3, sender=tester.k0) is False
        assert c.coinBalance(sender=tester.k0) == 999000
        assert c.coinBalanceOf(tester.a2) == 400
        assert c.coinBalanceOf(tester.a3) == 600
        assert o == [{"_event_type": b"CoinSent", "from": utils.encode_hex(tester.a0),
                      "value": 1000, "to": utils.encode_hex(tester.a2)},
                     {"_event_type": b"CoinSent", "from": utils.encode_hex(tester.a2),
                      "value": 400, "to": utils.encode_hex(tester.a3)},
                     {"_event_type": b"CoinSent", "from": utils.encode_hex(tester.a2),
                      "value": 100, "to": utils.encode_hex(tester.a3)},
                     {"_event_type": b"CoinSent", "from": utils.encode_hex(tester.a2),
                      "value": 100, "to": utils.encode_hex(tester.a3)}]

serpent_namereg = open('namereg.se').read()
solidity_namereg = open('namereg.sol').read()


@pytest.mark.skipif(get_solidity() is None, reason="'solc' compiler not available")
def test_registrar_apis():
    s = tester.state()
    c1 = s.abi_contract(serpent_namereg, sender=tester.k0)
    c2 = s.abi_contract(solidity_namereg, language='solidity', sender=tester.k0)
    o = []
    s.block.log_listeners.append(lambda x: o.append(c._translator.listen(x)))
    for c in (c1, c2):
        o = []
        assert c.reserve('moose', sender=tester.k0) is True
        assert c.reserve('moose', sender=tester.k0) is False
        assert c.owner('moose') == utils.encode_hex(tester.a0)
        c.setAddr('moose', tester.a5)
        c.setAddr('moose', tester.a6, sender=tester.k1)
        assert c.addr('moose') == utils.encode_hex(tester.a5)
        c.transfer('moose', tester.a1, sender=tester.k0)
        c.transfer('moose', tester.a2, sender=tester.k0)
        assert c.owner('moose') == utils.encode_hex(tester.a1)
        c.setContent('moose', 'antlers', sender=tester.k0)
        c.setContent('moose', 'reindeer', sender=tester.k1)
        assert c.content('moose')[:8] == 'reindeer'
        c.setSubRegistrar('moose', tester.a7, sender=tester.k1)
        c.setSubRegistrar('moose', tester.a8, sender=tester.k2)
        assert c.subRegistrar('moose') == utils.encode_hex(tester.a7)
        assert o == [{"_event_type": b"Changed", "name": b'moose', "__hash_name": utils.sha3(b'moose')}] * 5


solidity_exchange = open('exchange.sol').read()
serpent_exchange = open('exchange.se').read()


@pytest.mark.skipif(get_solidity() is None, reason="'solc' compiler not available")
def test_exchange_apis():
    s = tester.state()
    oc1 = s.abi_contract(serpent_currency, sender=tester.k0)
    oc2 = s.abi_contract(solidity_currency, language='solidity', sender=tester.k0)
    wc1 = s.abi_contract(serpent_currency, sender=tester.k1)
    wc2 = s.abi_contract(solidity_currency, language='solidity', sender=tester.k1)
    e1 = s.abi_contract(serpent_exchange, sender=tester.k0)
    e2 = s.abi_contract(solidity_exchange, language='solidity', sender=tester.k0)
    o = []
    s.block.log_listeners.append(lambda x: o.append(e1._translator.listen(x)))
    # Test serpent-solidity, solidity-serpent interop
    for (oc, wc, e) in ((oc1, wc1, e2), (oc2, wc2, e1))[1:]:
        o = []
        assert oc.coinBalanceOf(tester.a0) == 1000000
        assert oc.coinBalanceOf(tester.a1) == 0
        assert wc.coinBalanceOf(tester.a0) == 0
        assert wc.coinBalanceOf(tester.a1) == 1000000
        # Offer fails because not approved to withdraw
        assert e.placeOrder(oc.address, 1000, wc.address, 5000, sender=tester.k0) == 0
        # Approve to withdraw
        oc.approveOnce(e.address, 1000, sender=tester.k0)
        # Offer succeeds
        oid = e.placeOrder(oc.address, 1000, wc.address, 5000, sender=tester.k0)
        assert oid > 0
        # Offer fails because withdrawal approval was one-time
        assert e.placeOrder(oc.address, 1000, wc.address, 5000, sender=tester.k0) == 0
        # Claim fails because not approved to withdraw
        assert e.claimOrder(oid, sender=tester.k1) is False
        # Approve to withdraw
        wc.approveOnce(e.address, 5000, sender=tester.k1)
        # Claim succeeds
        assert e.claimOrder(oid, sender=tester.k1) is True
        # Check balances
        assert oc.coinBalanceOf(tester.a0) == 999000
        assert oc.coinBalanceOf(tester.a1) == 1000
        assert wc.coinBalanceOf(tester.a0) == 5000
        assert wc.coinBalanceOf(tester.a1) == 995000
        cxor = utils.big_endian_to_int(oc.address) ^ utils.big_endian_to_int(wc.address)
        assert {"_event_type": b"Traded",
                "currencyPair": oc.address[:16] + wc.address[:16],
                "seller": utils.encode_hex(tester.a0), "offerValue": 1000,
                "buyer": utils.encode_hex(tester.a1), "wantValue": 5000} in o


serpent_datafeed = open('datafeed.se').read()
solidity_datafeed = open('datafeed.sol').read()

@pytest.mark.skipif(get_solidity() is None, reason="'solc' compiler not available")
def test_datafeeds():
    s = tester.state()
    c1 = s.abi_contract(serpent_datafeed, sender=tester.k0)
    c2 = s.abi_contract(solidity_datafeed, language='solidity', sender=tester.k0)
    for c in (c1, c2):
        c.set('moose', 110, sender=tester.k0)
        c.set('moose', 125, sender=tester.k1)
        assert c.get('moose') == 110


serpent_ether_charging_datafeed = open('fee_charging_datafeed.se').read()
solidity_ether_charging_datafeed = open('fee_charging_datafeed.sol').read()


@pytest.mark.skipif(get_solidity() is None, reason="'solc' compiler not available")
def test_ether_charging_datafeeds():
    s = tester.state()
    c1 = s.abi_contract(serpent_ether_charging_datafeed, sender=tester.k0)
    c2 = s.abi_contract(solidity_ether_charging_datafeed, language='solidity', sender=tester.k0)
    for c in (c1, c2):
        c.set('moose', 110, sender=tester.k0)
        c.set('moose', 125, sender=tester.k1)
        assert c.get('moose') == 110
        c.setFee(70, sender=tester.k0)
        c.setFee(110, sender=tester.k1)
        assert c.getFee() == 70
        assert c.get('moose') == 0
        assert c.get('moose', value=69) == 0
        assert c.get('moose', value=70) == 110


if __name__ == '__main__':
    test_currency_apis()
    test_registrar_apis()
    test_exchange_apis()
    test_datafeeds()
    test_ether_charging_datafeeds()
