library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity decoder is

  port (
    instruction          : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    instruction_valid    : out std_logic;
    read_address_a       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    read_address_b       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    alu_operator         : out alu_operation;
    mux_controller_a     : out alu_source;
    mux_controller_b     : out alu_source;
    is_requisition       : out std_logic;
    is_write             : out std_logic;
    is_branch            : out std_logic;
    is_jump              : out std_logic;
    destination_register : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    immediate_extension  : out std_logic_vector(WORD_WIDTH-1 downto 0));

end entity decoder;

architecture behavioural of decoder is

  signal sign_extended_immediate : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal zero_extended_immediate : std_logic_vector(WORD_WIDTH-1 downto 0);

  signal opcode       : std_logic_vector(OPCODE_LENGTH-1 downto 0);
  signal func7        : std_logic_vector(FUNC7_LENGTH-1 downto 0);
  signal func3        : std_logic_vector(FUNC3_LENGTH-1 downto 0);
  signal rsource1     : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal rsource2     : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal rdestination : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

  signal sign_bit          : std_logic;
  signal immediate_type_i  : std_logic_vector(IMMEDIATE_I_LENGTH-1 downto 0);
  signal immediate_type_s  : std_logic_vector(IMMEDIATE_S_LENGTH-1 downto 0);
  signal immediate_type_sb : std_logic_vector(IMMEDIATE_SB_LENGTH-1 downto 0);
  signal immediate_type_u  : std_logic_vector(IMMEDIATE_U_LENGTH-1 downto 0);
  signal immediate_type_uj : std_logic_vector(IMMEDIATE_UJ_LENGTH-1 downto 0);

