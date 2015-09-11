library StringUtils {
    /// @dev Does a byte-by-byte lexicographical comparison of two strings.
    /// @return a negative number if `_a` is smaller, zero if they are equal
    /// and a positive numbe if `_b` is smaller.
    function compare(string _a, string _b) returns (int) {
		bytes memory a = bytes(_a);
		bytes memory b = bytes(_b);
		uint minLength = a.length;
		if (b.length < minLength) minLength = b.length;
		//@todo unroll the loop into increments of 32 and do full 32 byte comparisons
		for (uint i = 0; i < minLength; i ++)
			if (a[i] < b[i])
			    return -1;
			else if (a[i] > b[i])
			    return 1;
	    if (a.length < b.length)
	        return -1;
	    else if (a.length > b.length)
	        return 1;
	    else
	        return 0;
	}
	/// @dev Compares two strings and returns true iff they are equal.
	function equal(string _a, string _b) returns (bool) {
	    return compare(_a, _b) == 0;
	}
}
