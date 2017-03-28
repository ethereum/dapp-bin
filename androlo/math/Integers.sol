library Integers {

    // Modular inverse of a (mod p) using euclid.
    // 'a' and 'p' must be co-prime.
    function invmod(uint a, uint p) constant returns (uint) {
        if (a == 0 || a == p || p == 0)
            throw;
        if (a > p)
            a = a % p;
        int t1;
        int t2 = 1;
        uint r1 = p;
        uint r2 = a;
        uint q;
        while (r2 != 0) {
            q = r1 / r2;
            (t1, t2, r1, r2) = (t2, t1 - int(q) * t2, r2, r1 - q * r2);
        }
        if (t1 < 0)
            return (p - uint(-t1));
        return uint(t1);
    }

    // Modular exponentiation, b^e % m
    // Basically the same as can be found here:
    /// https://github.com/ethereum/serpent/blob/develop/examples/ecc/modexp.se
    function expmod(uint b, uint e, uint m) constant returns (uint r) {
        if (b == 0)
            return 0;
        if (e == 0)
            return 1;
        if (m == 0)
            throw;
        r = 1;
        uint bit = 2 ** 255;
        assembly {
            loop:
                jumpi(end, not(bit))
                r := mulmod(mulmod(r, r, m), exp(b, not(not(and(e, bit)))), m)
                r := mulmod(mulmod(r, r, m), exp(b, not(not(and(e, div(bit, 2))))), m)
                r := mulmod(mulmod(r, r, m), exp(b, not(not(and(e, div(bit, 4))))), m)
                r := mulmod(mulmod(r, r, m), exp(b, not(not(and(e, div(bit, 8))))), m)
                bit := div(bit, 16)
                jump(loop)
            end:
        }

    }

}