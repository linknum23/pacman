library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dot is
	port(
		addr : in std_logic_vector(5 downto 0);
		data : out std_logic
	);
end dot;

architecture Behavioral of dot is

type dot_array is array (integer range <>) of std_logic_vector(0 to 7);
constant dot : dot_array (0 to 7):= (
	"00000000",
	"01111110",
	"01111110",
	"01111110",
	"01111110",
	"01111110",
	"01111110",
	"00000000"
);

begin

	process(addr)
	begin
		if addr(5 downto 3) < 7  then
			data <= dot(to_integer(unsigned(addr(5 downto 3))))(to_integer(unsigned(addr(2 downto 0))));
		end if;
	end process;



end Behavioral;

