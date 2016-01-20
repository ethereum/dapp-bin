/// This contract can be used (with some small additions to create an economic
/// incentive for the claimant to answer) to claim computation results for
/// scrypt (actually only the part where we do not have precompiled contracts)
/// and interactively convict a false claim.
/// Scrypt first applies a certain hash function to the input in 1024 iterations.
/// Then it applies the hash function another 1024 times but looks up an
/// additional input in the table of the first 1024 values where the look
/// up index depends on the first input.
/// Formally: Assume that H computes the salsa8 hash function as defined below.
/// If value[0] is the input and value[2048] is the output, we have the following
/// relation:
/// value[i] = H(value[i-1]) for 0 < i <= 1024
/// value[i] = H(value[i-1] ^ value[value[i-1] % 1024]) for 1024 < i <= 2048
/// Strictly, not the lowermost byte in value[i-1] is used for addressing,
/// but that does not matter here.
///
/// In this contract, a challenger can ask for each of the value[i]. If the
/// claimant was wrong and the challenger asks in a clever way, she can
/// force the claimant to commit to values for a certain step that do not
/// match the computation done in the actual step.
///
/// The strategy is as follows:
/// We start with a binary search for a point where value[i] is correct but
/// value[i+1] is incorrect (if the response is correct we go up, if it is
/// incorrect we go down).
/// If i <= 1024, the challenger can directly call convict because
/// the commited values do not match the computation.
/// If this ends up at a point i > 1024 it is more complicated because of
/// the second auxiliary input. The challenger has to compute the index
/// of the auxiliary input (value[i] % 1024) and query that. If it is correct,
/// we can again call convict because the output will not match the committed
/// value. If the auxiliary input value is incorrect, it might be that the
/// computation still matches. In this case, we cannot directly call convict
/// but we found an incorrect value at an index smaller than i. This means
/// that we can continue our binary search inside the first half and
/// will end up at a point i' <= 1024 where we can directyl call convict.
///
/// Overall, this should take not more than 22 rounds. Each round costs approximately
/// 140000 gas and a call to convict is about 80000 gas.
/// This means in total, convicting a false claim should not cost more than
/// around three million gas.
/// Of course, as usual, having to convict a false claimant is only a matter
/// of last resort, because every claimant knows that a false claim can be
/// detected and if this is connected with deposits from both sides that
/// go to the winning party, a false claim will probably not be attempted.
///
/// Disclaimer: This has not been tested and is only meant as a proof of concept
/// and a way to compute the gas costs.
contract Scrypt {
    address claimant;
    address challenger;

    function Scrypt(uint[4] _input, uint[4] _output) {
        claimant = msg.sender;
        queries.length = 2;
        queries.push(0);
        queries.push(2048);
        values.push(_input);
        values.push(_output);
    }
    event Convicted();

    modifier onlyClaimant() { if (msg.sender != claimant) throw; _ }
    modifier onlyChallenger() {
        if (challenger == 0) challenger = msg.sender;
        else if (msg.sender != challenger) throw;
        _
    }

    uint16[] public queries;
    /// Challenger queries claimant for the value on a wire `_i`.
    /// Value 0 is the input, value 1024 is the first input to the second
    /// half of the computation, value 2048 is the output.
    function query(uint16 _i) onlyChallenger {
        if (_i > 2048) throw;
        queries.push(_i);
    }

    uint[4][] public values;
    /// Claimant responds to challenge, committing to a value.
    function respond(uint[4] _value) onlyClaimant {
        if (values.length >= queries.length) throw;
        values.push(_value);
    }

    /// Convicts the claimant to have provided inputs and outputs for a single
    /// step that do not match the computation of the step.
    /// q1, q2 and q3 are query indices providing the relevant values.
    /// q1 is the query index of the first input, q2 the query index of
    /// the output and q2 is the query index of the auxiliary input only
    /// used in the second half of the scrypt computation.
    function convict(uint q1, uint q2, uint q3) {
        var i = queries[q1];
        if (queries[q2] != i + 1) throw;
        var input = values[q1];
        var output = values[q2];
        if (i < 1024) {
            if (!verifyFirstHalf(input, output))
                Convicted();
        } else {
            var auxIndex = queries[q3];
            if (auxIndex != (input[2] / 0x100000000000000000000000000000000000000000000000000000000) % 1024)
                throw;
            var auxInput = values[q3];
            if (!verifySecondHalf(input, auxInput, output))
                Convicted();
        }
    }

    /// Verifies a salsa step in the first half of the scrypt computation.
    function verifyFirstHalf(uint[4] input, uint[4] output) constant returns (bool) {
        var (a, b, c, d) = Salsa8.round(input[0], input[1], input[2], input[3]);
        return (a == output[0] && b == output[1] && c == output[2] && d == output[3]);
    }
    /// Verifies a salsa step in the second half of the scrypt computation.
    function verifySecondHalf(uint[4] input, uint[4] vinput, uint[4] output) constant returns (bool) {
        input[0] ^= vinput[0];
        input[1] ^= vinput[1];
        input[2] ^= vinput[2];
        input[3] ^= vinput[3];
        return verifyFirstHalf(input, output);
    }

}

