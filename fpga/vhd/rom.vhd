library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

entity rom is
  
  generic (
    rom_depth  : natural := ROM_DEPTH;
    word_width : natural := MEMORY_WIDTH);

end entity rom;
