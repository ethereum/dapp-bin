library Math {
    /// @dev Computes the modular exponential (x ** k) % m.
    function modExp(uint x, uint k, uint m) returns (uint r) {
        r = 1;
        for (uint s = 1; s <= k; s *= 2) {
            if (k & s != 0)
                r = mulmod(r, x, m);
            x = mulmod(x, x, m);
        }
    }
}
