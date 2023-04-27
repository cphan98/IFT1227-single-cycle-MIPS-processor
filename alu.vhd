library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity alu is -- ALU
	port(a, b: in STD_LOGIC_VECTOR(31 downto 0);
			f: in STD_LOGIC_VECTOR(2 downto 0);
			z: out STD_LOGIC;
			y: out STD_LOGIC_VECTOR(31 downto 0) := X"00000000");
end;

architecture behave of alu is
signal diff, tmp: STD_LOGIC_VECTOR(31 downto 0);
begin
	diff <= a - b;
	process(a, b, f, diff, tmp) 
	begin
		case f is
			when "000" => tmp <= a and b; -- and
			when "001" => tmp <= a or b; -- or
			when "010" => tmp <= a + b; -- add
			when "100" => tmp <= a and (not b); -- and not
			when "101" => tmp <= a or (not b); -- or not
			when "110" => tmp <= diff; -- sub
			when "111" => tmp <= X"0000000" & "000" & diff(31); -- SLT
			when others => tmp <= X"FFFFFFFF"; 
		end case;
	end process;
	z <= '1' when tmp = X"00000000" else '0';
	y <= tmp;
end;