----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:23:26 11/22/2011 
-- Design Name: 
-- Module Name:    ghost_ai - Behavioral 
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

entity ghost_ai is
    Port ( clk : in  STD_LOGIC;
           en : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           rom_addr : out  STD_LOGIC_VECTOR (8 downto 0);
           rom_data : in  STD_LOGIC;
           dots_eaten : in  STD_LOGIC_VECTOR (7 downto 0);
           level : in  STD_LOGIC_VECTOR (8 downto 0);
           done : out  STD_LOGIC;
           ghost_mode : out  STD_LOGIC);
end ghost_ai;

architecture Behavioral of ghost_ai is

begin


end Behavioral;

