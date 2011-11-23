library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity display_manager is
  port (
    clk                        : in  std_logic;
    rst                        : in  std_logic; 
    current_draw_location      : in  POINT;
    pacman_direction_selection : in  DIRECTION; 
    data                       : out COLOR
    );
end display_manager;

architecture Behavioral of display_manager is
  component grid_display is
    generic (
      GAME_OFFSET : POINT;
      GAME_SIZE   : POINT
      );
      port(
        clk                   :     std_logic;
        rst                   :     std_logic; 
        current_draw_location : in  POINT;
        data_type             : in  std_logic_vector(4 downto 0);
        current_tile_location : out POINT;
        mode                  : in  std_logic_vector(2 downto 0);
        data                  : out COLOR;
        valid_location        : out std_logic
        );
  end component;

  component pacman_manager
    generic (
      GAME_OFFSET : POINT
      );
    port(
      clk                      : in  std_logic;
      rst                      : in  std_logic;
      collision                : in  std_logic;
      direction_select         : in  DIRECTION;
      current_draw_location    : in  POINT;
      mode                     : in  std_logic_vector(2 downto 0);
      data_type                : in  std_logic_vector(4 downto 0);
      pacman_pixel_location    : out POINT;
      pacman_tile_location     : out POINT;
      pacman_rom_tile_location : out POINT;
      pacman_direction         : out DIRECTION;
      data                     : out COLOR;
      valid_location           : out std_logic;
      rom_request_response     : in  std_logic;
      rom_request              : out std_logic
      );
  end component;

  component collision_machine is
    port(
      clk                  : in  std_logic;
      rst                  : in  std_logic;
      pacman_tile_location : in  POINT;
      blinky_tile_location : in  POINT;
      pinky_tile_location  : in  POINT;
      inky_tile_location   : in  POINT;
      clyde_tile_location  : in  POINT;
      collision            : out std_logic
      );
  end component;

  component game_grid is
    port(
      addr : in  POINT;
      data : out std_logic_vector(4 downto 0)
      );
  end component;

  constant GAME_SIZE   : POINT := (448, 496);
  constant GAME_OFFSET : POINT := ((1024-GAME_SIZE.X)/2, (768-GAME_SIZE.Y)/2);

  --valid signals
  signal grid_valid   : std_logic := '0';
  signal pacman_valid : std_logic := '0';

  --color signals
  signal grid_color_data   : COLOR;
  signal pacman_color_data : COLOR;

  --location signals
  signal pacman_pixel_location    : POINT;
  signal pacman_tile_location     : POINT;
  signal pacman_rom_tile_location : POINT;
  signal blinky_tile_location     : POINT;
  signal pinky_tile_location      : POINT;
  signal inky_tile_location       : POINT;
  signal clyde_tile_location      : POINT;
  signal grid_tile_location       : POINT;
  signal rom_tile_location        : POINT;
  
  signal pacman_direction : DIRECTION := NONE;

  signal collision : std_logic;
  
  --rom signals
  signal pacman_rom_request : std_logic := '0';
  signal pacman_rom_request_response : std_logic := '0';
  signal grid_rom_request : std_logic := '0';
  signal grid_rom_request_response : std_logic := '0';
  signal grid_data : std_logic_vector(4 downto 0);
  
begin
  board : grid_display
    generic map (
      GAME_SIZE   => GAME_SIZE,
      GAME_OFFSET => GAME_OFFSET
      )
    port map (
      clk                   => clk,
      rst                   => rst,
      current_draw_location => current_draw_location,
      data_type             => grid_data,
      current_tile_location => grid_tile_location,
      mode                  => "000",
      valid_location        => grid_valid,
      data                  => grid_color_data
      );  
      
      the_pacman : pacman_manager
    generic map(
      GAME_OFFSET => GAME_OFFSET
      )
    port map (

      clk                      => clk,
      rst                      => rst,
      collision                => collision,
      direction_select         => pacman_direction_selection,
      current_draw_location    => current_draw_location,
      mode                     => "000",
      data_type                => grid_data,
      pacman_pixel_location    => pacman_pixel_location,
      pacman_tile_location     => pacman_tile_location,
      pacman_rom_tile_location => pacman_rom_tile_location,
      pacman_direction         => pacman_direction,
      data                     => pacman_color_data,
      valid_location           => pacman_valid,
      rom_request_response     => pacman_rom_request_response,
      rom_request              => pacman_rom_request
      );

  collision_check : collision_machine
    port map(
      clk                  => clk,
      rst                  => rst,
      pacman_tile_location => pacman_tile_location,
      blinky_tile_location => blinky_tile_location,
      pinky_tile_location  => pinky_tile_location,
      inky_tile_location   => inky_tile_location,
      clyde_tile_location  => clyde_tile_location,
      collision            => collision
      );



  -------------------------------------------------
  --grid and its mux
  -------------------------------------------------
  the_grid : game_grid
    port map(
      addr.X => rom_tile_location.X,
      addr.Y => rom_tile_location.Y,
      data   => grid_data
      );

  --mux the output color for the display
  process(pacman_rom_request,pacman_rom_tile_location, grid_tile_location)
  begin
     pacman_rom_request_response <= '0';
     grid_rom_request_response <= '0';
    if pacman_rom_request = '1' then
      rom_tile_location <= pacman_rom_tile_location;
      pacman_rom_request_response <= '1';
    else
      --give it to the grid
      rom_tile_location <= grid_tile_location;
      grid_rom_request_response <= '1';
    end if;
  end process;


-------------------------------------------------
  --mux the output color for the display
  -------------------------------------------------
  process(pacman_color_data, pacman_valid, grid_color_data, grid_valid)
  begin
    if pacman_valid = '1' then
      data <= pacman_color_data;
    elsif grid_valid = '1' then
      data <= grid_color_data;
    else
      data.R <= "000";
      data.G <= "000";
      data.B <= "00";
    end if;
  end process;
  
end Behavioral;

