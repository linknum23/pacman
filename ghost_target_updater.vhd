----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:47:06 11/23/2011 
-- Design Name: 
-- Module Name:    ghost_target_updater - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ghost_target_updater is 
	port ( 
		clk : in  STD_LOGIC;
		en : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		rom_addr : out  STD_LOGIC_VECTOR (8 downto 0);
		rom_data : in  STD_LOGIC;
		done : out  STD_LOGIC;
		pman_loc : in POINT;
		ghost_mode : in GHOST_MODE;
		blinky_target : out POINT;
		pinky_target : out  POINT;
		inky_target : out  POINT;
		clyde_target : out  POINT

	);
	end ghost_target_updater;
	
architecture Behavioral of ghost_target_updater is

begin


end Behavioral;