library Salsa8 {
    uint constant m0 = 0x100000000000000000000000000000000000000000000000000000000;
    uint constant m1 = 0x1000000000000000000000000000000000000000000000000;
    uint constant m2 = 0x10000000000000000000000000000000000000000;
    uint constant m3 = 0x100000000000000000000000000000000;
    uint constant m4 = 0x1000000000000000000000000;
    uint constant m5 = 0x10000000000000000;
    uint constant m6 = 0x100000000;
    uint constant m7 = 0x1;
    function quarter(uint32 y0, uint32 y1, uint32 y2, uint32 y3)
        internal returns (uint32, uint32, uint32, uint32)
    {
        uint32 t;
        t = y0 + y3;
        y1 = y1 ^ ((t * 2**7) | (t / 2**(32-7)));
        t = y1 + y0;
        y2 = y2 ^ ((t * 2**9) | (t / 2**(32-9)));
        t = y2 + y1;
        y3 = y3 ^ ((t * 2**13) | (t / 2**(32-13)));
        t = y3 + y2;
        y0 = y0 ^ ((t * 2**18) | (t / 2**(32-18)));
        return (y0, y1, y2, y3);        
    }
    function get(uint data, uint word) internal returns (uint32 x)
    {
        return uint32(data / 2**(256 - word * 32 - 32));
    }
    function put(uint x, uint word) internal returns (uint) {
        return x * 2**(256 - word * 32 - 32);
    }
    function rowround(uint first, uint second) internal returns (uint f, uint s)
    {
        var (a,b,c,d) = quarter(uint32(first / m0), uint32(first / m1), uint32(first / m2), uint32(first / m3));
        f = (((((uint(a) * 2**32) | uint(b)) * 2 ** 32) | uint(c)) * 2**32) | uint(d);
        (b,c,d,a) = quarter(uint32(first / m5), uint32(first / m6), uint32(first / m7), uint32(first / m4));
        f = (((((((f * 2**32) | uint(a)) * 2**32) | uint(b)) * 2 ** 32) | uint(c)) * 2**32) | uint(d);
        (c,d,a,b) = quarter(uint32(second / m2), uint32(second / m3), uint32(second / m0), uint32(second / m1));
        s = (((((uint(a) * 2**32) | uint(b)) * 2 ** 32) | uint(c)) * 2**32) | uint(d);
        (d,a,b,c) = quarter(uint32(second / m7), uint32(second / m4), uint32(second / m5), uint32(second / m6));
        s = (((((((s * 2**32) | uint(a)) * 2**32) | uint(b)) * 2 ** 32) | uint(c)) * 2**32) | uint(d);
    }
    function columnround(uint first, uint second) internal returns (uint f, uint s)
    {
        var (a,b,c,d) = quarter(uint32(first / m0), uint32(first / m4), uint32(second / m0), uint32(second / m4));
        f = (uint(a) * m0) | (uint(b) * m4);
        s = (uint(c) * m0) | (uint(d) * m4);
        (a,b,c,d) = quarter(uint32(first / m5), uint32(second / m1), uint32(second / m5), uint32(first / m1));
        f |= (uint(a) * m5) | (uint(d) * m1);
        s |= (uint(b) * m1) | (uint(c) * m5);
        (a,b,c,d) = quarter(uint32(second / m2), uint32(second / m6), uint32(first / m2), uint32(first / m6));
        f |= (uint(c) * m2) | (uint(d) * m6);
        s |= (uint(a) * m2) | (uint(b) * m6);
        (a,b,c,d) = quarter(uint32(second / m7), uint32(first / m3), uint32(first / m7), uint32(second / m3));
        f |= (uint(b) * m3) | (uint(c) * m7);
        s |= (uint(a) * m7) | (uint(d) * m3);
    }
    function salsa20_8(uint _first, uint _second) internal returns (uint rfirst, uint rsecond) {
        uint first = _first;
        uint second = _second;
        for (uint i = 0; i < 8; i += 2)
        {
            (first, second) = columnround(first, second);
            (first, second) = rowround(first, second);
        }
        for (i = 0; i < 8; i++)
        {
            rfirst |= put(get(_first, i) + get(first, i), i);
            rsecond |= put(get(_second, i) + get(second, i), i);
        }
    }
    function round(uint _a, uint _b, uint _c, uint _d) constant returns (uint, uint, uint, uint) {
        (_a, _b) = salsa20_8(_a ^ _c, _b ^ _d);
        (_c, _d) = salsa20_8(_a ^ _c, _b ^ _d);
        return (_a, _b, _c, _d);
    }
}
