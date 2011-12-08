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
  constant SCREEN_SIZE   : POINT   := (544, 496);
  constant SCREEN_OFFSET : POINT   := (GAME_OFFSET.X-48, GAME_OFFSET.Y);
  constant BASE_Y        : integer := 15;
  constant BASE_Y2       : integer := BASE_Y + 3;
  constant BASE_Y3       : integer := BASE_Y2 + 3;
  constant BASE_Y4       : integer := BASE_Y3 + 3;

  constant BASE_X4 : integer := 0;
  constant BASE_X3 : integer := BASE_X4 + 4;
  constant BASE_X  : integer := BASE_X4 + 9;
  constant BASE_X2 : integer := BASE_X + 2;

  signal valid                            : std_logic                 := '0';
  signal current_tile                     : POINT                     := (0, 0);
  signal current_tile_offset              : POINT                     := (0, 0);
  signal current_draw_location_unsigned_X : unsigned(10 downto 0)     := (others => '0');
  signal current_draw_location_unsigned_Y : unsigned(10 downto 0)     := (others => '0');
  signal value                            : integer range -1 to 27    := 0;
  signal databit                          : std_logic                 := '0';
  signal high_score                       : integer range 0 to 999999 := 0;
  signal count                            : integer range 0 to 16     := 0;

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
  constant d    : integer := 21;
  constant expl : integer := 22;
  constant g    : integer := 23;
  constant m    : integer := 24;
  constant v    : integer := 25;
  constant dash : integer := 26;
  constant f    : integer := 27;
  
