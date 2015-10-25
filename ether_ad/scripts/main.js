//var web3 = new Web3();
console.log(0);

var EtherAdView = React.createClass({
    getInitialState: function() {
        return {
        };
    },

  handleInputChange: function(key, event) {
  },

  render: function() {
    console.log('rendering');
    var _urls = this.state.urls;
    window.myAccount = this.refs.etherAddressSelect;
    if (window.myAccount)
        window.myAccount = window.myAccount.getDOMNode().value;
    var blockNum = web3.eth.blockNumber;
    var blockHash = web3.eth.getBlock(web3.eth.blockNumber).hash;
    return (
      <div>
        <table style={{tableLayout: "fixed", width: (adSize * 4 + 50)+'px'}}>
        <col width={(adSize + 10)+'px'} />
        <col width={(adSize + 10)+'px'} />
        <col width={(adSize + 10)+'px'} />
        <col width={(adSize + 10)+'px'} />
            <tr>
                <td>My address: </td>
                <td>
                    <select ref="etherAddressSelect">
                        {
                            web3.eth.accounts.map(function(a) {
                                return(<option>{a}</option>)
                            })
                        }
                    </select>
                </td>
                <td></td>
                <td>Block: {blockNum}, <a href={"http://etherscan.io/block/"+blockHash}>{blockHash.substring(0, 8)}</a></td>
            </tr>
            <tr><td colSpan="4">One-phase (ie. non-sealed-bid) auctions</td></tr>
            <tr style={{height: (adSize + 40)+'px'}}>
                <td style={{width: adSizePx, maxWidth: adSizePx, height: (adSize + 40)+'px', position: 'absolute', left: '0px'}}><OnePhaseAdBox id={0} /></td>
                <td style={{width: adSizePx, maxWidth: adSizePx, height: (adSize + 40)+'px', position: 'absolute', left: (adSize + 10) + 'px'}}><OnePhaseAdBox id={1} /></td>
                <td style={{width: adSizePx, maxWidth: adSizePx, height: (adSize + 40)+'px', position: 'absolute', left: (adSize * 2 + 20) + 'px'}}><OnePhaseAdBox id={2} /></td>
                <td style={{width: adSizePx, maxWidth: adSizePx, height: (adSize + 40)+'px', position: 'absolute', left: (adSize * 3 + 30) + 'px'}}><OnePhaseAdBox id={3} /></td>
            </tr>
            <tr>
                <td> <small>Non-cumulative bids, winner pays</small> </td>
                <td> <small>Cumulative bids (ie. can increase your bid after posting it), winner pays</small> </td>
                <td> <small>Non-cumulative bids, all pay</small> </td>
                <td> <small>Cumulative bids, all pay</small> </td>
            </tr>
            <tr><td colSpan="4">Two-phase (ie. sealed-bid) auctions</td></tr>
            <tr style={{height: (adSize + 40)+'px'}}>
                <td style={{width: adSizePx, maxWidth: adSizePx, height: (adSize + 40)+'px', position: 'absolute', left: '0px'}}><TwoPhaseAdBox id={4} /></td>
                <td style={{width: adSizePx, maxWidth: adSizePx, height: (adSize + 40)+'px', position: 'absolute', left: (adSize + 10) + 'px'}}><TwoPhaseAdBox id={5} /></td>
                <td style={{width: adSizePx, maxWidth: adSizePx, height: (adSize + 40)+'px', position: 'absolute', left: (adSize * 2 + 20) + 'px'}}><TwoPhaseAdBox id={6} /></td>
                <td style={{width: adSizePx, maxWidth: adSizePx, height: (adSize + 40)+'px', position: 'absolute', left: (adSize * 3 + 30) + 'px'}}><TwoPhaseAdBox id={7} /></td>
            </tr>
            <tr>
                <td> <small>First price</small> </td>
                <td> <small>Second price</small> </td>
                <td> <small>All-pay</small> </td>
                <td> <small>All-pay second price (ie. winner pays second bid, others pay own bid)</small> </td>
            </tr>
        </table>
      </div>
    );
  }
});

console.log(2);

var c = web3.eth.contract(window.accounts.adStorer.abi).at(window.accounts.adStorer.address);

var auctionContracts = Array(8);
// Get auction addresses
for (var i = 0; i < 8; i++) {
    (function(j) {
        c.getAuctionAddress(i, function(err, res) {
            if (err) alert("Cannot get auction address. Something is likely wrong with your connection.");
            if (j < 4) auctionContracts[j] = web3.eth.contract(window.accounts.OnePhaseAuction.abi).at(res);
            else auctionContracts[j] = web3.eth.contract(window.accounts.TwoPhaseAuction.abi).at(res);
        });
    })(i);
}

console.log(3);


var auctions = [];
for (var i = 0; i < 8; i++) {
   auctions.push({
        winnerAddr: '',
        url: '',
        startBlock: -5,
        logs: {
            BidCommitted: { filter: null, fl: { logs: [] } },
            BidRevealed: { filter: null, fl: { logs: [] } },
            BidSubmitted: { filter: null, fl: { logs: [] } },
            BidIncreased: { filter: null, fl: { logs: [] } },
        }
    });
}

var filterKeys = Object.keys(auctions[0].logs);

console.log(4);


var renderMe = function() {
    var totDataGathered = 0;
    for (var i = 0; i < 8; i++) {
        (function(j) {
            if (!auctionContracts[j]) return;
            c.getWinnerUrl(j, function(err, url) { 
                auctions[j].url = url; 
            });
            c.getWinnerAddress(j, function(err, winnerAddr) {
                auctions[j].winnerAddr = winnerAddr; 
            });
            auctionContracts[j].getMostRecentAuctionStart(function(err, startBlock) {
                if (web3.toDecimal(startBlock) != auctions[j].startBlock) {
                    console.log('starting new round of auction', j);
                    filterKeys.map(function(key) {
                        if (auctions[j].logs[key].filter) 
                            auctions[j].logs[key].fl.shutdown();
                        if (auctionContracts[j][key]) {
                            auctions[j].logs[key].filter = auctionContracts[j][key]({}, {fromBlock: startBlock});
                            auctions[j].logs[key].fl = new filtered_list(auctions[j].logs[key].filter);
                        }
                        else {
                            auctions[j].logs[key].filter = null;
                            auctions[j].logs[key].l = { logs: [] };
                        }
                    });
                }
                auctions[j].startBlock = web3.toDecimal(startBlock); 
            });
            auctionContracts[j].getPhase(function(err, phase) {
                auctions[j].phase = web3.toDecimal(phase); 
            });
            if (j < 4) {
                auctionContracts[j].getPhaseExpiry(function(err, phaseExpiry) {
                    auctions[j].phaseExpiry = web3.toDecimal(phaseExpiry);
                });
            }
            else {
                auctionContracts[j].getHashSubmissionEnd(function(err, hashSubmissionEnd) {
                    auctions[j].hashSubmissionEnd = web3.toDecimal(hashSubmissionEnd);
                });
                auctionContracts[j].getHashRevealEnd(function(err, hashRevealEnd) {
                    auctions[j].hashRevealEnd = web3.toDecimal(hashRevealEnd);
                });
            }
        })(i);
    }
};

console.log(5);

web3.eth.filter('latest').watch(renderMe);
setTimeout(renderMe, 500);

var finalize = function() {
    console.log('finalizing');
    React.render(
      <EtherAdView />,
      document.getElementById('container')
    );
}
setInterval(finalize, 600);
console.log('finalized');
