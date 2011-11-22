library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dot_tb is
end dot_tb;

architecture behavior of dot_tb is
  
  component dot
    port(
      addr : in  std_logic_vector(5 downto 0);
      data : out std_logic
      );
  end component;


  --Inputs
  signal addr : std_logic_vector(5 downto 0) := (others => '0');

  --Outputs
  signal data : std_logic;
  -- No clocks detected in port list. Replace <clock> below with 
  -- appropriate port name 

  constant clk_period : time := 10 ns;
  signal   clk        : std_logic;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : dot port map (
    addr => addr,
    data => data
    );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  process(clk)
  begin
    if clk = '1' and clk'event then
      addr <= addr + 1;
    end if;
  end process;
end;
