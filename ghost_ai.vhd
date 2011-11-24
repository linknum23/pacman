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
use work.PACAGE.ALL;

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
           rom_addr : out POINT;
           rom_data : in  STD_LOGIC;
           dots_eaten : in  STD_LOGIC_VECTOR (7 downto 0);
           level : in  STD_LOGIC_VECTOR (8 downto 0);
			  ghost_mode : in  STD_LOGIC;
			  pman_loc : POINT;
           done : out  STD_LOGIC;
			  blinky_info : out GHOST_INFO;
			  pinky_info : out GHOST_INFO;
			  inky_info : out GHOST_INFO;
			  clyde_info : out GHOST_INFO;
			  blinky_tile_loc : out POINT;
			  pinky_tile_loc : out POINT;
			  inky_tile_loc : out POINT;
			  clyde_tile_loc : out POINT;
			  collision : out std_logic
			  );
end ghost_ai;

architecture Behavioral of ghost_ai is

	type AI_STATE is (START,CALC_TARGETS,CALC_MOVE,SDONE);
	signal state : AI_STATE := SDONE;
	signal next_state : AI_STATE;
	
	signal do_calc_targets : std_logic; 
	signal do_calc_move : std_logic;
	signal calc_targets_done : std_logic;
	signal calc_move_done : std_logic;
	signal move_rom_addr,target_rom_addr : POINT;
	signal collision_index : natural range 0 to 3;

	component ghost_target_updater is 
		port ( 
			clk : in  STD_LOGIC;
			en : in  STD_LOGIC;
			rst : in  STD_LOGIC;
			rom_addr : out  STD_LOGIC_VECTOR (8 downto 0);
			rom_data : in  STD_LOGIC;
			done : out  STD_LOGIC;
			pman_loc : in POINT;
			ghostmode : in GHOST_MODE;
			blinky_target : out POINT;
			pinky_target : out  POINT;
			inky_target : out  POINT;
			clyde_target : out  POINT
		);
	end component;
	
	component move_ghost is 
	port ( 
		clk : in  STD_LOGIC;
		en : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		rom_addr : out  STD_LOGIC_VECTOR (8 downto 0);
		rom_data : in  STD_LOGIC;
		done : out  STD_LOGIC;
		ghostmode : GHOST_MODE;
		blinky_target : in POINT;
		pinky_target : in POINT;
		inky_target : in  POINT;
		clyde_target : in  POINT;
		blinky_info : out GHOST_INFO;
		pinky_info : out GHOST_INFO;
		inky_info : out GHOST_INFO;
		clyde_info : out GHOST_INFO
	);
	end component;
	
	component collision_machine is
  port(
    clk                  : in  std_logic;
    rst                  : in  std_logic;
    pacman_tile_location : in  POINT;
    blinky_tile_location : in  POINT;
    pinky_tile_location  : in  POINT;
    inky_tile_location   : in  POINT;
    clyde_tile_location  : in  POINT;
	 collision_index 	    : out natural range 0 to 3;
    collision            : out std_logic
    );
end component;
	
	  signal pacman_tile_location,
	  blinky_tile_location, 
	  pinky_tile_location,  
	  inky_tile_location,   
	  clyde_tile_location : POINT;

begin

blinky_tile_loc.X <= to_integer(to_unsigned(blinky_info.PT.X, 9) srl 4);
blinky_tile_loc.Y <= to_integer(to_unsigned(blinky_info.PT.Y, 9) srl 4);
pinky_tile_loc.X <= to_integer(to_unsigned(pinky_info.PT.X, 9) srl 4);
pinky_tile_loc.Y <= to_integer(to_unsigned(pinky_info.PT.Y, 9) srl 4);
inky_tile_loc.X <= to_integer(to_unsigned(inky_info.PT.X, 9) srl 4);
inky_tile_loc.Y <= to_integer(to_unsigned(inky_info.PT.Y, 9) srl 4);
clyde_tile_loc.X <= to_integer(to_unsigned(clyde_info.PT.X, 9) srl 4);
clyde_tile_loc.Y <= to_integer(to_unsigned(CLYDE_info.PT.Y, 9) srl 4);

collision_check : collision_machine
port map(
	  clk                  => clk,
	  rst                  => rst,
	  pacman_tile_location => pman_loc,
	  blinky_tile_location => blinky_tile_loc,
	  pinky_tile_location  => pinky_tile_loc,
	  inky_tile_location   => inky_tile_loc,
	  clyde_tile_location  => clyde_tile_loc,
	  collision_index 	   => collision_index,
	  collision            => collision
  );

ai_routine_next : process(clk,rst) 
begin
	if clk'event and clk = '1' then
		if rst = '1' then
			state <= next_state;
		else
			state <= SDONE;
		end if;
	end if;
end process;

ai_routine : process(state, calc_move_done, calc_targets_done) 
begin
		do_calc_move <= '0';
		do_calc_targets <= '0';
		done <= '0';
		
		case state is
			when START =>
				next_state <= CALC_TARGETS;
			when CALC_TARGETS =>
				do_calc_targets <= '1';
				if calc_targets_done = '1' then 
					next_state <= CALC_MOVE;
				else
					next_state <= CALC_TARGETS;
				end if;
			when CALC_MOVE =>
				do_calc_move <= '1';
				if calc_move_done = '1' then 
					next_state <= SDONE;
				else
					next_state <= CALC_MOVE;
				end if;
			when SDONE =>
				if en = '1' then
					next_state <= START;
					done <= '0';
				else
					next_state <= SDONE;
					done <= '1';
				end if;
			when others =>
				next_state <= SDONE;
		end case;
end process;

rom_mux : process(state)
begin
	case state is
		when CALC_MOVE =>
			rom_addr <= move_rom_addr;
		when CALC_TARGETS =>
			rom_addr <= target_rom_addr;
		when others =>
			rom_addr <= (others => 0);

	end case;

end process;

end Behavioral;

