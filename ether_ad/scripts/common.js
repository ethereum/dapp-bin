web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));
var adSize = 220;
var adSizePx = adSize + "px";
var getTime = function() {
    return new Date().getTime() * 0.001 + clockOffset;
}
var clockOffset = 0;

web3.eth.filter('latest').watch(function(err, block) {
    var timeOffset = web3.eth.getBlock(block).timestamp - (new Date().getTime() * 0.001);
    var clockOffsetDelta = (timeOffset - clockOffset) * 0.25;
    clockOffset += Math.max(Math.min(clockOffsetDelta, 10), -10);
    console.log('clock offset:', clockOffset, 'latest block:', timeOffset);
});

var colorDict = {
    'pending': '#ffff00',
    'confirming': '#66ff66',
    'confirmed': '#dddddd',
    'dblspent': '#ffaa66',
}

var statusPrecedenceOrder = {
    'confirmed': 1,
    'confirming': 2,
    'pending': 3,
    'dblspent': 4
}
