var contribute = function() {
    var id = window.location.hash.substr(1);
    if (!parseInt(id)) {
        el("progress").innerText = "Value invalid";
        return;
    }
    getDetails(parseInt(id), function(d) {
        eth.transact({
            from: eth.key,
            value: el("value").value,
            to: crowdFundAddr,
            data: '0x' + eth.fromAscii("1".pad(32) + id.pad(32)),
            gas: "65537",
            gasPrice: "10000000000000"
        });
        var curContrib = d.contributed;
        el("progress").innerText = "Waiting for confirmation.";
        update(parseInt(id), curContrib);
    });
}

var update = function(id, curContrib) {
    getDetails(id, function(d) {
        console.log(id, d);
        el("recipient").innerText = d.recipient;
        el("goal").innerText = d.goal;
        el("timeleft").innerText = d.timeleft;
        el("contributed").innerText = d.contributed;
        if (d.recipient == '0000000000000000000000000000000000000000') {
            el("notdone").style.display = "none";
            el("done").style.display = "inline";
        }
        if (curContrib >= 0) {
            if (d.contributed != curContrib) {
                el("progress").innerText = "Contribution sent!";
            }
            else {
                el("progress").innerText = el("progress").innerText + "."
                setTimeout(function() { update(id, curContrib); }, 1000);
            }
        }
    })
}
setTimeout(function() {
    var id = window.location.hash.substr(1);
    update(parseInt(id), -1);
}, 200);
