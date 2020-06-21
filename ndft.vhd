----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.all;

entity ndft is
    generic(
	SIZE: integer:=5;
	WIDTH: integer :=18
	);
    port (
    clk : in std_logic;
	rst : in std_logic;
	start : in std_logic;
	rdin, idin: in std_logic_vector(WIDTH-1 downto 0);
	rdout, idout: out std_logic_vector(WIDTH-1 downto 0);
	di_ready: out std_logic;
	di_valid: in std_logic;
	do_ready: in std_logic;
	do_valid: out std_logic
	);
	
end ndft;

architecture structural of ndft is

type signalarray is array (2**SIZE-1 downto 0) of std_logic;
type signalvectorarray is array (2**SIZE-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
type sumarray is array (2**SIZE-1 downto 0) of std_logic_vector(WIDTH*2-1 downto 0);
type indexarray is array (2**SIZE-1 downto 0) of std_logic_vector(2*SIZE-1 downto 0);

constant ZEROES  : std_logic_vector(WIDTH*2-1 downto 0):=(others => '0');
signal eni : signalarray;
signal rqi, iqi : signalvectorarray;
signal rinput, iinput : std_logic_vector(WIDTH-1 downto 0);
signal rprod, iprod, rsum, isum, rregin, iregin : sumarray;
signal rdout36, idout36 : std_logic_vector(WIDTH*2-1 downto 0);
signal enld, ensum, outreginit : std_logic;
signal ldcntr : std_logic_vector(SIZE-1 downto 0);
signal index : indexarray;
signal col : std_logic_vector(SIZE-1 downto 0);
signal realcoeff, imagcoeff : signalvectorarray;

begin

-- input register bank
initreg: for i in 0 to 2**SIZE-1 generate

rinreg : entity work.regn(behavioral)
    generic map(
    N => WIDTH
    )
    port map(

        clk => clk,
		en => eni(i),
		d => rdin,
		q => rqi(i)
	);  
iinreg : entity work.regn(behavioral)
    generic map(
    N => WIDTH
    )
    port map(

        clk => clk,
		en => eni(i),
		d => idin,
		q => iqi(i)
	);  

-- decoder

eni(i) <= '1' when ((unsigned(ldcntr) = i) and (enld = '1')) else '0';
	
end generate initreg;  

-- summation and output register bank
outreg: for i in 0 to 2**SIZE-1 generate

routreg : entity work.regn(behavioral)
    generic map(
    N => WIDTH*2
    )
    port map(

        clk => clk,
		en => ensum,
		d => rregin(i),
		q => rsum(i)
	);  
	
rregin(i) <= ZEROES when (outreginit = '1') else (rprod(i) + rsum(i));

ioutreg : entity work.regn(behavioral)
    generic map(
    N => WIDTH*2
    )
    port map(

        clk => clk,
		en => ensum,
		d => iregin(i),
		q => isum(i)
	);  

iregin(i) <= ZEROES when (outreginit = '1') else (iprod(i) + isum(i));

end generate outreg;  

-- single cycle complex multiplier

-- x[n] r component selector
rmult32: if (SIZE = 5) generate

		with col select
		rinput <= rqi(0) when "00000",
    		    rqi(1) when "00001",
				rqi(2) when "00010",
				rqi(3) when "00011",
				rqi(4) when "00100",
				rqi(5) when "00101",
				rqi(6) when "00110",
				rqi(7) when "00111",
                rqi(8+0) when "01000",
    		    rqi(8+1) when "01001",
				rqi(8+2) when "01010",
				rqi(8+3) when "01011",
				rqi(8+4) when "01100",
				rqi(8+5) when "01101",
				rqi(8+6) when "01110",
				rqi(8+7) when "01111",
                rqi(16+0) when "10000",
    		    rqi(16+1) when "10001",
				rqi(16+2) when "10010",
				rqi(16+3) when "10011",
				rqi(16+4) when "10100",
				rqi(16+5) when "10101",
				rqi(16+6) when "10110",
				rqi(16+7) when "10111",
                rqi(24+0) when "11000",
    		    rqi(24+1) when "11001",
				rqi(24+2) when "11010",
				rqi(24+3) when "11011",
				rqi(24+4) when "11100",
				rqi(24+5) when "11101",
				rqi(24+6) when "11110",
				rqi(24+7) when "11111",
				rqi(0) when others;

end generate rmult32;

-- x[n] i component selector
imult32: if (SIZE = 5) generate

		with col select
		iinput <= iqi(0) when "00000",
    		    iqi(1) when "00001",
				iqi(2) when "00010",
				iqi(3) when "00011",
				iqi(4) when "00100",
				iqi(5) when "00101",
				iqi(6) when "00110",
			    iqi(7) when "00111",
                iqi(8+0) when "01000",
    		    iqi(8+1) when "01001",
				iqi(8+2) when "01010",
				iqi(8+3) when "01011",
				iqi(8+4) when "01100",
				iqi(8+5) when "01101",
				iqi(8+6) when "01110",
				iqi(8+7) when "01111",
                iqi(16+0) when "10000",
    		    iqi(16+1) when "10001",
				iqi(16+2) when "10010",
				iqi(16+3) when "10011",
				iqi(16+4) when "10100",
				iqi(16+5) when "10101",
				iqi(16+6) when "10110",
				iqi(16+7) when "10111",
                iqi(24+0) when "11000",
    		    iqi(24+1) when "11001",
				iqi(24+2) when "11010",
				iqi(24+3) when "11011",
				iqi(24+4) when "11100",
				iqi(24+5) when "11101",
				iqi(24+6) when "11110",
				iqi(24+7) when "11111",
				iqi(0) when others;

end generate imult32;

cmultgen: for i in 0 to 2**SIZE-1 generate

rprod(i) <= std_logic_vector(signed(rinput)*signed(realcoeff(i))-signed(iinput)*signed(imagcoeff(i)));
iprod(i) <= std_logic_vector(signed(rinput)*signed(imagcoeff(i))+signed(iinput)*signed(realcoeff(i)));

end generate cmultgen;

-- output layer

-- reduce from 36 bit signed accumulation to fixedpoint18
-- this keeps the sign bit, lower 7 integer bits, and upper 10 fractional bits

rdout <= rdout36(35) & rdout36(26 downto 10);
idout <= idout36(35) & idout36(26 downto 10);

dft32: if (SIZE = 5) generate

		with ldcntr select
		rdout36 <= rsum(0) when "00000",
    		    rsum(1) when "00001",
				rsum(2) when "00010",
				rsum(3) when "00011",
				rsum(4) when "00100",
				rsum(5) when "00101",
				rsum(6) when "00110",
				rsum(7) when "00111",
                rsum(8+0) when "01000",
    		    rsum(8+1) when "01001",
				rsum(8+2) when "01010",
				rsum(8+3) when "01011",
				rsum(8+4) when "01100",
				rsum(8+5) when "01101",
				rsum(8+6) when "01110",
				rsum(8+7) when "01111",
                rsum(16+0) when "10000",
    		    rsum(16+1) when "10001",
				rsum(16+2) when "10010",
				rsum(16+3) when "10011",
				rsum(16+4) when "10100",
				rsum(16+5) when "10101",
				rsum(16+6) when "10110",
				rsum(16+7) when "10111",
                rsum(24+0) when "11000",
    		    rsum(24+1) when "11001",
				rsum(24+2) when "11010",
				rsum(24+3) when "11011",
				rsum(24+4) when "11100",
				rsum(24+5) when "11101",
				rsum(24+6) when "11110",
				rsum(24+7) when "11111",
				rsum(0) when others;

		with ldcntr select
		idout36 <= isum(0) when "00000",
    		    isum(1) when "00001",
				isum(2) when "00010",
				isum(3) when "00011",
				isum(4) when "00100",
				isum(5) when "00101",
				isum(6) when "00110",
				isum(7) when "00111",
                isum(8+0) when "01000",
    		    isum(8+1) when "01001",
				isum(8+2) when "01010",
				isum(8+3) when "01011",
				isum(8+4) when "01100",
				isum(8+5) when "01101",
				isum(8+6) when "01110",
				isum(8+7) when "01111",
                isum(16+0) when "10000",
    		    isum(16+1) when "10001",
				isum(16+2) when "10010",
				isum(16+3) when "10011",
				isum(16+4) when "10100",
				isum(16+5) when "10101",
				isum(16+6) when "10110",
				isum(16+7) when "10111",
                isum(24+0) when "11000",
    		    isum(24+1) when "11001",
				isum(24+2) when "11010",
				isum(24+3) when "11011",
				isum(24+4) when "11100",
				isum(24+5) when "11101",
				isum(24+6) when "11110",
				isum(24+7) when "11111",
				isum(0) when others;

end generate dft32;

-- 32-point dft coefficients

coeffgen: for i in 0 to 2**SIZE-1 generate
    index(i) <= std_logic_vector(to_unsigned(i,SIZE)) & col;

realcoeffrom : entity work.realcoeff32(dataflow)
    generic map(
    SIZE => SIZE,
    WIDTH => WIDTH
    )
    port map(
        index => index(i),
		coeff => realcoeff(i)
	);  

imagcoeffrom : entity work.imagcoeff32(dataflow)
    generic map(
    SIZE => SIZE,
    WIDTH => WIDTH
    )
    port map(
        index => index(i),
		coeff => imagcoeff(i)
	);  

end generate coeffgen;

col <= ldcntr;  

ctrl: entity work.controller(behavioral)
    generic map(
		SIZE => SIZE
	)
    port map (
		clk => clk,
		rst => rst,
	    start => start,
	    di_ready => di_ready,
		di_valid => di_valid,
		do_ready => do_ready,
		do_valid => do_valid,
		cntr => ldcntr,
		enld => enld,
		ensum => ensum,
		outreginit => outreginit
        );
	
end structural;