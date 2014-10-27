var genId = function() {
    return ''+Math.floor(Math.random() * 1000000000)
}

var initiate = function() {
    var id = genId(),
        timeLimit = 86400 * parseInt(el("timelimit").value),
        weiValue = el("goal").value + '000000000000000000';
    eth.transact({
        from: eth.key,
        value: "0",
        to: crowdFundAddr,
        data: "0x" + eth.fromAscii("0".pad(32) + id.pad(32) + ('0x'+el("address").value).pad(32) + el("goal").value.pad(32) + (""+timeLimit).pad(32)),
        //data: '0x123123123123123123123123123123456456456456456456456456456456789789',
        gas: "65537",
        gasPrice: "10000000000000"
    }, function(){
    })
    el("campaign_addr").innerText = "Waiting for confirmation.";
    el("campaign_addr").href = "campaign.html#" + id;
    update(parseInt(id));
}



var update = function(id) {
    getDetails(id, function(d) {
        console.log(id, d);
        if (d.recipient != '0000000000000000000000000000000000000000') {
            el("campaign_addr").innerText = "http://superfunder.eth/campaign#" + id;
        }
        else {
            el("campaign_addr").innerText = el("campaign_addr").innerText + ".";
            setTimeout(function() { update(id) }, 1000);
        }
    })
}