begin
  numberz : font_rom
    port map(
      addr  => current_tile_offset,
      value => value,
      data  => databit
      );

  valid_location <= '1' when valid = '1' and databit = '1' and (gameinfo.gamescreen = START_SCREEN or gameinfo.gamescreen = PAUSE1 or gameinfo.gamescreen = PAUSE2 or gameinfo.gamescreen = POST_SCREEN or gameinfo.gamescreen = PAUSE8) else '0';

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

  process(clk)
  begin
    if clk = '1' and clk'event then
      data.R <= "000";
      data.G <= "000";
      data.B <= "00";
      value  <= -1;
      if gameinfo.gamescreen = START_SCREEN then
        case current_tile.Y is
          when BASE_Y =>
            data.R <= "110";
            data.G <= "100";
            data.B <= "00";
            case current_tile.X is
              when BASE_X =>
                value <= p;             --P
              when BASE_X+1 | BASE_X+12 =>
                value <= u;             --U
              when BASE_X+2 | BASE_X+5 =>
                value <= s;             --S
              when BASE_X+3 =>
                value <= h;             --H
              when BASE_X+6 | BASE_X+9 | BASE_X+13 | BASE_X+14 =>
                value <= t;             --T
              when BASE_X+7 =>
                value <= a;             --A
              when BASE_X+8 =>
                value <= r;             --R
              when BASE_X+11 =>
                value <= b;             --B
              when BASE_X+15 =>
                value <= o;             --O
              when BASE_X+16 =>
                value <= n;             --N            
              when others => null;
            end case;
          when BASE_Y2 =>
            data.R <= "000";
            data.G <= "110";
            data.B <= "11";
            case current_tile.X is
              when BASE_X2 =>
                value <= one;           --1
              when BASE_X2+2 =>
                value <= p;             --P
              when BASE_X2+3 | BASE_X2+11 =>
                value <= l;             --L
              when BASE_X2+4 =>
                value <= a;             --A
              when BASE_X2+5 | BASE_X2+12 =>
                value <= y;             --Y
              when BASE_X2+6 =>
                value <= e;             --E
              when BASE_X2+7 =>
                value <= r;             --R
              when BASE_X2+9 =>
                value <= o;             --O
              when BASE_X2+10 =>
                value <= n;             --N         
              when others => null;
            end case;
          when BASE_Y3 =>
            data.R <= "111";
            data.G <= "101";
            data.B <= "10";
            case current_tile.X is
              when BASE_X3 =>
                value <= b;
              when BASE_X3+1 | BASE_X3+15 =>
                value <= o;
              when BASE_X3+2 | BASE_X3+12 =>
                value <= n;
              when BASE_X3+3 =>
                value <= u;
              when BASE_X3+4 | BASE_X3+26 =>
                value <= s;
              when BASE_X3+6 | BASE_X3+24 =>
                value <= p;
              when BASE_X3+7 | BASE_X3+11 =>
                value <= a;
              when BASE_X3+8 =>
                value <= c;
              when BASE_X3+9 =>
                value <= dash;
              when BASE_X3+10 =>
                value <= m;
              when BASE_X3+14 =>
                value <= f;
              when BASE_X3+16 =>
                value <= r;
              when BASE_X3+18 =>
                value <= one;
              when BASE_X3+19 | BASE_X3+20 | BASE_X3+21 | BASE_X3+22 =>
                value <= zero;
              when BASE_X3+25 =>
                value <= t;
              when others => null;
            end case;
          when BASE_Y4 =>
            data.R <= "111";
            data.G <= "101";
            data.B <= "11";
            case current_tile.X is
              when BASE_X4 =>
                value <= copy;
              when BASE_X4+2 =>
                value <= two;
              when BASE_X4+3 =>
                value <= zero;
              when BASE_X4+4 | BASE_X4+5 =>
                value <= one;
              when BASE_X4+7 =>
                value <= b;
              when BASE_X4+8 | BASE_X4+30 =>
                value <= r;
              when BASE_X4+9 =>
                value <= y;
              when BASE_X4+10 =>
                value <= a;
              when BASE_X4+11 | BASE_X4+16 | BASE_X4+22 | BASE_X4+26 | BASE_X4+32 =>
                value <= n;
              when BASE_X4+12 =>
                value <= t;
              when BASE_X4+14 =>
                value <= j;
              when BASE_X4+15 | BASE_X4+24 | BASE_X4+29 =>
                value <= o;
              when BASE_X4+17 | BASE_X4+31 =>
                value <= e;
              when BASE_X4+18 =>
                value <= s;
              when BASE_X4+20 | BASE_X4+25 | BASE_X4+28 =>
                value <= l;
              when BASE_X4+21 =>
                value <= i;
              when BASE_X4+23 =>
                value <= c;
              when BASE_X4+33 =>
                value <= zee;
              when others => null;
            end case;
          when others => null;
        end case;
      end if;
      if gameinfo.gamescreen = PAUSE2 or gameinfo.gamescreen = PAUSE1 then
        case current_tile.Y is
          when BASE_Y+2 =>
            data.B <= "00";
            data.R <= "111";
            data.G <= "111";
            case current_tile.X is
              when BASE_X+5 =>
                value <= r;
              when BASE_X+6 =>
                value <= e;
              when BASE_X+7 =>
                value <= a;
              when BASE_X+8 =>
                value <= d;
              when BASE_X+9 =>
                value <= y;
              when BASE_X+10 =>
                value <= expl;
              when others => null;
            end case;
          when others => null;
        end case;
      end if;
      if gameinfo.gamescreen = PAUSE1 then
        case current_tile.Y is
          when BASE_Y-4 =>
            data.R <= "000";
            data.G <= "110";
            data.B <= "11";
            case current_tile.X is
              when BASE_X+3 =>
                value <= p;
              when BASE_X+4 =>
                value <= l;
              when BASE_X+5 =>
                value <= a;
              when BASE_X+6 =>
                value <= y;
              when BASE_X+7 =>
                value <= e;
              when BASE_X+8 =>
                value <= r;
              when BASE_X+10 =>
                value <= o;
              when BASE_X+11 =>
                value <= n;
              when BASE_X+12 =>
                value <= e;
              when others => null;
            end case;
          when others => null;
        end case;
      end if;
      if gameinfo.gamescreen = POST_SCREEN or gameinfo.gamescreen = PAUSE8 then
        data.R <= "111";
        data.G <= "000";
        data.B <= "00";
        case current_tile.Y is
          when BASE_Y+2 =>
            case current_tile.X is
              when BASE_X+3 =>
                value <= g;
              when BASE_X+4 =>
                value <= a;
              when BASE_X+5 =>
                value <= m;
              when BASE_X+6 | BASE_X+11 =>
                value <= e;
              when BASE_X+9 =>
                value <= o;
              when BASE_X+10 =>
                value <= v;
              when BASE_X+12 =>
                value <= r;
              when others => null;
            end case;
          when others => null;
        end case;
      end if;
    end if;
  end process;

end Behavioral;
