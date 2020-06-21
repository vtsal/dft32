# vhdl coefficient generation
# generates complex coefficients for N-point DFT in fixed point 18 notation
# <sign bit> <7-bit integer> < 10-bit fraction = 18 bits
# generates realfile.txt and imagfile.txt formatted for vhdl

import math, cmath, numpy

def fixedpoint18(a):
    afx = float.hex(a)
    print(afx)
    afxstr = str(afx)
    print(afxstr)
    if (afxstr[0]=='-'):
        sign = -1
    else:
        sign = 1
    print(sign)

    i = afxstr.index('p')
    #print(i)
    p = int(afxstr[i+2:len(afxstr)])
    print(p)

#    if (a == 0) or (p >= 9):
    if (a == 0):

        result = 0
    else:
        if (a == 1):
            result = 1 << 10
        else:
            if (a == -1):
                result = 0x3fc00
        
            else:
        
                pt = afxstr.index('.')
                mantissa = afxstr[pt+1:pt+4]
                #print(mantissa)

                ftptmantissa = int(mantissa, 16) + 2**12
                #print(ftptmantissa)
                ftptmantissaadj = ftptmantissa >> int(p)
                #print(hex(ftptmantissaadj))

                result = ftptmantissa >> 3
                #print(hex(result))

                if (sign == -1):
                    #print(hex(result))
                    result = ~result + 1 # 2s complement
                    #print(hex(result))
    
    #print(hex(result))
    mask = 0x3FFFF
    result = result & mask
    return result

realfile = open('realfile.txt','w')
imagfile = open('imagfile.txt','w')

N = 32 # 4-point DFT
nstr = str(N) + ' point coefficients\n'
realfile.write(nstr)
imagfile.write(nstr)
for i in range(0,N):
    realfile.write('--Row ' + str(i) + '\n') 
    imagfile.write('--Row ' + str(i) + '\n')
    for j in range(0,N):
        print(i,j)
        phase = -2*i*j*math.pi/N
        c = cmath.rect(1, phase)
        a = c.real
        b = c.imag
        print(a,b)
        if (abs(a)< float(1/2**10)):
            a = 0.0
        if (abs(b) < float(1/2**10)):
            b = 0.0

        afx = fixedpoint18(a)
        bfx = fixedpoint18(b)
        afxstr = 'x"' + '{:05x}'.format(afx) + '",\n'
        bfxstr = 'x"' + '{:05x}'.format(bfx) + '",\n'
        
        print(afxstr, bfxstr)
        realfile.write(afxstr)
        imagfile.write(bfxstr)
        
        #print('\n')
        
realfile.close()
imagfile.close()


        



