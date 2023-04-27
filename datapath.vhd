library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_ARITH.all;

entity datapath is -- MIPS datapath
	port(clk, reset: in STD_LOGIC;
			instr: in STD_LOGIC_VECTOR(31 downto 0);
			readdata: in STD_LOGIC_VECTOR(31 downto 0);
			alucontrol: in STD_LOGIC_VECTOR(2 downto 0);
			alusrc: in STD_LOGIC_VECTOR(1 downto 0);
			jump, jumpr: in STD_LOGIC;
			memtoreg: in STD_LOGIC_VECTOR(1 downto 0);
			pcsrc: in STD_LOGIC;
			regdst: in STD_LOGIC_VECTOR(1 downto 0);
			regwrite: in STD_LOGIC;
			convert: in STD_LOGIC;
			pc: buffer STD_LOGIC_VECTOR(31 downto 0);
			aluout, writedata: buffer STD_LOGIC_VECTOR(31 downto 0);
			zero: out STD_LOGIC);
end;

architecture struct of datapath is
	component alu
		port(a, b: in STD_LOGIC_VECTOR(31 downto 0);
				f: in STD_LOGIC_VECTOR(2 downto 0);
				z: out STD_LOGIC;
				y: buffer STD_LOGIC_VECTOR(31 downto 0));
	end component;
	component regfile
		port(clk: in STD_LOGIC;
				we3: in STD_LOGIC;
				ra1, ra2, wa3: in STD_LOGIC_VECTOR(4 downto 0);
				wd3: in STD_LOGIC_VECTOR(31 downto 0);
				rd1, rd2: out STD_LOGIC_VECTOR(31 downto 0));
	end component;
	component adder
		port(a, b: in STD_LOGIC_VECTOR(31 downto 0);
				y: out STD_LOGIC_VECTOR(31 downto 0));
	end component;
	component sl2
		port(a: in STD_LOGIC_VECTOR(31 downto 0);
				y: out STD_LOGIC_VECTOR(31 downto 0));
	end component;
	component signext
		port(a: in STD_LOGIC_VECTOR(15 downto 0);
				y: out STD_LOGIC_VECTOR(31 downto 0));
	end component;
	component zeroext
		port(a: in STD_LOGIC_VECTOR(15 downto 0);
				y: out STD_LOGIC_VECTOR(31 downto 0));
	end component;
	component flopr 
		generic(width: integer);
		port(clk, reset: in STD_LOGIC;
				d: in STD_LOGIC_VECTOR(width-1 downto 0);
				q: out STD_LOGIC_VECTOR(width-1 downto 0));
	end component;
	component mux2 
		generic(width: integer);
		port(d0, d1: in STD_LOGIC_VECTOR(width-1 downto 0);
				s: in STD_LOGIC;
				y: out STD_LOGIC_VECTOR(width-1 downto 0));
	end component;
	component mux4
		generic(width: integer);
		port(d0, d1, d2, d3: in STD_LOGIC_VECTOR(width-1 downto 0);
				s: in STD_LOGIC_VECTOR(1 downto 0);
				y: out STD_LOGIC_VECTOR(width-1 downto 0));
	end component;
	signal writereg: STD_LOGIC_VECTOR(4 downto 0);
	signal pcjump, pcjumpr, pcnext, pcnextbr, pcplus4, pcbranch:
		STD_LOGIC_VECTOR(31 downto 0);
	signal signimm, signimmsh: STD_LOGIC_VECTOR(31 downto 0);
	signal zeroimm: STD_LOGIC_VECTOR(31 downto 0);
	signal srca, srcb, result: STD_LOGIC_VECTOR(31 downto 0);	
	signal data1, data1sh: STD_LOGIC_VECTOR(31 downto 0);
begin
	-- next PC logic
	pcjump <= pcplus4(31 downto 28) & instr(25 downto 0) & "00";
	pcreg: flopr 
		generic map(32) 
		port map(clk, reset, pcnext, pc);
	pcadd1: adder 
		port map(pc, X"00000004", pcplus4);
	immsh: sl2 
		port map(signimm, signimmsh);
	pcadd2: adder 
		port map(pcplus4, signimmsh, pcbranch);
	pcbrmux: mux2 
		generic map(32) 
		port map(pcplus4, pcbranch, pcsrc, pcnextbr);
	pcjrmux: mux2
		generic map(32)
		port map(data1, pcnextbr, jumpr, pcjumpr);
	pcjmux: mux2 
		generic map(32) 
		port map(pcjump, pcjumpr, jump, pcnext);
	-- register file logic
	rf: regfile 
		port map(clk, regwrite, instr(25 downto 21), instr(20 downto 16), writereg, result, data1, writedata);
	wrmux: mux4
		generic map(5)
		port map(instr(20 downto 16), instr(15 downto 11), "11111", "-----", regdst, writereg);
	resmux: mux4
		generic map(31)
		port map(aluout, readdata, pcplus4, X"--------", memtoreg, result);
	se: signext 
		port map(instr(15 downto 0), signimm);
	-- ALU logic
	ze: zeroext
		port map(instr(15 downto 0), zeroimm);
	srcbmux: mux4
		generic map(32)
		port map(writedata, signimm, zeroimm, X"--------", alusrc, srcb);
	idxsh: sl2
		port map(data1, data1sh);
	srcamux: mux2
		generic map(32)
		port map(data1, data1sh, convert, srca);
	mainalu: alu 
		port map(srca, srcb, alucontrol, zero, aluout);
end;