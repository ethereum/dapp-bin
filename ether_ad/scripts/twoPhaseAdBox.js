var NOT_YET_INCLUDED = -2;

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
    // Commit a bid (first phase of two)
    commitBid: function() {
        var me = this;
        // Bid value
        var value = web3.toBigNumber(web3.toWei(parseFloat(this.refs.bidValue.getDOMNode().value), 'ether'));
        // Bid metadata
        var metadata = this.refs.bidURL.getDOMNode().value;
        // Calculate "bid ceiling": the amount of funds to deposit.
        // This should exceed one's bid.
        var ceiling = web3.toBigNumber(1);
        while (value.gt(ceiling))
            ceiling = ceiling.mul(10);
        console.log('ceiling:', web3.toDecimal(web3.fromWei(ceiling, 'ether')));
        // Compute a random nonce
        var nonce = '0x' + web3.sha3('' + Math.random() + new Date().getTime());
        // Create the hash
        var h = '0x' + hashValue(value, nonce);
        var params = {
            value: ceiling,
            gas: 500000,
            from: window.myAccount
        }
        console.log('with metadata: ', metadata);
        (function(_metadata) {
            auctionContracts[me.props.id].commitBid(h, _metadata, params, function(err, res) {
                if (err) { alert(''+err); return; }
                console.log(res);
                // Push a fake log to get instant feedback
                auctions[me.props.id].logs.BidCommitted.fl.addLog({
                    transactionHash: res,
                    args: {
                        index: NOT_YET_INCLUDED,
                        bidder: window.myAccount,
                        url: _metadata,
                        bidValueHash: h
                    },
                });
            });
        })(metadata);
        web3.db.putString('hashlookup', h, JSON.stringify({value: web3.toHex(value), nonce: nonce}));
        console.log('put', h);
    },
    // Reveal a bid (second phase of two)
    revealBid: function() {
        var me = this;
        var value;
        var nonce;
        var index = -1;
        for (var i = 0; i < auctions[me.props.id].logs.BidCommitted.fl.logs.length; i++) {
            var log = auctions[me.props.id].logs.BidCommitted.fl.logs[i];
            if (log.args.bidder == window.myAccount) {
                index = log.args.index;
                if (index == NOT_YET_INCLUDED) {
                    alert("Cannot reveal your bid until the bid has at least one confirmation");
                    return;
                }
                console.log('getting', log.args.bidValueHash);
                var dbEntry = web3.db.getString('hashlookup', log.args.bidValueHash);
                console.log('dbentry', dbEntry);
                value = web3.toBigNumber(JSON.parse(dbEntry).value);
                nonce = JSON.parse(dbEntry).nonce;
                break;
            }
        }
        if (index == -1) {
            alert("Matching bid not found!");
            return;
        }
        var params = {
            gas: 500000,
            from: window.myAccount
        }
        console.log('p', index, value, nonce, params);
        (function(_index, _value, _nonce, _params) {
            auctionContracts[me.props.id].revealBid(_index, _value, _nonce, _params, function(err, res) {
                if (err) { alert(''+err); return; }
                console.log(res);
                // Push a fake log to get instant feedback
                auctions[me.props.id].logs.BidRevealed.fl.addLog({
                    transactionHash: res,
                    args: {
                        index: _index,
                        bidder: window.myAccount,
                        bidValue: _value,
                    },
                });
            });
        })(index, value, nonce, params);
    },
    // Ping
    ping: function() {
        console.log('pinging');
        var me = this;
        auctionContracts[this.props.id].ping({gas: 2500000, from: window.myAccount}, function(err, res) {
            if (err) { alert(''+err); return; }
            console.log(res);
            auctions[me.props.id].lastPungFor = auctions[me.props.id].hashRevealEnd;
            auctions[me.props.id].lastPungTxhash = res;
        });
    },
    // Render
    render: function() {
        var innerView;
        if (this.state.tab == 0) {
            var _url = auctions[this.props.id].url;
            innerView = (
                <img src={_url} style={{maxWidth: adSizePx, maxHeight: adSizePx}} />
            );
        }
        else {
            // Initialize a dictionary containing bids by index
            var bids = {};
            var me = this;
            var didIBid = false;
            var didIReveal = false;
            var a = auctions[this.props.id];
            // Process available BidCommitted logs
            a.logs.BidCommitted.fl.logs.map(function(log) {
                if (log.args.bidder == window.myAccount)
                    didIBid = true;
                log.revealed = false;
                bids[web3.toDecimal(log.args.index)] = {
                    bidder: log.args.bidder,
                    url: log.args.metadata,
                    bidValueHash: log.args.bidValueHash,
                    status: log.status
                }
            });
            // Process available BidRevealed logs
            a.logs.BidRevealed.fl.logs.map(function(log) {
                if (log.args.bidder == window.myAccount)
                    didIReveal = true;
                var bid = bids[web3.toDecimal(log.args.index)];
                if (!bid) alert(web3.toDecimal(log.args.index) + '___' +  Object.keys(bids))
                bid.revealed = true;
                bid.bidValue = log.args.bidValue;
                bid.status = log.status;
            });
            // Convert the dictionary to a list
            var out = [];
            Object.keys(bids).map(function(key) { out.push(bids[key]); });
            console.log('bids', out);
            // Print the view
            var now = new Date().getTime() * 0.001;
            innerView = (
                <table style={{width: "100%", fontSize: '12px', tableLayout: "fixed", wordWrap: "break-word"}}>
                <tbody>
                {
                    out.map(function(o) {
                        return(
                            <tr style={{'backgroundColor': colorDict[o.status]}}>
                                <td> Address: <a href={"http://etherscan.io/address/"+o.bidder}>{o.bidder.substring(0, 8)}</a> </td>
                                <td> URL: <a href={o.url}>{o.url}</a> </td>
                                <td> Bid: {o.revealed ? web3.toDecimal(web3.fromWei(o.bidValue, 'ether')) : '#hashed'} </td>
                            </tr>
                        );
                    })
                }
                {
                    (function() {
                        var t = web3.eth.getTransaction(a.lastPungTxhash || "");
                        // Phase 0: auction not initialized yet
                        if (a.phase == 0) return (
                            <tr style={{'backgroundColor': '#ff6666'}}>
                                <td colSpan="3">Cannot bid; auction not initialized</td>
                            </tr>
                        )
                        // Phase 2: auction expired
                        else if (a.phase == 2 || (a.phase == 1 && a.hashRevealEnd < now)) { 
                            // Have not yet pinged the auction to process winners
                            if (a.lastPungFor != a.hashRevealEnd) return (
                                <tr style={{'backgroundColor': '#ff6666'}}>
                                    <td colSpan="2">Auction ended.</td>
                                    <td> <button className="btn" onClick={me.ping}>Start new round</button> </td>
                                </tr>
                            )
                            // Pinged the auction to process winners, tx pending
                            else if (!t || !t.blockNumber) return (
                                <tr style={{'backgroundColor': '#ffff66'}}>
                                    <td colSpan="3">Processing previous auction winners.</td>
                                </tr>
                            )
                            // Pinged the auction to process winners, tx confirming
                            else return (
                                <tr style={{'backgroundColor': '#ff8866'}}>
                                    <td colSpan="3">Auction winners partially processed.</td>
                                    <td> <button className="btn" onClick={me.ping}>Continue processing</button> </td>
                                </tr>
                            )
                        }
                        // Phase 1.1: submit hashes
                        else if (!didIBid && a.phase == 1 && now < a.hashSubmissionEnd) return (
                            <tr>
                                <td> <input type="text" className="lower4" placeholder="Amount" ref="bidValue" style={{width: "70px"}}></input> </td>
                                <td> <input type="text" className="lower4" placeholder="URL" ref="bidURL" style={{width: "70px"}}></input> </td>
                                <td> <button className="btn" onClick={me.commitBid}>Bid</button> </td>
                            </tr>
                        )
                        else if (a.phase == 1 && now < a.hashSubmissionEnd) return (
                            <tr style={{'backgroundColor': '#ff6666'}}>
                                <td colSpan="3">You already made a bid</td>
                            </tr>
                        )
                        // Phase 1.2: reveal bids
                        else if (!didIBid && a.phase == 1 && now >= a.hashSubmissionEnd && now < a.hashRevealEnd) return (
                            <tr style={{'backgroundColor': '#ff6666'}}>
                                <td colSpan="3">Cannot bid during this phase</td>
                            </tr>
                        )
                        else if (a.phase == 1 && now >= a.hashSubmissionEnd && now < a.hashRevealEnd) {
                            if (!didIReveal) return (
                                <tr>
                                    <td colSpan="3"> <button className="btn" onClick={me.revealBid}>Reveal my bid</button> </td>
                                </tr>
                            )
                            else return (<tr> </tr>)
                        }
                        // Catch-all
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
                </tbody>
                </table>
            );
        }
        return(
            <div style={{height: (adSize + 30)+'px', overflowY: 'auto'}}>
                <div>
                    <button onClick={this.setTab0} style={{width: '50%'}} className="btn">View</button>
                    <button onClick={this.setTab1} style={{width: '50%'}} className="btn">Bid</button>
                </div>
                {innerView}
            </div>
        );
    }
});

console.log('done tpa');
