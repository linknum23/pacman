library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pacage.all;

entity nes_controller_TB is
end nes_controller_TB;

architecture behavior of nes_controller_TB is
  
  component nes_controller is
    port(
      clk        : in  std_logic;
      rst        : in  std_logic;
      power_pin  : out std_logic;
      data_pin   : in  std_logic;
      latch_pin  : out std_logic;
      pulse_pin  : out std_logic;
      ground_pin : out std_logic;
      buttons    : out NES_BUTTONS
      );
  end component;


  --Inputs
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  -- Clock period definitions
  constant clk_period : time      := 20 ns;
  signal   data       : std_logic := '1';
  signal   pulse      : std_logic := '0';
  signal   buttons      : NES_BUTTONS;
  
begin
  -- Instantiate the Unit Under Test (UUT)
  uut : nes_controller port map (
    clk        => clk,
    rst        => rst,
    power_pin  => open,
    latch_pin  => open,
    pulse_pin  => pulse,
    ground_pin => open,
    data_pin   => data,
    buttons    => buttons
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
          data <= '0';
        when 5 =>
          data <= '1';
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
