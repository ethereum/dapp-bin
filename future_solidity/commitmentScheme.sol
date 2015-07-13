// Enum holding additional data (marked union / sum datatype)
enum Commitment {
    Hidden(bytes32 hash),
    Revealed(uint value)
}

function reveal(Commitment storage _c, uint _value, uint _nonce) {
    if (_c == Commitment.Hidden && this.Hidden.hash == sha3(_value, _nonce))
        _c = Commitment.Revealed(_value);
}

