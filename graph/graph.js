var el = function(n) {
return document.getElementById(n)
}

var graphAddr = '51985dc4943b09bf86f32d4bfd534ef0c47f4502'
var ticker = 0

var initiate = function() {

eth.transact({
    from: eth.key,
    value: 0,
    to: graphAddr,
    data: '0x' + eth.fromAscii("0".pad(32) + ('0x'+el("address").value).pad(32)),
    gas: "65534",
    gasPrice: "10000000000000"
});

}

var check = function() {

eth.transact({
    from: eth.key,
    value: 0,
    to: graphAddr,
    data: '0x' + eth.fromAscii("1".pad(32) + ('0x'+el("checkfrom").value).pad(32) + ('0x'+el("checkto").value).pad(32)),
    gas: "65533",
    gasPrice: "10000000000000"
});

    eth.stateAt(graphAddr, eth.fromAscii('4'.pad(32))).done(function(t) {
        ticker = t;
        update();
    });

}

var update = function(id) {
    eth.stateAt(graphAddr, eth.fromAscii('4'.pad(32))).done(function(t) {
        if (t != ticker) {
            eth.stateAt(graphAddr, eth.fromAscii('5'.pad(32))).done(function(v) {
                el("result").innerText = ('0x'+v).dec();
            })
        }
        else {
            el("result").innerText = el("result").innerText + ".";
            setTimeout(function() { update(id) }, 1000);
        }
    })
}

