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
    clk                         : in  std_logic;
    rst                         : in  std_logic;
    collision                   : in  std_logic;
    direction_select            : in  DIRECTION;
    current_draw_location       : in  POINT;
    mode                        : in  std_logic_vector(2 downto 0);
    rom_data_in                 : in  std_logic_vector(4 downto 0);
    pacman_pixel_location       : out POINT;
    gameinfo                    : in  GAME_INFO;
    pacman_tile_location        : out POINT;
    pacman_rom_tile_location    : out POINT;
    pacman_tile_location_offset : out POINT;
    pacman_direction            : out DIRECTION;
    data                        : out COLOR;
    valid_location              : out std_logic;
    rom_enable                  : in  std_logic;
    rom_use_done                : out std_logic
    );
end pacman_manager;

architecture Behavioral of pacman_manager is

  component pacman_rom is
    port(
      addr   : in  POINT;
      offset : in  POINT;
      data   : out std_logic
      );
  end component;

  component pacman_target_selection is
    port(
      clk                : in  std_logic;
      current_direction  : in  DIRECTION;
      current_location   : in  POINT;
      current_tile_point : in  POINT;
      rom_data_type      : in  std_logic_vector(4 downto 0);
      rom_enable         : in  std_logic;
      rom_location       : out POINT;
      rom_use_done       : out std_logic;
      speed              : out std_logic
      );
  end component;

  component speed_clock is
    port(
      uspeed    : in  SPEED;
      clk_50mhz : in  std_logic;
      flag      : out std_logic;
      clr_flag  : in  std_logic
      );
  end component;

--offsets into the pacman rom for the different images
  constant PAC_CLOSED_OFFSET            : integer := 0;
  constant PAC_OPEN_OFFSET              : integer := 32;
--size of pacman and his tile
  constant PAC_SIZE                     : POINT   := (32, 32);
  constant TILE_SIZE                    : POINT   := (4, 4);  --in bits
--locations
  signal   current_position             : POINT   := (GAME_OFFSET.X + (2*16)-8, GAME_OFFSET.Y + (23*16));  --14, 23
  signal   board_pixel_location         : POINT;
  signal   current_tile_position        : POINT;
  signal   current_tile_position_offset : POINT;
  signal   pacman_draw_location         : POINT;
  signal   tile_location                : POINT;


  signal next_location : POINT := (0, 0);

  signal validh, validv    : std_logic := '0';
  signal offset            : POINT     := (0, 0);
  signal current_direction : DIRECTION := STILL;

  signal clocks      : std_logic_vector(22 downto 0) := (others => '0');
  signal wacka_clk   : std_logic                     := '0';
  signal pac_rom_bit : std_logic                     := '0';
  signal addr        : POINT;
  signal speed       : SPEED                         := SPEED_80;
  signal enable_move : std_logic                     := '0';

  --speed clock
  signal   speed_clear    : std_logic                     := '0';
  signal   speed_flag     : std_logic                     := '0';
  signal   dot_count_prev : integer range 0 to 244        := 0;
  signal   counter_60hz   : std_logic_vector(20 downto 0) := (others => '0');
  constant ONE_60_SECOND  : std_logic_vector(20 downto 0) := "100001000011111000101";
