--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:32:51 11/23/2011
-- Design Name:   
-- Module Name:   C:/projects/Pacman/pacman/move_ghost_tb1.vhd
-- Project Name:  pacman
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: move_ghost
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
use work.pacage.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY move_ghost_tb1 IS
END move_ghost_tb1;
 
ARCHITECTURE behavior OF move_ghost_tb1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT move_ghost
    PORT(
         clk : IN  std_logic;
         en : IN  std_logic;
         rst : IN  std_logic;
			rom_addr : out  POINT;
			rom_data : in  STD_LOGIC;
			done : out  STD_LOGIC;
			ghost_mode : GHOST_MODE;
			blinky_target : in POINT;
			pinky_target : in POINT;
			inky_target : in  POINT;
			clyde_target : in  POINT;
			blinky_info : out GHOST_INFO;
			pinky_info : out GHOST_INFO;
			inky_info : out GHOST_INFO;
			clyde_info : out GHOST_INFO
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal en : std_logic := '0';
   signal rst : std_logic := '0';
   signal rom_data : std_logic := '0';
   signal ghost_mode : GHOST_MODE := NORMAL;

 	--Outputs
   signal rom_addr : POINT;
   signal done : std_logic;
   signal blinky_info : GHOST_INFO;
   signal pinky_info : GHOST_INFO;
   signal inky_info : GHOST_INFO;
   signal clyde_info : GHOST_INFO;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: move_ghost PORT MAP (
          clk => clk,
          en => en,
          rst => rst,
          rom_addr => rom_addr,
          rom_data => rom_data,
          done => done,
          ghost_mode => ghost_mode,
			 
          blinky_target => (X=>0,Y=>11),
          pinky_target => (X=>0,Y=>11),
          inky_target => (X=>0,Y=>11),
          clyde_target => (X=>0,Y=>11),
			 
          blinky_info => blinky_info,
          pinky_info => pinky_info,
          inky_info => inky_info,
          clyde_info => clyde_info
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
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;	
		rst <= '0';
      wait for clk_period*10;

		en <= '1';
      -- insert stimulus here 

      wait;
   end process;
	
	imit_rom : process 
	begin
		if rom_addr.Y=11 then 
			rom_data <= '1';
		else
			rom_data <= '0';
		end if;
		wait for clk_period;
	end process;
END;
