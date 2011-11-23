library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacage.all;

entity display_manager is
   Port ( 
      clk : in std_logic;
      rst : in std_logic;
      current_draw_location : in POINT;
      data : out COLOR
      );
end display_manager;

architecture Behavioral of display_manager is
   component grid_display is
       Port ( 
         clk : in std_logic;
         rst : in std_logic;
         pacman_location : in POINT;
         current_draw_location : in POINT;
         mode : in std_logic_vector(2 downto 0);
         valid_location : out std_logic;
         data_type : out std_logic_vector(4 downto 0);
         data : out COLOR
         );
   end component;
   
   signal grid_valid : std_logic :='0';
   signal grid_color_data : COLOR;
   signal pacman_location : POINT;

begin
board: grid_display 
   PORT MAP (
       clk => clk,
       rst => rst,
       pacman_location => pacman_location,
       current_draw_location => current_draw_location,
       mode => "000",
       valid_location => grid_valid,
       data => grid_color_data
     );  
     
     data <= grid_color_data;

end Behavioral;

