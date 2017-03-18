library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

package memory_definitions is

  constant MEMORY_WIDTH : natural := WORD_WIDTH;
  constant MEMORY_DEPTH : natural := 8;

  constant ROM_BEGIN : natural := 16#00#;
  constant ROM_END   : natural := 16#7F#;
  constant ROM_DEPTH : natural := 8;
  constant RAM_BEGIN : natural := 16#80#;
  constant RAM_END   : natural := 16#FF#;
  constant RAM_DEPTH : natural := 8;
  constant HEX_ADDR  : natural := 16#FE#;
  constant IO_ADDR   : natural := 16#FF#;

end package memory_definitions;
