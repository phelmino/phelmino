library ieee;
use ieee.std_logic_1164.all;

package phelmino_definitions is
  -- ALU Operations
  type alu_operation is (ALU_ADD, ALU_SUB, ALU_XOR, ALU_OR, ALU_AND, ALU_LTU, ALU_GEU, ALU_EQ, ALU_NE);

  -- GPR
  constant WORD_WIDTH          : natural := 32;
  constant WORD_WIDTH_IN_BYTES : natural := WORD_WIDTH/8;
  constant GPR_ADDRESS_WIDTH   : natural := 5;

  -- Prefetch Buffer
  constant PREFETCH_ADDRESS_WIDTH : natural := 2;

  -- Decoder
  constant OPCODE_LENGTH       : natural := 7;
  constant OPCODE_BEGIN        : natural := 6;
  constant OPCODE_END          : natural := 0;
  constant FUNC3_LENGTH        : natural := 3;
  constant FUNC3_BEGIN         : natural := 14;
  constant FUNC3_END           : natural := 12;
  constant FUNC7_LENGTH        : natural := 7;
  constant FUNC7_BEGIN         : natural := 31;
  constant FUNC7_END           : natural := 25;
  constant REG_LENGTH          : natural := 5;
  constant RDESTINATION_BEGIN  : natural := 11;
  constant RDESTINATION_END    : natural := 7;
  constant RSOURCE1_BEGIN      : natural := 19;
  constant RSOURCE1_END        : natural := 15;
  constant RSOURCE2_BEGIN      : natural := 24;
  constant RSOURCE2_END        : natural := 20;
  constant IMMEDIATE_I_LENGTH  : natural := 12;
  constant IMMEDIATE_S_LENGTH  : natural := 12;
  constant IMMEDIATE_I_BEGIN   : natural := 31;
  constant IMMEDIATE_I_END     : natural := 20;
  constant IMMEDIATE_SB_LENGTH : natural := 13;

  -- Controls of MUX generating ALU Operands
  type alu_source is (ALU_SOURCE_ZERO, ALU_SOURCE_FROM_REGISTER, ALU_SOURCE_FROM_ALU, ALU_SOURCE_FROM_WB_STAGE, ALU_SOURCE_FROM_IMM);

  -- OPCODEs from ISA
  constant OPCODE_ALU_REGISTER_REGISTER  : std_logic_vector(OPCODE_LENGTH-1 downto 0) := "0110011";
  constant OPCODE_ALU_IMMEDIATE_REGISTER : std_logic_vector(OPCODE_LENGTH-1 downto 0) := "0010011";
  constant OPCODE_BRANCH                 : std_logic_vector(OPCODE_LENGTH-1 downto 0) := "1100011";
  constant OPCODE_LOAD 			 : std_logic_vector(OPCODE_LENGTH-1 downto 0) := "0000011";
  constant OPCODE_STORE			 : std_logic_vector(OPCODE_LENGTH-1 downto 0) := "0100011";
  
  -- Some instructions
  constant NOP            : std_logic_vector(WORD_WIDTH-1 downto 0) := "0000000" & "00000" & "00000" & "000" & "00000" & "0110011";
  constant ADD_R1_PLUS_R2 : std_logic_vector(WORD_WIDTH-1 downto 0) := "0000000" & "00010" & "00001" & "000" & "11111" & "0110011";
  constant BEQ_R1_R2      : std_logic_vector(WORD_WIDTH-1 downto 0) := "0000000" & "00010" & "00001" & "000" & "00000" & "1100011";
  constant BNE_R1_R2      : std_logic_vector(WORD_WIDTH-1 downto 0) := "0000000" & "00010" & "00001" & "001" & "00000" & "1100011";
  constant LW_R1_0        : std_logic_vector(WORD_WIDTH-1 downto 0) := "000000000000" & "00001" & "010" & "00000" & "0000011";
  constant SW_R2_0 : std_logic_vector(WORD_WIDTH-1 downto 0) := "0000000" & "00010" & "00001" & "010" & "00000" & "0100011";

end package phelmino_definitions;
