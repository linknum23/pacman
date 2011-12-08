--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:35:23 12/06/2011
-- Design Name:   
-- Module Name:   C:/projects/Pacman/pacman/ghost_score_TB.vhd
-- Project Name:  pacman
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ghost_score_display
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
 
ENTITY ghost_score_TB IS
END ghost_score_TB;
 
ARCHITECTURE behavior OF ghost_score_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ghost_score_display
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         current_draw_location : IN  POINT;
         pacman_tile : IN  POINT;
         gameinfo : IN  game_info;
         data : OUT  COLOR;
         valid_location : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal current_draw_location : POINT := (0,0);
   signal pacman_tile : POINT := (0,0);
   signal gameinfo : game_info ;

 	--Outputs
   signal data : COLOR;
   signal valid_location : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ghost_score_display PORT MAP (
          clk => clk,
          rst => rst,
          current_draw_location => current_draw_location,
          pacman_tile => pacman_tile,
          gameinfo => gameinfo,
          data => data,
          valid_location => valid_location
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	gameinfo.ghost_score <= "00011001000";
 current_draw_location.x <= current_draw_location.x + 1 after 10ns;
 current_draw_location.y <= current_draw_location.y + 1 after 160ns;
 pacman_tile.X <= 0;
 pacman_tile.Y <= 0;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
