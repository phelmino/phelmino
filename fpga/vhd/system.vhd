library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

entity system is

  port (
    CLOCK_50               : in  std_logic;
    RESET                  : in  std_logic;
    HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0);
    SW                     : in  std_logic_vector (9 downto 0);
    LEDR                   : out std_logic_vector (9 downto 0));

end entity system;

architecture structural of system is
  component phelmino is
    port (
      clk           : in  std_logic;
      rst_n         : in  std_logic;
      core_input    : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      hex_display_0 : out std_logic_vector(6 downto 0);
      hex_display_1 : out std_logic_vector(6 downto 0);
      hex_display_2 : out std_logic_vector(6 downto 0);
      hex_display_3 : out std_logic_vector(6 downto 0));
  end component phelmino;

  signal core_input      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal next_core_input : std_logic_vector(WORD_WIDTH-1 downto 0);

  --attribute chip_pin of CLOCK_50 : signal is "L1";  -- Si 50 MHz
  --attribute chip_pin of RESET    : signal is "R22";
  --attribute chip_pin of HEX0     : signal is "E2,F1,F2,H1,H2,J1,J2";
  --attribute chip_pin of HEX1     : signal is "D1,D2,G3,H4,H5,H6,E1";
  --attribute chip_pin of HEX2     : signal is "D3,E4,E3,C1,C2,G6,G5";
  --attribute chip_pin of HEX3     : signal is "D4,F3,L8,J4,D6,D5,F4";
  --attribute chip_pin of SW       : signal is "L2,M1,M2,U11,U12,W12,V12,M22,L21,L22";
  --attribute chip_pin of LEDR     : signal is "R17,R18,U18,Y18,V19,T18,Y19,U19,R19,R20";

begin  -- architecture structural

  -- data of the switches copied into leds
  LEDR <= SW;

  phelmino_1 : entity lib_fpga.phelmino
    port map (
      clk           => CLOCK_50,
      rst_n         => RESET,
      core_input    => core_input,
      hex_display_0 => HEX0,
      hex_display_1 => HEX1,
      hex_display_2 => HEX2,
      hex_display_3 => HEX3);

  sequential : process (CLOCK_50, RESET) is
  begin  -- process sequential
    if RESET = '0' then                 -- asynchronous reset (active low)
      core_input <= (others => '0');
    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      core_input <= next_core_input;
    end if;
  end process sequential;

  combinational : process (SW) is
    constant zero_padding : std_logic_vector(21 downto 0) := (others => '0');
  begin  -- process combinational
    next_core_input <= zero_padding & SW;
  end process combinational;

end architecture structural;
