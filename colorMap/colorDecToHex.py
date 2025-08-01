#!/usr/bin/python3

import math

debug = False
# debug = True

def conv(c):
    h = round((float(c) * 256) - 0.5)
    if h < 0:
        h = 0
    if h > 255:
        h = 255
    return h
    
def colorDecToHex():
    if debug:
        import pdb;
        pdb.set_trace()

    with open('parula.map.notes', 'r') as f:
        for rec in f:
            s = rec.split()
            r = conv(s[1])
            g = conv(s[2])
            b = conv(s[3])
            
            print('      {')
            print('      R = {:>3d}'.format(r))
            print('      G = {:>3d}'.format(g))
            print('      B = {:>3d}'.format(b))
            print('      }')



if __name__ == '__main__':
    colorDecToHex()
