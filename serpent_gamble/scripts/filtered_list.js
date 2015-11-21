// Assume we will not revert more than this number of blocks
SAFE_CONFIRMATIONS = 12;

// Maintain a list of all logs that satisfy a particular filter. Call a
// callback when an initial list is prepared.
function filtered_list(filter, cb) {
    this.filter = filter;
    this.logs = [];
    this.logMap = {};
    var me = this;
    // Function for adding a log to the list
    this.addResult = function(result) {
        if (me.logMap[result.transactionHash]) return;
        me.logs.push(result); 
        me.logMap[result.transactionHash] = result;
    }
    // Start off by grabbing all previous results with filter.get()
    filter.get(function(error, results) {
        // Add the results that we get to our list
        results.map(function(result) { me.addResult(result) });
        // Sort the results
        me.logs = me.logs.sort(function(a, b) { return a.blockNumber > b.blockNumber });
        // Add a filter watch for incoming new results
        filter.watch(function(error, result) { if (!error) me.addResult(result) });
        // Call the callback
        cb(null, me.logs);
    });
    web3.eth.filter('latest', function(err, block) {
        // Grab all the results within the last SAFE_CONFIRMATIONS confirmations,
        // check that they are still valid, and re-sort them just in case as
        // filter.watch does sometimes give results out of order
        var grab = [];
        while (me.logs.length && me.logs[me.logs.length - 1].blockNumber > block.blockNumber - SAFE_CONFIRMATIONS) {
            var lastLog = me.logs.pop();
            if (eth.getTransactionReceipt(lastLog.transactionHash))
                grab.append(lastLog);
            else
                me.logMap[lastLog.transactionHash] = false;
        }
        grab = grab.sort(function(a, b) { return a.blockNumber > b.blockNumber });
        grab.map(function(x) { me.logs.append(x) });
        console.log('l', me.logs);
    });
}
