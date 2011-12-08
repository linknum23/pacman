library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity ghost_score_rom is
  port(
    addr  : in  POINT;
    value : in  integer;
    data  : out std_logic
    );
end ghost_score_rom;

architecture Behavioral of ghost_score_rom is

  type rom_array is array (integer range <>) of std_logic_vector (0 to 15);
  signal rom : rom_array (0 to 31) := (
    --200
    "0000000000000000",
    "0011100011000110",
    "0100010100101001",
    "0100010100101001",
    "0000100100101001",
    "0001000100101001",
    "0010000100101001",
    "0111110011000110",
    --400
    "0000000000000000",
    "0000100011000110",
    "0001100100101001",
    "0010100100101001",
    "0100100100101001",
    "0111110100101001",
    "0100100100101001",
    "0000100011000110",
    --800
    "0000000000000000",
    "0011100011000110",
    "0100010100101001",
    "0100010100101001",
    "0011100100101001",
    "0100010100101001",
    "0100010100101001",
    "0011100011000110",
    --1600
    "0000000000000000",
    "1001110011000110",
    "1010000100101001",
    "1010000100101001",
    "1011110100101001",
    "1010010100101001",
    "1010010100101001",
    "1001100011000110"
    );
  signal why, offset  : unsigned(5 downto 0);
  signal ex           : unsigned(4 downto 0);
  signal newy, newoff : unsigned(why'high downto 0);
  signal newx         : unsigned(ex'high downto 0);
begin
  offset <= to_unsigned(value, 2) & "0000";

  why    <= to_unsigned(addr.Y, why'length);
  ex     <= to_unsigned(addr.X, ex'length);
  newoff <= why + offset;
  newy   <= '0' & newoff(newoff'high downto 1);
  newx   <= '0' & ex(ex'high downto 1);
  process(newx, newy, value)

  begin
    data <= '0';
    if value >= 0 then
      data <= rom(to_integer(newy))(to_integer(newx));
    end if;
  end process;

end Behavioral;
