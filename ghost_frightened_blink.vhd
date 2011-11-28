library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;


entity ghost_frightened_blink is
port (
	gamemode : in GAME_INFO;
	clk_65 : in std_logic;
	blink : out std_logic);
end ghost_frightened_blink;

architecture Behavioral of ghost_frightened_blink is
  type int_array is array (integer range <>) of integer range -1 to 2000;
  --fright times
  constant FRIGHT_TIME_BY_LEVEL  : int_array (0 to 20)            := (12, 10, 8, 6, 4, 10, 4, 4, 2, 10, 4, 2, 2, 6, 2, 2, 2, 2, 2, 2, 2);
  signal sec_count : integer range 0 to 12:= 0;
  signal   fright_second_counter,count : std_logic_vector(27 downto 0) := (others => '0');

  --second counter
  constant HALF_SECOND    : std_logic_vector(24 downto 0) := "1111011111110100100100000";--"0000000000000110010110010";--
  constant ONE_6_SECOND : std_logic_vector(23 downto 0) :=  "101001010100110110110010";--  "000000000000010000111011"; --
  signal blink_sug : std_logic:= '0';
  signal last_mode : GHOST_MODE;
begin


--if count < 1.5 sec blink at rate of 6 hz
--count in seconds
process (clk_65)
begin
	if rising_edge(clk_65) then
		last_mode <= gamemode.GHOSTMODE;
		blink <= '0';
		if (last_mode = NORMAL or last_mode = SCATTER) and gamemode.GHOSTMODE = FRIGHTENED then
			if gamemode.level < 21 then
				sec_count <= FRIGHT_TIME_BY_LEVEL(to_integer(unsigned(gamemode.level)))+1;--keeps the blink going a lil longer than needed
			else
				sec_count <= 0;
			end if;
			fright_second_counter <= (others => '0');
		elsif fright_second_counter > HALF_SECOND then
			if sec_count > 0 then 
				sec_count <= sec_count -1;
			else 
				sec_count <= 0;
			end if;
			fright_second_counter <= (others => '0');
		else
			fright_second_counter <= fright_second_counter + 1;
			if sec_count < 4  and sec_count > 0 then --1.5 secs
				blink <= blink_sug;
			end if;
		end if;
	end if;
end process;


--blink 1/6 seconds
process (clk_65)
begin
	if rising_edge(clk_65) then
		if count > ONE_6_SECOND then
			blink_sug <= not blink_sug;
			count <= (others => '0');
		else
			count <= count + 1;
		end if;
	end if;
end process;
end Behavioral;

