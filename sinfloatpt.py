import math, cmath
import numpy as np
import matplotlib.pyplot as plt # library for plotting
from signalgenalt import sine_wave_alt # import the function
from scipy.fftpack import fft, fftshift
from scipy.signal import convolve

def fixpt18tofloat(a):
# takes signed fixedpoint 18, returns float or arbitrary precision    
    
    mask = 0x3FFFF
    signbit = int(a/2**17) # equal to 1 or zero
    #print(signbit)
    if (signbit == 1):
        #print('neg')
        sign = -1
        a = ~a + 1 # 2s complement
        a = a & mask # truncate to 18 bits
    else:
        sign = 1
    result = float(a/2**10) * sign
    return result
    
fixedptfile = open('fixedpt.txt','r')

#recreate sign wave
fs = 100 # sampling frequency in Hz
nsamples = 32

#create sine wave
f = 10 #frequency = 10 Hz
phase = 0 #1/3*np.pi #phase shift in radians
 # desired number of cycles of the sine wave
(t,x) = sine_wave_alt(f,fs,phase,nsamples) #function call

fpstr = fixedptfile.readline()
i = 0
while (fpstr != ""):
    a = int(fpstr,16)
   
    fp = fixpt18tofloat(a)
    x[i] = fp # substitutes converted fixed point 18 values using same time base
    i = i + 1
    fpstr = fixedptfile.readline()

fixedptfile.close()
        
#plt.plot(t,x) # plot using pyplot library from matplotlib package
#plt.title('Sine wave f='+str(f)+' Hz') # plot title
#plt.xlabel('Time (s)') # x-axis label
#plt.ylabel('Amplitude') # y-axis label
#plt.show() # display the figure 

NFFT=32
y = x[0:NFFT-1]

X=fftshift(fft(y,NFFT))
 
#plt.subplots(nrows=1, ncols=1) #create figure handle
 
fVals=np.arange(start = -NFFT/2,stop = NFFT/2)*fs/NFFT
plt.plot(fVals,np.abs(X),'b')
plt.title('Double Sided FFT - with FFTShift')
plt.xlabel('Frequency (Hz)')
plt.ylabel('|DFT Values|')
plt.xlim(-fs/2,fs/2)
plt.xticks(np.arange(-fs/2, fs/2+1,fs/5))
plt.show()

