library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

--library lib_synth_fpga;
--use lib_synth_fpga.all;

entity test_phelmino is

end entity test_phelmino;

architecture behavioural of test_phelmino is

  component system
    port (
      CLOCK_50               : in  std_logic;
      RESET                  : in  std_logic;
      core_output            : out std_logic_vector(WORD_WIDTH-1 downto 0);
      HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0)); 
  end component;
  signal CLOCK_50               : std_logic := '0';
  signal RESET                  : std_logic := '0';
  signal core_output            : std_logic_vector(31 downto 0);
  signal HEX0, HEX1, HEX2, HEX3 : std_logic_vector(6 downto 0);
  
begin  -- architecture behavioural

  CLOCK_50 <= not CLOCK_50 after 10 ns;
  RESET    <= '1'          after 15 ns;

  dut : system
    port map (
      CLOCK_50    => CLOCK_50,
      RESET       => RESET,
      core_output => core_output,
      HEX0        => HEX0,
      HEX1        => HEX1,
      HEX2        => HEX2,
      HEX3        => HEX3); 

end architecture behavioural;
