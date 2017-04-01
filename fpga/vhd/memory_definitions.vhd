library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

package memory_definitions is

  constant MEMORY_WIDTH : natural := WORD_WIDTH;
  constant MEMORY_DEPTH : natural := 12;

  constant ROM_BEGIN : natural := 16#000#;
  constant ROM_END   : natural := 16#F7F#;
  constant ROM_DEPTH : natural := 12;
  constant RAM_BEGIN : natural := 16#F80#;
  constant RAM_END   : natural := 16#FFE#;
  constant RAM_DEPTH : natural := 12;
  constant HEX_ADDR  : natural := 16#FFE#;
  constant IO_ADDR   : natural := 16#FFF#;

end package memory_definitions;
