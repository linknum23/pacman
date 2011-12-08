library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity ghost_score_display is
  generic (
    GAME_SIZE   : POINT := (448, 496);
    GAME_OFFSET : POINT := ((1024-448)/2, (768-496)/2)
    );
  port(
    clk                   : in  std_logic;
    rst                   : in  std_logic;
    current_draw_location : in  POINT;
    pacman_tile           : in  POINT;
    pacman_pixel          : in  POINT;
    gameinfo              : in  GAME_INFO;
    data                  : out COLOR;
    valid_location        : out std_logic
    );
end ghost_score_display;

architecture Behavioral of ghost_score_display is

  signal valid                                                                : std_logic              := '0';
  signal current_tile                                                         : POINT                  := (0, 0);
  signal current_tile_offset                                                  : POINT                  := (0, 0);
  signal current_draw_location_unsigned_X, current_pacman_location_unsigned_X : unsigned(10 downto 0)  := (others => '0');
  signal current_draw_location_unsigned_Y, current_pacman_location_unsigned_Y : unsigned(10 downto 0)  := (others => '0');
  signal value                                                                : integer range -1 to 22 := 0;
  signal databit                                                              : std_logic              := '0';
  
begin
  numberz : ghost_score_rom
    port map(
      addr  => current_tile_offset,
      value => value,
      data  => databit
      );

  valid_location <= '1' when valid = '1' and databit = '1' and gameinfo.gamescreen = PAUSE3 else '0';

  current_draw_location_unsigned_X <= to_unsigned(current_draw_location.X - GAME_OFFSET.X, 11);
  current_draw_location_unsigned_Y <= to_unsigned(current_draw_location.Y - GAME_OFFSET.Y, 11);

  --current_tile_offset.X  <= to_integer(current_draw_location_unsigned_X(3 downto 0));
  --current_tile_offset.Y  <= to_integer(current_draw_location_unsigned_Y(3 downto 0));
  current_tile.X        <= to_integer(current_draw_location_unsigned_X(10 downto 4));
  current_tile.Y        <= to_integer(current_draw_location_unsigned_Y(10 downto 4));
  current_tile_offset.X <= to_integer(current_draw_location_unsigned_X - (to_unsigned(pacman_tile.X, 10) and "1111110000")) when valid = '1' else -1;
  current_tile_offset.Y <= to_integer(current_draw_location_unsigned_Y - (to_unsigned(pacman_tile.Y, 10) and "1111110000")) when valid = '1' else -1;

  process(clk)
  begin
    if clk = '1' and clk'event then
      if pacman_tile.Y = current_tile.Y and (pacman_tile.X = current_tile.X or pacman_tile.X + 1 = current_tile.X) then
        --if current_draw_location.X >= (pacman_pixel.X - 8) and current_draw_location.X < (pacman_pixel.X + 24) and --current_draw_location.Y >= (pacman_pixel.Y) and current_draw_location.Y < (pacman_pixel.Y) then
        valid <= '1';
      else
        valid <= '0';
      end if;
    end if;
  end process;

  process(gameinfo.ghost_score)
  begin
    value <= -1;
    case gameinfo.ghost_score is
      when "00011001000" =>
        value <= 0;
      when "00110010000" =>
        value <= 1;
      when "01100100000" =>
        value <= 2;
      when "11001000000" =>
        value <= 3;
      when others => null;
    end case;
  end process;

  data.R <= "000";
  data.G <= "110";
  data.B <= "11";

end Behavioral;
