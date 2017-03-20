
library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity test_id_stage is
end entity test_id_stage;

architecture test of test_id_stage is

  component id_stage is
    port (
      clk                     : in  std_logic;
      rst_n                   : in  std_logic;
      instruction             : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      pc                      : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_a_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b_ex        : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator_ex         : out alu_operation;
      destination_register_ex : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      is_requisition_ex       : out std_logic;
      is_branch_ex            : out std_logic;
      branch_destination_if   : out std_logic_vector(WORD_WIDTH-1 downto 0);
      branch_active           : in  std_logic;
      write_enable_z          : in  std_logic;
      write_address_z         : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_z            : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      write_enable_y          : in  std_logic;
      write_address_y         : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
      write_data_y            : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_result              : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      data_read_from_memory   : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      ready_if                : out std_logic;
      ready                   : in  std_logic);
  end component id_stage;

  signal clk                     : std_logic                                      := '0';
  signal rst_n                   : std_logic                                      := '0';
  signal instruction             : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal pc                      : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal alu_operand_a_ex        : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal alu_operand_b_ex        : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal alu_operator_ex         : alu_operation                                  := ALU_ADD;
  signal destination_register_ex : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal is_requisition_ex       : std_logic                                      := '0';
  signal is_branch_ex            : std_logic                                      := '0';
  signal branch_destination_if   : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal branch_active           : std_logic                                      := '0';
  signal write_enable_z          : std_logic                                      := '0';
  signal write_address_z         : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal write_data_z            : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal write_enable_y          : std_logic                                      := '0';
  signal write_address_y         : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal write_data_y            : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal alu_result              : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal data_read_from_memory   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ready_if                : std_logic                                      := '0';
  signal ready                   : std_logic                                      := '0';


begin  -- architecture test

  dut : entity lib_vhdl.id_stage
    port map (
      clk                     => clk,
      rst_n                   => rst_n,
      instruction             => instruction,
      pc                      => pc,
      alu_operand_a_ex        => alu_operand_a_ex,
      alu_operand_b_ex        => alu_operand_b_ex,
      alu_operator_ex         => alu_operator_ex,
      destination_register_ex => destination_register_ex,
      is_requisition_ex       => is_requisition_ex,
      is_branch_ex            => is_branch_ex,
      branch_destination_if   => branch_destination_if,
      branch_active           => branch_active,
      write_enable_z          => write_enable_z,
      write_address_z         => write_address_z,
      write_data_z            => write_data_z,
      write_enable_y          => write_enable_y,
      write_address_y         => write_address_y,
      write_data_y            => write_data_y,
      alu_result              => alu_result,
      data_read_from_memory   => data_read_from_memory,
      ready_if                => ready_if,
      ready                   => ready);

  -- clock generation
  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

  -- waveform generation
  wavegen_proc : process
  begin
    wait for 20 ns;
    wait until falling_edge(clk);

    pc          <= (0 => '1', others => '0');
    instruction <= NOP;

    wait until falling_edge(clk);

    pc          <= (0 => '1', others => '0');
    instruction <= ADD_R1_PLUS_R2;

    wait until falling_edge(clk);
    wait;
  end process wavegen_proc;

end architecture test;
