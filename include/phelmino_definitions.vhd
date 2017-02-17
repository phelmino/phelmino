library ieee;
use ieee.std_logic_1164.all;

library lib_VHDL;

package phelmino_definitions is

  -- ALU
  constant ALU_OPERATOR_WIDTH : integer := 6;

  -- ALU Operations
  constant ALU_ADD : std_logic_vector             := "000000";
  constant ALU_SUB : std_logic_vector(5 downto 0) := "000010";
  constant ALU_XOR : std_logic_vector(5 downto 0) := "100000";
  constant ALU_OR  : std_logic_vector(5 downto 0) := "110000";
  constant ALU_AND : std_logic_vector(5 downto 0) := "111000";

  -- GPR
  constant WORD_WIDTH        : natural := 32;
  constant GPR_ADDRESS_WIDTH : natural := 5;

  -- Prefetch Buffer
  constant PREFETCH_ADDRESS_WIDTH : natural := 2;

end package phelmino_definitions;
