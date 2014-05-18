import os
import numpy as np
from rs import *
from fn import _

def processNum(b):
    binary = bin(abs(int(b)))[2:] #FIX ABS!!!!!
    res = int(binary[-3:], 2)
    return res

def compute2(bb, fl):
    reg = 0
    sin = 0
    const = 0
    for b in bb:
        fited, flip_fited =  fit_f(b) , fit_f(flip(b, fl))
        if flip_fited  > fited: reg += 1
        if flip_fited  < fited: sin += 1
        if flip_fited == fited: const += 1
    return reg, sin, const

def compAll(bb):
    return compute2(bb, flip1), compute2(bb, flipn1)

if __name__ == '__main__':
    dump_files_names = filter(_[:4] == 'dump', os.listdir('.'))
    print dump_files_names
    tstfn = dump_files_names[0]
    for tstfn in dump_files_names:
        print tstfn
        with open(tstfn) as f:
            fff = False
            blocks = map(lambda l: map(processNum, l.split()), f.read().split('\n'))
            res = []
            for x in blocks:
                h, p = np.histogram(x, 8,[0,7])
                #print np.std(h), np.mean(h)
                res.append(h[1:])
            print compAll(res)
            #m = np.mean(map(np.std, res))
            #print m
