--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   02:55:13 12/06/2011
-- Design Name:   
-- Module Name:   C:/projects/Pacman/pacman/game_grid_TB.vhd
-- Project Name:  pacman
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: game_grid
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
 
ENTITY game_grid_TB IS
END game_grid_TB;
 
ARCHITECTURE behavior OF game_grid_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT game_grid
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         addr : IN  POINT;
         cs : IN  std_logic;
         we : IN  std_logic;
         data_in : IN  std_logic_vector(4 downto 0);
         data_out : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal addr : POINT := (0,0);
   signal cs : std_logic := '0';
   signal we : std_logic := '0';
   signal data_in : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
rst <= '1','0' after 10ns;
cs <= '1';
 
	-- Instantiate the Unit Under Test (UUT)
   uut: game_grid 
	PORT MAP (
          clk => clk,
          rst => rst,
          addr => addr,
          cs => cs,
          we => we,
          data_in => data_in,
          data_out => data_out
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
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
