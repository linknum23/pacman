library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock_divider is
	port(
		clk_50mhz : in std_logic;
		clk_25mhz : out std_logic
	);
end clock_divider;

architecture Behavioral of clock_divider is
	signal count : std_logic_vector(0 downto 0) := (others => '0');
begin

	process(clk)
	begin
		if clk = '1' and clk'event then
			count <= count + 1;		
		end if;
	end process;
	
	clk_25mhz <= count(0);

end Behavioral;

