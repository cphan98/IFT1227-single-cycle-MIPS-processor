library IEEE; use IEEE.STD_LOGIC_1164.all;

entity maindec is -- main control decoder
	port (op: in STD_LOGIC_VECTOR (5 downto 0);
			funct: in STD_LOGIC_VECTOR (5 downto 0);
			regwrite: out STD_LOGIC;
			regdst: out STD_LOGIC_VECTOR (1 downto 0);
			alusrc: out STD_LOGIC_VECTOR (1 downto 0);
			branch: out STD_LOGIC;
			memwrite: out STD_LOGIC;
			memtoreg: out STD_LOGIC_VECTOR (1 downto 0);
			jump, jumpr: out STD_LOGIC;
			convert: out;
			aluop: out STD_LOGIC_VECTOR (1 downto 0));
end;

architecture behave of maindec is
	signal controls: STD_LOGIC_VECTOR(13 downto 0);
begin
process(op) begin
	case op is
		when "000000" => -- R-type
			if funct = "001000" then
				controls <= "00000000001010"; -- JR
			elsif funct = "111111" then
				controls <= "10100000000110"; -- INDEX2ADR
			else
				controls <= "10100000000010"; -- AND, OR, ADD, SUB, SLT
			end if;
		when "100011" => controls <= "10001000100000"; -- LW
		when "101011" => controls <= "00001010000000"; -- SW
		when "000100" => controls <= "00000100000001"; -- BEQ
		when "001000" => controls <= "10001000000000"; -- ADDI
		when "000010" => controls <= "00000000010000"; -- J
		when "001100" => controls <= "10010000000011"-- ANDI
		when "000011" => controls <= "11000001010000"-- JAL
		when others => controls <= "---------"; -- illegal op
	end case;
end process;
	regwrite <= controls(13);
	regdst <= controls(12 downto 11);
	alusrc <= controls(10 downto 9);
	branch <= controls(8);
	memwrite <= controls(7);
	memtoreg <= controls(6 downto 5);
	jump <= controls(4);
	jumpr <= controls(3);
	convert <= controls(2);
	aluop <= controls(1 downto 0);
end;