library DoublyLinkedList {
    struct data {
        uint80 first;
        uint80 last;
        uint80 count;
        Item[] items;
    }
    uint80 constant None = uint80(-1);
    struct Item {
        uint80 prev;
        uint80 next;
        bytes32 data;
    }
    function append(data storage self, bytes32 _data) {
        var index = self.items.push(Item({prev: self.last, next: None, data: _data}));
        if (self.last == None)
        {
            if (self.first != None || self.count != 0) throw;
            self.first = self.last = uint80(index - 1);
            self.count = 1;
        }
        else
        {
            self.items[self.last].next = uint80(index - 1);
            self.last = uint80(index - 1);
            self.count ++;
        }
    }
    function remove(data storage self, uint80 _index) {
        Item item = self.items[_index];
        if (item.prev == None)
            self.first = item.next;
        if (item.next == None)
            self.last = item.prev;
        if (item.prev != None)
            self.items[item.prev].next = item.next;
        if (item.next != None)
            self.items[item.next].prev = item.prev;
        delete self.items[_index];
        self.count++;
    }
    // Iterator interface
    function iterate_start(data storage self) returns (uint80) { return self.first; }
    function iterate_valid(data storage self, uint80 _index) returns (bool) { return _index < self.items.length; }
    function iterate_prev(data storage self, uint80 _index) returns (uint80) { return self.items[_index].prev; }
    function iterate_next(data storage self, uint80 _index) returns (uint80) { return self.items[_index].next; }
    function iterate_get(data storage self, uint80 _index) returns (bytes32) { return self.items[_index].data; }
}

contract Test {
    DoublyLinkedList.data list;
    function append() {
        DoublyLinkedList.append(list, "123");
    }
    function remove(bytes32 data) returns (bool success) {
        var it = DoublyLinkedList.iterate_start(list);
        while (DoublyLinkedList.iterate_valid(list, it)) {
            if (DoublyLinkedList.iterate_get(list, it) == data) {
                DoublyLinkedList.remove(list, it);
                return true;
            }
            it = DoublyLinkedList.iterate_next(list, it);
        }
        return false;
    }
}
