from ethereum import tester as t
import sys
def log_listener(x):
    if x['_event_type'] == 'BlockMixInput':
        bminputs.append(x['data'])
        print len(bminputs), x
    else:
        print x
s = t.state()
bminputs = []
print 'Creating contract'
c = s.abi_contract('scrypt.se.py', log_listener=log_listener)
print 'Computing hash and getting blockmix inputs'
o = '\x00' * 32
i = 0
while o == '\x00' * 32:
    o = c.scrypt("cow")
    i += 1
    print '%d transactions sent' % i
print 'Checking result correctness'
assert o == "1c989eff71803fb4c9b3e47e611330da1a7d153d2ab5f6bef57dc3253d51cc52".decode('hex'), o.encode('hex')
print 'Success'
