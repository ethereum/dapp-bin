var OnePhaseAdBox = React.createClass({
    getInitialState: function() {
        return {
            tab: 0
        }
    },
    // Switch to tab 0 (viewing the ad)
    setTab0: function() { this.setState({tab: 0}); },
    // Switch to tab 1 (bidding for the ad)
    setTab1: function() { this.setState({tab: 1}); },
    // Submit a bid (one-phase)
    bid: function() {
        var value = parseFloat(this.refs.bidValue.getDOMNode().value);
        var metadata = this.refs.bidURL.getDOMNode().value;
        console.log('bidding');
        var me = this;
        auctionContracts[this.props.id].bid(metadata, {value: web3.toWei(value, 'ether'), from: window.myAccount, gas: 500000}, function(err, res) {
            if (err) {
                alert(''+err);
                return;
            }
            console.log(res);
            // Push a fake log to get instant feedback
            auctions[me.props.id].logs.BidSubmitted.fl.logs.push({
                blockNumber: 999999999999,
                transactionHash: '',
                args: {
                    index: 888888,
                    bidder: window.myAccount,
                    metadata: metadata,
                    bidValue: web3.toDecimal(web3.toWei(value, 'ether'))
                },
                pending: true
            });
        });
    },
    // Increase your bid (one-phase)
    increaseBid: function() {
        var value = parseFloat(this.refs.increaseBidValue.getDOMNode().value);
        var a = auctions[this.props.id];
        var me = this;
        for (var i = 0; i < a.logs.BidSubmitted.fl.logs.length; i++) {
            var log = a.logs.BidSubmitted.fl.logs[i];
            if (log.args.bidder == window.myAccount) {
                var id = log.args.index;
                console.log('increasing bid');
                auctionContracts[me.props.id].increaseBid(id, {value: web3.toWei(value, 'ether'), from: window.myAccount, gas: 500000}, function(err, res) {
                    if (err) {
                        alert(''+err);
                        return;
                    }
                    console.log(res);
                    // Push a fake log to get instant feedback
                    auctions[me.props.id].logs.BidIncreased.fl.logs.push({
                        blockNumber: 999999999999,
                        transactionHash: res,
                        args: {
                            index: id,
                            bidder: window.myAccount,
                            url: log.metadata,
                            bidValue: web3.toWei(value, 'ether'),
                            cumValue: web3.toBigNumber(web3.toWei(value, 'ether')).add(log.args.bidValue),
                        },
                        pending: true
                    });
                });       
                break;
            }
        };
    },
    // Ping
    ping: function() {
        console.log('pinging');
        var me = this;
        auctionContracts[this.props.id].ping({gas: 2500000, from: window.myAccount}, function(err, res) {
            if (err) {
                alert(''+err);
                return;
            }
            console.log(res);
            auctions[me.props.id].lastPungFor = auctions[me.props.id].phaseExpiry;
            auctions[me.props.id].lastPungTxhash = res;
        });
    },
    // Render
    render: function() {
        //console.log('rendering one phase ad box');
        var innerView;
        if (this.state.tab == 0) {
            var _url = auctions[this.props.id].url;
            innerView = (
                <img src={_url} style={{maxWidth: adSizePx, maxHeight: adSizePx}} />
            );
        }
        else {
            var bids = {};
            var myBidIndex = -1;
            var a = auctions[this.props.id];
            console.log('bid logs', a.logs.BidSubmitted.fl.logs);
            a.logs.BidSubmitted.fl.logs.map(function(log) {
                if (log.args.bidder == window.myAccount) {
                    myBidIndex = web3.toDecimal(log.args.index);
                }
                bids[web3.toDecimal(log.args.index)] = log;
            });
            var increases = a.logs.BidIncreased.fl.logs;
            increases.map(function(log) {
                if (log.args.cumValue.gt(bids[web3.toDecimal(log.args.index)].args.bidValue)) {
                    bids[web3.toDecimal(log.args.index)].args.bidValue = log.args.cumValue;
                    bids[web3.toDecimal(log.args.index)].pending = log.pending;
                }
            });
            console.log('increases', increases);
            var out = [];
            var me = this;
            Object.keys(bids).map(function(key) { out.push(bids[key]); });
            out = out.sort(function(x, y) { return web3.toDecimal(x.bidValue) < web3.toDecimal(y.bidValue); });
            console.log('bids', out);
            var now = getTime();
            innerView = (
                <table style={{width: "100%", fontSize: '12px', tableLayout: "fixed", wordWrap: "break-word"}}>
                <tbody>
                {
                    out.map(function(o) {
                        return(
                            <tr style={{'backgroundColor': o.pending ? '#ffff00' : '#dddddd'}}>
                                <td> Address: <a href={"http://etherscan.io/address/"+o.args.bidder}>{o.args.bidder.substring(0, 8)}</a> </td>
                                <td> URL: <a href={o.args.metadata}>{o.args.metadata}</a> </td>
                                <td> Bid: {web3.toDecimal(web3.fromWei(o.args.bidValue, 'ether'))} </td>
                            </tr>
                        );
                    })
                }
                {
                    (function() {
                        var t = web3.eth.getTransaction(a.lastPungTxhash || "");
                        if (a.phase == 0) return (
                            <tr style={{'backgroundColor': '#ff6666'}}>
                                <td colSpan="3">Cannot bid; auction not initialized</td>
                            </tr>
                        )
                        else if (a.phase == 2 || (a.phase == 1 && a.phaseExpiry < now)) { 
                            if (a.lastPungFor != a.phaseExpiry) return (
                                <tr style={{'backgroundColor': '#ff6666'}}>
                                    <td colSpan="2">Auction ended.</td>
                                    <td> <button className="btn" onClick={me.ping}>Start new round</button> </td>
                                </tr>
                            )
                            else if (!t || !t.blockNumber) return (
                                <tr style={{'backgroundColor': '#ffff66'}}>
                                    <td colSpan="3">Processing previous auction winners.</td>
                                </tr>
                            )
                            else return (
                                <tr style={{'backgroundColor': '#ff8866'}}>
                                    <td colSpan="3">Auction winners partially processed.</td>
                                    <td> <button className="btn" onClick={me.ping}>Continue processing</button> </td>
                                </tr>
                            )
                        }
                        else if (myBidIndex == -1) return (
                            <tr>
                                <td> <input type="text" ref="bidValue" placeholder="Amount" style={{width: "70px"}}></input> </td>
                                <td> <input type="text" ref="bidURL" placeholder="URL" style={{width: "70px"}}></input> </td>
                                <td> <button className="btn" onClick={me.bid}>Bid</button> </td>
                            </tr>
                        )
                        else return (
                            <tr>
                                <td> <input type="text" ref="increaseBidValue" placeholder="Amount" style={{width: "45px"}}></input> </td>
                                <td colspan="2"> <button className="btn" onClick={me.increaseBid}>Increase bid</button> </td>
                            </tr>
                        )
                    })()
                }
                {
                    (function() {
                        if (a.phase == 1) return (
                            <tr>
                                <td colSpan="3">Bidding phase ends in {a.phaseExpiry - getTime()} seconds</td>
                            </tr>
                        )
                        else return (<tr> </tr>)
                    })()
                }
                </tbody>
                </table>
            );
        }
        //console.log('almost rendered one phase box');
        return(
            <div style={{height: (adSize + 20)+'px', width: adSizePx, maxWidth: adSizePx}}>
                <div>
                    <button onClick={this.setTab0} style={{width: (adSize/2)+'px'}} className="btn">View</button>
                    <button onClick={this.setTab1} style={{width: (adSize/2)+'px'}} className="btn">Bid</button>
                </div>
                {innerView}
            </div>
        );
    }
});

console.log('done opa');
