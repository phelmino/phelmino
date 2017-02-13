library ieee;
use ieee.std_logic_1164.all;

package phelmino_definitions is

  -- ALU
  constant ALU_OPERATOR_WIDTH : integer := 6;
  
  -- ALU Operations
  constant ALU_ADD : std_logic_vector := "000000";
  constant ALU_SUB : std_logic_vector(5 downto 0) := "000010";
  constant ALU_XOR : std_logic_vector(5 downto 0) := "100000";
  constant ALU_OR : std_logic_vector(5 downto 0) := "110000";
  constant ALU_AND : std_logic_vector(5 downto 0)  := "111000";

end package phelmino_definitions;
