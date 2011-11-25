library ieee;
use ieee.std_logic_1164.all;

entity direction_TB is
end direction_TB;

architecture behavior of direction_TB is

  -- Component Declaration for the Unit Under Test (UUT)

  component direction_manager
    port(
      clk                          : in  std_logic;
      rst                          : in  std_logic;
      direction_selection          : in  std_logic;
      pacman_current_tile_location : in  std_logic;
      pacman_current_tile_offset   : in  std_logic;
      rom_data_in                  : in  std_logic_vector(3 downto 0);
      rom_enable                   : in  std_logic;
      current_direction            : out std_logic;
      rom_address                  : out std_logic;
      rom_use_done                 : out std_logic
      );
  end component;


  --Inputs
  signal clk                          : std_logic                    := '0';
  signal rst                          : std_logic                    := '0';
  signal direction_selection          : std_logic                    := '0';
  signal pacman_current_tile_location : std_logic                    := '0';
  signal pacman_current_tile_offset   : std_logic                    := '0';
  signal rom_data_in                  : std_logic_vector(3 downto 0) := (others => '0');
  signal rom_enable                   : std_logic                    := '0';

  --Outputs
  signal current_direction : std_logic;
  signal rom_address       : std_logic;
  signal rom_use_done      : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : direction_manager port map (
    clk                          => clk,
    rst                          => rst,
    direction_selection          => direction_selection,
    pacman_current_tile_location => pacman_current_tile_location,
    pacman_current_tile_offset   => pacman_current_tile_offset,
    rom_data_in                  => rom_data_in,
    rom_enable                   => rom_enable,
    current_direction            => current_direction,
    rom_address                  => rom_address,
    rom_use_done                 => rom_use_done
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

end;
