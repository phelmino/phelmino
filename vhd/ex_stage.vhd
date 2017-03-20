library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity ex_stage is

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- alu signals
    alu_operand_a : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operand_b : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operator  : in alu_operation;

    -- branches
    is_branch        : in  std_logic;
    branch_active_if : out std_logic;
    branch_active_id : out std_logic;

    -- forwarding
    alu_result_id : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- writing on gpr
    write_enable_z_id  : out std_logic;
    write_address_z_id : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_z_id    : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- data memory interface
    is_requisition    : in  std_logic;
    is_requisition_wb : out std_logic;
    is_write          : in  std_logic;
    is_write_data     : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    data_requisition  : out std_logic;
    data_address      : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_write_enable : out std_logic;
    data_write_data   : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_grant        : in  std_logic;

    -- destination register
    destination_register    : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    destination_register_wb : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

    -- pipeline control signals
    ready_id : out std_logic;
    ready    : in  std_logic);

end entity ex_stage;

architecture behavioural of ex_stage is
  component alu is
    port (
      alu_operand_a : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator  : in  alu_operation;
      alu_result    : out std_logic_vector(WORD_WIDTH-1 downto 0));
  end component alu;

  signal alu_result                   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal branch_active                : std_logic;
  signal next_branch_active           : std_logic;
  signal destination_register_wb_i    : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal next_destination_register_wb : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

  signal data_requisition_i     : std_logic;
  signal data_address_i         : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal data_write_enable_i    : std_logic;
  signal data_write_data_i      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal last_data_requisition  : std_logic;
  signal last_data_address      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal last_data_write_enable : std_logic;
  signal last_data_write_data   : std_logic_vector(WORD_WIDTH-1 downto 0);

  signal waiting_for_memory      : std_logic;
  signal next_waiting_for_memory : std_logic;
  signal is_requisition_wb_i     : std_logic;
  signal next_is_requisition_wb  : std_logic;

begin  -- architecture behavioural

  ready_id         <= ready when (waiting_for_memory = '0') else ready and data_grant;
  alu_result_id    <= alu_result;
  branch_active_if <= branch_active;
  branch_active_id <= branch_active;

  -- gpr
  write_enable_z_id  <= not data_requisition_i;
  write_address_z_id <= destination_register;
  write_data_z_id    <= alu_result;

  alu_1 : entity lib_vhdl.alu
    port map (
      alu_operand_a => alu_operand_a,
      alu_operand_b => alu_operand_b,
      alu_operator  => alu_operator,
      alu_result    => alu_result);

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- destination register
      destination_register_wb   <= (others => '0');
      destination_register_wb_i <= (others => '0');

      -- branch
      branch_active <= '0';

      -- memorizing signals from memory
      last_data_requisition  <= '0';
      last_data_address      <= (others => '0');
      last_data_write_enable <= '0';
      last_data_write_data   <= (others => '0');
      waiting_for_memory     <= '0';

      -- interface with wb stage
      is_requisition_wb   <= '0';
      is_requisition_wb_i <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge
      -- destination register
      destination_register_wb   <= next_destination_register_wb;
      destination_register_wb_i <= next_destination_register_wb;

      -- branch
      branch_active <= next_branch_active;

      -- memorizing signals from memory
      last_data_requisition  <= data_requisition_i;
      last_data_address      <= data_address_i;
      last_data_write_enable <= data_write_enable_i;
      last_data_write_data   <= data_write_data_i;
      waiting_for_memory     <= next_waiting_for_memory;

      -- interface with wb stage
      is_requisition_wb_i <= next_is_requisition_wb;
      is_requisition_wb   <= next_is_requisition_wb;

    end if;
  end process sequential;

  combinational : process (alu_result, branch_active, data_grant,
                           destination_register, is_branch, is_requisition,
                           is_requisition_wb_i, is_write, is_write_data,
                           last_data_address, last_data_requisition,
                           last_data_write_data, last_data_write_enable, ready,
                           waiting_for_memory)
  begin  -- process combinational

    case branch_active is
      when '1' =>
        next_branch_active <= '0';

      when others =>
        next_branch_active <= is_branch and alu_result(0);
    end case;

    case ready is
      when '0' =>
        data_requisition        <= last_data_requisition;
        data_address            <= last_data_address;
        data_write_enable       <= last_data_write_enable;
        data_write_data         <= last_data_write_data;
        data_requisition_i      <= last_data_requisition;
        data_address_i          <= last_data_address;
        data_write_enable_i     <= last_data_write_enable;
        data_write_data_i       <= last_data_write_data;
        next_waiting_for_memory <= waiting_for_memory;
        next_is_requisition_wb  <= is_requisition_wb_i;

      when others =>

        -- it is a new requisition. starts memory interface.
        if (is_requisition = '1' and waiting_for_memory = '0') then
          data_requisition             <= is_requisition;
          data_address                 <= alu_result;
          data_write_enable            <= is_write and (is_requisition);
          data_write_data              <= is_write_data;
          data_requisition_i           <= is_requisition;
          data_address_i               <= alu_result;
          data_write_enable_i          <= is_write and (is_requisition);
          data_write_data_i            <= is_write_data;
          next_waiting_for_memory      <= not data_grant;
          next_is_requisition_wb       <= data_grant;
          next_destination_register_wb <= destination_register;
          -- requisition happening and still waiting for memory to answer
        elsif (waiting_for_memory = '1') then
          data_requisition             <= last_data_requisition;
          data_address                 <= last_data_address;
          data_write_enable            <= last_data_write_enable;
          data_write_data              <= last_data_write_data;
          data_requisition_i           <= last_data_requisition;
          data_address_i               <= last_data_address;
          data_write_enable_i          <= last_data_write_enable;
          data_write_data_i            <= last_data_write_data;
          next_waiting_for_memory      <= not data_grant;
          next_is_requisition_wb       <= data_grant;
          next_destination_register_wb <= destination_register_wb_i;
          -- just a logical operation
        else
          data_requisition             <= '0';
          data_address                 <= (others => '0');
          data_write_enable            <= '0';
          data_write_data              <= (others => '0');
          data_requisition_i           <= '0';
          data_address_i               <= (others => '0');
          data_write_enable_i          <= '0';
          data_write_data_i            <= (others => '0');
          next_waiting_for_memory      <= '0';
          next_is_requisition_wb       <= '0';
          next_destination_register_wb <= (others => '0');
        end if;

    end case;
  end process combinational;

end architecture behavioural;
