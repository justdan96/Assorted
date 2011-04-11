#!/usr/bin/env python
"""

MD5 Crypt salted MD5 implementation in Python.

Almost all of the code is from Mark Johnston's Python port of md5crypt.
Available here: http://code.activestate.com/recipes/325204/

def Main() code based off Didier Stevens' shellcode2vbscript.py
Available here: http://blog.didierstevens.com/2009/05/06/shellcode-2-vbscript/

"""

__author__ = 'Dan Bryant'
__version__ = '0.0.2'
__date__ = '2009/06/07'

import optparse
import md5

def md5crypt(password, salt, magic='$1$'):
    # /* The password first, since that is what is most unknown */ /* Then our magic string */ /* Then the raw salt */
    m = md5.new()
    m.update(password + magic + salt)

    # /* Then just as many characters of the MD5(pw,salt,pw) */
    mixin = md5.md5(password + salt + password).digest()
    for i in range(0, len(password)):
        m.update(mixin[i % 16])

    # /* Then something really weird... */
    # Also really broken, as far as I can tell.  -m
    i = len(password)
    while i:
        if i & 1:
            m.update('\x00')
        else:
            m.update(password[0])
        i >>= 1

    final = m.digest()

    # /* and now, just to make sure things don't run too fast */
    for i in range(1000):
        m2 = md5.md5()
        if i & 1:
            m2.update(password)
        else:
            m2.update(final)

        if i % 3:
            m2.update(salt)

        if i % 7:
            m2.update(password)

        if i & 1:
            m2.update(final)
        else:
            m2.update(password)

        final = m2.digest()

    # This is the bit that uses to64() in the original code.

    itoa64 = './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

    rearranged = ''
    for a, b, c in ((0, 6, 12), (1, 7, 13), (2, 8, 14), (3, 9, 15), (4, 10, 5)):
        v = ord(final[a]) << 16 | ord(final[b]) << 8 | ord(final[c])
        for i in range(4):
            rearranged += itoa64[v & 0x3f]; v >>= 6

    v = ord(final[11])
    for i in range(2):
        rearranged += itoa64[v & 0x3f]; v >>= 6

    return magic + salt + '$' + rearranged



def Main():
    oParser = optparse.OptionParser(usage='usage: %prog [options]', version='%prog ' + __version__)
    oParser.add_option('-s', '--salt', default='', help='the template file')
    oParser.add_option('-k', '--key', default='', help='the credentials file')
    (options, args) = oParser.parse_args()

    if len(args) == 0:
        if options.key != '' and options.salt != '':
            print md5crypt(options.key, options.salt)
        else:
            print '//PixCreate'
            print '//Version = ' + __version__
            print '//PixCreate will attempt to create a Cisco IOS salted MD5 hash from user input.'
            print ''
            oParser.print_help()        
    else:
        oParser.print_help()
        print 'Incorrect arguments supplied'

    return

if __name__ == '__main__':
    Main()
