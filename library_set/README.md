# AddressSet

Simple address-set library with docs and tests. Based on the library/iterable_map. Uses many of the newer features such as tuples and library to type bindings.

Iterating is possible by getting the size of the set then just call 'valueFromIndex' to get each value inside a loop. The entire set can be gotten only through an external call, as the set is backed by a dynamically sized array. That's a general (VM) issue btw, not specific to this library.

### Test

The simplest thing is to just run the test contract in browser-solidity. 

1. Copy in the AddressSet library code first, then the two contracts in the test file.

2. Click 'create' at the AddressSetTest contract in the side bar.

3. Click each function. The return values should be true - but it's a bit difficult to see since they're all packed into one massive byte array. Should see some strategically placed 1's in there though. :D

Tests serves as usage examples as well.

