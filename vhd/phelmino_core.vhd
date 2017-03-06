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

    -- instruction memory interface
    instr_requisition : out std_logic;
    instr_address     : out std_logic_vector(WORD_WIDTH-1 downto 0);
    instr_grant       : in  std_logic;
    instr_reqvalid    : in  std_logic;
    instr_reqdata     : in  std_logic_vector(WORD_WIDTH-1 downto 0);

    -- data memory interface
    data_requisition  : out std_logic;
    data_address      : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_write_enable : out std_logic;
    data_write_data   : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_reqdata      : in  std_logic_vector(WORD_WIDTH-1 downto 0);
    data_grant        : in  std_logic;
    data_reqvalid     : in  std_logic);

end entity phelmino_core;

architecture behavioural of phelmino_core is
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
      branch_destination : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ready              : in  std_logic);
  end component if_stage;
  signal instruction_id     : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal pc_id              : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal branch_active      : std_logic;
  signal branch_destination : std_logic_vector(WORD_WIDTH-1 downto 0);

  component id_stage is
    port (
      clk                     : in  std_logic;
      rst_n                   : in  std_logic;
      instruction             : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_a_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator_ex         : out std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      destination_register_ex : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      is_requisition_ex       : out std_logic;
      branch_active_if        : out std_logic;
      branch_destination_if   : out std_logic_vector(WORD_WIDTH-1 downto 0);
      write_enable_z          : in  std_logic;
      write_address_z         : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_z            : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      write_enable_y          : in  std_logic;
      write_address_y         : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_y            : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_result              : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      data_read_from_memory   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      pc                      : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ready_if                : out std_logic;
      ready                   : in  std_logic);
  end component id_stage;
  signal instruction             : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operand_a_ex        : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operand_b_ex        : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operator_ex         : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal destination_register_ex : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal is_requisition_ex       : std_logic;
  signal branch_active_if        : std_logic;
  signal branch_destination_if   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal pc                      : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ready_if                : std_logic;

  component ex_stage is
    port (
      clk                     : in  std_logic;
      rst_n                   : in  std_logic;
      alu_operand_a           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b           : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator            : in  std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      alu_result_id           : out std_logic_vector(WORD_WIDTH-1 downto 0);
      write_enable_z_id       : out std_logic;
      write_address_z_id      : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_z_id         : out std_logic_vector(WORD_WIDTH-1 downto 0);
      is_requisition          : in  std_logic;
      data_requisition        : out std_logic;
      data_address            : out std_logic_vector(WORD_WIDTH-1 downto 0);
      data_write_enable       : out std_logic;
      data_write_data         : out std_logic_vector(WORD_WIDTH-1 downto 0);
      data_grant              : in  std_logic;
      destination_register    : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      destination_register_wb : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      ready_id                : out std_logic;
      ready                   : in  std_logic);
  end component ex_stage;
  signal alu_result_id           : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal write_enable_z_id       : std_logic;
  signal write_address_z_id      : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal write_data_z_id         : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal destination_register_wb : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal ready_id                : std_logic;

  component wb_stage is
    port (
      clk                      : in  std_logic;
      rst_n                    : in  std_logic;
      data_read_from_memory_id : out std_logic_vector(WORD_WIDTH-1 downto 0);
      destination_register     : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      data_reqdata             : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      data_reqvalid            : in  std_logic;
      write_enable_y_id        : out std_logic;
      write_address_y_id       : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_y_id          : out std_logic_vector(WORD_WIDTH-1 downto 0);
      ready_ex                 : out std_logic);
  end component wb_stage;
  signal data_read_from_memory_id : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal write_enable_y_id        : std_logic;
  signal write_address_y_id       : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal write_data_y_id          : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ready_ex                 : std_logic;

begin  -- architecture behavioural

  stage_if : entity lib_vhdl.if_stage
    port map (
      clk                => clk,
      rst_n              => rst_n,
      instr_requisition  => instr_requisition,
      instr_address      => instr_address,
      instr_grant        => instr_grant,
      instr_reqvalid     => instr_reqvalid,
      instr_reqdata      => instr_reqdata,
      instruction_id     => instruction_id,
      pc_id              => pc_id,
      branch_active      => branch_active_if,
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
      branch_active_if        => branch_active_if,
      branch_destination_if   => branch_destination_if,
      write_enable_z          => write_enable_z_id,
      write_address_z         => write_address_z_id,
      write_data_z            => write_data_z_id,
      write_enable_y          => write_enable_y_id,
      write_address_y         => write_address_y_id,
      write_data_y            => write_data_y_id,
      pc                      => pc_id,
      alu_result              => alu_result_id,
      data_read_from_memory   => data_read_from_memory_id,
      ready_if                => ready_if,
      ready                   => ready_id);

  stage_ex : entity lib_vhdl.ex_stage
    port map (
      clk                     => clk,
      rst_n                   => rst_n,
      alu_operand_a           => alu_operand_a_ex,
      alu_operand_b           => alu_operand_b_ex,
      alu_operator            => alu_operator_ex,
      alu_result_id           => alu_result_id,
      write_enable_z_id       => write_enable_z_id,
      write_address_z_id      => write_address_z_id,
      write_data_z_id         => write_data_z_id,
      is_requisition          => is_requisition_ex,
      data_requisition        => data_requisition,
      data_address            => data_address,
      data_write_enable       => data_write_enable,
      data_write_data         => data_write_data,
      data_grant              => data_grant,
      destination_register    => destination_register_ex,
      destination_register_wb => destination_register_wb,
      ready_id                => ready_id,
      ready                   => ready_ex);

  stage_wb : entity lib_vhdl.wb_stage
    port map (
      clk                      => clk,
      rst_n                    => rst_n,
      data_read_from_memory_id => data_read_from_memory_id,
      destination_register     => destination_register_wb,
      data_reqdata             => data_reqdata,
      data_reqvalid            => data_reqvalid,
      write_enable_y_id        => write_enable_y_id,
      write_address_y_id       => write_address_y_id,
      write_data_y_id          => write_data_y_id,
      ready_ex                 => ready_ex);

end architecture behavioural;
