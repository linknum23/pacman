library ieee;
use ieee.std_logic_1164.all;
use work.pacage.all;

entity grid_TB is
end grid_TB;

architecture behavior of grid_TB is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component grid_display
    port(
      clk              : in  std_logic;
      current_location : in  POINT;
      mode             : in  std_logic_vector(2 downto 0);
      valid_location   : out std_logic;
      data             : out COLOR
      );
  end component;


  --Inputs
  signal clk              : std_logic                    := '0';
  signal current_location : POINT;
  signal mode             : std_logic_vector(2 downto 0) := (others => '0');

  --Outputs
  signal valid_location : std_logic;
  signal data           : COLOR;

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : grid_display port map (
    clk              => clk,
    current_location => current_location,
    mode             => mode,
    valid_location   => valid_location,
    data             => data
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
  process(clk)
  begin
    if clk = '1' and clk'event then
      if current_location.X < 1023 then
        current_location.X <= current_location.X + 1;
      else
        current_location.X <= 0;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk = '1' and clk'event then
      if current_location.X >= 1023 then
        if current_location.Y < 767 then
          current_location.Y <= current_location.Y + 1;
        else
          current_location.Y <= 0;
        end if;
      end if;
    end if;
  end process;

end;
