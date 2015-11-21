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
        // Bid value
        var value = parseFloat(this.refs.bidValue.getDOMNode().value);
        // Bid metadata
        var metadata = this.refs.bidURL.getDOMNode().value;
        console.log('bidding');
        var me = this;
        // Function calling parameters
        var params = {
            value: web3.toWei(value, 'ether'),
            from: window.myAccount,
            gas: 500000
        }
        // Place the bid
        auctionContracts[this.props.id].bid(metadata, params, function(err, res) {
            if (err) { alert(''+err); return; }
            console.log(res);
            // Push a fake log to get instant feedback
            auctions[me.props.id].logs.BidSubmitted.fl.addLog({
                transactionHash: res,
                logIndex: 0,
                args: {
                    index: res, // txhash as a ghetto temporary index
                    bidder: window.myAccount,
                    metadata: metadata,
                    bidValue: web3.toBigNumber(web3.toWei(value, 'ether'))
                },
            });
        });
    },
    // Increase your bid (one-phase)
    increaseBid: function() {
        // Bid value
        var value = parseFloat(this.refs.increaseBidValue.getDOMNode().value);
        var me = this;
        for (var i = 0; i < auctions[this.props.id].logs.BidSubmitted.fl.logs.length; i++) {
            var log = auctions[this.props.id].logs.BidSubmitted.fl.logs[i];
            // Look for an existing bid where you are the submitter
            if (log.args.bidder == window.myAccount) {
                var id = log.args.index;
                if ((''+id).length >= 64) { // Unconfirmed bids show with the txhash as their index
                    alert("Cannot increase your bid until the bid has at least one confirmation");
                    return;
                }
                console.log('setting params');
                var params = {
                    value: web3.toWei(value, 'ether'),
                    from: window.myAccount,
                    gas: 500000
                }
                console.log('increasing bid', id, web3.toDecimal(id));
                (function(_id, _params, _log) {
                    auctionContracts[me.props.id].increaseBid(_id, _params, function(err, res) {
                        if (err) { alert(''+err); return; }
                        console.log(res);
                        // Push a fake log to get instant feedback
                        auctions[me.props.id].logs.BidIncreased.fl.addLog({
                            transactionHash: res,
                            logIndex: 0,
                            args: {
                                index: _id,
                                bidder: window.myAccount,
                                url: _log.metadata,
                                bidValue: web3.toBigNumber(web3.toWei(value, 'ether')),
                            },
                        });
                    });       
                })(id, params, log);
                break;
            }
        };
    },
    // Ping
    ping: function() {
        console.log('pinging');
        var me = this;
        auctionContracts[this.props.id].ping({gas: 2500000, from: window.myAccount}, function(err, res) {
            if (err) { alert(''+err); return; }
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
            // Initialize a dictionary containing bids by index
            var bids = {};
            var me = this;
            var didIBid = false;
            var a = auctions[this.props.id];
            // Process available BidSubmitted logs
            console.log('bid logs', a.logs.BidSubmitted.fl.logs);
            a.logs.BidSubmitted.fl.logs.map(function(log) {
                if (log.args.bidder == window.myAccount)
                    didIBid = true;    
                bids[web3.toDecimal(log.args.index)] = {
                    bidder: log.args.bidder,
                    value: log.args.bidValue,
                    url: log.args.metadata,
                    status: log.status
                }
            });
            // Process available BidIncreased logs
            console.log('increases', a.logs.BidIncreased.fl.logs);
            a.logs.BidIncreased.fl.logs.map(function(log) {
                var bid = bids[web3.toDecimal(log.args.index)];
                if (!bid)
                    alert("Error processing logs" + web3.toDecimal(log.args.index) + ' ' + Object.keys(bids));
                bid.value = bid.value.add(log.args.bidValue);
                // Apply precdence order to status of logs (eg. a bid with a confirmed and a
                // pending log will show as pending)
                if ((statusPrecedenceOrder[log.status] || -1) > (statusPrecedenceOrder[bid.status] || -1)) {
                    bid.status = log.status;
                }
            });
            // Convert the dictionary to a list
            var out = [];
            Object.keys(bids).map(function(key) { out.push(bids[key]); });
            out = out.sort(function(x, y) { return web3.toDecimal(x.value) < web3.toDecimal(y.value); });
            console.log('bids', out);
            // Print the view
            var now = getTime();
            innerView = (
                <table style={{width: "100%", fontSize: '12px', tableLayout: "fixed", wordWrap: "break-word"}}>
                <tbody>
                {
                    // Print an object for every bid
                    out.map(function(o) {
                        return(
                            <tr style={{'backgroundColor': colorDict[o.status]}}>
                                <td> Address: <a href={"http://etherscan.io/address/"+o.bidder}>{o.bidder.substring(0, 8)}</a> </td>
                                <td> URL: <a href={o.url}>{o.url}</a> </td>
                                <td> Bid: {web3.toDecimal(web3.fromWei(o.value, 'ether'))} </td>
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
                        else if (a.phase == 2 || (a.phase == 1 && a.phaseExpiry < now)) { 
                            // Have not yet pinged the auction to process winners
                            if (a.lastPungFor != a.phaseExpiry) return (
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
                        // Phase 1 + you have not yet bid: show the option to bid
                        else if (!didIBid) return (
                            <tr>
                                <td> <input type="text" className="lower4" ref="bidValue" placeholder="Amount" style={{width: "70px"}}></input> </td>
                                <td> <input type="text" className="lower4" ref="bidURL" placeholder="URL" style={{width: "70px"}}></input> </td>
                                <td> <button className="btn" onClick={me.bid}>Bid</button> </td>
                            </tr>
                        )
                        // Phase 1 + you already bid: show the option to increase the bid if the auction allows it
                        else if (me.props.id == 1 || me.props.id == 3) return (
                            <tr>
                                <td> <input type="text" className="lower4" ref="increaseBidValue" placeholder="Amount" style={{width: "45px"}}></input> </td>
                                <td colspan="2"> <button className="btn" onClick={me.increaseBid}>Increase bid</button> </td>
                            </tr>
                        )
                        else return ( <tr> </tr> )
                    })()
                }
                {
                    // Show time remaining if the auction is in session
                    (function() {
                        if (a.phase == 1 && a.phaseExpiry > now) return (
                            <tr>
                                <td colSpan="3">Bidding phase ends in approximately {parseInt(a.phaseExpiry - getTime())} seconds</td>
                            </tr>
                        )
                        else return (<tr> </tr>)
                    })()
                }
                </tbody>
                </table>
            );
        }
        // Render the main object, including the button to switch between view and bid mode
        return(
            <div style={{height: (adSize + 30)+'px', width: adSizePx, maxWidth: adSizePx, overflowY: 'auto'}}>
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
