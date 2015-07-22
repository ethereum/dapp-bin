/// @dev Models a uint -> uint mapping where it is possible to iterate over all keys.
struct itmap
{
  struct IndexValue { uint keyIndex; uint value; }
  struct KeyFlag { uint key; bool deleted; }
  struct KeyValue { uint key; uint value; }

  mapping(uint => IndexValue) data;
  KeyFlag[] keys;
  uint size;
}
library itmap_impl
{
  function insert(itmap storage self, uint key, uint value) returns (bool replaced)
  {
    uint keyIndex = self.data[key].keyIndex;
    self.data[key].value = value;
    if (keyIndex > 0)
      return true;
    else
    {
      keyIndex = keys.length++;
      self.data[key].keyIndex = keyIndex + 1;
      self.keys[keyIndex].key = key;
      self.size++;
      return false;
    }
  }
  function remove(itmap storage self, uint key) returns (bool success)
  {
    uint keyIndex = self.data[key].keyIndex;
    if (keyIndex == 0)
      return false;
    delete self.data[key];
    self.keys[keyIndex - 1].deleted = true;
    self.size --;
  }
  function contains(itmap storage self, uint key)
  {
    return self.data[key].keyIndex > 0;
  }
  function iterate_start(itmap storage self) returns (uint keyIndex)
  {
    return iterate_next(self, -1);
  }
  function iterate_valid(itmap storage self, uint keyIndex) returns (bool)
  {
    return keyIndex < self.keys.length;
  }
  function iterate_next(itmap storage self, uint keyIndex) returns (uint r_keyIndex)
  {
    keyIndex++;
    while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
      keyIndex++;
    return keyIndex;
  }
  function iterate_get(itmap storage self, uint keyIndex) returns (KeyValue r)
  {
    r.key = self.keys[keyIndex].key;
    r.value = self.data[key];
  }
}

/// How to use it:
contract User
{
  /// Just a struct holding our data.
  itmap data;
  /// Tell the compiler to bind all functions from itmap_impl to all instances of itmap.
  using itamp_impl for itmap;
  /// Insert something
  function insert(uint k, uint v) returns (uint size)
  {
    /// Actually calls itmap_impl.insert, auto-supplying the first parameter for us.
    data.insert(k, v);
    /// We can still access members of the struct - but we should take care not to mess with them.
    return data.size;
  }
  /// Computes the sum of all stored data.
  function sum() returns (uint)
  {
    uint s;
    for (var i = data.iterate_start(); data.iterate_valid(i); i = data.iterate_next(i))
      s += data.iterate_get(i).value;
  }
}
