library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.pacage.all;

entity nes_controller is
  port(
    clk        : in  std_logic;
    rst        : in  std_logic;
    power_pin  : out std_logic;
    data_pin   : in  std_logic;
    latch_pin  : out std_logic;
    pulse_pin  : out std_logic;
    ground_pin : out std_logic;
    buttons    : out NES_BUTTONS := (others => '0')
    );
end nes_controller;

architecture Behavioral of nes_controller is
  -- this spec is based off of the following source
  -- http://www.mit.edu/~tarvizo/nes-controller.html

  --60 hz stuff
  constant ONE_60_SECOND : integer                          := 833333;
  signal   counter_60hz  : integer range 0 to ONE_60_SECOND := 0;
  signal   pulse_60hz    : std_logic                        := '0';

  --6us stuff
  constant US_6   : integer := 300;
  constant US_12  : integer := 2*US_6;
  constant US_18  : integer := 3*US_6;
  constant US_24  : integer := 4*US_6;
  constant US_30  : integer := 5*US_6;
  constant US_36  : integer := 6*US_6;
  constant US_42  : integer := 7*US_6;
  constant US_48  : integer := 8*US_6;
  constant US_54  : integer := 9*US_6;
  constant US_60  : integer := 10*US_6;
  constant US_66  : integer := 11*US_6;
  constant US_72  : integer := 12*US_6;
  constant US_78  : integer := 13*US_6;
  constant US_84  : integer := 14*US_6;
  constant US_90  : integer := 15*US_6;
  constant US_96  : integer := 16*US_6;
  constant US_102 : integer := 17*US_6;
  constant US_108 : integer := 18*US_6;

  signal counter_108us : integer range 0 to US_108 := 0;
  signal latch, pulse  : std_logic                 := '0';
begin
  power_pin  <= '1';
  latch_pin  <= latch;
  pulse_pin  <= pulse;
  ground_pin <= '0';

--60 hz counter
  process(clk)
  begin
    if clk = '1' and clk'event then
      pulse_60hz <= '0';
      if counter_60hz = ONE_60_SECOND - 2 then
        pulse_60hz   <= '1';
        counter_60hz <= counter_60hz + 1;
      elsif counter_60hz = ONE_60_SECOND - 1 then
        counter_60hz <= 0;
      else
        counter_60hz <= counter_60hz + 1;
      end if;
    end if;
  end process;

  process(clk)
    variable enable : std_logic := '0';
  begin
    if clk = '1' and clk'event then
      if pulse_60hz = '1' then
        enable := '1';
      end if;
      latch <= '0';
      pulse <= '0';
      if enable = '1' then
        counter_108us <= counter_108us + 1;
        if counter_108us < US_12 then
          latch <= '1';
        elsif counter_108us >= US_18 and counter_108us < US_24 then
          pulse <= '1';
        elsif counter_108us >= US_30 and counter_108us < US_36 then
          pulse <= '1';
        elsif counter_108us >= US_42 and counter_108us < US_48 then
          pulse <= '1';
        elsif counter_108us >= US_54 and counter_108us < US_60 then
          pulse <= '1';
        elsif counter_108us >= US_66 and counter_108us < US_72 then
          pulse <= '1';
        elsif counter_108us >= US_78 and counter_108us < US_84 then
          pulse <= '1';
        elsif counter_108us >= US_90 and counter_108us < US_96 then
          pulse <= '1';
        elsif counter_108us >= US_102 and counter_108us < US_108 then
          pulse <= '1';
        elsif counter_108us >= US_108 then
          enable        := '0';
          counter_108us <= 0;
        end if;
      end if;
    end if;
  end process;

  --only grab the data when the pulse is low.
  process(clk)
  begin
    if clk = '1' and clk'event then
      if counter_108us <= US_12 then
        buttons.A_BUTTON <= not data_pin and not latch;
      elsif counter_108us <= US_18 then
        buttons.A_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_24 then
        buttons.B_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_30 then
        buttons.B_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_36 then
        buttons.SELECT_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_42 then
        buttons.SELECT_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_48 then
        buttons.START_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_54 then
        buttons.START_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_60 then
        buttons.UP_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_66 then
        buttons.UP_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_72 then
        buttons.DOWN_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_78 then
        buttons.DOWN_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_84 then
        buttons.LEFT_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_90 then
        buttons.LEFT_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_96 then
        buttons.RIGHT_BUTTON <= not data_pin and not pulse;
      elsif counter_108us <= US_102 then
        buttons.RIGHT_BUTTON <= not data_pin and not pulse;
      end if;
    end if;
  end process;


end Behavioral;

