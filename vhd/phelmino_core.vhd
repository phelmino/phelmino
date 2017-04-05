library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.all;
use lib_vhdl.phelmino_definitions.all;

entity phelmino_core is

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- instruction memory interfaceg
    instr_requisition : out std_logic;
    instr_address     : out std_logic_vector(WORD_WIDTH-1 downto 0);
    instr_grant       : in  std_logic;
    instr_reqvalid    : in  std_logic;
    instr_reqdata     : in  std_logic_vector(WORD_WIDTH-1 downto 0);

    -- data memory interface
    data_requisition     : out std_logic;
    data_address         : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_write_enable    : out std_logic;
    data_write_data      : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_byte_enable     : out std_logic_vector(3 downto 0);
    data_read_data       : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    data_grant           : in  std_logic;
    data_read_data_valid : in  std_logic);

end entity phelmino_core;

architecture behavioural of phelmino_core is
  signal instr_requisition_i : std_logic;
  signal data_requisition_i  : std_logic;

  component if_stage is
    port (
      clk                : in  std_logic;
      rst_n              : in  std_logic;
      instr_requisition  : out std_logic;
      instr_address      : out std_logic_vector(WORD_WIDTH-1 downto 0);
      instr_grant        : in  std_logic;
      instr_reqvalid     : in  std_logic;
      instr_reqdata      : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      instruction_id     : out std_logic_vector(WORD_WIDTH-1 downto 0);
      pc_id              : out std_logic_vector(WORD_WIDTH-1 downto 0);
      branch_active      : in  std_logic;
      jump_active        : in  std_logic;
      branch_destination : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ready              : in  std_logic);
  end component if_stage;
  signal instruction_id : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal pc_id          : std_logic_vector(WORD_WIDTH-1 downto 0);

  component id_stage is
    port (
      clk                     : in  std_logic;
      rst_n                   : in  std_logic;
      instruction             : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_a_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator_ex         : out alu_operation;
      destination_register_ex : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      is_requisition_ex       : out requisition_size;
      is_write_ex             : out std_logic;
      is_write_data_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
      is_branch_ex            : out std_logic;
      branch_destination_if   : out std_logic_vector(WORD_WIDTH-1 downto 0);
      branch_active           : in  std_logic;
      jump_active_if          : out std_logic;
      write_enable_z          : in  std_logic;
      write_address_z         : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_z            : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      write_enable_y          : in  std_logic;
      write_address_y         : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_y            : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_result              : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      pc                      : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ready_if                : out std_logic;
      ready                   : in  std_logic);
  end component id_stage;
  signal alu_operand_a_ex        : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operand_b_ex        : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operator_ex         : alu_operation;
  signal is_branch_ex            : std_logic;
  signal branch_destination_if   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal destination_register_ex : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal is_requisition_ex       : requisition_size;
  signal is_write_ex             : std_logic;
  signal is_write_data_ex        : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ready_if                : std_logic;
  signal jump_active_if          : std_logic;

  component ex_stage
    port (
      clk                     : in  std_logic;
      rst_n                   : in  std_logic;
      alu_operand_a           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator            : in  alu_operation;
      is_branch               : in  std_logic;
      branch_active_if        : out std_logic;
      branch_active_id        : out std_logic;
      alu_result_id           : out std_logic_vector(WORD_WIDTH-1 downto 0);
      write_enable_z_id       : out std_logic;
      write_address_z_id      : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_z_id         : out std_logic_vector(WORD_WIDTH-1 downto 0);
      is_requisition          : in  requisition_size;
      is_requisition_wb       : out requisition_size;
      is_write                : in  std_logic;
      is_write_data           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      byte_mask_wb            : out std_logic_vector(1 downto 0);
      data_requisition        : out std_logic;
      data_address            : out std_logic_vector(WORD_WIDTH-1 downto 0);
      data_write_enable       : out std_logic;
      data_write_data         : out std_logic_vector(WORD_WIDTH-1 downto 0);
      data_grant              : in  std_logic;
      destination_register    : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      destination_register_wb : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      ready_id                : out std_logic;
      ready                   : in  std_logic);
  end component;
  signal alu_result_id           : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal branch_active_if        : std_logic;
  signal branch_active_id        : std_logic;
  signal write_enable_z_id       : std_logic;
  signal write_address_z_id      : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal write_data_z_id         : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal destination_register_wb : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal byte_mask_wb            : std_logic_vector(1 downto 0);
  signal ready_id                : std_logic;
  signal is_requisition_wb       : requisition_size;

  component wb_stage
    port (
      clk                  : in  std_logic;
      rst_n                : in  std_logic;
      destination_register : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      is_requisition       : in  requisition_size;
      data_read_data       : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      data_read_data_valid : in  std_logic;
      byte_mask            : in  std_logic_vector(1 downto 0);
      write_enable_y_id    : out std_logic;
      write_address_y_id   : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_y_id      : out std_logic_vector(WORD_WIDTH-1 downto 0);
      ready_ex             : out std_logic);
  end component;
  signal write_enable_y_id  : std_logic;
  signal write_address_y_id : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal write_data_y_id    : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ready_ex           : std_logic;

