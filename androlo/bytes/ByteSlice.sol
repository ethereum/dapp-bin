/// Used to create slices from 'bytes'.
contract ByteSlice {

    struct Slice {
        uint _unsafe_memPtr;   // Memory address of the first byte.
        uint _unsafe_len;      // Length.
    }

    /// Create a slice from bytes.
    function fromBytes(bytes memory bts) internal constant returns (Slice memory slice) {
        uint memPtr;
        assembly {
            memPtr := add(bts, 0x20)
        }
        slice = Slice(memPtr, bts.length);
    }

    /// Length of the slice.
    function len(Slice memory slice) internal constant returns (uint) {
        return slice._unsafe_len;
    }

    /// returns the byte at 'index'.
    /// Index must be less then 'len(slice)', or the function will throw.
    function at(Slice memory slice, uint index) internal constant returns (byte b) {
        if (index >= slice._unsafe_len)
            throw;
        uint start = slice._unsafe_memPtr;
        uint bb;
        assembly {
            bb := byte(0, mload(add(start, index)))
        }
        b = byte(bb);
    }

    /// returns the byte at index 'index', where 'index' is allowed to be negative.
    /// The index must be less then 'len(slice)', and greater then '-len(slice)'
    function at(Slice memory slice, int index) internal constant returns (byte b) {
        if (index >= 0)
            return at(slice, uint(index));
        uint iAbs = uint(-index);
        if (iAbs > slice._unsafe_len)
            throw;
        return at(slice, slice._unsafe_len - iAbs);
    }

    /// creates a 'bytes' memory-variable from a slice, copying the data.
    function toBytes(Slice memory slice) internal constant returns (bytes memory bts) {
        uint len = slice._unsafe_len;
        uint memPtr = slice._unsafe_memPtr;
        bts = new bytes(len);
        if (len == 0)
            return;
        // We can do word-by-word copying since 'bts' was the last thing to be
        // allocated. Just overwrite any excess bytes with zeroes at the end.
        assembly {
            {
                    let i := 0
                    let btsOffset := add(bts, 0x20)
                    let words := add(add(div(len, 32), gt(mod(len, 32), 0)), 1)
                tag_loop:
                    jumpi(end, gt(i, words))
                    {
                        let offset := mul(i, 32)
                        mstore(add(btsOffset, offset), mload(add(memPtr, offset)))
                        i := add(i, 1)
                    }
                    jump(tag_loop)
                end:
                    mstore(add(add(bts, len), 0x20), 0)
            }
        }
    }

    /// Copy the slice.
    function newSlice(Slice memory slice) internal constant returns (Slice memory newSlice) {
        newSlice = Slice(slice._unsafe_memPtr, slice._unsafe_len);
    }

    /// Create a new slice from the given starting position.
    /// 'startpos' must be less then 'len(slice)'
    function newSlice(Slice memory slice, uint startpos) internal constant returns (Slice memory newSlice) {
        if (startpos > slice._unsafe_len)
            throw;
        var memPtr = startpos != slice._unsafe_len ? slice._unsafe_memPtr + startpos : 0;
        newSlice = Slice(memPtr, slice._unsafe_len - startpos);
    }

    /// Create a new slice from the given starting position.
    /// Negative starting position allowed.
    /// 'startpos' must be less then 'len(slice)', and greater then '-len(slice)'
    /// Warning: higher gas-cost then the function that uses usigned integers.
    function newSlice(Slice memory slice, int startpos) internal constant returns (Slice memory newSlice) {
        uint sAbs;
        uint startpos_;
        if (startpos >= 0) {
            startpos_ = uint(startpos);
            if (startpos_ > slice._unsafe_len)
                throw;
        } else {
            startpos_ = uint(-startpos);
            if (startpos_ > slice._unsafe_len)
                throw;
            startpos_ = slice._unsafe_len - startpos_;
        }

        uint memPtr = slice._unsafe_len != startpos_ ? slice._unsafe_memPtr + startpos_ : 0;
        newSlice = Slice(memPtr, slice._unsafe_len - startpos_);
    }

    /// Create a new slice from the given starting position.
    /// 'startpos' and 'endpos' must not be larger then 'len(slice)',
    /// and 'startpos' must not be greater then 'endpos'.
    function newSlice(Slice memory slice, uint startpos, uint endpos) internal constant returns (Slice memory newSlice) {
        if (startpos > slice._unsafe_len || endpos > slice._unsafe_len || startpos > endpos)
            throw;
        var newLen = endpos - startpos;
        var memPtr = newLen > 0 ? slice._unsafe_memPtr + startpos : 0;
        newSlice = Slice(memPtr, endpos - startpos);
    }

    /// Same as new(Slice memory, uint, uint) but allows for negative indices.
    /// 'startpos' and 'endpos' must both be less then 'len(slice)', and larger then '-len(slice)'
    /// additionally, 'endpos' may not be smaller then 'startpos' (or 'len(slice) - pos' in the
    /// case of negative values.
    /// Warning: higher gas-cost then the function that uses usigned integers.
    function newSlice(Slice memory slice, int startpos, int endpos) internal constant returns (Slice memory newSlice) {
        uint startpos_;
        uint endpos_;
        if (startpos < 0) {
            startpos_ = uint(-startpos);
            if (startpos_ > slice._unsafe_len)
                throw;
            startpos_ = slice._unsafe_len - startpos_;
        }
        else {
            startpos_ = uint(startpos);
            if (startpos_ > slice._unsafe_len)
                throw;
        }
        if (endpos < 0) {
            endpos_ = uint(-endpos);
            if (endpos_ > slice._unsafe_len)
                throw;
            endpos_ = slice._unsafe_len - endpos_;
        }
        else {
            endpos_ = uint(endpos);
            if (endpos_ > slice._unsafe_len)
                throw;
        }
        if(startpos_ > endpos_)
            throw;
        uint newLen = endpos_ - startpos_;
        uint memPtr = newLen > 0 ? slice._unsafe_memPtr + startpos_ : 0;
        newSlice = Slice(memPtr, newLen);
    }

    // Check if two slices are equal.
    function slicesEqual(Slice memory slice1, Slice memory slice2) internal constant returns (bool) {
        return (slice1._unsafe_len == slice2._unsafe_len && slice1._unsafe_memPtr == slice2._unsafe_memPtr);
    }

    // Only sets the length to 0 and deletes the pointer.
    // A deleted slice can still be turned into bytes, but will only generate the empty bytes.
    function deleteSlice(Slice memory slice) internal constant {
        slice._unsafe_memPtr = 0;
        slice._unsafe_len = 0;
    }

}