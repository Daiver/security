import cv2, scipy.stats
import numpy as np

def viz(h):
    height = 500
    width = 255 * 5
    img = np.zeros((height, width))
    for i, x in enumerate(h):
        for j in xrange(x/50):
            img[height - j - 1][i*4] = 255
    cv2.imshow('', img)
    cv2.waitKey()

if __name__ == '__main__':
    img  = cv2.imread('../5/0005.bmp', 0)
    img2 = cv2.imread('../5/0006.bmp', 0)
    img  = cv2.imread('/home/daiver/sec_images/images_jpg/image_002.jpg', 0)
    img2  = cv2.imread('/home/daiver/sec_images/images_jpg/image_003.jpg', 0)
    cv2.imshow('1', img) ; cv2.imshow('2', img2)
    h1, p1 = np.histogram(img, 256, [0, 255])
    h2, p2 = np.histogram(img2, 256, [0, 255])
    print scipy.stats.chisquare(h1/255)
    print scipy.stats.chisquare(h2/255)
    cv2.waitKey()
    viz(h1)
    viz(h2)