begin  -- architecture behavioural

  opcode       <= instruction(OPCODE_BEGIN downto OPCODE_END);
  func7        <= instruction(FUNC7_BEGIN downto FUNC7_END);
  func3        <= instruction(FUNC3_BEGIN downto FUNC3_END);
  rsource1     <= instruction(RSOURCE1_BEGIN downto RSOURCE1_END);
  rsource2     <= instruction(RSOURCE2_BEGIN downto RSOURCE2_END);
  rdestination <= instruction(RDESTINATION_BEGIN downto RDESTINATION_END);

  sign_bit <= instruction(WORD_WIDTH-1);

  immediate_type_i  <= instruction(31 downto 20);
  immediate_type_sb <= instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';
  immediate_type_s  <= instruction(31 downto 25) & instruction(11 downto 7);
  immediate_type_u  <= instruction(31 downto 12) & "000000000000";
  immediate_type_uj <= instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0';

  -- purpose: decodes an instruction
  -- type   : combinational
  -- inputs : instruction
  decoder_process : process (func3, func7, opcode, rdestination, rsource1,
                             rsource2, sign_extended_immediate) is
  begin  -- process decoder_process 

    case opcode is
      when OPCODE_ALU_REGISTER_REGISTER =>
        read_address_a       <= rsource1;
        read_address_b       <= rsource2;
        mux_controller_a     <= ALU_SOURCE_FROM_REGISTER;
        mux_controller_b     <= ALU_SOURCE_FROM_REGISTER;
        instruction_valid    <= '1';
        is_requisition       <= '0';
        is_branch            <= '0';
        is_jump              <= '0';
        destination_register <= rdestination;
        alu_operator         <= ALU_ADD;
        is_write             <= '0';
        immediate_extension  <= sign_extended_immediate;

        case func3 is
          when "000" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_ADD;
              when "0100000" => alu_operator      <= ALU_SUB;
              when others    => instruction_valid <= '0';
            end case;

          when "001" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_SLL;
              when others    => instruction_valid <= '0';
            end case;

          when "010" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_LT;
              when others    => instruction_valid <= '0';
            end case;

          when "011" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_LTU;
              when others    => instruction_valid <= '0';
            end case;

          when "100" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_XOR;
              when others    => instruction_valid <= '0';
            end case;

          when "101" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_SRL;
              when "0100000" => alu_operator      <= ALU_SRA;
              when others    => instruction_valid <= '0';
            end case;

          when "110" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_OR;
              when others    => instruction_valid <= '0';
            end case;

          when "111" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_AND;
              when others    => instruction_valid <= '0';
            end case;

          when others =>
            instruction_valid <= '0';
        end case;

      when OPCODE_ALU_IMMEDIATE_REGISTER =>
        read_address_a       <= rsource1;
        read_address_b       <= rsource2;
        mux_controller_a     <= ALU_SOURCE_FROM_REGISTER;
        mux_controller_b     <= ALU_SOURCE_FROM_IMM;
        instruction_valid    <= '1';
        is_requisition       <= '0';
        is_branch            <= '0';
        is_jump              <= '0';
        destination_register <= rdestination;
        alu_operator         <= ALU_ADD;
        is_write             <= '0';
        immediate_extension  <= sign_extended_immediate;

        case func3 is
          when "000" => alu_operator <= ALU_ADD;
          when "001" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_SLL;
              when others    => instruction_valid <= '0';
            end case;
          when "010" => alu_operator <= ALU_LT;
          when "011" => alu_operator <= ALU_LTU;
          when "100" => alu_operator <= ALU_XOR;
          when "101" =>
            case func7 is
              when "0000000" => alu_operator      <= ALU_SRL;
              when "0100000" => alu_operator      <= ALU_SRA;
              when others    => instruction_valid <= '0';
            end case;
          when "110"  => alu_operator      <= ALU_OR;
          when "111"  => alu_operator      <= ALU_AND;
          when others => instruction_valid <= '0';
        end case;

      when OPCODE_BRANCH =>
        -- adds rs1 and rs2 and stores in rs0. this has no effect on the gpr.
        read_address_a       <= rsource1;
        alu_operator         <= ALU_ADD;
        read_address_b       <= rsource2;
        destination_register <= (others => '0');
        mux_controller_a     <= ALU_SOURCE_FROM_REGISTER;
        mux_controller_b     <= ALU_SOURCE_FROM_REGISTER;
        instruction_valid    <= '1';
        is_requisition       <= '0';
        is_branch            <= '1';
        is_jump              <= '0';
        is_write             <= '0';
        immediate_extension  <= sign_extended_immediate;

        case func3 is
          when "000"  => alu_operator      <= ALU_EQ;
          when "001"  => alu_operator      <= ALU_NE;
          when "100"  => alu_operator      <= ALU_LT;
          when "101"  => alu_operator      <= ALU_GE;
          when "110"  => alu_operator      <= ALU_LTU;
          when "111"  => alu_operator      <= ALU_GEU;
          when others => instruction_valid <= '0';
        end case;

      -- adding load instruction 
      when OPCODE_LOAD =>
        read_address_a       <= rsource1;
        read_address_b       <= (others => '0');
        mux_controller_a     <= ALU_SOURCE_FROM_REGISTER;
        mux_controller_b     <= ALU_SOURCE_FROM_IMM;
        is_requisition       <= '1';
        is_branch            <= '0';
        is_jump              <= '0';
        destination_register <= rdestination;
        alu_operator         <= ALU_ADD;
        is_write             <= '0';
        immediate_extension  <= sign_extended_immediate;

        case func3 is
          when "010"  => instruction_valid <= '1';
          when others => instruction_valid <= '0';
        end case;

      -- adding store instruction 
      when OPCODE_STORE =>
        read_address_a       <= rsource1;
        read_address_b       <= rsource2;
        mux_controller_a     <= ALU_SOURCE_FROM_REGISTER;
        mux_controller_b     <= ALU_SOURCE_FROM_IMM;
        is_requisition       <= '1';
        is_branch            <= '0';
        is_jump              <= '0';
        destination_register <= (others => '0');
        alu_operator         <= ALU_ADD;
        is_write             <= '1';
        immediate_extension  <= sign_extended_immediate;

        case func3 is
          when "010"  => instruction_valid <= '1';
          when others => instruction_valid <= '0';
        end case;

      -- adding load upper immediate instruction
      when OPCODE_LUI =>
        read_address_a       <= (others => '0');
        read_address_b       <= (others => '0');
        mux_controller_a     <= ALU_SOURCE_FROM_IMM;
        mux_controller_b     <= ALU_SOURCE_ZERO;
        is_requisition       <= '0';
        is_branch            <= '0';
        is_jump              <= '0';
        destination_register <= rdestination;
        alu_operator         <= ALU_ADD;
        is_write             <= '0';
        immediate_extension  <= sign_extended_immediate;
        instruction_valid    <= '1';

      -- adding add upper immediate to pc instruction
      when OPCODE_AUIPC =>
        read_address_a       <= (others => '0');
        read_address_b       <= (others => '0');
        mux_controller_a     <= ALU_SOURCE_FROM_IMM;
        mux_controller_b     <= ALU_SOURCE_FROM_PC;
        is_requisition       <= '0';
        is_branch            <= '0';
        is_jump              <= '0';
        destination_register <= rdestination;
        alu_operator         <= ALU_ADD;
        is_write             <= '0';
        immediate_extension  <= sign_extended_immediate;
        instruction_valid    <= '1';

      -- adding jump and link instruction
      when OPCODE_JAL =>
        read_address_a       <= (others => '0');
        read_address_b       <= (others => '0');
        mux_controller_a     <= ALU_SOURCE_FROM_PC;
        mux_controller_b     <= ALU_SOURCE_FOUR;
        is_requisition       <= '0';
        is_branch            <= '0';
        is_jump              <= '1';
        destination_register <= rdestination;
        alu_operator         <= ALU_ADD;
        is_write             <= '0';
        immediate_extension  <= sign_extended_immediate;
        instruction_valid    <= '1';

      when others =>
        instruction_valid    <= '0';
        is_requisition       <= '0';
        is_branch            <= '0';
        is_jump              <= '0';
        mux_controller_a     <= ALU_SOURCE_ZERO;
        mux_controller_b     <= ALU_SOURCE_ZERO;
        read_address_a       <= (others => '0');
        read_address_b       <= (others => '0');
        alu_operator         <= ALU_ADD;
        destination_register <= (others => '0');
        is_write             <= '0';
        immediate_extension  <= sign_extended_immediate;
    end case;
  end process decoder_process;

