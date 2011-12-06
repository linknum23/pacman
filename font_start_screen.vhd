library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity font_start_screen is
  generic (
    GAME_SIZE   : POINT := (448, 496);
    GAME_OFFSET : POINT := (100, 100)
    );
  port(
    clk, clk_25           : in  std_logic;
    rst                   : in  std_logic;
    current_draw_location : in  POINT;
    gameinfo              : in  GAME_INFO;
    data                  : out COLOR;
    valid_location        : out std_logic
    );
end font_start_screen;

architecture Behavioral of font_start_screen is

  component pacman_rom is
    port(
      addr   : in  POINT;
      offset : in  POINT;
      data   : out std_logic
      );
  end component;

  constant SCREEN_SIZE   : POINT   := (544, 496);
  constant SCREEN_OFFSET : POINT   := (GAME_OFFSET.X-48, GAME_OFFSET.Y);
  constant BASE_Y        : integer := 15;
  constant BASE_Y2       : integer := BASE_Y + 3;
  constant BASE_Y3       : integer := BASE_Y2 + 3;
  constant BASE_Y4       : integer := BASE_Y3 + 3;

  constant BASE_X4 : integer := 0;
  constant BASE_X3 : integer := 0;
  constant BASE_X  : integer := BASE_X4 + 9;
  constant BASE_X2 : integer := BASE_X + 2;

  signal valid                                    : std_logic                     := '0';
  signal current_tile                             : POINT                         := (0, 0);
  signal current_tile_offset                      : POINT                         := (0, 0);
  signal current_draw_location_unsigned_X         : unsigned(10 downto 0)         := (others => '0');
  signal current_draw_location_unsigned_Y         : unsigned(10 downto 0)         := (others => '0');
  signal bcd_score_0, bcd_score_1, bcd_score_2    : integer range -1 to 9         := 0;
  signal bcd_score_3, bcd_score_4, bcd_score_5    : integer range -1 to 9         := 0;
  signal bcd_hscore_0, bcd_hscore_1, bcd_hscore_2 : integer range -1 to 9         := 0;
  signal bcd_hscore_3, bcd_hscore_4, bcd_hscore_5 : integer range -1 to 9         := 0;
  signal value                                    : integer range -1 to 20        := 0;
  signal databit, flash_clk                       : std_logic                     := '0';
  signal clocks                                   : std_logic_vector(23 downto 0) := (others => '0');
  signal high_score                               : integer range 0 to 999999     := 0;
  signal count                                    : integer range 0 to 16         := 0;

--letter offsets
  constant zero : integer := 0;
  constant one  : integer := 1;
  constant two  : integer := 2;
  constant p    : integer := 3;
  constant u    : integer := 4;
  constant s    : integer := 5;
  constant h    : integer := 6;
  constant i    : integer := 7;
  constant c    : integer := 8;
  constant o    : integer := 9;
  constant r    : integer := 10;
  constant e    : integer := 11;
  constant t    : integer := 12;
  constant a    : integer := 13;
  constant b    : integer := 14;
  constant n    : integer := 15;
  constant l    : integer := 16;
  constant y    : integer := 17;
  constant copy : integer := 18;
  constant j    : integer := 19;
  constant zee  : integer := 20;
  
