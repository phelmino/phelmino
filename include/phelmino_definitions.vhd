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

  -- Decoder
  constant OPCODE_LENGTH      : natural := 7;
  constant OPCODE_BEGIN       : natural := 6;
  constant OPCODE_END         : natural := 0;
  constant FUNC3_LENGTH       : natural := 3;
  constant FUNC3_BEGIN        : natural := 14;
  constant FUNC3_END          : natural := 12;
  constant FUNC7_LENGTH       : natural := 7;
  constant FUNC7_BEGIN        : natural := 31;
  constant FUNC7_END          : natural := 25;
  constant REG_LENGTH         : natural := 5;
  constant RDESTINATION_BEGIN : natural := 11;
  constant RDESTINATION_END   : natural := 7;
  constant RSOURCE1_BEGIN     : natural := 19;
  constant RSOURCE1_END       : natural := 15;
  constant RSOURCE2_BEGIN     : natural := 24;
  constant RSOURCE2_END       : natural := 20;

  constant ALU_SOURCE_ZERO             : std_logic_vector(1 downto 0) := "00";
  constant ALU_SOURCE_FROM_REGISTER    : std_logic_vector(1 downto 0) := "01";
  constant BRANCH_MUX_NOT_IN_A_BRANCH  : std_logic_vector(2 downto 0) := "000";
  constant BRANCH_MUX_EQUAL            : std_logic_vector(2 downto 0) := "001";
  constant BRANCH_MUX_UNEQUAL          : std_logic_vector(2 downto 0) := "010";
  constant BRANCH_MUX_LESS_THAN        : std_logic_vector(2 downto 0) := "011";
  constant BRANCH_MUX_GREATER_OR_EQUAl : std_logic_vector(2 downto 0) := "100";

  -- OPCODEs from ISA
  constant OPCODE_ALU_REGISTER_REGISTER : std_logic_vector(OPCODE_LENGTH-1 downto 0) := "0110011";

  -- Some instructions
  constant NOP            : std_logic_vector(WORD_WIDTH-1 downto 0) := "0000000" & "00000" & "00000" & "000" & "00000" & "0110011";
  constant ADD_R1_PLUS_R2 : std_logic_vector(WORD_WIDTH-1 downto 0) := "0000000" & "00010" & "00001" & "000" & "11111" & "0110011";

end package phelmino_definitions;
