library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

package memory_definitions is

  constant MEMORY_WIDTH : natural := WORD_WIDTH;
  constant MEMORY_DEPTH : natural := 14;
  constant RAM_DEPTH    : natural := 14;
  constant IO_ADDR      : natural := 16#80000#;

end package memory_definitions;
