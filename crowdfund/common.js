var el = function(n) {
return document.getElementById(n)
}
var crowdFundAddr = 
"978724a48106eb396b0368c69222b91023bf757f"

var timify = function(s) {
    var o = '';
    if (s >= 86400) {
        o += Math.floor(s / 86400) + ' days, '
        s = s % 86400
    }
    if (s >= 3600) {
        o += Math.floor(s / 3600) + ' hours, '
        s = s % 3600
    }
    if (s >= 60) {
        o += Math.floor(s / 60) + ' minutes, '
        s = s % 60
    }
    o += Math.floor(s) + ' seconds'
    return o;
}

var getDetails = function(id, cb) {
    // Hex repr of storage value without final digit
    var ind = '0x'+id.toString(16)+'0000000000000000000000000000000'
    eth.stateAt(crowdFundAddr, eth.fromAscii((ind+'0').pad(32))).done(function(recipient) {
        eth.stateAt(crowdFundAddr, eth.fromAscii((ind+'1').pad(32))).done(function(goal) {
            eth.stateAt(crowdFundAddr, eth.fromAscii((ind+'2').pad(32))).done(function(deadline) {
                eth.stateAt(crowdFundAddr, eth.fromAscii((ind+'4').pad(32))).done(function(contrib) {
                    // Parameters
                    cb({
                        recipient: eth.fromAscii(('0x'+recipient).pad(32)).substr(24),
                        goal: ('0x'+goal).dec(),
                        timeleft: timify(parseInt(('0x'+deadline).dec()) - new Date().getTime() / 1000),
                        contributed: ('0x'+contrib).dec()
                    })
                })
            })
        })
    })
}
