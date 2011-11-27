library IEEE;
use IEEE.STD_LOGIC_1164.all;

package pacage is

  type POINT is
  record
    X : integer range -1 to 2000;
    Y : integer range -1 to 2000;
  end record;

  type COLOR is
  record
    R : std_logic_vector(2 downto 0);
    G : std_logic_vector(2 downto 0);
    B : std_logic_vector(1 downto 0);
  end record;

  type DIRECTION is (L, R, UP, DOWN, NONE, STILL);
  type GHOST_MODE is (NORMAL, SCATTER, FRIGHTENED);
  type GHOST_DISP_MODE is (NORM, SCATTER, FRIGHTENED, EYES);
  
  subtype SPEED is natural range 0 to 22;
  constant SPEED_50 : SPEED := 10;
  constant SPEED_55 : SPEED := 11;
  constant SPEED_60 : SPEED := 12;
  constant SPEED_65 : SPEED := 13;
  constant SPEED_70 : SPEED := 14;
  constant SPEED_75 : SPEED := 15;
  constant SPEED_80 : SPEED := 16;
  constant SPEED_85 : SPEED := 17;
  constant SPEED_90 : SPEED := 18;
  constant SPEED_95 : SPEED := 19;
  constant SPEED_100 : SPEED := 20;
  constant SPEED_105 : SPEED := 21;
  

  type GHOST_INFO is
  record
    PT    : POINT;
    DIR   : DIRECTION;
    MODE  : GHOST_DISP_MODE;
    CAGED : boolean;
  end record;

  type GAME_INFO is
  record
    ghostmode                 : GHOST_MODE;
    game_in_progess           : std_logic;
    number_lives_left         : integer range 0 to 3;
    number_eaten_dots         : integer range 0 to 244;
    time_since_last_dot_eaten : integer;
    score                     : integer range 0 to 999999;
    level                     : std_logic_vector(8 downto 0);
    reset_level               : std_logic;
    level_complete            : std_logic;
  end record;


  --components
  component grid_display is
    generic (
      GAME_OFFSET : POINT;
      GAME_SIZE   : POINT
      );
    port(
      clk                   : in  std_logic;
      rst                   : in  std_logic;
      current_draw_location : in  POINT;
      data_type             : in  std_logic_vector(4 downto 0);
      current_tile_location : out POINT;
      mode                  : in  std_logic_vector(2 downto 0);
      data                  : out COLOR;
      valid_location        : out std_logic
      );
  end component;

  component ghost_display is
    generic (
      GAME_OFFSET : POINT
      );
    port(
      clk                   : in  std_logic;
      blinky_info           : in  GHOST_INFO;
      pinky_info            : in  GHOST_INFO;
      inky_info             : in  GHOST_INFO;
      clyde_info            : in  GHOST_INFO;
      ghostmode             : in  GHOST_MODE;
      fright_blink          : in  std_logic;
      current_draw_location : in  POINT;
      ghost_valid           : out std_logic;
      squiggle              : in  std_logic;
      ghost_color           : out COLOR
      );
  end component;

  component pacman_manager is
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
      pacman_tile_location        : out POINT;
      pacman_rom_tile_location    : out POINT;
      pacman_tile_location_offset : out POINT;
      pacman_direction            : out DIRECTION;
      data                        : out COLOR;
      valid_location              : out std_logic;
      rom_enable                  : in  std_logic;
      rom_use_done                : out std_logic
      );
  end component;

  component ghost_ai is
    generic (
      GAME_OFFSET : POINT;
      GAME_SIZE   : POINT
      );
    port (
      clk         : in  std_logic;
      en          : in  std_logic;
      rst         : in  std_logic;
      rom_addr    : out POINT;
      rom_data    : in  std_logic;
      gameinfo    : in  GAME_INFO;
      pman_loc    : in  POINT;
      pman_dir    : in  DIRECTION;
      done        : out std_logic;
      blinky_info : out GHOST_INFO;
      pinky_info  : out GHOST_INFO;
      inky_info   : out GHOST_INFO;
      clyde_info  : out GHOST_INFO;
      collision   : out std_logic;
      squiggle    : out std_logic
      );
  end component;

  component game_grid is
    port(
      clk      : in  std_logic;
      rst      : in  std_logic;
      addr     : in  POINT;
      we       : in  std_logic;
      data_in  : in  std_logic_vector(4 downto 0);
      data_out : out std_logic_vector(4 downto 0)
      );
  end component;

  component direction_manager
    port(
      clk                          : in  std_logic;
      rst                          : in  std_logic;
      direction_selection          : in  DIRECTION;
      pacman_current_tile_location : in  POINT;
      pacman_current_tile_offset   : in  POINT;
      rom_data_in                  : in  std_logic_vector(4 downto 0);
      rom_enable                   : in  std_logic;
      current_direction            : out DIRECTION;
      rom_address                  : out POINT;
      rom_use_done                 : out std_logic
      );
  end component;

  component game_machine is
    port (
      clk                   : in  std_logic;
      rst                   : in  std_logic;
      game_en               : in  std_logic;
      collision             : in  std_logic;
      current_draw_location : in  POINT;
      pacman_tile_location  : in  POINT;
      rom_data_in           : in  std_logic_vector(4 downto 0);
      rom_enable            : in  std_logic;
      rom_address           : out POINT;
	  rom_we                : out std_logic;
      rom_data_out          : out std_logic_vector(4 downto 0);
      rom_use_done          : out std_logic;
      gameinfo              : out GAME_INFO
      );
  end component;

  component ghost_target_updater is
    port (
      clk             : in  std_logic;
      en              : in  std_logic;
      rst             : in  std_logic;
      rom_addr        : out POINT;
      rom_data        : in  std_logic;
      done            : out std_logic;
      pman_tile_loc   : in  POINT;
      pman_dir        : in  DIRECTION;
      blinky_tile_loc : in  POINT;
      pinky_tile_loc  : in  POINT;
      inky_tile_loc   : in  POINT;
      clyde_tile_loc  : in  POINT;
      ghostmode       : in  GHOST_MODE;
      blinky_target   : out POINT;
      pinky_target    : out POINT;
      inky_target     : out POINT;
      clyde_target    : out POINT
      );
  end component;

  component move_ghost is
    generic (
      GAME_OFFSET : POINT;
      GAME_SIZE   : POINT
      );
    port (
      clk           : in  std_logic;
      en            : in  std_logic;
      rst           : in  std_logic;
      rom_addr      : out POINT;
      rom_data      : in  std_logic;
      done          : out std_logic;
      gameinfo      :     GAME_INFO;
      blinky_target : in  POINT;
      pinky_target  : in  POINT;
      inky_target   : in  POINT;
      clyde_target  : in  POINT;
      blinky_info   : out GHOST_INFO;
      pinky_info    : out GHOST_INFO;
      inky_info     : out GHOST_INFO;
      clyde_info    : out GHOST_INFO;
      squiggle      : out std_logic
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
      collision_index      : out natural range 0 to 3;
      collision            : out std_logic
      );
  end component;
  component speed_clock is
port(
	uspeed : in SPEED;
	clk_50mhz : in std_logic;
	flag :  out std_logic;
	clr_flag : in std_logic
	);
	end component;
end package;
