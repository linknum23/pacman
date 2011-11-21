LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
 
ENTITY vga1024x768_tb IS
END vga1024x768_tb;
 
ARCHITECTURE behavior OF vga1024x768_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT vga_1024x768
    PORT(
         clk : IN  std_logic;
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         hc : OUT  std_logic_vector(10 downto 0);
         vc : OUT  std_logic_vector(10 downto 0);
         vidon : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';

 	--Outputs
   signal hsync : std_logic;
   signal vsync : std_logic;
   signal hc : std_logic_vector(10 downto 0);
   signal vc : std_logic_vector(10 downto 0);
   signal vidon : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: vga_1024x768 PORT MAP (
          clk => clk,
          hsync => hsync,
          vsync => vsync,
          hc => hc,
          vc => vc,
          vidon => vidon
        );
 
	--65 Mhz
	clk <= not clk after 7.692 ns;

END;
