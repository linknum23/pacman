library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vga1024x768_tb is
end vga1024x768_tb;

architecture behavior of vga1024x768_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component vga_1024x768
    port(
      clk   : in  std_logic;
      hsync : out std_logic;
      vsync : out std_logic;
      hc    : out std_logic_vector(10 downto 0);
      vc    : out std_logic_vector(10 downto 0);
      vidon : out std_logic
      );
  end component;


  --Inputs
  signal clk : std_logic := '1';

  --Outputs
  signal hsync : std_logic;
  signal vsync : std_logic;
  signal hc    : std_logic_vector(10 downto 0);
  signal vc    : std_logic_vector(10 downto 0);
  signal vidon : std_logic;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : vga_1024x768 port map (
    clk   => clk,
    hsync => hsync,
    vsync => vsync,
    hc    => hc,
    vc    => vc,
    vidon => vidon
    );

  --65 Mhz
  clk <= not clk after 7.692 ns;

end;
