// Templated struct datatype.
struct Heap[T] {
    T[] data;
}

// Templated library implementing functions for the struct.
library MinHeap_impl[T] {
  // using Heap[T] = T[]; ?
  function insert(Heap[T] storage _heap, T _value)
  {
    _heap.data.length++;
    for (
      uint _index = _heap.data.length - 1;
      _index > 0 && _value < _heap.data[_index / 2];
      _index /= 2)
    {
      _heap.data[_index] = _heap.data[_index / 2];
    }
    _heap.data[_index] = _value;
  }
  function top(Heap[T] storage _heap) returns (T)
  {
    return _heap.data[0];
  }
  function pop(Heap[T] storage _heap)
  {
    T storage last = _heap.data[_heap.data.length - 1];
    for (
      uint index = 0;
      2 * index < _heap.data.length
      ;)
    {
      uint nextIndex = 2 * index;
      if (2 * index + 1 < _heap.data.length && _heap.data[2 * index + 1] < _heap.data[2 * index])
        nextIndex = 2 * index + 1;
      if (_heap.data[nextIndex] < last)
        _heap.data[index] = _heap.data[nextIndex];
      else
        break;
      index = nextIndex;
    }
    _heap.data[index] = last;
    _heap.data.length--;
  }
}


// Use in your contract:

contract MyContractUsingHeap {
  // Binds all functions from MinHeap_impl[uint] to Heap[uint].
  using MinHeap_impl[uint] for Heap[uint];
  Heap[uint] m_heap;
  function addSomething(uint val) {
    // This will use CALLCODE to invoke a contract that
    // is deployed only once and can be re-used by all
    // other contracts.
    m_heap.insert(val);
  }
}

