library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

package memory_definitions is

  constant MEMORY_WIDTH : natural := WORD_WIDTH;
  constant MEMORY_DEPTH : natural := 16;

  constant RAM_BEGIN  : natural := 16#10074#;
  constant RAM_END    : natural := 16#50070#;
  constant RAM_DEPTH  : natural := 16;
  constant HEX_ADDR   : natural := 16#3406C#;
  constant IO_ADDR    : natural := 16#34070#;
  constant PAGE_LIMIT : natural := 16#34074#;

end package memory_definitions;
