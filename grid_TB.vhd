LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.pacage.all;

ENTITY grid_TB IS
END grid_TB;
 
ARCHITECTURE behavior OF grid_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT grid_display
    PORT(
         clk : IN  std_logic;
         current_location : IN  POINT;
         mode : IN  std_logic_vector(2 downto 0);
         valid_location : OUT  std_logic;
         data : OUT  COLOR
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal current_location : POINT;
   signal mode : std_logic_vector(2 downto 0) := (others => '0');

 	--Outputs
   signal valid_location : std_logic;
   signal data : COLOR;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: grid_display PORT MAP (
          clk => clk,
          current_location => current_location,
          mode => mode,
          valid_location => valid_location,
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

END;
