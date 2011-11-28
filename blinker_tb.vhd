--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   03:05:00 11/28/2011
-- Design Name:   
-- Module Name:   C:/projects/Pacman/pacman/blinker_tb.vhd
-- Project Name:  pacman
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ghost_frightened_blink
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.pacage.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY blinker_tb IS
END blinker_tb;
 
ARCHITECTURE behavior OF blinker_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ghost_frightened_blink
    PORT(
         gamemode : IN  GAME_INFO;
         clk_65 : IN  std_logic;
         blink : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal gameinfo : GAME_INFO;
   signal clk_65 : std_logic := '0';

 	--Outputs
   signal blink : std_logic;

   -- Clock period definitions
   constant clk_65_period : time := 15 ns;
 
BEGIN
 

 
	-- Instantiate the Unit Under Test (UUT)
   uut: ghost_frightened_blink PORT MAP (
          gamemode => gameinfo,
          clk_65 => clk_65,
          blink => blink
        );

   -- Clock process definitions
   clk_65_process :process
   begin
		clk_65 <= '0';
		wait for clk_65_period/2;
		clk_65 <= '1';
		wait for clk_65_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		 gameinfo.ghostmode         <= NORMAL;
		gameinfo.level             <= "000000000";

      wait for clk_65_period*10;
				 gameinfo.ghostmode         <= FRIGHTENED;

      -- insert stimulus here 

      wait;
   end process;

END;
