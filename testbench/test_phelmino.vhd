library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

library lib_fpga;
use lib_fpga.all;
use lib_fpga.memory_definitions.all;

--library lib_synth_fpga;
--use lib_synth_fpga.all;

entity test_phelmino is

end entity test_phelmino;

architecture behavioural of test_phelmino is

  component system is
    port (
      CLOCK_50               : in  std_logic;
      RESET                  : in  std_logic;
      HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0);
      SW                     : in  std_logic_vector (9 downto 0);
      LEDR                   : out std_logic_vector (9 downto 0));
  end component system;
  signal CLOCK_50               : std_logic := '0';
  signal RESET                  : std_logic := '0';
  signal HEX0, HEX1, HEX2, HEX3 : std_logic_vector(6 downto 0);
  signal SW                     : std_logic_vector (9 downto 0);
  signal LEDR                   : std_logic_vector (9 downto 0);

begin  -- architecture behavioural

  CLOCK_50 <= not CLOCK_50 after 10 ns;
  RESET    <= '1'          after 15 ns;

  dut : system
    port map (
      CLOCK_50 => CLOCK_50,
      RESET    => RESET,
      HEX0     => HEX0,
      HEX1     => HEX1,
      HEX2     => HEX2,
      HEX3     => HEX3,
      SW       => SW,
      LEDR     => LEDR);

end architecture behavioural;
