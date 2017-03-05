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
    Destination_Register_Output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0));

end entity Decoder;

architecture Behavioural of Decoder is
begin  -- architecture Behavioural

  -- purpose: Decodes an Instruction
  -- type   : combinational
  -- inputs : Instruction_Input
  Decoder_Process : process (Instruction_Input) is
    alias OPCODE is Instruction_Input(OPCODE_BEGIN downto OPCODE_END);
    alias FUNC7 is Instruction_Input(FUNC7_BEGIN downto FUNC7_END);
    alias FUNC3 is Instruction_Input(FUNC3_BEGIN downto FUNC3_END);
    alias RSOURCE1 is Instruction_Input(RSOURCE1_BEGIN downto RSOURCE1_END);
    alias RSOURCE2 is Instruction_Input(RSOURCE2_BEGIN downto RSOURCE2_END);
    alias RDESTINATION is Instruction_Input(RDESTINATION_BEGIN downto RDESTINATION_END);
  begin  -- process Decoder_Process 
    case OPCODE is
      when OPCODE_ALU_REGISTER_REGISTER =>
        Read_Address_A_Output       <= RSOURCE1;
        Read_Address_B_Output       <= RSOURCE2;
        Mux_Controller_A            <= ALU_SOURCE_FROM_REGISTER;
        Mux_Controller_B            <= ALU_SOURCE_FROM_REGISTER;
        Mux_Controller_Branch       <= BRANCH_MUX_NOT_IN_A_BRANCH;
        Instruction_Valid           <= '1';
        Destination_Register_Output <= RDESTINATION;
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

      when OPCODE_BRANCH =>
        -- Adds rs1 and rs2 and stores in rs0. This has no effect on the GPR.
        Read_Address_A_Output       <= RSOURCE1;
        ALU_Operator_Output         <= ALU_ADD;
        Read_Address_B_Output       <= RSOURCE2;
        Destination_Register_Output <= (others => '0');
        Mux_Controller_A            <= ALU_SOURCE_FROM_REGISTER;
        Mux_Controller_B            <= ALU_SOURCE_FROM_REGISTER;
        Instruction_Valid           <= '1';
        
        case FUNC3 is
          when "000" => Mux_Controller_Branch <= BRANCH_MUX_EQUAL;
          when "001" => Mux_Controller_Branch <= BRANCH_MUX_UNEQUAL;
          when "100" => Mux_Controller_Branch <= BRANCH_MUX_LESS_THAN;
          when "101" => Mux_Controller_Branch <= BRANCH_MUX_GREATER_OR_EQUAL;
          when others =>
            Mux_Controller_Branch <= BRANCH_MUX_NOT_IN_A_BRANCH;
            Instruction_Valid     <= '0';
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
    end case;
  end process Decoder_Process;

end architecture Behavioural;
