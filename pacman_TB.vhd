library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pacage.all;

entity pacman_TB is
end pacman_TB;

architecture behavior of pacman_TB is
  
  component pacman_manager is
    generic (
      GAME_OFFSET : POINT;
      GAME_SIZE   : POINT
      );
    port(
      clk                   : in  std_logic;
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

  constant GAME_SIZE             : POINT                        := (448, 496);
  constant GAME_OFFSET           : POINT                        := ((1024-GAME_SIZE.X)/2, (768-GAME_SIZE.Y)/2);
  --Inputs
  signal   clk                   : std_logic                    := '0';
  signal   rst                   : std_logic                    := '0';
  signal   collision             : std_logic                    := '0';
  signal   direction_select      : DIRECTION                    := NONE;
  signal   current_draw_location : POINT                        := (0, 0);
  signal   mode                  : std_logic_vector(2 downto 0) := (others => '0');
  signal   grid_data             : std_logic_vector(4 downto 0) := (others => '0');
  signal   rom_request_response  : std_logic                    := '0';

  --Outputs
  signal pacman_pixel_location    : POINT;
  signal pacman_tile_location     : POINT;
  signal pacman_rom_tile_location : POINT;
  signal pacman_direction         : DIRECTION;
  signal data                     : COLOR;
  signal gameinfo                 : GAME_INFO;
  signal valid_location           : std_logic;
  signal rom_request              : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin

  the_grid : game_grid
    port map(
      clk      => clk,
      rst      => rst,
      cs       => '1',
      data_in  => "00000",
      we       => '0',
      addr     => pacman_rom_tile_location,
      data_out => grid_data
      );

  direction_select <= R, UP after 10ms;
  -- Instantiate the Unit Under Test (UUT)
  uut : pacman_manager
    generic map(
      GAME_SIZE   => GAME_SIZE,
      GAME_OFFSET => GAME_OFFSET
      )
    port map (

      clk                   => clk,
      rst                   => rst,
      direction_select      => direction_select,
      current_draw_location => current_draw_location,
      rom_data_in           => grid_data,
      gameinfo              => gameinfo,
      tile_location         => pacman_tile_location,
      rom_location          => pacman_rom_tile_location,
      current_direction     => pacman_direction,
      data                  => data,
      valid_location        => valid_location,
      rom_enable            => '1',
      rom_use_done          => rom_request
      );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*10;

    -- insert stimulus here 

    wait;
  end process;

  process(clk)
  begin
    if clk = '1' and clk'event then
      if current_draw_location.X < 1023 then
        current_draw_location.X <= current_draw_location.x + 1;
      else
        current_draw_location.X <= 0;
      end if;

      if current_draw_location.X = 1023 then
        if current_draw_location.Y < 768 then
          current_draw_location.y <= current_draw_location.y + 1;
        else
          current_draw_location.y <= 0;
        end if;
      end if;
    end if;
  end process;

end;
