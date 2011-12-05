library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pacage.all;

entity top_level_tb is
end top_level_tb;

architecture behavior of top_level_tb is

  -- Component Declaration for the Unit Under Test (UUT)

  component top_level
    port(
      mclk  : in    std_logic;
      hsync : out   std_logic;
      vsync : out   std_logic;
      btn   : in    std_logic_vector(3 downto 0);
      red   : out   std_logic_vector(2 downto 0);
      green : out   std_logic_vector(2 downto 0);
      blue  : out   std_logic_vector(1 downto 0);
      j     : inout std_logic_vector(3 downto 0)  --j4 is already gnd
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
  signal j     : std_logic_vector(3 downto 0);
  signal dir   : std_logic_vector(3 downto 0);

  -- Clock period definitions
  constant mclk_period : time      := 5 ns;
  signal   data        : std_logic := '1';
  signal   pulse       : std_logic := '0';
  signal   buttons     : NES_BUTTONS;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : top_level port map (
    mclk  => mclk,
    hsync => hsync,
    vsync => vsync,
    btn   => dir,
    red   => red,
    green => green,
    blue  => blue,
    j     => j
    -- buttons => buttons
    );
  j(1)  <= data;
  pulse <= j(3);

  --buttons.LEFT_BUTTON  <= '1' after 1ms, '0' after 2ms, '1' after 4ms;
  --buttons.RIGHT_BUTTON <= '1' after 500ns, '0' after 2.5ms;
  --buttons.UP_BUTTON    <= '1' after 2.6ms, '0' after 2.7ms;
  --buttons.DOWN_BUTTON <= '1' after 1us, '0' after 2us;

  -- Clock process definitions
  mclk_process : process
  begin
    mclk <= '0';
    wait for mclk_period/2;
    mclk <= '1';
    wait for mclk_period/2;
  end process;


  stim_proc : process(pulse)
    variable count : integer range 0 to 7 := 0;
  begin
    if pulse = '1' and pulse'event then
      case count is
        when 0 =>
          data <= '1';
        when 1 =>
          data <= '1';
        when 2 =>
          data <= '1';
        when 3 =>
          data <= '1';
        when 4 =>
          data <= '1';
        when 5 =>
          data <= '0';
        when 6 =>
          data <= '1';
        when 7 =>
          data <= '1';
        when others => null;
      end case;
      count := count + 1;
    end if;
  end process;

end;
