library ieee;
use ieee.std_logic_1164.all;
use work.pacage.all;

entity move_ghost_tb1 is
end move_ghost_tb1;

architecture behavior of move_ghost_tb1 is

  -- Component Declaration for the Unit Under Test (UUT)

  component move_ghost
    port(
      clk           : in  std_logic;
      en            : in  std_logic;
      rst           : in  std_logic;
      rom_addr      : out POINT;
      rom_data      : in  std_logic;
      done          : out std_logic;
      ghostmode    :     GHOST_MODE;
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

  --Inputs
  signal clk        : std_logic  := '0';
  signal en         : std_logic  := '0';
  signal rst        : std_logic  := '0';
  signal rom_data   : std_logic  := '0';
  signal ghostmode : GHOST_MODE := NORMAL;

  --Outputs
  signal rom_addr    : POINT;
  signal done        : std_logic;
  signal blinky_info : GHOST_INFO;
  signal pinky_info  : GHOST_INFO;
  signal inky_info   : GHOST_INFO;
  signal clyde_info  : GHOST_INFO;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : move_ghost port map (
    clk        => clk,
    en         => en,
    rst        => rst,
    rom_addr   => rom_addr,
    rom_data   => rom_data,
    done       => done,
    ghostmode => ghostmode,

    blinky_target => (X => 0, Y => 11),
    pinky_target  => (X => 0, Y => 11),
    inky_target   => (X => 0, Y => 11),
    clyde_target  => (X => 0, Y => 11),

    blinky_info => blinky_info,
    pinky_info  => pinky_info,
    inky_info   => inky_info,
    clyde_info  => clyde_info
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
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait for clk_period*10;

    en <= '1';
    -- insert stimulus here

    wait;
  end process;

  imit_rom : process
  begin
    if rom_addr.Y = 11 then
      rom_data <= '1';
    else
      rom_data <= '0';
    end if;
    wait for clk_period;
  end process;
end;
