LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
 
ENTITY dot_tb IS
END dot_tb;
 
ARCHITECTURE behavior OF dot_tb IS 
 
    COMPONENT dot
    PORT(
         addr : IN  std_logic_vector(5 downto 0);
         data : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal addr : std_logic_vector(5 downto 0) := (others => '0');

 	--Outputs
   signal data : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
	signal clk : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dot PORT MAP (
          addr => addr,
          data => data
        );

   -- Clock process definitions
   clk_process :process
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
END;
