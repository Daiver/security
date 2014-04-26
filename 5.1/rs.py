import cv2
import numpy as np

flip1_table1 = {x:x+1 for x in xrange(0, 256, 2)}
flip1_table2 = {v: k for k, v in flip1_table1.iteritems()}

flip2_table2 = {k - 1: v - 1 for k, v in flip1_table1.iteritems()}
flip2_table1 = {v: k for k, v in flip2_table2.iteritems()}
flip2_table1[255] = 256
flip2_table2[255] = 256

def flip_one(b, t1, t2):
    if b % 2 == 0:
        return t1[b]
    if  b not in t2: print 'b', b
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
    #img  = cv2.imread('../5/0009.bmp', 0)
    #img2 = cv2.imread('../5/0010.bmp', 0)
    #(4018, 1861, 265) (4057, 1826, 261)
    img  = cv2.imread('/home/daiver/sec_images/images/sailboat_at_anchor_2.jpg', 0) 
    #(4008, 1907, 229) (4069, 1843, 232)
    img2 = cv2.imread('/home/daiver/sec_images/images/sailboat_at_anchor_1.jpg', 0)

    #(16757, 13227, 16) (17644, 12332, 24)
    img = cv2.imread('/home/daiver/sec_images/images/image_002.jpg', 0)
    #(17637, 12348, 15) (17469, 12505, 26)
    img2 = cv2.imread('/home/daiver/sec_images/images/image_003.jpg', 0)

    #(17781, 12191, 28) (17661, 12315, 24)
    img = cv2.imread('/home/daiver/sec_images/images/image_004.jpg', 0)
    #(17420, 12561, 19) (17426, 12555, 19)
    img2 = cv2.imread('/home/daiver/sec_images/images/image_005.jpg', 0)

    #(16818, 13166, 16) (17589, 12393, 18)
    img = cv2.imread('/home/daiver/sec_images/images/image_006.jpg', 0)
    #(17153, 12824, 23) (17472, 12504, 24)
    img2 = cv2.imread('/home/daiver/sec_images/images/image_007.jpg', 0)


    #(3175, 913, 8) (3121, 968, 7)
    img = cv2.imread('/home/daiver/sec_images/images/Lena_1.jpg', 0)
    #(3129, 961, 6) (3125, 959, 12)
    img2 = cv2.imread('/home/daiver/sec_images/images/Lena_2.jpg', 0)
    
    img  = cv2.imread('/home/daiver/sec_images/images2/0009.bmp', 0)
    img2 = cv2.imread('/home/daiver/sec_images/images2/0010.bmp', 0)

    #cv2.imshow('1', img)
    #cv2.imshow('2', img2)
    print compute(img, flip1), compute(img, flipn1)
    print compute(img2, flip1), compute(img2, flipn1)
    cv2.waitKey()
    '''    #print '1', fit_f(i), fit_f(flip(i, flipn1))
        y =  '2', fit_f(i2), fit_f(flip(i2, flip1))
        #print '2', fit_f(i2), fit_f(flip(i2, flipn1))
        print x[2]

    '''
    #for k, v in flip2_table1.iteritems():  print k, v
    #for k, v in flip2_table2.iteritems():  print k, v