begin  -- architecture behavioural

  instr_requisition <= instr_requisition_i;
  data_requisition  <= data_requisition_i;

  stage_if : entity lib_vhdl.if_stage
    port map (
      clk                => clk,
      rst_n              => rst_n,
      instr_requisition  => instr_requisition_i,
      instr_address      => instr_address,
      instr_grant        => instr_grant,
      instr_reqvalid     => instr_reqvalid,
      instr_reqdata      => instr_reqdata,
      instruction_id     => instruction_id,
      pc_id              => pc_id,
      branch_active      => branch_active_if,
      jump_active        => jump_active_if,
      branch_destination => branch_destination_if,
      ready              => ready_if);

  stage_id : entity lib_vhdl.id_stage
    port map (
      clk                     => clk,
      rst_n                   => rst_n,
      instruction             => instruction_id,
      alu_operand_a_ex        => alu_operand_a_ex,
      alu_operand_b_ex        => alu_operand_b_ex,
      alu_operator_ex         => alu_operator_ex,
      destination_register_ex => destination_register_ex,
      is_requisition_ex       => is_requisition_ex,
      is_write_ex             => is_write_ex,
      is_write_data_ex        => is_write_data_ex,
      is_branch_ex            => is_branch_ex,
      branch_destination_if   => branch_destination_if,
      branch_active           => branch_active_id,
      jump_active_if          => jump_active_if,
      write_enable_z          => write_enable_z_id,
      write_address_z         => write_address_z_id,
      write_data_z            => write_data_z_id,
      write_enable_y          => write_enable_y_id,
      write_address_y         => write_address_y_id,
      write_data_y            => write_data_y_id,
      pc                      => pc_id,
      alu_result              => alu_result_id,
      ready_if                => ready_if,
      ready                   => ready_id);

  stage_ex : entity lib_vhdl.ex_stage
    port map (
      clk                     => clk,
      rst_n                   => rst_n,
      alu_operand_a           => alu_operand_a_ex,
      alu_operand_b           => alu_operand_b_ex,
      alu_operator            => alu_operator_ex,
      is_branch               => is_branch_ex,
      branch_active_if        => branch_active_if,
      branch_active_id        => branch_active_id,
      alu_result_id           => alu_result_id,
      write_enable_z_id       => write_enable_z_id,
      write_address_z_id      => write_address_z_id,
      write_data_z_id         => write_data_z_id,
      is_requisition          => is_requisition_ex,
      is_requisition_wb       => is_requisition_wb,
      is_write                => is_write_ex,
      is_write_data           => is_write_data_ex,
      data_requisition        => data_requisition_i,
      data_address            => data_address,
      data_write_enable       => data_write_enable,
      data_write_data         => data_write_data,
      data_byte_enable        => data_byte_enable,
      data_grant              => data_grant,
      destination_register    => destination_register_ex,
      destination_register_wb => destination_register_wb,
      byte_mask_wb            => byte_mask_wb,
      ready_id                => ready_id,
      ready                   => ready_ex);

  stage_wb : entity lib_vhdl.wb_stage
    port map (
      clk                  => clk,
      rst_n                => rst_n,
      destination_register => destination_register_wb,
      is_requisition       => is_requisition_wb,
      data_read_data       => data_read_data,
      data_read_data_valid => data_read_data_valid,
      write_enable_y_id    => write_enable_y_id,
      write_address_y_id   => write_address_y_id,
      write_data_y_id      => write_data_y_id,
      byte_mask            => byte_mask_wb,
      ready_ex             => ready_ex);

  -- verification
  -- psl default clock is (clk'event and clk = '1');

  -- psl property instruction_requisition_triggers_grant is
  --    always(rst_n = '1' and instr_requisition_i = '1' -> (eventually! instr_grant = '1')
  --    abort (instr_requisition_i = '0' or rst_n = '0'));
  -- psl assert instruction_requisition_triggers_grant;

  -- psl property instruction_requisition_grant_before_valid is
  --    always (rst_n = '1' and instr_requisition_i = '1' ->
  --    {[*1 to inf]; instr_grant = '1' and instr_reqvalid = '0'; [*0 to inf]; instr_grant = '0' and instr_reqvalid = '1'})
  --    abort (instr_requisition_i = '0' or rst_n = '0');
  -- psl assert instruction_requisition_grant_before_valid;

  -- psl property data_requisition_triggers_grant is
  --    always (rst_n = '1' and data_requisition_i = '1' -> (eventually! data_grant = '1'))
  --    abort (data_requisition_i = '0' or rst_n = '0');
  -- psl assert data_requisition_triggers_grant;

  -- psl property data_requisition_grant_before_valid is
  --    always (rst_n = '1' and data_requisition_i = '1' ->
  --    {[*1 to inf]; data_grant = '1' and data_read_data_valid = '0'; [*0 to inf]; data_grant = '0' and data_read_data_valid = '1'})
  --    abort (data_requisition_i = '0' or rst_n = '0');
  -- psl assert data_requisition_grant_before_valid;

end architecture behavioural;
