from ethereum import tester as t
from itertools import permutations
from ethereum import utils
import sys

def sha3num(*args):
    o = ''
    for arg in args:
        if isinstance(arg, (int, long)):
            o += utils.zpad(utils.encode_int(arg), 32)
        else:
            o += arg
    return utils.sha3(o)


def test():
    s = t.state()
    t.gas_price = 0
    s.block.coinbase = '\x35' * 20
    content = open('one_phase_auction.sol').read() + open('two_phase_auction.sol').read() + open('adStorer.sol').read()
    logs = []
    c = s.abi_contract(content, language='solidity', log_listener = lambda x: logs.append(x))
    print s.block.get_receipts()[-1].gas_used
    opa_sig = t.languages['solidity'].mk_full_signature(content, 'OnePhaseAuction')
    tpa_sig = t.languages['solidity'].mk_full_signature(content, 'TwoPhaseAuction')
    auctions = []
    while not c.initialize(86400, 86400, 86400, 3600, 50, 10):
        pass
    for i in range(8):
        a = utils.normalize_address(c.getAuctionAddress(i))
        auctions.append(t.ABIContract(s, opa_sig if i < 4 else tpa_sig, a, True, lambda x: logs.append(x)))
    bids = (
        # bidder, value, higherValue, metadata
        (0, 10000, 100000, 'horse'),
        (1, 50000, 200000, 'cow'),
        (2, 102000, 300000, 'dog'),
        (3, 80000, 400000, 'mooch')
    )
    desired_winner = (2, 'dog')
    desired_balance_changes = [
        # First price
        [0 + 102, 0 + 204, -102000 + 306, 0 + 408],
        # Second price
        [0 + 80, 0 + 160, -80000 + 240, 0 + 320],
        # All pay
        [-10000 + 242, -50000 + 484, -102000 + 726, -80000 + 968],
        # All pay second price
        [-10000 + 220, -50000 + 440, -80000 + 660, -80000 + 880]
    ]
    # Test all four auction types
    start_time = s.block.timestamp
    for i in range(4):
        print 'Starting tests for two-phase auction type %d' % i
        s.block.timestamp = start_time
        for p in permutations(bids):
            old_balances = [s.block.get_balance(x) for x in t.accounts]
            bid_ids = []
            for bidder, value, higherValue, metadata in p:
                _id = auctions[4 + i].commitBid(sha3num(value, '\x35' * 32), metadata, value=higherValue, sender=t.keys[bidder])
                assert _id >= 0, _id
                bid_ids.append(_id)
            assert not auctions[4 + i].revealBid(_id, value, '\x35' * 32)
            s.mine(1, coinbase='\x35' * 20)
            s.block.timestamp += 86400
            assert auctions[4 + i].commitBid(sha3num(value, '\x35' * 32), metadata, value=higherValue, sender=t.keys[bidder]) < 0
            for _id, (bidder, value, higherValue, metadata) in zip(bid_ids, p):
                assert not auctions[4 + i].revealBid(_id, value - 1, '\x35' * 32)
                o = auctions[4 + i].revealBid(_id, value, '\x35' * 32)
                assert o
            s.mine(1, coinbase='\x35' * 20)
            s.block.timestamp += 86400
            assert not auctions[4 + i].revealBid(_id, value)
            while 1:
                r = auctions[4 + i].ping()
                if r:
                    break
            assert auctions[4 + i].getPhase() == 1, auctions[4 + i].getPhase()
            auction_winner_logs = [x for x in logs if x["_event_type"] == "AuctionWinner"]
            assert len(auction_winner_logs)
            assert auction_winner_logs[-1]["bidder"] == t.accounts[desired_winner[0]].encode('hex')
            assert auction_winner_logs[-1]["metadata"].strip('\x00') == desired_winner[1]
            new_balances = [s.block.get_balance(x) for x in t.accounts]
            deltas = [a - b for a,b in zip(new_balances, old_balances)]
            assert deltas[:len(desired_balance_changes[i])] == desired_balance_changes[i], (deltas, desired_balance_changes[i])
            assert c.getWinnerAddress(4 + i) == t.accounts[desired_winner[0]].encode('hex')
            assert c.getWinnerUrl(4 + i) == desired_winner[1]

    bids = (
        # bidder, value, metadata, expected result
        (0, 200, "cow", True),
        (2, 220, "moose", True), # increases max 200 -> 220
        (1, 270, "pig", True), # increases max 220 -> 270
        (2, 240, "moose", False), # 240 < 270
        (3, 280, "mouse", False), # 280 < 270 * 1.05
        (4, 290, "remorse", True), # increases max 270 -> 290
        (1, 30, None, False), # 270+30 = 300 < 290 * 1.05
        (1, 50, None, True), # increases max 290 -> 270+50 = 320
        (2, 110, None, False), # 220+110 = 330 < 320 * 1.05
        (2, 170, None, True), # increasea max 320 -> 220+170 = 390
    )
    desired_winners = [(4, "remorse"), (2, "moose"), (4, "remorse"), (2, "moose")]
    desired_balance_changes = [
        [0, 0, 0, 0, -290],
        [0, 0, -390, 0, 0],
        [-200, -270, -220, 0, -290],
        [-200, -320, -390, 0, -290]
    ]
    for i in range(4):
        print "Starting tests for one-phase auction type %d" % i
        s.block.timestamp = start_time
        bidmap = {}
        old_balances = [s.block.get_balance(x) for x in t.accounts]
        for bidder, value, metadata, expected_result in bids:
            if metadata:
                o = auctions[i].bid(metadata, value=value, sender=t.keys[bidder])
                assert (o >= 0) is expected_result
                if o >= 0:
                    bidmap[bidder] = o
            elif i & 1:
                assert auctions[i].increaseBid(bidmap[bidder], value=value, sender=t.keys[bidder]) is expected_result
        s.mine(1, coinbase='\x35' * 20)
        s.block.timestamp += 86400
        newish_balances = [s.block.get_balance(x) for x in t.accounts]
        deltas0 = [a - b for a,b in zip(newish_balances, old_balances)]
        while not auctions[i].ping():
            pass
        auction_winner_logs = [x for x in logs if x["_event_type"] == "AuctionWinner"]
        assert len(auction_winner_logs)
        assert auction_winner_logs[-1]["bidder"] == t.accounts[desired_winners[i][0]].encode('hex')
        assert auction_winner_logs[-1]["metadata"] == desired_winners[i][1]
        new_balances = [s.block.get_balance(x) for x in t.accounts]
        deltas = [a - b for a,b in zip(new_balances, old_balances)]
        assert deltas[:len(desired_balance_changes[i])] == desired_balance_changes[i]
        assert c.getWinnerAddress(i) == t.accounts[desired_winners[i][0]].encode('hex')
        assert c.getWinnerUrl(i) == desired_winners[i][1]
    

if __name__ == '__main__':
    test()
