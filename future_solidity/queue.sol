/// @title implements a ring buffer
/// @dev some unimplemented features (templated structs and exceptions)
/// of the compiler are only used in comments.
// struct queue[Value,Capacity]
contract queue
{
    uint/*Value*/[2**64/*Capacity*/] q;
    uint front = 0;
    uint back = 0;
    /// @dev the number of elements stored in the queue.
    function length() constant returns (uint) { return back - front; }
    /// @dev the number of elements this queue can hold
    /// @invariant capacity() < length()
    function capacity() constant returns (uint) { return q.length - 1; }
    /// @dev push a new element to the back of the queue
    /// @precondition length() < capacity() - 1
    function push(uint /*Value*/ data)
    {
        if ((back + 1) % q.length == front)
            return; // throw;
        q[back] = data;
        back = (back + 1) % q.length;
    }
    /// @dev remove and return the element at the front of the queue
    /// @precondition length() > 0
    function pop() returns (uint /* Value */ r)
    {
        if (back == front)
            return; // throw;
        r = q[front];
        delete q[front];
        front = (front + 1) % q.length;
    }
}
