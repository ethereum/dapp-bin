data smix_intermediates[2**160](pos, stored[1024][4], state[8])

event TestLog6(h:bytes32)

macro blockmix($_inp):
    with inp = $_inp:
        with X = string(64):
            mcopy(X, inp + 64, 64)

            X[0] = ~xor(X[0], inp[0])
            X[1] = ~xor(X[1], inp[1])
            log(type=TestLog, 1, msg.gas)
            X = salsa20(X)
            log(type=TestLog, 2, msg.gas)
            inp[4] = X[0]
            inp[5] = X[1]

            X[0] = ~xor(X[0], inp[2])
            X[1] = ~xor(X[1], inp[3])
            X = salsa20(X)
            inp[6] = X[0]
            inp[7] = X[1]

            inp[0] = inp[4]
            inp[1] = inp[5]
            inp[2] = inp[6]
            inp[3] = inp[7]
            inp

macro endianflip($x):
    with $y = string(len($x)):
        with $i = 0:
            with $L = len($y):
                while $i < $L:
                    with $d = mload($x - 28 + $i):
                        mcopylast4($y + $i - 28, byte(31, $d) * 2**24 + byte(30, $d) * 2**16 + byte(29, $d) * 2**8 + byte(28, $d))
                        $i += 4
        $y

macro mcopylast4($to, $frm):
    ~mstore($to, (~mload($to) & sub(0, 2**32)) + ($frm & 0xffffffff))

roundz = text("\x04\x00\x0c\x07\x08\x04\x00\x09\x0c\x08\x04\x0d\x00\x0c\x08\x12\x09\x05\x01\x07\x0d\x09\x05\x09\x01\x0d\x09\x0d\x05\x01\x0d\x12\x0e\x0a\x06\x07\x02\x0e\x0a\x09\x06\x02\x0e\x0d\x0a\x06\x02\x12\x03\x0f\x0b\x07\x07\x03\x0f\x09\x0b\x07\x03\x0d\x0f\x0b\x07\x12\x01\x00\x03\x07\x02\x01\x00\x09\x03\x02\x01\x0d\x00\x03\x02\x12\x06\x05\x04\x07\x07\x06\x05\x09\x04\x07\x06\x0d\x05\x04\x07\x12\x0b\x0a\x09\x07\x08\x0b\x0a\x09\x09\x08\x0b\x0d\x0a\x09\x08\x12\x0c\x0f\x0e\x07\x0d\x0c\x0f\x09\x0e\x0d\x0c\x0d\x0f\x0e\x0d\x12")

macro salsa20($x):
    with b = string(64):
        b[0] = $x[0]
        b[1] = $x[1]
        b = endianflip(b)
        with x = string(64):
            x[0] = b[0]
            x[1] = b[1]
            with i = 0:
                with refpos = roundz:
                    while i < 4:
                        with destination = x + (~mload(refpos - 31) & 255) * 4 - 28:
                            with bb = ~mload(refpos - 28) & 255:
                                with a = (mload(x + (~mload(refpos-30) & 255) * 4 - 28) + mload(x + (~mload(refpos-29) & 255) * 4 - 28)) & 0xffffffff:
                                    with oldval = mload(destination):
                                        mcopylast4(destination, ~xor(oldval, ~or(a * 2**bb, a / 2**(32 - bb))))
                        refpos += 4
                        if refpos == roundz + 128:
                            i += 1
                            refpos = roundz
                i = 0
                while i < 64:
                    oldval = mload(b + i - 28) & 0xffffffff
                    newval = (oldval + mload(x + i - 28)) & 0xffffffff
                    mcopylast4(b + i - 28, newval)
                    i += 4
            endianflip(b)
    

event TestLog(a:uint256, b:uint256)
event TestLog2(a:str)
event TestLog3(a:str, x:uint256)
event TestLog4(a:str, x:uint256, y:uint256)
event TestLog5(x:uint256, v1:bytes32, v2:bytes32, v3:bytes32, v4:bytes32)

def smix(b:str):
    with h = mod(sha3(b:str), 2**160):
        with x = string(256):
            mcopy(x, b, 128)
            with i = self.smix_intermediates[h].pos:
                    k = 0
                    while k < if(i > 0, 8, 0):
                        x[k] = self.smix_intermediates[h].state[k]
                        k += 1
                    while i < 2048 and msg.gas > 450000:
                        if i < 1024:
                            self.smix_intermediates[h].stored[i][0] = x[0]
                            self.smix_intermediates[h].stored[i][1] = x[1]
                            self.smix_intermediates[h].stored[i][2] = x[2]
                            self.smix_intermediates[h].stored[i][3] = x[3]
                            x = blockmix(x)
                            # if i == 1023:
                            #     log(type=TestLog2, x)
                        else:
                            j = div(x[2], 256**31) + (div(x[2], 256**30) & 3) * 256
                            x[0] = ~xor(x[0], self.smix_intermediates[h].stored[j][0])
                            x[1] = ~xor(x[1], self.smix_intermediates[h].stored[j][1])
                            x[2] = ~xor(x[2], self.smix_intermediates[h].stored[j][2])
                            x[3] = ~xor(x[3], self.smix_intermediates[h].stored[j][3])
                            x = blockmix(x)
                        i += 1
                    k = 0
                    while k < 8:
                        self.smix_intermediates[h].state[k] = x[k]
                        k += 1
                    self.smix_intermediates[h].pos = i
                    # log(type=TestLog2, x)
                    if i == 2048:
                        with b = string(128):
                            mcopy(b, x, 128)
                            return(b:str)
                    else:
                        return(text(""):str)

event BlockMixInput(data:str)

def scrypt(pass:str): #implied: pass=salt, n=1024, r=1, p=1, dklen=32
    b = self.pbkdf2(pass, pass, 128, outchars=128)
    b = self.smix(b, outchars=128)
    if not len(b):
        return(0:bytes32)
    o = self.pbkdf2(pass, b, 32, outchars=32)
    return(o[0]:bytes32)

macro hmac_sha256($_key, $message): #implied: c=1, hash=sha256
    with key = $_key:
        if len(key) > 64:
            key = [sha256(key:str)]
            key[-1] = 32
        if len(key) < 64:
            with _o = string(64):
                mcopy(_o, key, len(key))
                key = _o
        with o_key_pad_left = ~xor(0x5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c, key[0]):
            with o_key_pad_right = ~xor(0x5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c, key[1]):
                with padded_msg = string(len($message) + 64):
                    padded_msg[0] = ~xor(0x3636363636363636363636363636363636363636363636363636363636363636, key[0])
                    padded_msg[1] = ~xor(0x3636363636363636363636363636363636363636363636363636363636363636, key[1])
                    mcopy(padded_msg + 64, $message, len($message))
                    sha256([o_key_pad_left, o_key_pad_right, sha256(padded_msg:str)]:arr)

def hmac_sha256(key:str, msg:str):
    return(hmac_sha256(key, msg):bytes32)

def pbkdf2(pass:str, salt:str, dklen): #implied: c=1, hash=sha256
    o = string(dklen)
    i = 0
    while i * 32 < len(o):
        o[i] = chain_prf(pass, salt, i + 1)
        i += 1
    return(o:str)

macro chain_prf($pass, $salt, $i):
    with ext_salt = string(len($salt) + 4):
        $j = $i
        mcopy(ext_salt, $salt, len($salt))
        mcopy(ext_salt + len($salt), ref($j) + 28, 4)
        hmac_sha256($pass, ext_salt)
