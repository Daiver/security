import cv2
import numpy as np
import scipy
import rs

def bin2(char):
    b = bin(char)[2:]
    return ('0' * (8 - len(b))) + b

def toBits(s)   : return ''.join(map(bin2, toBytes(s)))
def toBytes(s)  : return map(ord, s)
def toBytes2(s) : return [int(s[i*8 : 8*i + 8], 2) for i in xrange(len(s)/8)]
def toChars(s)  : return map(chr, s)

def encode(img, bitstr):
    img = img.copy()
    lmbd = 0.1

    for i, bt in enumerate(bitstr):
        pixel_to_decode_idx = i * 2
        px = pixel_to_decode_idx / img.shape[1] + 20
        py = pixel_to_decode_idx % img.shape[1] 
        pix = img[px, py]
        Y = 0.3 * pix[2] + 0.59 * pix[1] + 0.11 * pix[0]
        B = (pix[0] + lmbd * Y) if bt == '1' else (pix[0] - lmbd * Y)
        #print B, pix[0]
        pix[0] = round(B)
        img[px, py] = pix
    return img

def decode(img, ln):
    omega = 2
    res = ''
    for i in xrange(ln):
        pixel_to_decode_idx =  i * 2
        px = pixel_to_decode_idx / img.shape[1] + 20
        py = pixel_to_decode_idx % img.shape[1] 
        pix = img[px, py]
        '''avg = float(sum( [img[px + x, py, 0] for x in xrange(-omega, omega + 1)]) + \
            sum( [img[px, py + x, 0] for x in xrange(-omega, omega + 1)]))
        avg /= 4 * omega'''
        avg = np.mean(img[px - omega:px + omega, py - omega:py + omega, 0])
        #print pix[0], avg
        if avg > pix[0]: 
            res += '0'
        else:
            res += '1'
    return res

def bigRSDecode(s):
    coder = rs.RSCoder(200, 100)
    blocks = [s[i*100: i*100 + 100] for i in xrange(len(s)/100)]
    return ''.join(map(coder.decode, blocks))

def bigRSEncode(s):
    coder = rs.RSCoder(200, 100)
    blocks = [s[i*100: i*100 + 100] for i in xrange(len(s)/100)]
    return ''.join(map(coder.encode, blocks))

if __name__ == '__main__':
    s_orig = 'some secret message (='#open('data').read().encode('ascii')#'ham Hi :)finally i completed the course:)'
    s_orig = 'RVANII POLET SOHRANYAET BABOCHKU KAK VID'#open('data').read().encode('ascii')#'ham Hi :)finally i completed the course:)'
    #s_orig = s_orig[:len(s_orig) - (len(s_orig) % 200)]
    #print bigRSEncode(s_orig)
    print len(s_orig), len(toBits(s_orig))
    coder = rs.RSCoder(len(s_orig) * 2,len(s_orig))
    s = coder.encode(s_orig)
    print s_orig
    print s

    img = cv2.imread('src.bmp')
    img2 = encode(img, toBits(s))
    #cv2.imshow('1', img)
    #cv2.imshow('2', img2)
    #cv2.waitKey()

    diff = img - img2
    print np.mean(diff), np.std(diff)
    print np.mean(img), np.std(img)
    print np.mean(img2), np.std(img2)
    img = img[:,:,0]
    img2 = img2[:,:,0]
    h1, p1 = np.histogram(img, 255, [0, 255])
    h2, p2 = np.histogram(img2, 255, [0, 255])
    #h2, p2 = np.histogram(img2)
    print 'h1'
    print h1
    print 'h2'
    print h2
    print 'diff'
    print h1 - h2
    print np.mean(h1)
    print np.mean(h2)
    print np.std(h1)
    print np.std(h2)
    print len(h1), len(h2)

    #print toBits(s)
    '''print toBytes(s)
    print toBytes2(toBits(s))
    print toChars(toBytes2(toBits(s)))
    print toChars(toBytes(s))'''

    d = decode(img2, len(toBits(s)))
    #print d
    #print ''.join(toChars(toBytes2(d)))
    d2 = coder.decode(''.join(toChars(toBytes2(d))))
    #print d2
    #print d2 == s_orig
