var EtherAdView = React.createClass({
    getInitialState: function() {
        return {
            urls: ['', '', '', '', '', '', ''],
            addresses: ['', '', '', '', '', '', ''],
        };
    },

  /**
   * This function will be re-bound in render multiple times. Each .bind() will
   * create a new function that calls this with the appropriate key as well as
   * the event. The key is the key in the state object that the value should be
   * mapped from.
   */
  handleInputChange: function(key, event) {
    var partialState = {};
    partialState[key] = event.target.value;
    this.setState(partialState);
  },

  render: function() {
    var _a = this.state.a;
    var _b = this.state.b;
    var _c = this.state.c
    var a = parseFloat(_a)
    var b = parseFloat(_b)
    var c = parseFloat(_c)
    var x1 = (-b + Math.sqrt(Math.pow(b, 2) - 4 * a * c)) / (2 * a);
    var x2 = (-b - Math.sqrt(Math.pow(b, 2) - 4 * a * c)) / (2 * a);
    return (
      <div>
        <strong>
          <em>ax</em><sup>2</sup> + <em>bx</em> + <em>c</em> = 0
        </strong>
        <h4>Solve for <em>x</em>:</h4>
        <p>
          <label>
            a: <input type="number" value={_a} onChange={this.handleInputChange.bind(null, 'a')} />
          </label>
          <br />
          <label>
            b: <input type="number" value={_b} onChange={this.handleInputChange.bind(null, 'b')} />
          </label>
          <br />
          <label>
            c: <input type="number" value={_c} onChange={this.handleInputChange.bind(null, 'c')} />
          </label>
          <br />
          x: <strong>{x1}, {x2}</strong>
        </p>
      </div>
    );
  }
});

var c = web3.eth.contract(window.adStorer.ABI).at(window.adStorer.address);

web3.eth.filter('latest').watch(function() {
    var totDataGathered = 0;
    function finalize() {
        React.render(
            <EtherAdView />
        );
    }
    for (var i = 0; i < 7; i++) {
        c.getWinnerUrl(i, function(err, res) {
            EtherAdView.state.urls[i] = res;
            totDataGathered += 1;
        });
        c.getWinnerAddress(i, function(err, res) {
            EtherAdView.state.addresses[i] = res;
            totDataGathered += 1;
        });
        EtherAdView
    }
React.render(
  <QuadraticCalculator />,
  document.getElementById('container')
);
}
