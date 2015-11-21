contract currency {
    function sendCoinFrom(address _from, uint _val, address _to) returns (bool _success) { }
    function sendCoin(uint _val, address _to) returns (bool _success) { }
}

contract exchange {
    struct Order {
        address creator;
        address offerCurrency;
        uint256 offerValue;
        address wantCurrency;
        uint256 wantValue;
    }

    event Traded(bytes32 indexed currencyPair, address indexed seller, uint256 offerValue, address indexed buyer, uint256 wantValue);

    mapping ( uint256 => Order ) orders;
    uint256 nextOrderId = 1;

    function placeOrder(address _offerCurrency, uint256 _offerValue, address _wantCurrency, uint256 _wantValue) returns (uint256 _offerId) {
        if (currency(_offerCurrency).sendCoinFrom(msg.sender, _offerValue, this)) {
            _offerId = nextOrderId;
            nextOrderId += 1;
            orders[_offerId].creator = msg.sender;
            orders[_offerId].offerCurrency = _offerCurrency;
            orders[_offerId].offerValue = _offerValue;
            orders[_offerId].wantCurrency = _wantCurrency;
            orders[_offerId].wantValue = _wantValue;
        }
        else _offerId = 0;
    }

    function claimOrder(uint256 _offerId) returns (bool _success) {
        if (currency(orders[_offerId].wantCurrency).sendCoinFrom(msg.sender, orders[_offerId].wantValue, orders[_offerId].creator)) {
            currency(orders[_offerId].offerCurrency).sendCoin(orders[_offerId].offerValue, msg.sender);
            bytes32 currencyPair = bytes32(((uint256(orders[_offerId].offerCurrency) / 2**32) * 2**128) + (uint256(orders[_offerId].wantCurrency) / 2**32));
            Traded(currencyPair, orders[_offerId].creator, orders[_offerId].offerValue, msg.sender, orders[_offerId].wantValue);
            orders[_offerId].creator = 0;
            orders[_offerId].offerCurrency = 0;
            orders[_offerId].offerValue = 0;
            orders[_offerId].wantCurrency = 0;
            orders[_offerId].wantValue = 0;
            _success = true;
        }
        else _success = false;
    }

    function deleteOrder(uint256 _offerId) {
        currency(orders[_offerId].offerCurrency).sendCoin(orders[_offerId].offerValue, orders[_offerId].creator);
        orders[_offerId].creator = 0;
        orders[_offerId].offerCurrency = 0;
        orders[_offerId].offerValue = 0;
        orders[_offerId].wantCurrency = 0;
        orders[_offerId].wantValue = 0;
    }
}

