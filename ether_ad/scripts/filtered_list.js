// Assume we will not revert more than this number of blocks
SAFE_CONFIRMATIONS = 12;

var eth = web3.eth;

var firstSeenTimestamps = {};

// Maintain a list of all logs that satisfy a particular filter. Call a
// callback when an initial list is prepared.
function filtered_list(filter, cb) {
    this.now = function() { return new Date().getTime() * 0.001; }
    this.filter = filter;
    this.logs = [];
    this.logMap = {};
    // List of first-seen timestamps of every log. Used to auto-forget a log
    // after 300 seconds
    var me = this;
    this.cb = cb || function(){};
    // Function for adding a log to the list. You can add logs youself,
    // but make sure to set the transaction hash parameter
    this.addLog = function(log) {
        console.log('adding log', log.transactionHash);
        // Maintain the first-seen timestamp dictionary
        if (!firstSeenTimestamps[log.transactionHash])
            firstSeenTimestamps[log.transactionHash] = me.now();
        // If a log already exists, just update it
        var existingLog = me.logMap[log.transactionHash];
        if (existingLog) {
            if (existingLog.status) {
                Object.keys(log).map(function(k) {
                    existingLog[k] = log[k];
                });
            }
        }
        // Otherwise, add it to the list and the map
        else {
            me.logs.push(log); 
            me.logMap[log.transactionHash] = log;
        }
        // Update confirmation status
        me.updateStatus(existingLog || log);
    }
    // Start off by grabbing all previous results with filter.get()
    filter.get(function(error, results) {
        // Add the results that we get to our list
        results.map(function(result) { me.addLog(result) });
        // Sort the results
        me.logs = me.logs.sort(function(a, b) { return a.blockNumber > b.blockNumber });
        // Add a filter watch for incoming new results
        filter.watch(function(error, result) { if (!error) me.addLog(result) });
        // Call the callback
        me.cb();
    });
    eth.filter('latest', function(err, block) { me.filterGrabber(err, block); })
    // Update the confirmation status of a log
    this.updateStatus = function(log) {
        eth.getTransaction(log.transactionHash, function(err, tx) {
            if (err) return;
            eth.getTransactionCount(tx.from, function(err, nonce) {
                if (err) return;
                // Set the status
                var oldStatus = log.status;
                if (nonce >= tx.from && !tx.blockNumber)
                    log.status = "dblspent";
                else if (!tx.blockNumber)
                    log.status = "pending";
                else if (eth.blockNumber < tx.blockNumber + SAFE_CONFIRMATIONS)
                    log.status = "confirming";
                else
                    log.status = "confirmed";
                if (log.status != oldStatus)
                    console.log('setting status of log', log.transactionHash, 'to', log.status);
                // Call the callback
                me.cb();
            }); 
        }); 
    }
    this.filterGrabber = function(err, block) {
        block = eth.getBlock(block);
        // Grab all the results within the last SAFE_CONFIRMATIONS confirmations,
        // check that they are still valid, and re-sort them just in case as
        // filter.watch does sometimes give results out of order
        var grab = [];
        while (me.logs.length && me.logs[me.logs.length - 1].blockNumber >= block.number - SAFE_CONFIRMATIONS) {
            var lastLog = me.logs.pop();
            me.updateStatus(lastLog);
            // If the transaction is not in a block and it has already been 300 seconds,
            // then forget it for the time being
            if (me.now() < firstSeenTimestamps + 300 || (lastLog.status == "confirming" || lastLog.status == "confirmed"))
                grab.push(lastLog)
            else
                me.logMap[lastLog.transactionHash] = false;
        }
        grab = grab.sort(function(a, b) { return a.blockNumber > b.blockNumber });
        grab.map(function(x) { me.logs.push(x) });
        me.cb();
    };
    this.shutdown = function() { me.filterGrabber = function(){}; };
}
