library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity score_manager is
  generic (
    GAME_OFFSET : POINT;
    GAME_SIZE   : POINT
    );
  port(
    clk, clk_25           : in  std_logic;
    rst                   : in  std_logic;
    current_draw_location : in  POINT;
    gameinfo              : in  GAME_INFO;
    data                  : out COLOR;
    valid_location        : out std_logic
    );
end score_manager;

architecture Behavioral of score_manager is

  component pacman_rom is
    port(
      addr   : in  POINT;
      offset : in  POINT;
      data   : out std_logic
      );
  end component;

  constant SCORE_SIZE   : POINT := (288, 32);
  constant SCORE_OFFSET : POINT := (GAME_OFFSET.X, GAME_OFFSET.Y - SCORE_SIZE.Y-16);

  signal valid                                    : std_logic                     := '0';
  signal current_tile                             : POINT                         := (0, 0);
  signal current_tile_offset                      : POINT                         := (0, 0);
  signal current_draw_location_unsigned_X         : unsigned(10 downto 0)         := (others => '0');
  signal current_draw_location_unsigned_Y         : unsigned(10 downto 0)         := (others => '0');
  signal bcd_score_0, bcd_score_1, bcd_score_2    : integer range -1 to 9         := 0;
  signal bcd_score_3, bcd_score_4, bcd_score_5    : integer range -1 to 9         := 0;
  signal bcd_hscore_0, bcd_hscore_1, bcd_hscore_2 : integer range -1 to 9         := 0;
  signal bcd_hscore_3, bcd_hscore_4, bcd_hscore_5 : integer range -1 to 9         := 0;
  signal value                                    : integer range -1 to 19        := 0;
  signal databit, flash_clk                       : std_logic                     := '0';
  signal clocks                                   : std_logic_vector(23 downto 0) := (others => '0');
  signal high_score                               : integer range 0 to 999999     := 0;
begin

--clock divider
  process(clk)
  begin
    if clk = '1' and clk'event then
      clocks <= clocks + 1;
    end if;
  end process;
  flash_clk <= clocks(19);

  numberz : number_rom
    port map(
      addr  => current_tile_offset,
      value => value,
      data  => databit
      );

  valid_location <= valid and databit;
  data.R         <= "111";
  data.G         <= "111";
  data.B         <= "11";

  current_draw_location_unsigned_X <= to_unsigned(current_draw_location.X - SCORE_OFFSET.X, 11);
  current_draw_location_unsigned_Y <= to_unsigned(current_draw_location.Y - SCORE_OFFSET.Y, 11);

  current_tile_offset.X <= to_integer(current_draw_location_unsigned_X(3 downto 0)) when valid = '1' else -1;
  current_tile_offset.Y <= to_integer(current_draw_location_unsigned_Y(3 downto 0)) when valid = '1' else -1;
  current_tile.X        <= to_integer(current_draw_location_unsigned_X(8 downto 4)) when valid = '1' else -1;
  current_tile.Y        <= to_integer(current_draw_location_unsigned_Y(6 downto 4)) when valid = '1' else -1;
  process(clk)
  begin
    if clk = '1' and clk'event then
      if current_draw_location.X >= (SCORE_OFFSET.X-1) and current_draw_location.X < (SCORE_OFFSET.X + SCORE_SIZE.X-1)
        and current_draw_location.Y >= (SCORE_OFFSET.Y) and current_draw_location.Y < (SCORE_OFFSET.Y + SCORE_SIZE.Y) then
        valid <= '1';
      else
        valid <= '0';
      end if;
    end if;
  end process;

  process(valid, current_tile, flash_clk, bcd_score_0, bcd_score_1, bcd_score_2, bcd_score_3, bcd_score_4, bcd_score_5, bcd_hscore_0, bcd_hscore_1, bcd_hscore_2, bcd_hscore_3, bcd_hscore_4, bcd_hscore_5)
  begin
    value <= -1;
    if valid = '1' then
      if current_tile.Y = 0 then
        case current_tile.X is
          when 2 =>
            if flash_clk = '1' then
              value <= 1;
            end if;
          when 3 =>
            if flash_clk = '1' then
              value <= 10;
            end if;
          when 4 =>
            if flash_clk = '1' then
              value <= 11;
            end if;
          when 8 | 11 => value <= 12;
          when 9      => value <= 13;
          when 10     => value <= 14;
          when 13     => value <= 15;
          when 14     => value <= 16;
          when 15     => value <= 17;
          when 16     => value <= 18;
          when 17     => value <= 19;
          when others => null;
        end case;
      else
        case current_tile.X is
          when 0      => value <= bcd_score_0;
          when 1      => value <= bcd_score_1;
          when 2      => value <= bcd_score_2;
          when 3      => value <= bcd_score_3;
          when 4      => value <= bcd_score_4;
          when 5      => value <= bcd_score_5;
          when 10     => value <= bcd_hscore_0;
          when 11     => value <= bcd_hscore_1;
          when 12     => value <= bcd_hscore_2;
          when 13     => value <= bcd_hscore_3;
          when 14     => value <= bcd_hscore_4;
          when 15     => value <= bcd_hscore_5;
          when others => null;
        end case;
      end if;
    end if;
  end process;

  process(gameinfo.score)
    variable z : unsigned(43 downto 0) := (others => '0');
  begin
    z              := (others => '0');
    --first 3 shifts
    z(22 downto 3) := to_unsigned(gameinfo.score, 20);
    for i in 0 to 16 loop
      if z(23 downto 20) > 4 then
        z(23 downto 20) := z(23 downto 20) + 3;
      end if;
      if z(27 downto 24) > 4 then
        z(27 downto 24) := z(27 downto 24) + 3;
      end if;
      if z(31 downto 28) > 4 then
        z(31 downto 28) := z(31 downto 28) + 3;
      end if;
      if z(35 downto 32) > 4 then
        z(35 downto 32) := z(35 downto 32) + 3;
      end if;
      if z(39 downto 36) > 4 then
        z(39 downto 36) := z(39 downto 36) + 3;
      end if;
      if z(43 downto 40) > 4 then
        z(43 downto 40) := z(43 downto 40) + 3;
      end if;
      z(43 downto 1) := z(42 downto 0);
    end loop;
    bcd_score_3 <= -1;
    bcd_score_2 <= -1;
    bcd_score_1 <= -1;
    bcd_score_0 <= -1;
    --always show
    bcd_score_5 <= to_integer(z(23 downto 20));
    bcd_score_4 <= to_integer(z(27 downto 24));
    --only show if needed
    if z(43 downto 28) > 0 then
      bcd_score_3 <= to_integer(z(31 downto 28));
    end if;
    if z(43 downto 32) > 0 then
      bcd_score_2 <= to_integer(z(35 downto 32));
    end if;
    if z(43 downto 36) > 0 then
      bcd_score_1 <= to_integer(z(39 downto 36));
    end if;
    if z(43 downto 40) > 0 then
      bcd_score_0 <= to_integer(z(43 downto 40));
    end if;
  end process;

  process(clk_25)
  begin
    if clk_25 = '1' and clk_25'event then
      if gameinfo.score >= high_score then
        high_score   <= gameinfo.score;
        bcd_hscore_5 <= bcd_score_5;
        bcd_hscore_4 <= bcd_score_4;
        bcd_hscore_3 <= bcd_score_3;
        bcd_hscore_2 <= bcd_score_2;
        bcd_hscore_1 <= bcd_score_1;
        bcd_hscore_0 <= bcd_score_0;
      end if;
    end if;
  end process;

end Behavioral;
