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

  type GAME_SCREEN is (START_SCREEN, PLAYER_ONE_READY, READY, IN_GAME, GHOST_DEAD_SCREEN, PACMAN_DEAD_SCREEN, LEVEL_COMPLETE_SCREEN, POST_SCREEN, PAUSE1, PAUSE2, PAUSE3, PAUSE4, PAUSE5, PAUSE6, PAUSE7);
  type DIRECTION is (L, R, UP, DOWN, NONE, STILL);
  type GHOST_MODE is (NORMAL, SCATTER, FRIGHTENED);
  type GHOST_DISP_MODE is (NORM, SCATTER, FRIGHTENED, EYES);

  --relative speeds used for move clocks
  subtype  SPEED is natural range 0 to 40;
  constant SPEED_40  : SPEED := 8;
  constant SPEED_45  : SPEED := 9;
  constant SPEED_50  : SPEED := 10;
  constant SPEED_55  : SPEED := 11;
  constant SPEED_60  : SPEED := 12;
  constant SPEED_65  : SPEED := 13;
  constant SPEED_70  : SPEED := 14;
  constant SPEED_75  : SPEED := 15;
  constant SPEED_80  : SPEED := 16;
  constant SPEED_85  : SPEED := 17;
  constant SPEED_90  : SPEED := 18;
  constant SPEED_95  : SPEED := 19;
  constant SPEED_100 : SPEED := 20;
  constant SPEED_105 : SPEED := 21;
  constant SPEED_200 : SPEED := 40;

  --ghost names to indices
  constant I_BLINKY : natural := 0;
  constant I_PINKY  : natural := 1;
  constant I_INKY   : natural := 2;
  constant I_CLYDE  : natural := 3;

                                        --ghost targets 
  constant BLINKY_SCATTER_TARGET : POINT := (27, 0);
  constant PINKY_SCATTER_TARGET  : POINT := (0, 0);
  constant INKY_SCATTER_TARGET   : POINT := (27, 31);
  constant CLYDE_SCATTER_TARGET  : POINT := (0, 31);
  constant HOME_TARGET           : POINT := (13, 11);  -- this is where ghost go when they are killed in scatter mode
  constant HOME                  : POINT := HOME_TARGET;

  --65MHZ time constants
  constant HALF_SECOND  : std_logic_vector(24 downto 0) := "1111011111110100100100000";  --"0000000000000110010110010";--
  constant ONE_6_SECOND : std_logic_vector(23 downto 0) := "101001010100110110110010";  --  "000000000000010000111011"; --


  type GHOST_INFO is
  record
    PT    : POINT;
    DIR   : DIRECTION;
    MODE  : GHOST_DISP_MODE;
    CAGED : boolean;
  end record;

  type NES_BUTTONS is
  record
    A_BUTTON      : std_logic;
    B_BUTTON      : std_logic;
    SELECT_BUTTON : std_logic;
    START_BUTTON  : std_logic;
    UP_BUTTON     : std_logic;
    DOWN_BUTTON   : std_logic;
    LEFT_BUTTON   : std_logic;
    RIGHT_BUTTON  : std_logic;
  end record;

  type GAME_INFO is
  record
    ghostmode         : GHOST_MODE;
    game_in_progress  : std_logic;
    number_lives_left : integer range 0 to 3;
    number_eaten_dots : integer range 0 to 244;
    score             : integer range 0 to 999999;
    level             : std_logic_vector(8 downto 0);
    reset_level       : std_logic;
    level_complete    : std_logic;
    small_dot_eaten   : std_logic;
    big_dot_eaten     : std_logic;
    ghost_eaten       : std_logic;
    pacman_dead       : std_logic;
    gamescreen        : GAME_SCREEN;
    ghost_pause       : std_logic;
    pacman_pause      : std_logic;
    ghost_disable     : std_logic;
    pacman_disable    : std_logic;
    ready_enable      : std_logic;
    player_one_enable : std_logic;
    dot_reset         : std_logic;
  end record;

  component font_start_screen is
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
  end component;

  component font_rom is
    port(
      addr  : in  POINT;
      value : in  integer;
      data  : out std_logic
      );
  end component;

  component score_manager is
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
  end component;

  component number_rom is
    port(
      addr  : in  POINT;
      value : in  integer;
      data  : out std_logic
      );
  end component;

  component pacman_rom is
    port(
      addr   : in  POINT;
      offset : in  POINT;
      data   : out std_logic
      );
  end component;

  component pacman_target_selection is
    generic (
      GAME_OFFSET : POINT;
      GAME_SIZE   : POINT
      );
    port(
      clk                   : in  std_logic;
      direction_selection   : in  DIRECTION;
      gameinfo              : in  GAME_INFO;
      rom_data_type         : in  std_logic_vector(4 downto 0);
      rom_enable            : in  std_logic;
      current_location      : out POINT;
      current_location_tile : out POINT;
      current_direction     : out DIRECTION;
      rom_location          : out POINT;
      rom_use_done          : out std_logic;
      move_in_progress      : out std_logic
      );
  end component;

  component pacman_lives is
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
  end component;

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
      gameinfo              : in  GAME_INFO;
      data_type             : in  std_logic_vector(4 downto 0);
      current_tile_location : out POINT;
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
  end component;

  component ghost_ai is
    generic (
      GAME_OFFSET : POINT;
      GAME_SIZE   : POINT
      );
    port (
      clk         : in  std_logic;
      clk_25      : in  std_logic;
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
      squiggle    : out std_logic;
      blink       : out std_logic
      );
  end component;

  component game_grid is
    port(
      clk      : in  std_logic;
      rst      : in  std_logic;
      addr     : in  POINT;
      we, cs   : in  std_logic;
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
      buttons               : in  NES_BUTTONS;
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
      clk                 : in  std_logic;
      clk_25              : in  std_logic;
      en                  : in  std_logic;
      rst                 : in  std_logic;
      rom_addr            : out POINT;
      loc_valid           : in  boolean;
      done                : out std_logic;
      gameinfo            :     GAME_INFO;
      blinky_is_in_tunnel : in  boolean;
      pinky_is_in_tunnel  : in  boolean;
      inky_is_in_tunnel   : in  boolean;
      clyde_is_in_tunnel  : in  boolean;
      blinky_target       : in  POINT;
      pinky_target        : in  POINT;
      inky_target         : in  POINT;
      clyde_target        : in  POINT;
      blinky_info         : out GHOST_INFO;
      pinky_info          : out GHOST_INFO;
      inky_info           : out GHOST_INFO;
      clyde_info          : out GHOST_INFO;
      squiggle            : out std_logic;
      collision           : in  std_logic;
      collision_index     : in  natural range 0 to 3
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
      uspeed    : in  SPEED;
      clk_50mhz : in  std_logic;
      flag      : out std_logic;
      clr_flag  : in  std_logic
      );
  end component;

  component ghost_tunnel_check is
    port(
      blinky_tile_loc     : in  POINT;
      pinky_tile_loc      : in  POINT;
      inky_tile_loc       : in  POINT;
      clyde_tile_loc      : in  POINT;
      blinky_is_in_tunnel : out boolean;
      pinky_is_in_tunnel  : out boolean;
      inky_is_in_tunnel   : out boolean;
      clyde_is_in_tunnel  : out boolean
      );
  end component;
end package;
