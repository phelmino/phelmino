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
    is_requisition    : in  requisition_size;
    is_requisition_wb : out requisition_size;
    is_write          : in  std_logic;
    is_write_data     : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    bit_mask_wb       : out std_logic_vector(1 downto 0);
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
  signal next_destination_register_wb : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal next_bitmask_wb              : std_logic_vector(1 downto 0);

  signal data_requisition_i : std_logic;

  signal waiting_for_memory     : std_logic;
  signal next_is_requisition_wb : requisition_size;

  signal valid : std_logic;

begin  -- architecture behavioural

  valid            <= ready when (waiting_for_memory = '0') else ready and data_grant;
  ready_id         <= valid;
  alu_result_id    <= alu_result;
  branch_active_if <= branch_active;
  branch_active_id <= branch_active;

  -- gpr
  write_enable_z_id  <= not data_requisition_i;
  write_address_z_id <= destination_register;
  write_data_z_id    <= alu_result;

  -- memory interface
  data_address       <= alu_result(WORD_WIDTH-1 downto 2) & "00";
  data_requisition   <= '1' when (is_requisition /= NO_REQ) else '0';
  data_requisition_i <= '1' when (is_requisition /= NO_REQ) else '0';
  data_write_enable  <= is_write;
  data_write_data    <= is_write_data;

  alu_1 : entity lib_vhdl.alu
    port map (
      alu_operand_a => alu_operand_a,
      alu_operand_b => alu_operand_b,
      alu_operator  => alu_operator,
      alu_result    => alu_result);

  interface_wb : process (clk, rst_n) is
  begin  -- process memory_interface
    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- destination register
      destination_register_wb <= (others => '0');

      -- branch
      branch_active <= '0';

      -- interface with wb stage
      is_requisition_wb <= NO_REQ;
      bit_mask_wb       <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (valid = '1') then
        -- destination register
        destination_register_wb <= next_destination_register_wb;

        -- branch
        branch_active <= next_branch_active;

        -- interface with wb stage
        is_requisition_wb <= next_is_requisition_wb;
        bit_mask_wb       <= next_bitmask_wb;
      end if;

      if (ready = '1' and valid = '0') then
        -- destination register
        destination_register_wb <= (others => '0');

        -- branch
        branch_active <= '0';

        -- interface with wb stage
        is_requisition_wb <= NO_REQ;
        bit_mask_wb       <= (others => '0');
      end if;
    end if;
  end process interface_wb;

  combinational : process (alu_result, branch_active, data_grant,
                           destination_register, is_branch, is_requisition)
  begin  -- process combinational

    case branch_active is
      when '1' =>
        next_branch_active <= '0';

      when others =>
        next_branch_active <= is_branch and alu_result(0);
    end case;

    -- it is a new requisition. starts memory interface.
    if (is_requisition /= NO_REQ) then
      waiting_for_memory <= not data_grant;
      case data_grant is
        when '1'    => next_is_requisition_wb <= is_requisition;
        when others => next_is_requisition_wb <= NO_REQ;
      end case;
      next_destination_register_wb <= destination_register;
      next_bitmask_wb              <= alu_result(1 downto 0);
    -- just a logical operation
    else
      waiting_for_memory           <= '0';
      next_is_requisition_wb       <= NO_REQ;
      next_destination_register_wb <= (others => '0');
      next_bitmask_wb              <= (others => '0');
    end if;
  end process combinational;

end architecture behavioural;
