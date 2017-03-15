library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.all;
use lib_vhdl.phelmino_definitions.all;

entity id_stage is

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- data input from if stage
    instruction : in std_logic_vector(WORD_WIDTH-1 downto 0);
    pc          : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- ex signals
    alu_operand_a_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operand_b_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operator_ex         : out alu_operation;
    destination_register_ex : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    is_requisition_ex       : out std_logic;

    -- branches
    is_branch_ex          : out std_logic;
    branch_destination_if : out std_logic_vector(WORD_WIDTH-1 downto 0);
    branch_active         : in  std_logic;

    -- write acess to gpr, from ex stage.
    write_enable_z  : in std_logic;
    write_address_z : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_z    : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- write acess to gpr, from wb stage.
    write_enable_y  : in std_logic;
    write_address_y : in std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_y    : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- forwarding signals
    alu_result            : in std_logic_vector(WORD_WIDTH-1 downto 0);
    data_read_from_memory : in std_logic_vector(WORD_WIDTH-1 downto 0);

    -- pipeline control signals
    ready_if : out std_logic;
    ready    : in  std_logic);

end entity id_stage;

architecture behavioural of id_stage is
  component general_purpose_registers is
    generic (
      w : natural;
      n : natural);
    port (
      clk             : in  std_logic;
      rst_n           : in  std_logic;
      read_address_a  : in  std_logic_vector(n-1 downto 0);
      read_data_a     : out std_logic_vector(w-1 downto 0);
      read_address_b  : in  std_logic_vector(n-1 downto 0);
      read_data_b     : out std_logic_vector(w-1 downto 0);
      write_enable_y  : in  std_logic;
      write_address_y : in  std_logic_vector(n-1 downto 0);
      write_data_y    : in  std_logic_vector(w-1 downto 0);
      write_enable_z  : in  std_logic;
      write_address_z : in  std_logic_vector(n-1 downto 0);
      write_data_z    : in  std_logic_vector(w-1 downto 0));
  end component general_purpose_registers;
  signal read_address_a : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal read_data_a    : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal read_address_b : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal read_data_b    : std_logic_vector(WORD_WIDTH-1 downto 0);

  component decoder is
    port (
      instruction          : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      instruction_valid    : out std_logic;
      is_requisition       : out std_logic;
      is_branch            : out std_logic;
      read_address_a       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      read_address_b       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      alu_operator         : out alu_operation;
      mux_controller_a     : out alu_source;
      mux_controller_b     : out alu_source;
      destination_register : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      immediate_extension  : out std_logic_vector(WORD_WIDTH-1 downto 0));
  end component decoder;
  signal instruction_valid       : std_logic;
  signal is_requisition          : std_logic;
  signal is_branch               : std_logic;
  signal alu_operand_a           : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operand_b           : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operator            : alu_operation;
  signal mux_controller_a        : alu_source;
  signal mux_controller_b        : alu_source;
  signal destination_register    : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal immediate_extension     : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal next_branch_destination : std_logic_vector(WORD_WIDTH-1 downto 0);

  -- mux signals
  signal current_mux_controller_a : alu_source;
  signal current_mux_controller_b : alu_source;

  -- stall detection
  signal stall : std_logic;
