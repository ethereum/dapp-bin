
// Checks all your Balances
function checkAllBalances() { 
var i =0; 
eth.accounts.forEach( function(e){
    console.log("  eth.accounts["+i+"]: " +  e + " \tbalance: " + web3.fromWei(eth.getBalance(e), "ether") + " ether"); 
i++; 
})
}; 


// Current state of the Crowdsale
"The current funding at " +( 100 *  crowdsaleInstance.amountRaised.call() / crowdsaleInstance.fundingGoal.call()) + "% of its goals. Currently, " + crowdsaleInstance.numFunders.call() + " funders have contributed a total of " + web3.fromWei(crowdsaleInstance.amountRaised.call(), "ether") + " ether. The deadline is at " + Date(crowdsaleInstance.deadline.call())



// List all the proposals in the Democratic DAO
function checkAllProposals() {  
    for (i = 0; i< daoInstance.numProposals.call(); i++ ) { 
        var p = daoInstance.proposals.call(i)
        console.log("Proposal #" + i + "    Send " + web3.fromWei( p[1], "ether") + " ether to address " + p[0] + " for " + p[2] + ". " + (p[7]? (" It is still being voted with " + p[5] + " votes.") : (" It it's not active and received " + p[5] + " votes.") )); 
    }
}

