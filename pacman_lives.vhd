library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity pacman_lives is
  generic (
    GAME_OFFSET : POINT;
    GAME_SIZE   : POINT
    );
  port(
    clk                   : in  std_logic;
    rst                   : in  std_logic;
    current_draw_location : in  POINT;
    gameinfo              : in  GAME_INFO;
    data                  : out COLOR;
    valid_location        : out std_logic
    );
end pacman_lives;

architecture Behavioral of pacman_lives is
  constant LIVES_SIZE   : POINT := (160, 32);
  constant LIVES_OFFSET : POINT := (GAME_OFFSET.X, GAME_OFFSET.Y + GAME_SIZE.Y + 5);

  signal valid                            : std_logic             := '0';
  signal current_tile                     : POINT                 := (0, 0);
  signal current_tile_offset              : POINT                 := (0, 0);
  signal current_draw_location_unsigned_X : unsigned(10 downto 0) := (others => '0');
  signal current_draw_location_unsigned_Y : unsigned(10 downto 0) := (others => '0');
  signal databit                          : std_logic             := '0';

  signal life_valid : std_logic := '0';
begin

  rom : pacman_rom
    port map (
      addr   => current_tile_offset,
      offset => (0, 32),
      data   => databit
      );

  valid_location <= valid and databit and life_valid;
  data.B         <= "00";
  data.R         <= "111";
  data.G         <= "111";

  current_draw_location_unsigned_X <= to_unsigned(current_draw_location.X - LIVES_OFFSET.X, 11);
  current_draw_location_unsigned_Y <= to_unsigned(current_draw_location.Y - LIVES_OFFSET.Y, 11);

  current_tile_offset.X <= to_integer(current_draw_location_unsigned_X(4 downto 0)) when valid = '1' else -1;
  current_tile_offset.Y <= to_integer(current_draw_location_unsigned_Y(4 downto 0)) when valid = '1' else -1;
  current_tile.X        <= to_integer(current_draw_location_unsigned_X(7 downto 5)) when valid = '1' else -1;
  --current_tile.Y        <= to_integer(current_draw_location_unsigned_Y(6 downto 4)) when valid = '1' else -1;
  process(clk)
  begin
    if clk = '1' and clk'event then
      if current_draw_location.X >= (LIVES_OFFSET.X-1) and current_draw_location.X < (LIVES_OFFSET.X + LIVES_SIZE.X-1)
        and current_draw_location.Y >= (LIVES_OFFSET.Y) and current_draw_location.Y < (LIVES_OFFSET.Y + LIVES_SIZE.Y) then
        valid <= '1';
      else
        valid <= '0';
      end if;
    end if;
  end process;

  process(current_tile.X, gameinfo.number_lives_left)

  begin
    if current_tile.X = 4 and gameinfo.number_lives_left > 4 then
      life_valid <= '1';
    elsif current_tile.X = 3 and gameinfo.number_lives_left > 3 then
      life_valid <= '1';
    elsif current_tile.X = 2 and gameinfo.number_lives_left > 2 then
      life_valid <= '1';
    elsif current_tile.X = 1 and gameinfo.number_lives_left > 1 then
      life_valid <= '1';
    elsif current_tile.X = 0 and gameinfo.number_lives_left > 0 then
      life_valid <= '1';
    else
      life_valid <= '0';
    end if;
  end process;

end Behavioral;