begin

  speed_gen : speed_clock
    port map(
      uspeed    => speed,
      clk_50mhz => clk,
      flag      => speed_flag,
      clr_flag  => speed_clear
      );

  process(clk)
  begin
    if clk = '1' and clk'event then
      if gameinfo.level = 0 then
        if gameinfo.ghostmode = FRIGHTENED then
          speed <= SPEED_90;
        else
          speed <= SPEED_80;
        end if;
      elsif gameinfo.level >= 1 and gameinfo.level < 4 then
        if gameinfo.ghostmode = FRIGHTENED then
          speed <= SPEED_95;
        else
          speed <= SPEED_90;
        end if;
      elsif gameinfo.level >= 4 and gameinfo.level < 20 then
        speed <= SPEED_100;
      else
        speed <= SPEED_90;
      end if;
    end if;
  end process;

  --calculate the current position
  process(clk)
    variable enable_count : std_logic := '0';
  begin
    if clk = '1' and clk'event then
      dot_count_prev <= gameinfo.number_eaten_dots;
      if dot_count_prev /= gameinfo.number_eaten_dots then
        enable_count := '1';
      end if;

      if enable_count = '1' then
        counter_60hz <= counter_60hz + 1;
        if counter_60hz = ONE_60_SECOND-1 then
          --reached 1/60 seconds
          enable_count := '0';
        end if;
      else
        counter_60hz <= (others => '0');
      end if;

      speed_clear <= '0';
      if speed_flag = '1' and enable_move = '1' and enable_count = '0' then
        speed_clear <= '1';
        if current_direction = L then
          current_position.X <= current_position.X - 1;
        elsif current_direction = R then
          current_position.X <= current_position.X + 1;
        elsif current_direction = UP then
          current_position.Y <= current_position.Y - 1;
        elsif current_direction = DOWN then
          current_position.Y <= current_position.Y + 1;
        end if;
      end if;

      --toggle x for the wrap around
      if current_position.X < GAME_OFFSET.X + 8 then
        current_position.X <= GAME_OFFSET.X + GAME_SIZE.X - 24;
      elsif current_position.X > GAME_OFFSET.X + GAME_SIZE.X - 24 then
        current_position.X <= GAME_OFFSET.X + 8;
      end if;

    end if;
  end process;

  --register the requested direction
  process(clk)
  begin
    if clk = '1' and clk'event then
      if direction_select /= NONE and current_position.X >= GAME_OFFSET.X
        and current_position.X < GAME_OFFSET.X + GAME_SIZE.X then
        current_direction <= direction_select;
      end if;
    end if;
  end process;


  --handle the movements
  movement_engine : pacman_target_selection
    port map (
      clk                => clk,
      current_direction  => current_direction,
      current_location   => current_tile_position,
      current_tile_point => current_tile_position_offset,
      rom_data_type      => rom_data_in,
      rom_enable         => rom_enable,
      rom_location       => next_location,
      rom_use_done       => rom_use_done,
      speed              => enable_move
      );
  pacman_rom_tile_location    <= next_location;
  pacman_tile_location_offset <= current_tile_position_offset;

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

  board_pixel_location.X <= current_position.X - GAME_OFFSET.X;
  board_pixel_location.Y <= current_position.Y - GAME_OFFSET.Y;

--output the valid flag
  valid_location <= pac_rom_bit;

--output pacman's current direction register to be used by others
  pacman_direction <= current_direction;

--output pacman's current location in pixels within the board range

  pacman_pixel_location.X <= board_pixel_location.X;
  pacman_pixel_location.Y <= board_pixel_location.Y;

--get the current tile pacman is in, in the board
  current_tile_position.X <= to_integer(to_unsigned(board_pixel_location.X, 11) srl TILE_SIZE.X);
  current_tile_position.Y <= to_integer(to_unsigned(board_pixel_location.Y, 11) srl TILE_SIZE.Y);
  pacman_tile_location    <= current_tile_position;

--get offsets into that tile
  current_tile_position_offset.X <= board_pixel_location.X - to_integer(to_unsigned(board_pixel_location.X, 9) and "111110000");
  current_tile_position_offset.Y <= board_pixel_location.Y - to_integer(to_unsigned(board_pixel_location.Y, 9) and "111110000");

  rom : pacman_rom
    port map (
      addr   => addr,
      offset => offset,
      data   => pac_rom_bit
      );

--calculate the addresses for the rom using a 32x32 PROM. The prom will be scaled up from a 16x16 PROM.
  process(pacman_draw_location, current_direction)
  begin
    if current_direction = R then
      addr.Y <= pacman_draw_location.Y;
      addr.X <= 32 - pacman_draw_location.X;
    elsif current_direction = UP then
      addr.Y <= pacman_draw_location.X;
      addr.X <= pacman_draw_location.Y;
    elsif current_direction = DOWN then
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
  wacka_clk <= clocks(22);


--based on the wacka speed,
--toggle back an forth for mouth movement
  process(wacka_clk, current_direction, enable_move)
  begin
    if wacka_clk = '1' and current_direction /= STILL then
      offset.Y <= PAC_OPEN_OFFSET;
    elsif enable_move = '1' then
      offset.Y <= PAC_CLOSED_OFFSET;
    end if;
  end process;


  data.B <= "00";
  data.R <= "111";
  data.G <= "111";


end Behavioral;

