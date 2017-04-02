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
    is_requisition_ex       : out requisition_size;
    is_write_ex             : out std_logic;
    is_write_data_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- branches
    is_branch_ex          : out std_logic;
    jump_active_if        : out std_logic;
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
    alu_result : in std_logic_vector(WORD_WIDTH-1 downto 0);

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
  signal read_address_a   : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal read_data_a      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal read_address_b   : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal read_data_b      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal jump_active_if_i : std_logic;

  component decoder is
    port (
      instruction          : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      instruction_valid    : out std_logic;
      is_requisition       : out requisition_size;
      is_write             : out std_logic;
      is_branch            : out std_logic;
      is_jump              : out std_logic;
      is_jump_register     : out std_logic;
      read_address_a       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      read_address_b       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      alu_operator         : out alu_operation;
      mux_controller_a     : out alu_source;
      mux_controller_b     : out alu_source;
      destination_register : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      immediate_extension  : out std_logic_vector(WORD_WIDTH-1 downto 0));
  end component decoder;
  signal instruction_valid       : std_logic;
  signal is_requisition          : requisition_size;
  signal is_write                : std_logic;
  signal next_is_write_data_ex   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal is_branch               : std_logic;
  signal is_jump                 : std_logic;
  signal is_jump_register        : std_logic;
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
  signal current_mux_controller_c : alu_source;

  -- stall detection
  type stall_state is (stalling, normal_execution);
  signal current_stall_state           : stall_state;
  signal next_stall_state              : stall_state;
  signal valid                         : std_logic;
  signal stall                         : std_logic;
  signal registers_waiting_memory      : std_logic_vector(2**GPR_ADDRESS_WIDTH-1 downto 0);
  signal next_registers_waiting_memory : std_logic_vector(2**GPR_ADDRESS_WIDTH-1 downto 0);
