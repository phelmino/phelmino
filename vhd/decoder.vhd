library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity Decoder is

  port (
    Instruction_Input           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    Instruction_Valid           : out std_logic;
    Read_Address_A_Output       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    Read_Address_B_Output       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    ALU_Operator_Output         : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
    Mux_Controller_A            : out std_logic_vector(1 downto 0);
    Mux_Controller_B            : out std_logic_vector(1 downto 0);
    Mux_Controller_Branch       : out std_logic_vector(2 downto 0);
    Destination_Register_Output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    Immediate_Extension_Output  : out std_logic_vector(WORD_WIDTH-1 downto 0));

end entity Decoder;

architecture Behavioural of Decoder is
begin  -- architecture Behavioural

  -- purpose: Decodes an Instruction
  -- type   : combinational
  -- inputs : Instruction_Input
  Decoder_Process : process (Instruction_Input) is
    variable OPCODE       : std_logic_vector(OPCODE_LENGTH-1 downto 0) := (others => '0');
    variable FUNC7        : std_logic_vector(FUNC7_LENGTH-1 downto 0)  := (others => '0');
    variable FUNC3        : std_logic_vector(FUNC3_LENGTH-1 downto 0)  := (others => '0');
    variable RSOURCE1     : std_logic_vector(REG_LENGTH-1 downto 0)    := (others => '0');
    variable RSOURCE2     : std_logic_vector(REG_LENGTH-1 downto 0)    := (others => '0');
    variable RDESTINATION : std_logic_vector(REG_LENGTH-1 downto 0)    := (others => '0');
  begin  -- process Decoder_Process
    OPCODE       := Instruction_Input(OPCODE_BEGIN downto OPCODE_END);
    FUNC7        := Instruction_Input(FUNC7_BEGIN downto FUNC7_END);
    FUNC3        := Instruction_Input(FUNC3_BEGIN downto FUNC3_END);
    RSOURCE1     := Instruction_Input(RSOURCE1_BEGIN downto RSOURCE1_END);
    RSOURCE2     := Instruction_Input(RSOURCE2_BEGIN downto RSOURCE2_END);
    RDESTINATION := Instruction_Input(RDESTINATION_BEGIN downto RDESTINATION_END);

    case OPCODE is
      when OPCODE_ALU_REGISTER_REGISTER =>
        Read_Address_A_Output       <= RSOURCE1;
        Read_Address_B_Output       <= RSOURCE2;
        Mux_Controller_A            <= ALU_SOURCE_FROM_REGISTER;
        Mux_Controller_B            <= ALU_SOURCE_FROM_REGISTER;
        Mux_Controller_Branch       <= BRANCH_MUX_NOT_IN_A_BRANCH;
        Instruction_Valid           <= '1';
        Destination_Register_Output <= RDESTINATION;
        Immediate_Extension_Output  <= (others => '0');
        ALU_Operator_Output         <= ALU_ADD;
        case FUNC3 is
          when "000" =>
            case FUNC7 is
              when "0000000" => ALU_Operator_Output <= ALU_ADD;
              when "0100000" => ALU_Operator_Output <= ALU_SUB;
              when others    => Instruction_Valid   <= '0';
            end case;

          when "100" =>
            case FUNC7 is
              when "0000000" => ALU_Operator_Output <= ALU_XOR;
              when others    => Instruction_Valid   <= '0';
            end case;

          when "110" =>
            case FUNC7 is
              when "0000000" => ALU_Operator_Output <= ALU_OR;
              when others    => Instruction_Valid   <= '0';
            end case;

          when "111" =>
            case FUNC7 is
              when "0000000" => ALU_Operator_Output <= ALU_AND;
              when others    => Instruction_Valid   <= '0';
            end case;

          when others =>
            Instruction_Valid <= '0';
        end case;

      when others =>
        Instruction_Valid           <= '0';
        Mux_Controller_A            <= ALU_SOURCE_ZERO;
        Mux_Controller_B            <= ALU_SOURCE_ZERO;
        Mux_Controller_Branch       <= BRANCH_MUX_NOT_IN_A_BRANCH;
        Read_Address_A_Output       <= (others => '0');
        Read_Address_B_Output       <= (others => '0');
        ALU_Operator_Output         <= ALU_ADD;
        Destination_Register_Output <= (others => '0');
        Immediate_Extension_Output  <= (others => '0');
    end case;

  end process Decoder_Process;

end architecture Behavioural;
