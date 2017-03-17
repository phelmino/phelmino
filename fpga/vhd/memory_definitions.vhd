library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

package memory_definitions is

  constant MEMORY_WIDTH : natural := WORD_WIDTH;
  constant MEMORY_DEPTH : natural := 8;

  constant ROM_BEGIN   : natural := 16#00#;
  constant ROM_END     : natural := 16#7F#;
  constant ROM_DEPTH   : natural := ROM_END - ROM_BEGIN;
  constant RAM_BEGIN   : natural := 16#80#;
  constant RAM_END     : natural := 16#F9#;
  constant RAM_DEPTH   : natural := RAM_END - RAM_BEGIN;
  constant HEX_BEGIN   : natural := 16#FA#;
  constant HEX_END     : natural := 16#FD#;
  constant HEX_DEPTH   : natural := HEX_END - HEX_BEGIN;
  constant INPUT_ADDR  : natural := 16#FE#;
  constant OUTPUT_ADDR : natural := 16#FF#;

end package memory_definitions;
