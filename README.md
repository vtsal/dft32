# dft32
32-point DFT using 18-bit fixed point arithmetic with single-cycle complex multiply-accumulates

This project demonstrates a VHDL implementation of a 32-point Discrete Fourier Transform (DFT).  The goal is, given an N-length input signal x[n] representing a physical signal in the time domain, return an N-length output sequence X[k] representing a transformation of x[n] to the frequency domain.  The digital frequency range of X[k] is from theta = 0 to pi radians, or from -pi/2 to pi/2 radians if 0 frequency is centered.  The relation of the digital frequency to the physical frequency (Hz) is determined by the sampling rate fs (Hz) at which the signal x[n] was sampled.  According to the Shannon-Nyquist theorem, the maximum frequency component which can be recovered at a sampling rate of fs is fs/2.  Therefore, theta = pi corresponds to a signal with frequency fs, and theta = pi/2 corresponds to a signal frequency of fs/2.  In this demonstration, sine waves are digitally sampled at ts = .01 sec (fs = 100 Hz).  Thus an output range of -pi/2 to pi/2 radians in the DFT corresponds to signals from -50 to 50 Hz.  Assuming that our input signals are real, we expect to see mirror images of the output spectrum from 0 to 50 Hz and from 0 to -50 Hz.

In this demonstration all input and output products, and computations, are performed in an 18-bit fixed point format.  The 18-bit fixed point format is designed to optimize the Xilinx FPGA DSP multiply function, which uses a 25x18 bit input.  This demonstration uses a custom rendition of signed 18-bit fixed point format as follows:

<sign><7-bit integer><10-bit fraction>

The python scripts are used to generate the input signal rinfile.txt.  As x[n] is considered a complex signal, rinfile.txt represents the real coefficients.  The imaginary coefficients, iinfile.txt, are manually set to 0 in this example.  To generate the input file, run sinfixedpt.py.  This generates a sequence of 32 18-bit (5 hex characters) text file, which represent the summation of two sine waves, one at 10 Hz and one at 40 Hz.  Sine wave vectors are computed in floating point and custom-converted by a crude fixed point converter.  The resulting file fixedpt.txt should be manually renamed rinfile.txt (iinfile.txt should be manually created to zeroes of the same size).

To compute the 32-point DFT using the Python scipy library, run the sinfloatpt.py script.  This created the FFT shown in dft32scipy.png.

To simulate generation of the output files routfile.txt and ioutfile.txt, create a Vivado project and add text_tb.vhd, nfdt.vhd, regn.vhd, controller.vhd, realcoeff32.vhd, and imagcoeff32.vhd.  The DFT complex coefficients have been predefined for N=32, but can be regenerated for any value of N using dftcoeffgen.py.  Note that this script formats outputs for use in VHDL in custom 18-bit fixed point (if you are using only the 32-bit DFT, this step is not necessary).  Set the top module to the text bench (text_tb), and ensure that rinfile.txt and routfile.txt are in the correct file path.  Run the simulation, and collect the output files, routfile.txt, and ioutfile.txt.  These files contain the DFT results.

To plot the results, run the dftresult.py script, and note the result.  One has been pregenrated in dft32fpga.png.

Structure of the VHDL implementation:

The implementation sequences through 3 phases: 1) initialize input registers from text files; 2) compute DFT; and 3) dump result registers to text files.  The N-point DFT completes N complex multiply/accumulates (MAC) in a single clock cycle, and takes N clock cycles to complete, since DFT grows as N^2 in complexity (whereas FFT grows in N log N complexity).  One single-cycle complex multiply is observed to require about 4 DSPs in the Xilinx Artix-7 architecture.  Pipelined implementations of the complex multiply/accumulate can reduce the number of DSPs, but at the cost of additional latency.

Assumption:  This 18-bit fixed point format has limited dynamic range, and does not add bits of precision during accumulates, i.e., intermediate results are always truncated to 18 bits.  Therefore, we assume that the accumulated sum will not overflow 7 bits of integer (2^7 = 128) during the calculation.  Therefore, input signals should be carefully conditioned to normalize and minimize amplitudes to prevent overflows.  

Implementation:  This 32-bit DFT was implemented for the Nexys-A7 board (Artix-7 100T) at 50 MHz (20 ns clock period).  It required 1092 LUTs, used 160 out of 240 DSPs, and consumed approximately 200 mW.  As 32 complex multiply/accumulates are conducted in each clock cycle, this is equivalent to 1.6 GMAC per second.  
