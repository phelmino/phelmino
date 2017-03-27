library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity seven_segments is

  port (
    digit  : in  std_logic_vector(3 downto 0);
    output : out std_logic_vector(6 downto 0));

end entity seven_segments;

architecture behavioural of seven_segments is

  type tab_7seg is array (0 to 15) of bit_vector(7 downto 0);
  constant conversion_table : tab_7seg :=
    (0  => x"40",
     1  => x"79",
     2  => x"24",
     3  => x"30",
     4  => x"19",
     5  => x"12",
     6  => x"02",
     7  => x"78",
     8  => x"00",
     9  => x"10",
     10 => x"08",
     11 => x"03",
     12 => x"46",
     13 => x"21",
     14 => x"06",
     15 => x"0E");

begin  -- architecture behavioural

  output <= to_stdlogicvector(conversion_table(to_integer(unsigned(digit)))(6 downto 0));

end architecture behavioural;
