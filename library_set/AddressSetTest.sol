contract AddressSetWrapper {

    using AddressSet for AddressSet.Set;

    AddressSet.Set _set;

    function addAddress(address addr) returns (bool had) {
        return _set.insert(addr);
    }

    function removeAddress(address addr) returns (bool removed) {
        return _set.remove(addr);
    }

    function removeAllAddresses() returns (uint numRemoved) {
        return _set.removeAll();
    }

    function hasAddress(address addr) constant returns (bool has) {
        return _set.hasValue(addr);
    }

    function getAddressFromIndex(uint index) constant returns (address addr, bool has) {
        return _set.valueFromIndex(index);
    }

    function getAddressKeyIndex(address addr) constant returns (uint index, bool exists) {
        return _set.valueIndex(addr);
    }

    function numAddresses() constant returns (uint setSize) {
        return _set.size();
    }
}

contract AddressSetTest {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;
    address constant TEST_ADDRESS_3 = 0xC0FFEE;

    function testInsert() returns (bool has, bool atIndex0){
        AddressSetWrapper asw = new AddressSetWrapper();
        asw.addAddress(TEST_ADDRESS);
        has = asw.hasAddress(TEST_ADDRESS);
        var (a, e) = asw.getAddressFromIndex(0);
        atIndex0 = e && a == TEST_ADDRESS;
        return;
    }

    function testRemoveAddress() returns (bool removed, bool atIndex0IsNil, bool numAddressesIsNil){
        AddressSetWrapper asw = new AddressSetWrapper();
        asw.addAddress(TEST_ADDRESS);
        asw.removeAddress(TEST_ADDRESS);
        removed = !asw.hasAddress(TEST_ADDRESS);
        var (a, e) = asw.getAddressFromIndex(0);
        atIndex0IsNil = !e;
        numAddressesIsNil = (asw.numAddresses() == 0);
    }

    function testAddTwoAddresses() returns (bool hasFirst, bool hasSecond, bool firstIsCorrect, bool secondIsCorrect, bool sizeIsCorrect){
        AddressSetWrapper asw = new AddressSetWrapper();
        asw.addAddress(TEST_ADDRESS);
        asw.addAddress(TEST_ADDRESS_2);
        hasFirst = asw.hasAddress(TEST_ADDRESS);
        hasSecond = asw.hasAddress(TEST_ADDRESS_2);
        var (a, e) = asw.getAddressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS;
        (a, e) = asw.getAddressFromIndex(1);
        secondIsCorrect = e && a == TEST_ADDRESS_2;

        sizeIsCorrect = asw.numAddresses() == 2;
    }

    function testAddTwoAddressesRemoveLast() returns (bool hasFirst, bool secondRemoved, bool firstIsCorrect,
                bool secondIsCorrect, bool sizeIsCorrect){
        AddressSetWrapper asw = new AddressSetWrapper();
        asw.addAddress(TEST_ADDRESS);
        asw.addAddress(TEST_ADDRESS_2);
        asw.removeAddress(TEST_ADDRESS_2);

        hasFirst = asw.hasAddress(TEST_ADDRESS);
        secondRemoved = !asw.hasAddress(TEST_ADDRESS_2);

        var (a, e) = asw.getAddressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS;
        (a, e) = asw.getAddressFromIndex(1);
        secondIsCorrect = !e && a == 0;
        sizeIsCorrect = asw.numAddresses() == 1;
    }

    function testAddTwoAddressesRemoveFirst() returns (bool firstRemoved, bool hasSecond, bool firstIsCorrect,
                bool secondIsCorrect, bool sizeIsCorrect){
        AddressSetWrapper asw = new AddressSetWrapper();
        asw.addAddress(TEST_ADDRESS);
        asw.addAddress(TEST_ADDRESS_2);
        asw.removeAddress(TEST_ADDRESS);

        firstRemoved = !asw.hasAddress(TEST_ADDRESS);
        hasSecond = asw.hasAddress(TEST_ADDRESS_2);

        var (a, e) = asw.getAddressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS_2;
        (a, e) = asw.getAddressFromIndex(1);
        secondIsCorrect = !e && a == 0;
        sizeIsCorrect = asw.numAddresses() == 1;
    }

    function testAddThreeAddressesRemoveMiddle() returns (bool hasFirst, bool secondRemoved, bool hasThird,
                bool firstIsCorrect, bool secondIsCorrect, bool sizeIsCorrect){
        AddressSetWrapper asw = new AddressSetWrapper();
        asw.addAddress(TEST_ADDRESS);
        asw.addAddress(TEST_ADDRESS_2);
        asw.addAddress(TEST_ADDRESS_3);
        asw.removeAddress(TEST_ADDRESS_2);

        hasFirst = asw.hasAddress(TEST_ADDRESS);
        secondRemoved = !asw.hasAddress(TEST_ADDRESS_2);
        hasThird = asw.hasAddress(TEST_ADDRESS_3);

        var (a, e) = asw.getAddressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS;
        (a, e) = asw.getAddressFromIndex(1);
        secondIsCorrect = e && a == TEST_ADDRESS_3;
        sizeIsCorrect = asw.numAddresses() == 2;
    }

    function testRemoveAllAddresses() returns (bool firstRemoved, bool secondRemoved, bool thirdRemoved,
                bool sizeIsNil){
        AddressSetWrapper asw = new AddressSetWrapper();
        asw.addAddress(TEST_ADDRESS);
        asw.addAddress(TEST_ADDRESS_2);
        asw.addAddress(TEST_ADDRESS_3);
        asw.removeAllAddresses();

        firstRemoved = !asw.hasAddress(TEST_ADDRESS);
        secondRemoved = !asw.hasAddress(TEST_ADDRESS_2);
        thirdRemoved = !asw.hasAddress(TEST_ADDRESS_3);

        sizeIsNil = asw.numAddresses() == 0;
    }

    // Can't test AddressSet.values since it returns a dynamically sized array.

}
