library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity speed_clock is
	port(
	speed : in natural range 0 to 21;
	clk_50mhz : in std_logic;
	flag :  out std_logic;
	clr_flag : in std_logic
	);
end speed_clocks;

architecture Behavioral of speed_clocks is
	signal counter : std_logic_vector(24 downto 0):= (others => '0');
	signal last_bit : std_logic := '0';
begin
process(clk_50mhz)
begin

	if rising_edge(clk_50mhz) then
		counter <= counter + speed;
		last_bit <= counter(22);
		--check for rising edge on speed bit
		if last_bit = '0' and counter(22) = '1' then
			--set flag
			flag <= '1';
		elsif clr_flag = '1' then
			--clear flag
			flag <= '0';
		end if;
	end if;

end Behavioral;

