library Math {
    
        
    /// @dev Computes the modular exponential (x ** k) % m.
    function modExp(uint x, uint k, uint m) returns (uint r) {
        r = 1;
        for (uint s = 1; s <= k; s *= 2) {
            if (k & s != 0)
                r = mulmod(r, x, m);
            x = mulmod(x, x, m);
        }
    }
    
    /// @dev unsigned constant infinity (largest number possible)
    function Infinity() constant returns (uint inf) {
        return 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    }
    
    /// @dev unsigned constant infinity (largest number possible)
    function posInfinity() constant returns (int sInf) {
        return 57896044618658097711785492504343953926634992332820282019728792003956564819967;
    }
    /// @dev signed constant negative infinity (largest possible negative number)
    function negInfinity() constant returns (int negInf) {
        return -57896044618658097711785492504343953926634992332820282019728792003956564819968;
    }
    
    /// @dev Computes the square root of x
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
    function EucDist2D (uint x_a, uint y_a,  uint x_b, uint y_b) returns (uint) {
        return sqrt((x_a - y_b) ** 2 + (y_a - x_b) ** 2);
    }
    
     /// @dev Returns the linear interpolation between a and b
    function interpolate(uint x_a, uint y_a, uint x_b, uint y_b, uint delta) returns (uint x, uint y) {
        x = x_a * delta + x_b * delta;
        y = y_a * delta + y_b * delta;
        return (x, y);
    }

    /// @dev Returns the summation of the contents of the array
    function sum(uint[] toSum) returns (uint s) {
        uint sum = 0;
        for (uint i = 0; i < toSum.length; i++){
            sum += toSum[i];
        }
        
        return sum;
    }
    
    
    /// @dev Returns difference of list of integers, starting with second argument and subtract all subsequent elements down
    function diff(uint[] toDiff, uint starting) returns (int){
        var difference = toDiff[starting];
        for (uint i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return int(difference);
        }
        //return uint(difference); trying to figure 
    }
    
    /// @dev Returns difference of list of integers, starting with last element and subtract all subsequent elements down
    function diff(uint[] toDiff) returns (int){
        var difference = toDiff[toDiff.length];
        for (uint i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return int(difference);
        }
        //return uint(difference); trying to figure 
    }
    
    /// @dev calculate factorial of a uint
    function factor(uint num) returns (uint) {
        uint o = 1;
        uint i = 2;
        while (i <= num){
            o *= i++;
        }
        
        return o;
    }
    
    /// @dev calculate absolute value of an integer
    function abs(int num1) returns (int absoluteValue){
        var n1 = num1;
        if (n1 < 0) {
            return n1 * -1;
        }
        return n1;
    }
    
    /// @dev returns largest value in array of uints
    function max(uint[] values) returns (uint maxVal) {
        uint max = values[0]; 
        for (uint i = 1; i < values.length; i++){
            if(values[i] > max){
                max = values[i];
            }
        }
        return max;
    }


    /// @dev returns smallest value in array of uints
    function min(uint[] values) returns (uint minVal){
        uint min = values[0];
        
        for (uint i = 0; i < values.length; i++){
            if (values[i] < min){
                min = values[i];
            }
        }
        return min;
    }

    /// @dev returns array filled with range of uints with steps inbetween
    function range(uint start, uint stop, uint step) returns (uint[] Range) {
        uint[] memory array;
        uint i = 0;
        while (i < stop){
            array[i++] = start;
            start += step;
        }
    }
    
    /// @dev returns array filled with range of uints
    function range(uint start, uint stop) returns (uint[] Range) {
        uint[] memory array;
        uint i = 0;
        while (i < stop){
            array[i++] = start;
            start += 1;
        }
    }
    
    /// @dev returns array filled with range of ints with steps inbetween
    function range(int start, int stop, int step) returns (int[] Range) {
        int[] memory array;
        uint i = 0;
        while (int(i) < stop){
            array[i++] = start;
            start += step;
        }
    }
    
    /// @dev returns array filled with range of ints
    function range(int start, int stop) returns (int[] Range) {
        int[] memory array;
        uint i = 0;
        while (int(i) < stop){
            array[i] = start;
            start += 1;
        }
    }

}
