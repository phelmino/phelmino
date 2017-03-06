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
    alu_input_a_input  : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_input_b_input  : in std_logic_vector(WORD_WIDTH-1 downto 0);
    alu_operator_input : in std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);

    -- writing on gpr
    write_enable_z_output  : out std_logic;
    write_address_z_output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    write_data_z_output    : out std_logic_vector(WORD_WIDTH-1 downto 0);

    -- data memory interface
    data_requisition_output  : out std_logic;
    data_address_output      : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_write_enable_output : out std_logic;
    data_write_data_output   : out std_logic_vector(WORD_WIDTH-1 downto 0);
    data_grant_input         : in  std_logic;

    -- destination register
    destination_register_input  : in  std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
    destination_register_output : out std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);

    -- pipeline control signals
    ex_ready : out std_logic;
    wb_ready : in  std_logic);

end entity ex_stage;

architecture behavioural of ex_stage is
  component alu is
    port (
      alu_operand_a_input  : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operand_b_input  : in  std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_operator_input   : in  std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
      alu_result_output    : out std_logic_vector(WORD_WIDTH-1 downto 0);
      alu_carry_out_output : out std_logic);
  end component alu;

  signal alu_operand_a_input  : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operand_b_input  : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_operator         : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal alu_result_output    : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal alu_carry_out_output : std_logic;
begin  -- architecture behavioural

  ex_ready            <= wb_ready and data_grant_input;
  write_data_z_output <= alu_result_output;

  alu_1 : entity lib_vhdl.alu
    port map (
      alu_operand_a_input  => alu_operand_a_input,
      alu_operand_b_input  => alu_operand_b_input,
      alu_operator_input   => alu_operator,
      alu_result_output    => alu_result_output,
      alu_carry_out_output => alu_carry_out_output);

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- alu
      alu_operand_a_input <= (others => '0');
      alu_operand_b_input <= (others => '0');
      alu_operator        <= ALU_ADD;

      -- gpr
      write_enable_z_output  <= '0';
      write_address_z_output <= (others => '0');

      -- memory
      data_requisition_output  <= '0';
      data_address_output      <= (others => '0');
      data_write_enable_output <= '0';
      data_write_data_output   <= (others => '0');

      -- destination register
      destination_register_output <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- alu
      alu_operand_a_input <= alu_input_a_input;
      alu_operand_b_input <= alu_input_b_input;
      alu_operator        <= alu_operator_input;

      -- gpr
      write_enable_z_output  <= '1';
      write_address_z_output <= destination_register_input;

      -- memory
      data_requisition_output  <= '0';
      data_address_output      <= alu_result_output;
      data_write_enable_output <= '0';
      data_write_data_output   <= (others => '0');

      -- destination register
      destination_register_output <= destination_register_input;
    end if;
  end process sequential;

end architecture behavioural;