begin  -- architecture behavioural

  -- pipeline propagation
  ready_if <= ready and not stall;

  -- calculates next branch destination
  next_branch_destination <= std_logic_vector(unsigned(pc) + unsigned(immediate_extension));

  gpr : entity lib_vhdl.general_purpose_registers
    generic map (
      w => WORD_WIDTH,
      n => GPR_ADDRESS_WIDTH)
    port map (
      clk             => clk,
      rst_n           => rst_n,
      read_address_a  => read_address_a,
      read_data_a     => read_data_a,
      read_address_b  => read_address_b,
      read_data_b     => read_data_b,
      write_enable_y  => write_enable_y,
      write_address_y => write_address_y,
      write_data_y    => write_data_y,
      write_enable_z  => write_enable_z,
      write_address_z => write_address_z,
      write_data_z    => write_data_z);

  decoderblock : entity lib_vhdl.decoder
    port map (
      instruction          => instruction,
      instruction_valid    => instruction_valid,
      is_requisition       => is_requisition,
      is_branch            => is_branch,
      read_address_a       => read_address_a,
      read_address_b       => read_address_b,
      alu_operator         => alu_operator,
      mux_controller_a     => mux_controller_a,
      mux_controller_b     => mux_controller_b,
      destination_register => destination_register,
      immediate_extension  => immediate_extension);

  sequentialprocess : process (branch_active, clk, rst_n) is
  begin  -- process sequentialprocess
    if rst_n = '0' then                 -- asynchronous reset (active low).
      alu_operand_a_ex        <= (others => '0');
      alu_operand_b_ex        <= (others => '0');
      alu_operator_ex         <= ALU_ADD;
      is_requisition_ex       <= '0';
      is_branch_ex            <= '0';
      destination_register_ex <= (others => '0');
      branch_destination_if   <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (branch_active = '1') then     -- synchronous reset (active high)
        alu_operand_a_ex        <= (others => '0');
        alu_operand_b_ex        <= (others => '0');
        alu_operator_ex         <= ALU_ADD;
        is_requisition_ex       <= '0';
        is_branch_ex            <= '0';
        destination_register_ex <= (others => '0');
        branch_destination_if   <= (others => '0');
      else
        case ready is
          when '1' =>
            alu_operand_a_ex        <= alu_operand_a;
            alu_operand_b_ex        <= alu_operand_b;
            alu_operator_ex         <= alu_operator;
            is_requisition_ex       <= is_requisition;
            destination_register_ex <= destination_register;
            branch_destination_if   <= next_branch_destination;
            is_branch_ex            <= is_branch;

          when others =>
            alu_operand_a_ex        <= alu_operand_a;
            alu_operand_b_ex        <= alu_operand_b;
            alu_operator_ex         <= alu_operator;
            is_requisition_ex       <= is_requisition;
            is_branch_ex            <= is_branch;
            destination_register_ex <= destination_register;
            branch_destination_if   <= next_branch_destination;
        end case;
      end if;
    end if;
  end process sequentialprocess;

  combinationalprocess : process (alu_result, current_mux_controller_a,
                                  current_mux_controller_b,
                                  data_read_from_memory, is_branch,
                                  mux_controller_a, mux_controller_b,
                                  read_address_a, read_address_b, read_data_a,
                                  read_data_b, write_address_y,
                                  write_address_z, write_enable_y,
                                  write_enable_z) is
  begin  -- process combinationalprocess
    -- mux to define origin of signal alu_operand_a
    case current_mux_controller_a is
      when ALU_SOURCE_ZERO          => alu_operand_a <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => alu_operand_a <= read_data_a;
      when ALU_SOURCE_FROM_ALU      => alu_operand_a <= alu_result;
      when ALU_SOURCE_FROM_WB_STAGE => alu_operand_a <= data_read_from_memory;
      when others                   => alu_operand_a <= (others => '0');
    end case;

    -- mux to define origin of signal alu_operand_b
    case current_mux_controller_b is
      when ALU_SOURCE_ZERO          => alu_operand_b <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => alu_operand_b <= read_data_b;
      when ALU_SOURCE_FROM_ALU      => alu_operand_b <= alu_result;
      when ALU_SOURCE_FROM_WB_STAGE => alu_operand_b <= data_read_from_memory;
      when others                   => alu_operand_b <= (others => '0');
    end case;

    -- Controlling mux A. May choose to forward.
    current_mux_controller_a <= mux_controller_a;
    if ((write_enable_z = '1') and (unsigned(write_address_z) /= 0) and (mux_controller_a = ALU_SOURCE_FROM_REGISTER) and (read_address_a = write_address_z)) then
      current_mux_controller_a <= ALU_SOURCE_FROM_ALU;
    elsif ((write_enable_y = '1') and (unsigned(write_address_y) /= 0) and (mux_controller_a = ALU_SOURCE_FROM_REGISTER) and (read_address_a = write_address_y)) then
      current_mux_controller_a <= ALU_SOURCE_FROM_WB_STAGE;
    end if;

    -- Controlling mux B. May choose to forward.
    current_mux_controller_b <= mux_controller_b;
    if ((write_enable_z = '1') and (unsigned(write_address_z) /= 0) and (mux_controller_b = ALU_SOURCE_FROM_REGISTER) and (read_address_b = write_address_z)) then
      current_mux_controller_b <= ALU_SOURCE_FROM_ALU;
    elsif ((write_enable_y = '1') and (unsigned(write_address_y) /= 0) and (mux_controller_b = ALU_SOURCE_FROM_REGISTER) and (read_address_b = write_address_y)) then
      current_mux_controller_b <= ALU_SOURCE_FROM_WB_STAGE;
    end if;

    -- Can not branch if has not finished calculating the needed values.
    stall <= '0';
    if ((write_enable_z = '1') and
        (unsigned(write_address_z) /= 0) and
        (is_branch = '1') and
        ((read_address_a = write_address_z) or (read_address_b = write_address_z))) then
      stall <= '1';
    end if;
    if ((write_enable_y = '1') and
        (unsigned(write_address_y) /= 0) and
        (is_branch = '1') and
        ((read_address_a = write_address_y) or (read_address_b = write_address_y))) then
      stall <= '1';
    end if;

  end process combinationalprocess;

end architecture behavioural;
