library ieee;
use ieee.std_logic_1164.all;

entity top_level_tb is
end top_level_tb;

architecture behavior of top_level_tb is

  -- Component Declaration for the Unit Under Test (UUT)

  component top_level
    port(
      mclk  : in  std_logic;
      hsync : out std_logic;
      vsync : out std_logic;
      btn   : in  std_logic_vector(3 downto 0);
      red   : out std_logic_vector(2 downto 0);
      green : out std_logic_vector(2 downto 0);
      blue  : out std_logic_vector(1 downto 0)
      );
  end component;


  --Inputs
  signal mclk : std_logic := '0';

  --Outputs
  signal hsync : std_logic;
  signal vsync : std_logic;
  signal red   : std_logic_vector(2 downto 0);
  signal green : std_logic_vector(2 downto 0);
  signal blue  : std_logic_vector(1 downto 0);
  signal j     : std_logic_vector(0 downto 0);
  signal dir   : std_logic_vector(3 downto 0);

  -- Clock period definitions
  constant mclk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : top_level port map (
    mclk  => mclk,
    hsync => hsync,
    vsync => vsync,
    btn   => dir,
    red   => red,
    green => green,
    blue  => blue
    );

  -- Clock process definitions
  mclk_process : process
  begin
    mclk <= '0';
    wait for mclk_period/2;
    mclk <= '1';
    wait for mclk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    dir <= "0010";
    --wait for 40us;
    --dir <= "0100";
    --wait for 100ns;
    --dir <= "0000";
    --wait for 300us;
    --dir <= "0100";
   -- wait for 300us;
    --dir <= "1000";
    wait;
  end process;

end;
