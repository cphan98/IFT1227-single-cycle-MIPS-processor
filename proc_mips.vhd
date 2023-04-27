library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity proc_mips is -- single cycle MIPS processor
	port(clk, reset: in STD_LOGIC;
			instr: in STD_LOGIC_VECTOR(31 downto 0);
			readdata: in STD_LOGIC_VECTOR(31 downto 0));
			pc: out STD_LOGIC_VECTOR(31 downto 0);
			memwrite: out STD_LOGIC;
			aluout, writedata: out STD_LOGIC_VECTOR(31 downto 0);
end;

architecture struct of proc_mips is
	component controller
		port(op, funct: in STD_LOGIC_VECTOR(5 downto 0);
				zero: in STD_LOGIC;
				regwrite: out STD_LOGIC;
				regdst: out STD_LOGIC_VECTOR(1 downto 0);
				alusrc: out STD_LOGIC_VECTOR(1 downto 0);
				pcsrc: out STD_LOGIC;
				memwrite: out STD_LOGIC;
				memtoreg: out STD_LOGIC_VECTOR(1 downto 0);
				jump, jumpr: out STD_LOGIC;
				convert: out STD_LOGIC;
				alucontrol: out STD_LOGIC_VECTOR(2 downto 0));
	end component;
	component datapath
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
	end component;
	signal memtoreg, alusrc, regdst: STD_LOGIC_VECTOR(1 downto 0);
	signal regwrite, jump, jumpr, pcsrc, convert: STD_LOGIC;	
	signal zero: STD_LOGIC;
	signal alucontrol: STD_LOGIC_VECTOR(2 downto 0);
begin
	cont: controller 
		port map(instr(31 downto 26), instr(5 downto 0), zero, regwrite, 
			regdst, alusrc, pcsrc, memwrite, memtoreg, jump, jumpr, convert,
			alucontrol);
	dp: datapath 
		port map(clk, reset, instr, readdata, alucontrol, alusrc, jump, 
			jumpr, memtoreg, pcsrc, regdst, regwrite, convert, pc, aluout, 
			writedata, zero);
end;