-- purpose: sign extension of immediates
-- type   : combinational
  signextension : process (immediate_type_i, immediate_type_s,
                           immediate_type_sb, immediate_type_u,
                           immediate_type_uj, opcode, sign_bit) is
    constant filled_one  : std_logic_vector(WORD_WIDTH-13 downto 0) := (others => '1');
    constant filled_zero : std_logic_vector(WORD_WIDTH-13 downto 0) := (others => '0');
  begin  -- process signextension

    case opcode is
      when OPCODE_ALU_IMMEDIATE_REGISTER | OPCODE_LOAD =>
        zero_extended_immediate <= filled_zero & immediate_type_i;
        if sign_bit = '0' then
          sign_extended_immediate <= filled_zero & immediate_type_i;
        else
          sign_extended_immediate <= filled_one & immediate_type_i;
        end if;

      when OPCODE_JAL =>
        zero_extended_immediate <= filled_zero(WORD_WIDTH-21 downto 1) & immediate_type_uj;
        if sign_bit = '0' then
          sign_extended_immediate <= filled_zero(WORD_WIDTH-21 downto 1) & immediate_type_uj;
        else
          sign_extended_immediate <= filled_one(WORD_WIDTH-21 downto 1) & immediate_type_uj;
        end if;

      when OPCODE_BRANCH =>
        zero_extended_immediate <= filled_zero(WORD_WIDTH-13 downto 1) & immediate_type_sb;
        if sign_bit = '0' then
          sign_extended_immediate <= filled_zero(WORD_WIDTH-13 downto 1) & immediate_type_sb;
        else
          sign_extended_immediate <= filled_one(WORD_WIDTH-13 downto 1) & immediate_type_sb;
        end if;

      when OPCODE_STORE =>
        zero_extended_immediate <= filled_zero & immediate_type_s;
        if sign_bit = '0' then
          sign_extended_immediate <= filled_zero & immediate_type_s;
        else
          sign_extended_immediate <= filled_one & immediate_type_s;
        end if;

      when OPCODE_LUI | OPCODE_AUIPC =>
        zero_extended_immediate <= immediate_type_u;
        sign_extended_immediate <= immediate_type_u;

      when others =>
        zero_extended_immediate <= (others => '0');
        sign_extended_immediate <= (others => '0');

    end case;
  end process signextension;

end architecture behavioural;
