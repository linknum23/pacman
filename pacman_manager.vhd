library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity pacman_manager is
  generic (
    GAME_OFFSET : POINT
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
      speed              : out std_logic_vector(0 downto 0)
      );
  end component;

--offsets into the pacman rom for the different images
  constant PAC_CLOSED_OFFSET            : integer := 0;
  constant PAC_OPEN_OFFSET              : integer := 32;
--size of pacman and his tile
  constant PAC_SIZE                     : POINT   := (32, 32);
  constant TILE_SIZE                    : POINT   := (4, 4);  --in bits
--locations
  signal   current_position             : POINT   := (GAME_OFFSET.X + (14*16)-8, GAME_OFFSET.Y + (23*16));
  signal   board_pixel_location         : POINT;
  signal   current_tile_position        : POINT;
  signal   current_tile_position_offset : POINT;
  signal   pacman_draw_location         : POINT;
  signal   board_draw_location          : POINT;
  signal   tile_location                : POINT;


  signal next_location : POINT := (0, 0);

  signal valid             : std_logic := '0';
  signal offset            : POINT     := (0, 0);
  signal current_direction : DIRECTION := NONE;

  signal clocks              : std_logic_vector(22 downto 0) := (others => '0');
  signal wacka_clk, move_clk : std_logic                     := '0';
  signal pac_rom_bit         : std_logic                     := '0';
  signal addr                : POINT;
  signal speed               : std_logic_vector(0 downto 0)  := "0";
begin
  --register the requested direction
  process(clk)
  begin
    if clk = '1' and clk'event then
      current_direction <= direction_select;
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
      speed              => speed
      );
  pacman_rom_tile_location    <= next_location;
  pacman_tile_location_offset <= current_tile_position_offset;

  --calculate the current position
  process(move_clk)
  begin
    if move_clk = '1' and move_clk'event then
      --if current_position.X > -32 and current_position.X < 1055 and current_position.Y > -32 and current_position.Y < 799 then
      if current_direction = L then
        current_position.X <= current_position.X - to_integer(unsigned(speed));
      elsif current_direction = R then
        current_position.X <= current_position.X + to_integer(unsigned(speed));
      elsif current_direction = UP then
        current_position.Y <= current_position.Y - to_integer(unsigned(speed));
      elsif current_direction = DOWN then
        current_position.Y <= current_position.Y + to_integer(unsigned(speed));
      end if;
      --elsif current_position.X > -32 and current_position.X < 1055 then
      --toggle y
      if current_position.Y <= -32 then
        current_position.Y <= 798;
      elsif current_position.Y >= 799 then
        current_position.Y <= 0-31;
      end if;

      if current_position.X <= -32 then
        current_position.X <= 1054;
      elsif current_position.X >= 1055 then
        current_position.X <= 0-31;
      end if;

      --end if;
    end if;
  end process;

--output pacman's current direction register to be used by others
  pacman_direction <= current_direction;

--output pacman's current location in pixels within the board range
  board_pixel_location.X  <= current_position.X - GAME_OFFSET.X;
  board_pixel_location.Y  <= current_position.Y - GAME_OFFSET.Y;
  pacman_pixel_location.X <= board_pixel_location.X;
  pacman_pixel_location.Y <= board_pixel_location.Y;

--get the current tile pacman is in, in the board
  current_tile_position.X <= to_integer(to_unsigned(board_pixel_location.X, 11) srl TILE_SIZE.X);
  current_tile_position.Y <= to_integer(to_unsigned(board_pixel_location.Y, 11) srl TILE_SIZE.Y);
  pacman_tile_location    <= current_tile_position;

--get offsets into that tile
  current_tile_position_offset.X <= board_pixel_location.X - to_integer(to_unsigned(current_tile_position.X, 11) sll TILE_SIZE.X);
  current_tile_position_offset.Y <= board_pixel_location.Y - to_integer(to_unsigned(current_tile_position.Y, 11) sll TILE_SIZE.Y);

--location minus the offsets
--area to start drawing
  pacman_draw_location.X <= current_draw_location.X - current_position.X + 8 when valid = '1' else 0;
  pacman_draw_location.Y <= current_draw_location.Y - current_position.Y + 8 when valid = '1' else 0;

--location minus the offsets
--location of the drawing pixel within board coords
  board_draw_location.X <= current_draw_location.X - GAME_OFFSET.X when valid = '1' else 0;
  board_draw_location.Y <= current_draw_location.Y - GAME_OFFSET.Y when valid = '1' else 0;

  rom : pacman_rom
    port map (
      addr   => addr,
      offset => offset,
      data   => pac_rom_bit
      );

--calculate the addresses for the rom using a 32x32 PROM. The prom will be scaled up from a 16x16 PROM.
  process(pacman_draw_location, current_direction)
    variable y, x : std_logic_vector(11 downto 0) := (others => '0');
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

--valid flag to tell whether we are in range of the image and if we are drawing a color for it.
--shift valid by 8 bits down
  valid <= '1' when current_draw_location.X >= (current_position.X - 8)
           and current_draw_location.X < (current_position.X + PAC_SIZE.X - 8)
           and current_draw_location.Y >= (current_position.Y - 8)
           and current_draw_location.Y < (current_position.Y + PAC_SIZE.Y - 8)
           else '0';
--output the valid flag
  valid_location <= valid and pac_rom_bit;

--clock divider
  process(clk)
  begin
    if clk = '1' and clk'event then
      clocks <= clocks + 1;
    end if;
  end process;
  wacka_clk <= clocks(18);
  move_clk  <= clocks(14);


--based on the wacka speed,
--toggle back an forth for mouth movement
  process(wacka_clk, speed, current_direction)
  begin
    if wacka_clk = '1' and current_direction /= NONE then
      offset.Y <= PAC_OPEN_OFFSET;
    elsif speed > 0 then
      offset.Y <= PAC_CLOSED_OFFSET;
    end if;
  end process;

--output mux for the colors of pacman,
--only if we are valid
  process(valid)
  begin
    --data.R <= "000";
    --data.G <= "000";
    --data.B <= "00";
    --if valid = '1' then
      data.R <= "111";
      data.G <= "111";
    --end if;
  end process;


end Behavioral;

