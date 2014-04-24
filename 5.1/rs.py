import cv2
import numpy as np

flip1_table1 = {x:x+1 for x in xrange(0, 255, 2)}
flip1_table2 = {v: k for k, v in flip1_table1.iteritems()}

flip2_table2 = {k - 1: v - 1 for k, v in flip1_table1.iteritems()}
flip2_table1 = {v: k for k, v in flip2_table2.iteritems()}

def flip_one(b, t1, t2):
    if b % 2 == 0:
        return t1[b]
    return t2[b]

def flip1(b):return flip_one(b, flip1_table1, flip1_table2)
def flipn1(b):return flip_one(b, flip2_table1, flip2_table2)


def flip(block, f):return map(lambda b:map(f, b), block)

def fit_f(block):
    return np.std(block)

def madeBlocks(img):
    blockSize = 8
    res = []
    for i in xrange(0, img.shape[0], blockSize):
        for j in xrange(0, img.shape[1], blockSize):
            tile = img[i:i+blockSize,j:j+blockSize]
            res.append(tile)
    return res

def compute(img, fl):
    reg = 0
    sin = 0
    const = 0
    for b in madeBlocks(img):
        fited, flip_fited =  fit_f(b) , fit_f(flip(b, fl))
        if flip_fited  > fited: reg += 1
        if flip_fited  < fited: sin += 1
        if flip_fited == fited: const += 1
    return reg, sin, const


if __name__ == '__main__':
    print '1'
    img  = cv2.imread('../5/0009.bmp', 0)
    img2 = cv2.imread('../5/0010.bmp', 0)
    print compute(img, flip1), compute(img, flipn1)
    print compute(img2, flip1), compute(img2, flipn1)
    '''    #print '1', fit_f(i), fit_f(flip(i, flipn1))
        y =  '2', fit_f(i2), fit_f(flip(i2, flip1))
        #print '2', fit_f(i2), fit_f(flip(i2, flipn1))
        print x[2]

    '''
    #for k, v in flip2_table1.iteritems():  print k, v
    #for k, v in flip2_table2.iteritems():  print k, v
