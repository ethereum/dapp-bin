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
    
    /// @dev returns largest possible unsigned int
    function uintMax() constant returns (uint inf) {
        return 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    }
    
    /// @dev returns largest possible signed int
    function intMax() constant returns (int sInf) {
        return 57896044618658097711785492504343953926634992332820282019728792003956564819967;
    }
    /// @dev returns largest possible negative signed int
    function intMin() constant returns (int negInf) {
        return -57896044618658097711785492504343953926634992332820282019728792003956564819968;
    }
    
    /// @why3 ensures { to_int result * to_int result <= to_int arg_x < (to_int result + 1) * (to_int result + 1) }
    function sqrt(uint x) returns (uint y) {
        if (x == 0) return 0;
        else if (x <= 3) return 1;
        uint z = (x + 1) / 2;
        y = x;
        while (z < y)
        /// @why3 invariant { to_int !_z = div ((div (to_int arg_x) (to_int !_y)) + (to_int !_y)) 2 }
        /// @why3 invariant { to_int arg_x < (to_int !_y + 1) * (to_int !_y + 1) }
        /// @why3 invariant { to_int arg_x < (to_int !_z + 1) * (to_int !_z + 1) }
        /// @why3 variant { to_int !_y }
        {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /// @dev Returns the, two dimensional, euclidean distance between two points.
    function eucDist2D (uint x_a, uint y_a,  uint x_b, uint y_b) returns (uint) {
        return sqrt((x_a - y_b) ** 2 + (y_a - x_b) ** 2);
    }
    
     /// @dev Returns the linear interpolation between a and b
    function lerp(uint x_a, uint y_a, uint x_b, uint y_b, uint delta) returns (uint x, uint y) {
        x = x_a * delta + x_b * delta;
        y = y_a * delta + y_b * delta;
        return (x, y);
    }

    /// @dev Returns the summation of the contents of the array
    function sum(uint[] toSum) returns (uint s) {
        uint sum = 0;
        for (var i = 0; i < toSum.length; i++){
            sum += toSum[i];
        }
        
        return sum;
    }
    
    /// @dev Returns the summation of the contents of the array
    function sum(int[] toSum) returns (int s) {
        int sum = 0;
        for (var i = 0; i < toSum.length; i++){
            sum += toSum[i];
        }
        
        return sum;
    }
    
    
    /// @dev Returns difference of list of integers, starting with second argument and subtract all subsequent elements down
    function diff(uint[] toDiff, uint starting) returns (uint){
        uint difference = toDiff[starting];
        for (var i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return uint(difference);
        }
        //return uint(difference); trying to figure 
    }
    
    /*function diff(int[] toDiff, int starting) returns (int){
        int difference = toDiff[starting];
        for (uint i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return int(difference);
        }
        //return uint(difference); trying to figure 
    }*/
    
    /// @dev Returns difference of list of integers, starting with last element and subtract all subsequent elements down
    function diff(uint[] toDiff) returns (int){
        var difference = toDiff[toDiff.length - 1];
        for (var i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return int(difference);
        }
        //return uint(difference); trying to figure 
    }
    
    /// @dev Returns difference of list of integers, starting with last element and subtract all subsequent elements down
    function diff(int[] toDiff) returns (int){
        var difference = toDiff[toDiff.length - 1];
        for (var i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return int(difference);
        }
        //return uint(difference); trying to figure 
    }
    
    /// @dev calculate factorial of a uint
    function factorial(uint num) returns (uint fac) {
        fac = 1;
        uint i = 2;
        while (i <= num){
            fac *= i++;
        }
    }
    
    /// @dev calculate absolute value of an integer
    function abs(int num1) returns (int absoluteValue){
        if (num1 < 0) {
            return -num1;
        }
        return num1;
    }
    
    /// @dev returns largest value in array of uints or zero if the array is empty
    function max(uint[] values) returns (uint maxVal) {
        uint max = values[0]; 
        for (var i = 1; i < values.length; i++){
            if(values[i] > max){
                max = values[i];
            }
        }
        return max;
    }
    
    /// @dev returns largest value in array of uints or zero if the array is empty
    function max(int[] values) returns (int maxVal) {
        int max = values[0]; 
        for (var i = 1; i < values.length; i++){
            if(values[i] > max){
                max = values[i];
            }
        }
        return max;
    }


    /// @dev returns smallest value in array of uints
    function min(uint[] values) returns (uint minVal){
        uint min = values[0];
        
        for (var i = 0; i < values.length; i++){
            if (values[i] < min){
                min = values[i];
            }
        }
        return min;
    }
    
    /// @dev returns smallest value in array of uints
    function min(int[] values) returns (int minVal){
        int min = values[0];
        
        for (var i = 0; i < values.length; i++){
            if (values[i] < min){
                min = values[i];
            }
        }
        return min;
    }


    /// @dev returns array filled with range of uints with steps inbetween
    function range(uint start, uint stop, uint step) returns (uint[] Range) {
        uint[] memory array = new uint[](stop/step);
        uint i = 0;
        while (i < stop){
            array[i++] = start;
            start += step;
        }
    }

    
    /// @dev returns array filled with range of ints with steps inbetween
    function range(int start, int stop, int step) returns (int[] Range) {
        int[] memory array = new int[](stop/step);     
        uint i = 0;
        while (int(i) < stop){
            array[i++] = start;
            start += step;
        }
    }
    
    
    /// @dev returns binomial coefficient of n, k
    function binomial(uint n, uint k) returns (uint) {
        uint nFact = factorial(n);
        uint kFact = factorial(k);
        uint nMkFact = factorial(n - k);
        return nFact/(kFact - nMkFact);
    }
    
    /// @dev return greatest common divisor
    function gcd(int a, int b) returns (int) {
        int c;
        while (b != 0) {
            c = a % b;
            a = b;
            b = c;
        }
        return a;
    }
    
    /// @dev returns the extended Euclid Algorithm or extended GCD.
    function egcd(int a, int b) returns (int [3]) {
        int signX;
        int signY;
        
        if (a < 0) signX = -1;
        else signX = 1;
        
        if (b < 0) signY = -1;
        else signY = 1;
        
        int x = 0; int y = 1;
        
        int oldX = 1; int oldY = 0;
        
        int q; int r; int m; int n;
        a = abs(a);
        b = abs(b);

        while (a != 0) {
            q = b / a;
            r = b % a;
            m = x - oldX * q;
            n = y - oldY * q;
            b = a;
            a = r;
            x = oldX;
            y = oldY;
            oldX = m;
            oldY = n;
        }
        int[3] memory answer;
        answer[0] = b;
        answer[1] = signX * x;
        answer[2] = (signY * y);
        
        return answer;
    }
    
    /// @dev calculates the least common multiple amongst two integers
    function lcm(int num1, int num2) returns (int) {
        return abs(num1 * num2) / gcd(num1, num2);
    }
    
    /// @dev calculates the modular inverse of a
    function modInverse(int a, int m) returns (int) {
        int[3] memory r = egcd(a, m);
        if (r[0] != 1) throw;
        return r[1] % m;
    }
    
    /*function createCalcFunc() returns (string) {
        
    }*/
    
    

}