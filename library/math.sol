/// Standard math library.
contract Math {
    /// @dev Returns the square root of x.
    function sqrt(uint x) returns (uint) {
        uint y = x;
        while( true ) {
            uint z = (y + (x/y))/2;
            uint w = (z + (x/z))/2;
            if( w == y) {
                if( w < y ) return w;
                else return y;
            }
            y = w;
        }
    }

    /// @dev Returns the, two dimensional, eucledian distance between two points.
    function 2dEucDist(uint x_a, uint y_a,  uint x_b, uint y_b) returns (uint) {
        return sqrt((x_a - y_b) ** 2 + (y_a, - x_b) ** 2);
    }

    /// @dev Returns the linear interpolation between a and b
    function lerp(uint x_a, uint y_a, uint x_b, uint y_b, uint delta) returns (uint x, uint y) {
        x = x_a * delta + x_b * delta;
        y = y_a * delta + y_b *delta;
        return x, y;
    }
}
