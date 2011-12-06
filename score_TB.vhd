--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:55:11 12/05/2011
-- Design Name:   
-- Module Name:   C:/projects/Pacman/pacman/score_TB.vhd
-- Project Name:  pacman
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: score_manager
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
 
ENTITY score_TB IS
END score_TB;
 
ARCHITECTURE behavior OF score_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT score_manager
    generic (
    GAME_SIZE   : POINT := (448, 496);
    GAME_OFFSET : POINT := (100, 100)
    );
  port(
    clk, clk_25           : in  std_logic;
    rst                   : in  std_logic;
    current_draw_location : in  POINT;
    gameinfo              : in  GAME_INFO;
    data                  : out COLOR;
    valid_location        : out std_logic
    );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clk_25 : std_logic := '0';
   signal rst : std_logic := '0';
   signal current_draw_location : POINT := (0,0);
   signal gameinfo : GAME_INFO;

 	--Outputs
   signal data : COLOR;
   signal valid_location : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant clk_25_period : time := 10 ns;
 
BEGIN
gameinfo.score <= 50, 49 after 200ns;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: score_manager PORT MAP (
          clk => clk,
          clk_25 => clk_25,
          rst => rst,
          current_draw_location => current_draw_location,
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
 
   clk_25_process :process
   begin
		clk_25 <= '0';
		wait for clk_25_period/2;
		clk_25 <= '1';
		wait for clk_25_period/2;
   end process;
 

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
