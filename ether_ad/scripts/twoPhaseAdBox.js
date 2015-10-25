var hashValue = function(value, nonce) {
    var valueHex = web3.toHex(value);
    while (valueHex.length < 66)
        valueHex = '0x0' + valueHex.substr(2);
    if (nonce.substring(0, 2) == '0x')
        nonce = nonce.substring(2);
    return sha3Hex(valueHex + nonce);
}

var TwoPhaseAdBox = React.createClass({
    getInitialState: function() {
        return {
            tab: 0
        }
    },
    // Switch to tab 0 (viewing the ad)
    setTab0: function() { this.setState({tab: 0}); },
    // Switch to tab 1 (bidding for the ad)
    setTab1: function() { this.setState({tab: 1}); },
    // Commit a bid (two-phase)
    commitBid: function() {
        var value = web3.toWei(value, 'ether'); // TODO: FIXME
        var metadata = 'cow'; // TODO: FIXME
        var ceiling = web3.toBigNumber(1);
        while (value.gt(ceiling))
            ceiling = ceiling.mul(10);
        var nonce = web3.sha3('' + Math.random() + new Date().getTime());
        var h = hashValue(value, nonce);
        auctions[this.props.id].commitBid(h, metadata, {value: ceiling}, function(h) {
            // Push a fake log to get instant feedback
            auctions[this.props.id].BidCommitted.fl.logs.push({
                blockNumber: 999999999999,
                transactionHash: '',
                args: {
                    index: 888888,
                    bidder: myAddress,
                    url: metadata,
                },
                pending: true
            });
        });
        // TODO: db.store(h, value, nonce);
    },
    // Reveal a bid (two-phase)
    revealBid: function() {
        var value;
        var nonce;
        var index = 0; // TODO: FIXME
        reveals.map(function(log) {
            if (log.args.index == index) {
                // TODO: FIXME
                value = db.get(log.args.bidValueHash);
                nonce = db.get(log.args.bidValueHash);
            }
        });
        auctions[this.props.id].revealBid(index, value, nonce, {}, function(h) {
            // Push a fake log to get instant feedback
            auctions[this.props.id].BidRevealed.fl.logs.push({
                blockNumber: 999999999999,
                transactionHash: '',
                args: {
                    index: 888888,
                    bidder: myAddress,
                    bidValue: value,
                    url: metadata,
                },
                pending: true
            });
        });
    },
    // Render
    render: function() {
        var innerView;
        if (this.state.tab == 0) {
            var _url = auctions[this.props.id].url;
            innerView = (
                <img src={_url} width="200px" height="200px" />
            );
        }
        else {
            var bids = {};
            var myBidIndex = -1;
            var a = auctions[this.props.id];
            a.logs.BidCommitted.fl.logs.map(function(log) {
                if (log.args.bidder == myAddress) {
                    myBidIndex = log.args.index;
                }
                log.revealed = false;
                bids[log.index] = log;
            });
            var reveals = a.logs.BidRevealed.fl.logs;
            reveals.map(function(log) {
                bids[log.args.index].revealed = true;
            });
            var out = [];
            Object.keys(bids).map(function(key) { out.push(bids[key]); });
            var now = new Date().getTime() * 0.001;
            innerView = (
                <table>
                {
                    out.map(function(o) {
                        return(
                            <tr style={{'backgroundColor': o.args.revealed ? '#00ff00' : '#ffff00'}}>
                                <td> Address: {o.args.bidder.substring(0, 8)} </td>
                                <td> URL: {o.args.metadata} </td>
                                <td> Bid: {web3.fromWei(o.args.bidValue, 'ether')} </td>
                            </tr>
                        );
                    })
                }
                {
                    (function() {
                        if (myBidIndex == -1 && a.phase == 1 && now < a.hashSubmissionEnd) return (
                            <tr>
                                <td> <input type="text" placeholder="Amount" style={{width: "70px"}}></input> </td>
                                <td> <input type="text" placeholder="URL" style={{width: "70px"}}></input> </td>
                                <td> <button className="btn">Bid</button> </td>
                            </tr>
                        )
                        else if (a.phase == 1 && now < a.hashSubmissionEnd) return (
                            <tr style={{'backgroundColor': '#ff6666'}}>
                                <td colSpan="3">You already made a bid</td>
                            </tr>
                        )
                        else if (myBidIndex == -1 && a.phase == 1 && now >= a.hashSubmissionEnd && now < a.hashRevealEnd) return (
                            <tr style={{'backgroundColor': '#ff6666'}}>
                                <td colSpan="3">Cannot bid during this phase</td>
                            </tr>
                        )
                        else if (a.phase == 1 && now >= a.hashSubmissionEnd && now < a.hashRevealEnd) return (
                            <tr>
                                <td colSpan="3"> <button className="btn">Reveal my bid</button> </td>
                            </tr>
                        )
                        else return (
                            <tr style={{'backgroundColor': '#ff6666'}}>
                                <td colSpan="3">Cannot bid during this phase</td>
                            </tr>
                        )
                    })()
                }
                {
                    (function() {
                        if (a.phase == 1 && now < a.hashSubmissionEnd) return (
                            <tr>
                                <td colSpan="3">Bidding phase ends in {a.hashSubmissionEnd - now} seconds</td>
                            </tr>
                        )
                        else if (a.phase == 1 && now < a.hashRevealEnd) return (
                            <tr>
                                <td colSpan="3">Bid revealing phase ends in {a.hashRevealEnd - now} seconds</td>
                            </tr>
                        )
                        else return (<tr> </tr>)
                    })()
                }
                </table>
            );
        }
        return(
            <div style={{height: '220px'}}>
                <div>
                    <button onClick={this.setTab0} style={{width: '100px'}} className="btn">View</button>
                    <button onClick={this.setTab1} style={{width: '100px'}} className="btn">Bid</button>
                </div>
                {innerView}
            </div>
        );
    }
});

console.log('done tpa');
