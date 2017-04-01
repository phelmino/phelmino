library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

package memory_definitions is

  constant MEMORY_WIDTH : natural := WORD_WIDTH;
  constant MEMORY_DEPTH : natural := 16;

  constant RAM_BEGIN : natural := 16#0000#;
  constant RAM_END   : natural := 16#FFFF#;
  constant RAM_DEPTH : natural := 16;
  constant HEX_ADDR  : natural := 16#8FFE#;
  constant IO_ADDR   : natural := 16#8FFF#;

end package memory_definitions;
