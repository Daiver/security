import cv2
import numpy as np
import scipy.stats

def bin2(char):
    return bin(char)[-1]

def pairwiseDiff(h):
    res = []
    for i in xrange(1,len(h)/2):
        res.append((h[i*2] - h[i*2 - 1])**2)
    return res

def viz(h):
    height = 500
    width = 255 * 5
    img = np.zeros((height, width))
    for i, x in enumerate(h):
        for j in xrange(x/50):
            img[height - j - 1][i*4] = 255
    cv2.imshow('', img)
    cv2.waitKey()

def extract_last_bit(img):
    img = img.reshape((-1))
    return map(bin2, img)

if __name__ == '__main__':
    img  = cv2.imread('../5/0009.bmp', 0)
    img = cv2.imread('/home/daiver/sec_images/images/sailboat_at_anchor_2.jpg', 0)
    img2 = cv2.imread('/home/daiver/sec_images/images/sailboat_at_anchor_1.jpg', 0)
    img  = cv2.imread('../5/0009.bmp', 0)
    img2 = cv2.imread('../5/0010.bmp', 0)
    cv2.imshow('1', img)
    cv2.imshow('2', img2)
    h1, p1 = np.histogram(img, 256, [0, 255])
    h2, p2 = np.histogram(img2, 256, [0, 255])
    print h1
    print h2
    print h2 - h1
    print scipy.stats.chisquare(h1/255)
    print scipy.stats.chisquare(h2/255)
    d1 = pairwiseDiff(h1)
    d2 = pairwiseDiff(h2)
    print sum(d1), sum(d2)
    b1 = extract_last_bit(img)
    b2 = extract_last_bit(img2)


    cv2.waitKey()
    viz(h1)
    viz(h2)