begin
  numberz : font_rom
    port map(
      addr  => current_tile_offset,
      value => value,
      data  => databit
      );

  valid_location <= '1' when valid = '1' and databit = '1' and (gameinfo.gamescreen = START_SCREEN) else '0';


  current_draw_location_unsigned_X <= to_unsigned(current_draw_location.X - SCREEN_OFFSET.X, 11);
  current_draw_location_unsigned_Y <= to_unsigned(current_draw_location.Y - SCREEN_OFFSET.Y, 11);

  current_tile_offset.X <= to_integer(current_draw_location_unsigned_X(3 downto 0))  when valid = '1' else -1;
  current_tile_offset.Y <= to_integer(current_draw_location_unsigned_Y(3 downto 0))  when valid = '1' else -1;
  current_tile.X        <= to_integer(current_draw_location_unsigned_X(10 downto 4)) when valid = '1' else -1;
  current_tile.Y        <= to_integer(current_draw_location_unsigned_Y(10 downto 4)) when valid = '1' else -1;
  process(clk)
  begin
    if clk = '1' and clk'event then
      if current_draw_location.X >= (SCREEN_OFFSET.X-1) and current_draw_location.X < (SCREEN_OFFSET.X + SCREEN_SIZE.X-1)
        and current_draw_location.Y >= (SCREEN_OFFSET.Y) and current_draw_location.Y < (SCREEN_OFFSET.Y + SCREEN_SIZE.Y) then
        valid <= '1';
      else
        valid <= '0';
      end if;
    end if;
  end process;

  process(current_tile)
  begin
    data.R <= "000";
    data.G <= "000";
    data.B <= "00";
    value  <= -1;
    case current_tile.Y is
      when BASE_Y =>
        data.R <= "110";
        data.G <= "100";
        data.B <= "00";
        case current_tile.X is
          when BASE_X =>
            value <= p;                 --P
          when BASE_X+1 | BASE_X+12 =>
            value <= u;                 --U
          when BASE_X+2 | BASE_X+5 =>
            value <= s;                 --S
          when BASE_X+3 =>
            value <= h;                 --H
          when BASE_X+6 | BASE_X+9 | BASE_X+13 | BASE_X+14 =>
            value <= t;                 --T
          when BASE_X+7 =>
            value <= a;                 --A
          when BASE_X+8 =>
            value <= r;                 --R
          when BASE_X+11 =>
            value <= b;                 --B
          when BASE_X+15 =>
            value <= o;                 --O
          when BASE_X+16 =>
            value <= n;                 --N            
          when others => null;
        end case;
      when BASE_Y2 =>
        data.R <= "000";
        data.G <= "110";
        data.B <= "11";
        case current_tile.X is
          when BASE_X2 =>
            value <= one;               --1
          when BASE_X2+2 =>
            value <= p;                 --P
          when BASE_X2+3 | BASE_X2+11 =>
            value <= l;                 --L
          when BASE_X2+4 =>
            value <= a;                 --A
          when BASE_X2+5 | BASE_X2+12 =>
            value <= y;                 --Y
          when BASE_X2+6 =>
            value <= e;                 --E
          when BASE_X2+7 =>
            value <= r;                 --R
          when BASE_X2+9 =>
            value <= o;                 --O
          when BASE_X2+10 =>
            value <= n;                 --N         
          when others => null;
        end case;
      when BASE_Y3 =>
        -- case current_tile.X is
        -- when BASE_X1 =>
        -- value <= one;               --1
        -- when BASE_X1+2 =>
        -- value <= p;                 --P
        -- when BASE_X1+3 | BASE_X1+11 =>
        -- value <= l;                 --L
        -- when BASE_X1+4 =>
        -- value <= a;                 --A
        -- when BASE_X1+5 | BASE_X1+12 =>
        -- value <= y;                 --Y
        -- when BASE_X1+6 =>
        -- value <= e;                 --E
        -- when BASE_X1+7 =>
        -- value <= r;                 --R
        -- when BASE_X1+9 =>
        -- value <= o;                 --O
        -- when BASE_X1+10 =>
        -- value <= n;                 --N         
        -- when others => null;
        -- end case;
      when BASE_Y4 =>
        data.R <= "111";
        data.G <= "101";
        data.B <= "11";
        case current_tile.X is
          when BASE_X3 =>
            value <= copy;
          when BASE_X3+2 =>
            value <= two;
          when BASE_X3+3 =>
            value <= zero;
          when BASE_X3+4 | BASE_X3+5 =>
            value <= one;
          when BASE_X3+7 =>
            value <= b;
          when BASE_X3+8 | BASE_X3+30 =>
            value <= r;
          when BASE_X3+9 =>
            value <= y;
          when BASE_X3+10 =>
            value <= a;
          when BASE_X3+11 | BASE_X3+16 | BASE_X3+22 | BASE_X3+26 | BASE_X3+32 =>
            value <= n;
          when BASE_X3+12 =>
            value <= t;
          when BASE_X3+14 =>
            value <= j;
          when BASE_X3+15 | BASE_X3+24 | BASE_X3+29 =>
            value <= o;
          when BASE_X3+17 | BASE_X3+31 =>
            value <= e;
          when BASE_X3+18 =>
            value <= s;
          when BASE_X3+20 | BASE_X3+25 | BASE_X3+28 =>
            value <= l;
          when BASE_X3+21 =>
            value <= i;
          when BASE_X3+23 =>
            value <= c;
          when BASE_X3+33 =>
            value <= zee;
          when others => null;
        end case;
      when others => null;
    end case;
  end process;

end Behavioral;
