library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use work.pacage.all;
use IEEE.NUMERIC_STD.all;

entity ghost_ai is
  port (clk             : in  std_logic;
        en              : in  std_logic;
        rst             : in  std_logic;
        rom_addr        : out POINT;
        rom_data        : in  std_logic;
        dots_eaten      : in  std_logic_vector (7 downto 0);
        level           : in  std_logic_vector (8 downto 0);
        ghostmode       : in  GHOST_MODE;
        pman_loc        : in  POINT;
        done            : out std_logic;
        blinky_info     : out GHOST_INFO;
        pinky_info      : out GHOST_INFO;
        inky_info       : out GHOST_INFO;
        clyde_info      : out GHOST_INFO;
        blinky_tile_loc : out POINT;
        pinky_tile_loc  : out POINT;
        inky_tile_loc   : out POINT;
        clyde_tile_loc  : out POINT;
		  squiggle : out std_logic;
        collision       : out std_logic
        );
end ghost_ai;

architecture Behavioral of ghost_ai is

  type   AI_STATE is (START, CALC_TARGETS, CALC_MOVE, SDONE);
  signal state      : AI_STATE := SDONE;
  signal next_state : AI_STATE;

  --internal components go and done signals for the state controller
  signal do_calc_targets   : std_logic;
  signal do_calc_move      : std_logic;
  signal calc_targets_done : std_logic;
  signal calc_move_done    : std_logic;

  signal move_rom_addr, target_rom_addr : POINT;
  signal collision_index                : natural range 0 to 3;

  signal blinky_target       : POINT;
  signal pinky_target        : POINT;
  signal inky_target         : POINT;
  signal clyde_target        : POINT;
  signal blinky_info_int     : GHOST_INFO;
  signal pinky_info_int      : GHOST_INFO;
  signal inky_info_int       : GHOST_INFO;
  signal clyde_info_int      : GHOST_INFO;
  signal blinky_tile_loc_int : POINT;
  signal pinky_tile_loc_int  : POINT;
  signal inky_tile_loc_int   : POINT;
  signal clyde_tile_loc_int  : POINT;


  signal pacman_tile_location,
    blinky_tile_location,
    pinky_tile_location,
    inky_tile_location,
    clyde_tile_location : POINT;
  
  component ghost_target_updater is
    port (
      clk             : in  std_logic;
      en              : in  std_logic;
      rst             : in  std_logic;
      rom_addr        : out POINT;
      rom_data        : in  std_logic;
      done            : out std_logic;
      pman_tile_loc   : in  POINT;
      blinky_tile_loc : in  POINT;
      pinky_tile_loc  : in  POINT;
      inky_tile_loc   : in  POINT;
      clyde_tile_loc  : in  POINT;
      ghostmode       : in  GHOST_MODE;
      blinky_target   : out POINT;
      pinky_target    : out POINT;
      inky_target     : out POINT;
      clyde_target    : out POINT
      );
  end component;

  component move_ghost is
    port (
      clk           : in  std_logic;
      en            : in  std_logic;
      rst           : in  std_logic;
      rom_addr      : out POINT;
      rom_data      : in  std_logic;
      done          : out std_logic;
      ghostmode     :     GHOST_MODE;
      blinky_target : in  POINT;
      pinky_target  : in  POINT;
      inky_target   : in  POINT;
      clyde_target  : in  POINT;
      blinky_info   : out GHOST_INFO;
      pinky_info    : out GHOST_INFO;
      inky_info     : out GHOST_INFO;
      clyde_info    : out GHOST_INFO;
		squiggle : out std_logic
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
      collision_index      : out natural range 0 to 3;
      collision            : out std_logic
      );
  end component;

begin

  blinky_tile_loc_int.X <= to_integer(to_unsigned(blinky_info_int.PT.X, 9) srl 4);
  blinky_tile_loc_int.Y <= to_integer(to_unsigned(blinky_info_int.PT.Y, 9) srl 4);
  pinky_tile_loc_int.X  <= to_integer(to_unsigned(pinky_info_int.PT.X, 9) srl 4);
  pinky_tile_loc_int.Y  <= to_integer(to_unsigned(pinky_info_int.PT.Y, 9) srl 4);
  inky_tile_loc_int.X   <= to_integer(to_unsigned(inky_info_int.PT.X, 9) srl 4);
  inky_tile_loc_int.Y   <= to_integer(to_unsigned(inky_info_int.PT.Y, 9) srl 4);
  clyde_tile_loc_int.X  <= to_integer(to_unsigned(clyde_info_int.PT.X, 9) srl 4);
  clyde_tile_loc_int.Y  <= to_integer(to_unsigned(clyde_info_int.PT.Y, 9) srl 4);

  collision_check : collision_machine
    port map(
      clk                  => clk,
      rst                  => rst,
      pacman_tile_location => pman_loc,
      blinky_tile_location => blinky_tile_loc_int,
      pinky_tile_location  => pinky_tile_loc_int,
      inky_tile_location   => inky_tile_loc_int,
      clyde_tile_location  => clyde_tile_loc_int,
      collision_index      => collision_index,
      collision            => collision
      );

  blinky_tile_loc <= blinky_tile_loc_int;
  pinky_tile_loc  <= pinky_tile_loc_int;
  inky_tile_loc   <= inky_tile_loc_int;
  clyde_tile_loc  <= clyde_tile_loc_int;

  blinky_info <= blinky_info_int;
  pinky_info  <= pinky_info_int;
  inky_info   <= inky_info_int;
  clyde_info  <= clyde_info_int;


  target_ai : ghost_target_updater
    port map(
      clk             => clk,
      en              => do_calc_targets,
      rst             => rst,
      rom_addr        => target_rom_addr,
      rom_data        => rom_data,
      done            => calc_targets_done,
      ghostmode       => ghostmode,
      pman_tile_loc   => pman_loc,
      blinky_target   => blinky_target,
      pinky_target    => pinky_target,
      inky_target     => inky_target,
      clyde_target    => clyde_target,
      blinky_tile_loc => blinky_tile_loc_int,
      pinky_tile_loc  => pinky_tile_loc_int,
      inky_tile_loc   => inky_tile_loc_int,
      clyde_tile_loc  => clyde_tile_loc_int
      );

  move : move_ghost
    port map(
      clk           => clk,
      en            => do_calc_move,
      rst           => rst,
      rom_addr      => move_rom_addr,
      rom_data      => rom_data,
      done          => calc_move_done,
      ghostmode     => ghostmode,
      blinky_target => blinky_target,
      pinky_target  => pinky_target,
      inky_target   => inky_target,
      clyde_target  => clyde_target,
      blinky_info   => blinky_info_int,
      pinky_info    => pinky_info_int,
      inky_info     => inky_info_int,
      clyde_info    => clyde_info_int,
		squiggle => squiggle
      );

  ai_routine_next : process(clk, rst)
  begin
    if clk'event and clk = '1' then
      if rst = '1' then
        state <= next_state;
      else
        state <= SDONE;
      end if;
    end if;
  end process;

  rom_mux : process(state,move_rom_addr,target_rom_addr)
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

  ai_routine : process(state, en, calc_move_done, calc_targets_done)
  begin
    do_calc_move    <= '0';
    do_calc_targets <= '0';
    done            <= '0';

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
          done       <= '0';
        else
          next_state <= SDONE;
          done       <= '1';
        end if;
      when others =>
        next_state <= SDONE;
    end case;
  end process;

end Behavioral;

