library IEEE; use IEEE.STD_LOGIC_1164.all;

entity mux4 is -- four-input multiplexer
    generic (width: integer)
    port (d0, d1, d2, d3: in STD_LOGIC_VECTOR(width-1 downto 0);
                s: in STD_LOGIC_VECTOR(1 downto 0);
                y: out STD_LOGIC_VECTOR(width-1 downto 0));
end;

architecture behave of mux4 is
begin
process(s) begin
    case s is
        when "00" => y <= d0;
        when "01" => y <= d1;
        when "10" => y <= d2;
        when "11" => y <= d3;
        when others => y <= "--";
    end case;
end process;
end;