begin  -- architecture behavioural

  -- pipeline propagation
  valid    <= ready and not stall;
  ready_if <= valid;

  -- calculates next branch destination
  next_branch_destination <= std_logic_vector(unsigned(pc) + unsigned(immediate_extension)) when is_jump_register = '0'
                             else std_logic_vector(unsigned(read_data_a) + unsigned(immediate_extension));

  -- assertion
  assert (rst_n = '0' or instruction_valid = '1') report "Invalid instruction in decoding stage." severity failure;

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
      is_write             => is_write,
      is_branch            => is_branch,
      is_jump              => is_jump,
      is_jump_register     => is_jump_register,
      read_address_a       => read_address_a,
      read_address_b       => read_address_b,
      alu_operator         => alu_operator,
      mux_controller_a     => mux_controller_a,
      mux_controller_b     => mux_controller_b,
      destination_register => destination_register,
      immediate_extension  => immediate_extension);

  sequentialprocess : process (clk, rst_n) is
  begin  -- process sequentialprocess
    if rst_n = '0' then                 -- asynchronous reset (active low).
      alu_operand_a_ex         <= (others => '0');
      alu_operand_b_ex         <= (others => '0');
      alu_operator_ex          <= ALU_ADD;
      is_requisition_ex        <= NO_REQ;
      registers_waiting_memory <= (others => '0');
      is_write_ex              <= '0';
      is_write_data_ex         <= (others => '0');
      is_branch_ex             <= '0';
      jump_active_if           <= '0';
      jump_active_if_i         <= '0';
      destination_register_ex  <= (others => '0');
      branch_destination_if    <= (others => '0');
      current_stall_state      <= normal_execution;
    elsif clk'event and clk = '1' then  -- rising clock edge
      current_stall_state      <= next_stall_state;
      registers_waiting_memory <= next_registers_waiting_memory;

      if (valid = '1' and branch_active = '0') then
        alu_operand_a_ex        <= alu_operand_a;
        alu_operand_b_ex        <= alu_operand_b;
        alu_operator_ex         <= alu_operator;
        is_requisition_ex       <= is_requisition;
        is_write_ex             <= is_write;
        is_write_data_ex        <= next_is_write_data_ex;
        destination_register_ex <= destination_register;
        branch_destination_if   <= next_branch_destination;
        is_branch_ex            <= is_branch;
        jump_active_if          <= is_jump;
        jump_active_if_i        <= is_jump;
      end if;

      if (ready = '1' and jump_active_if_i = '1') then
        alu_operand_a_ex        <= (others => '0');
        alu_operand_b_ex        <= (others => '0');
        alu_operator_ex         <= ALU_ADD;
        destination_register_ex <= (others => '0');
        is_requisition_ex       <= NO_REQ;
        is_write_ex             <= '0';
        is_write_data_ex        <= (others => '0');
        is_branch_ex            <= '0';
      end if;

      if ((ready = '1' and valid = '0') or branch_active = '1') then
        alu_operand_a_ex        <= (others => '0');
        alu_operand_b_ex        <= (others => '0');
        alu_operator_ex         <= ALU_ADD;
        is_requisition_ex       <= NO_REQ;
        is_write_ex             <= '0';
        is_write_data_ex        <= (others => '0');
        is_branch_ex            <= '0';
        destination_register_ex <= (others => '0');
      end if;

      if (branch_active = '1') then
        jump_active_if   <= '0';
        jump_active_if_i <= '0';
      end if;
    end if;
  end process sequentialprocess;

  combinationalprocess : process (alu_result, branch_active,
                                  current_mux_controller_a,
                                  current_mux_controller_b,
                                  current_mux_controller_c,
                                  current_stall_state, destination_register,
                                  immediate_extension, is_requisition,
                                  jump_active_if_i, mux_controller_a,
                                  mux_controller_b, pc, read_address_a,
                                  read_address_b, read_data_a, read_data_b,
                                  registers_waiting_memory, write_address_y,
                                  write_address_z, write_data_y,
                                  write_enable_y, write_enable_z) is
  begin  -- process combinationalprocess
    next_registers_waiting_memory <= registers_waiting_memory;

    -- mux to define origin of signal alu_operand_a
    case current_mux_controller_a is
      when ALU_SOURCE_ZERO          => alu_operand_a <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => alu_operand_a <= read_data_a;
      when ALU_SOURCE_FROM_ALU      => alu_operand_a <= alu_result;
      when ALU_SOURCE_FROM_WB_STAGE => alu_operand_a <= write_data_y;
      when ALU_SOURCE_FROM_IMM      => alu_operand_a <= immediate_extension;
      when ALU_SOURCE_FROM_PC       => alu_operand_a <= pc;
      when ALU_SOURCE_FOUR          => alu_operand_a <= (2 => '1', others => '0');
      when others                   => alu_operand_a <= (others => '0');
    end case;

    -- mux to define origin of signal alu_operand_b
    case current_mux_controller_b is
      when ALU_SOURCE_ZERO          => alu_operand_b <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => alu_operand_b <= read_data_b;
      when ALU_SOURCE_FROM_ALU      => alu_operand_b <= alu_result;
      when ALU_SOURCE_FROM_WB_STAGE => alu_operand_b <= write_data_y;
      when ALU_SOURCE_FROM_IMM      => alu_operand_b <= immediate_extension;
      when ALU_SOURCE_FROM_PC       => alu_operand_b <= pc;
      when ALU_SOURCE_FOUR          => alu_operand_b <= (2 => '1', others => '0');
      when others                   => alu_operand_b <= (others => '0');
    end case;

    -- mux c
    case current_mux_controller_c is
      when ALU_SOURCE_ZERO          => next_is_write_data_ex <= (others => '0');
      when ALU_SOURCE_FROM_REGISTER => next_is_write_data_ex <= read_data_b;
      when ALU_SOURCE_FROM_ALU      => next_is_write_data_ex <= alu_result;
      when ALU_SOURCE_FROM_WB_STAGE => next_is_write_data_ex <= write_data_y;
      when ALU_SOURCE_FROM_IMM      => next_is_write_data_ex <= immediate_extension;
      when ALU_SOURCE_FROM_PC       => next_is_write_data_ex <= pc;
      when ALU_SOURCE_FOUR          => next_is_write_data_ex <= (2 => '1', others => '0');
      when others                   => next_is_write_data_ex <= (others => '0');
    end case;

    -- Controlling mux A. May choose to forward.
    current_mux_controller_a <= mux_controller_a;
    if ((write_enable_z = '1') and (unsigned(write_address_z) /= 0) and (mux_controller_a = ALU_SOURCE_FROM_REGISTER) and (read_address_a = write_address_z)) then
      current_mux_controller_a <= ALU_SOURCE_FROM_ALU;
    elsif ((mux_controller_a = ALU_SOURCE_FROM_REGISTER) and (registers_waiting_memory(to_integer(unsigned(read_address_a))) = '1')) then
      current_mux_controller_a <= ALU_SOURCE_FROM_WB_STAGE;
    end if;

    -- Controlling mux B. May choose to forward.
    current_mux_controller_b <= mux_controller_b;
    if ((write_enable_z = '1') and (unsigned(write_address_z) /= 0) and (mux_controller_b = ALU_SOURCE_FROM_REGISTER) and (read_address_b = write_address_z)) then
      current_mux_controller_b <= ALU_SOURCE_FROM_ALU;
    elsif ((mux_controller_b = ALU_SOURCE_FROM_REGISTER) and (registers_waiting_memory(to_integer(unsigned(read_address_b))) = '1')) then
      current_mux_controller_b <= ALU_SOURCE_FROM_WB_STAGE;
    end if;

    -- mux C
    current_mux_controller_c <= ALU_SOURCE_FROM_REGISTER;
    if ((write_enable_z = '1') and (unsigned(write_address_z) /= 0) and (read_address_b = write_address_z)) then
      current_mux_controller_c <= ALU_SOURCE_FROM_ALU;
    elsif ((registers_waiting_memory(to_integer(unsigned(read_address_b))) = '1')) then
      current_mux_controller_c <= ALU_SOURCE_FROM_WB_STAGE;
    end if;

    if (branch_active = '1' or jump_active_if_i = '1') then
      next_registers_waiting_memory <= (others => '0');
    end if;

    if (is_requisition /= NO_REQ and branch_active = '0' and unsigned(destination_register) /= 0 and jump_active_if_i = '0') then
      next_registers_waiting_memory(to_integer(unsigned(destination_register))) <= '1';
    end if;

    if (write_enable_y = '1' and branch_active = '0' and jump_active_if_i = '0') then
      next_registers_waiting_memory(to_integer(unsigned(write_address_y))) <= '0';
    end if;

    case current_stall_state is
      when normal_execution =>
        -- If it is a load instruction, next instruction must wait a cycle before
        -- reading the data.
        if (registers_waiting_memory(to_integer(unsigned(read_address_a))) = '1' or (registers_waiting_memory(to_integer(unsigned(read_address_b)))) = '1') then
          stall            <= '1';
          next_stall_state <= stalling;
        else
          stall            <= '0';
          next_stall_state <= normal_execution;
        end if;

      when stalling =>
        stall            <= '1';
        next_stall_state <= stalling;
        if (registers_waiting_memory(to_integer(unsigned(read_address_a))) = '0' and (registers_waiting_memory(to_integer(unsigned(read_address_b)))) = '0') then
          next_stall_state <= normal_execution;
          stall            <= '0';
        end if;
    end case;

  end process combinationalprocess;

end architecture behavioural;
