library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity pacman_manager is
  generic (
    GAME_OFFSET : POINT;
    GAME_SIZE   : POINT
    );
  port(
    clk, clk_25           : in  std_logic;
    rst                   : in  std_logic;
    direction_select      : in  DIRECTION;
    current_draw_location : in  POINT;
    rom_data_in           : in  std_logic_vector(4 downto 0);
    gameinfo              : in  GAME_INFO;
    tile_location         : out POINT;
    rom_location          : out POINT;
    current_direction     : out DIRECTION;
    data                  : out COLOR;
    valid_location        : out std_logic;
    rom_enable            : in  std_logic;
    rom_use_done          : out std_logic
    );
end pacman_manager;

architecture Behavioral of pacman_manager is

--offsets into the pacman rom for the different images
  constant PAC_CLOSED_OFFSET    : integer := 0;
  constant PAC_HALF_OFFSET      : integer := 32;
  constant PAC_OPEN_OFFSET      : integer := 64;
--size of pacman and his tile
  constant PAC_SIZE             : POINT   := (32, 32);
--locations
  signal   pacman_draw_location : POINT;

  signal next_location : POINT := (0, 0);

  signal validh, validv     : std_logic := '0';
  signal offset             : POINT     := (0, 0);
  signal pcurrent_direction : DIRECTION := STILL;
  signal current_position   : POINT     := (0, 0);

  signal clocks      : std_logic_vector(23 downto 0) := (others => '0');
  signal wacka_clk   : std_logic                     := '0';
  signal pac_rom_bit : std_logic                     := '0';
  signal addr        : POINT;

  signal move_in_progress : std_logic;

begin


  --handle the movements
  movement_engine : pacman_target_selection
    generic map(
      GAME_OFFSET => GAME_OFFSET,
      GAME_SIZE   => GAME_SIZE
      )
    port map (
      clk                   => clk,
      direction_selection   => direction_select,
      gameinfo              => gameinfo,
      rom_data_type         => rom_data_in,
      rom_enable            => rom_enable,
      current_direction     => pcurrent_direction,
      current_location      => current_position,
      current_location_tile => tile_location,
      rom_location          => rom_location,
      rom_use_done          => rom_use_done,
      move_in_progress      => move_in_progress
      );

  process(clk)
  begin
    if clk = '1' and clk'event then
      --10 = 8 + 2
      if current_draw_location.X >= (current_position.X - 10) and current_draw_location.X < (current_position.X + PAC_SIZE.X - 10) then
        validh <= '1';
      else
        validh <= '0';
      end if;
      if current_draw_location.Y >= (current_position.Y - 8) and current_draw_location.Y < (current_position.Y + PAC_SIZE.Y - 8) then
        validv <= '1';
      else
        validv <= '0';
      end if;


      --double register for timing delay
      if validh = '1' and validv = '1' then
        pacman_draw_location.X <= current_draw_location.X - current_position.X + 8 + 1;
        pacman_draw_location.Y <= current_draw_location.Y - current_position.Y + 8;

      else
        pacman_draw_location.X <= -1;
        pacman_draw_location.Y <= -1;
      end if;
    end if;

  end process;


  --output the valid flag
  valid_location <= pac_rom_bit when current_draw_location.X > GAME_OFFSET.X and current_draw_location.X < GAME_OFFSET.X + GAME_SIZE.X and gameinfo.pacman_disable = '0' else '0';

  --output pacman's current direction register to be used by others
  current_direction <= pcurrent_direction;

  rom : pacman_rom
    port map (
      addr   => addr,
      offset => offset,
      data   => pac_rom_bit
      );

  --calculate the addresses for the rom using a 32x32 PROM. The prom will be scaled up from a 16x16 PROM.
  process(pacman_draw_location, pcurrent_direction)
  begin
    if pcurrent_direction = R then
      addr.Y <= pacman_draw_location.Y;
      addr.X <= 32 - pacman_draw_location.X;
    elsif pcurrent_direction = UP then
      addr.Y <= pacman_draw_location.X;
      addr.X <= pacman_draw_location.Y;
    elsif pcurrent_direction = DOWN then
      addr.Y <= pacman_draw_location.X;
      addr.X <= 32 - pacman_draw_location.Y;
    else
      --left or none
      addr <= pacman_draw_location;
    end if;
  end process;

  --clock divider
  process(clk)
  begin
    if clk = '1' and clk'event then
      clocks <= clocks + 1;
    end if;
  end process;
  wacka_clk <= clocks(15);


  --based on the wacka speed,
  --toggle back an forth for mouth movement
  process(wacka_clk)
    variable offset_count : integer range 0 to 2 := 0;
    variable up_down      : std_logic            := '0';
  begin
    if wacka_clk = '1' and wacka_clk'event then
      if gameinfo.gamescreen = READY or gameinfo.gamescreen = PAUSE6 or gameinfo.gamescreen = PAUSE7 then
        offset.Y <= PAC_CLOSED_OFFSET;
      elsif move_in_progress = '1' then
        case offset_count is
          when 0 =>
            offset.Y <= PAC_CLOSED_OFFSET;
          when 1 =>
            offset.Y <= PAC_HALF_OFFSET;
          when 2 =>
            offset.Y <= PAC_OPEN_OFFSET;
          when others => null;
        end case;

        if offset_count = 2 then
          up_down := '1';
        elsif offset_count = 0 then
          up_down := '0';
        end if;

        if up_down = '0' then
          offset_count := offset_count + 1;
        else
          offset_count := offset_count - 1;
        end if;
      else
        offset.Y <= PAC_HALF_OFFSET;
      end if;
    end if;
  end process;

  data.B <= "00";
  data.R <= "111";
  data.G <= "111";

end Behavioral;

