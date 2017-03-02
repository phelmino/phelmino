library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity Decoder is

  port (
    Instruction_Input           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    Read_Enable_A_Output        : out std_logic;
    Read_Address_A_Output       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);  -- Read_Enable_B_Output
    Read_Enable_B_Output        : out std_logic;
    Read_Address_B_Output       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    ALU_Operator_Output         : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
    Destination_Register_Output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    Immediate_Extension_Output  : out std_logic_vector(WORD_WIDTH-1 downto 0));

end entity Decoder;

architecture Behavioural of Decoder is
  signal OPCODE       : std_logic_vector(OPCODE_LENGTH-1 downto 0) := (others => '0');
  signal FUNC7        : std_logic_vector(FUNC7_LENGTH-1 downto 0)  := (others => '0');
  signal FUNC3        : std_logic_vector(FUNC3_LENGTH-1 downto 0)  := (others => '0');
  signal RSOURCE1     : std_logic_vector(REG_LENGTH-1 downto 0)    := (others => '0');
  signal RSOURCE2     : std_logic_vector(REG_LENGTH-1 downto 0)    := (others => '0');
  signal RDESTINATION : std_logic_vector(REG_LENGTH-1 downto 0)    := (others => '0');
begin  -- architecture Behavioural

  -- purpose: Decodes an Instruction
  -- type   : combinational
  -- inputs : Instruction_Input
  Decoder_Process : process (Instruction_Input) is
  begin  -- process Decoder_Process
    OPCODE       <= Instruction_Input(OPCODE_BEGIN downto OPCODE_END);
    FUNC7        <= Instruction_Input(FUNC7_BEGIN downto FUNC7_END);
    FUNC3        <= Instruction_Input(FUNC3_BEGIN downto FUNC3_END);
    RSOURCE1     <= Instruction_Input(RSOURCE1_BEGIN downto RSOURCE1_END);
    RSOURCE2     <= Instruction_Input(RSOURCE2_BEGIN downto RSOURCE2_END);
    RDESTINATION <= Instruction_Input(RDESTINATION_BEGIN downto RDESTINATION_END);

  end process Decoder_Process;

end architecture Behavioural;
