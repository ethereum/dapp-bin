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
    /// @dev Finds the first occurrence of _b in _a and returns its index or -1 if failure
    function indexOf(string _a, string _b) returns (int) // _a = string to search, _b = string we want to find
    {
    	bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
    	if(a.length < 1 || b.length < 1 || (b.length > a.length)) 
    		return -1;
    	else if(a.length > (2**128 -1)) // since we have to be able to return -1 (if the char isn't found or input error), this function must return an "int" type with a max length of (2^128 - 1)
    		return -1;									
    	else
    	{
    		uint subindex = 0;
    		for (uint i = 0; i < a.length; i ++)
    		{
    			if (a[i] == b[0]) // found the first char of b
    			{
    				subindex = 1;
    				while(subindex < b.length && (i + subindex) < a.length && a[i + subindex] == b[subindex]) // search until the chars don't match or until we reach the end of a or b
    				{
    					subindex++;
    				}	
    				if(subindex == b.length)
    					return int(i);
    			}
    		}
    		return -1;
    	}	
    }
}
