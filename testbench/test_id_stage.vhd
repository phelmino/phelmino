library ieee;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity test_id_stage is
end entity test_id_stage;

architecture test of test_id_stage is

  -- component ports
  signal clk                            : std_logic                                      := '1';
  signal rst_n                          : std_logic                                      := '0';
  signal instr_reqdata_input            : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal ex_alu_input_a_output          : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ex_alu_input_b_output          : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal ex_alu_operator_output         : std_logic_vector(ALU_OPERATOR_WIDTH-1 downto 0);
  signal ex_destination_register_output : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0);
  signal branch_active_if_output        : std_logic;
  signal branch_destination_if_output   : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal write_enable_y_input           : std_logic                                      := '0';
  signal write_address_y_input          : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal write_data_y_input             : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal write_enable_z_input           : std_logic                                      := '0';
  signal write_address_z_input          : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal write_data_z_input             : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
  signal pc_id_input                    : std_logic_vector(31 downto 0)                  := (others => '0');
  signal id_ready                       : std_logic                                      := '0';
  signal ex_ready                       : std_logic                                      := '0';

begin  -- architecture test

  -- component instantiation
  dut : entity lib_vhdl.id_stage
    port map (
      clk                            => clk,
      rst_n                          => rst_n,
      instr_reqdata_input            => instr_reqdata_input,
      ex_alu_input_a_output          => ex_alu_input_a_output,
      ex_alu_input_b_output          => ex_alu_input_b_output,
      ex_alu_operator_output         => ex_alu_operator_output,
      ex_destination_register_output => ex_destination_register_output,
      branch_active_if_output        => branch_active_if_output,
      branch_destination_if_output   => branch_destination_if_output,
      write_enable_y_input           => write_enable_y_input,
      write_address_y_input          => write_address_y_input,
      write_data_y_input             => write_data_y_input,
      write_enable_z_input           => write_enable_z_input,
      write_address_z_input          => write_address_z_input,
      write_data_z_input             => write_data_z_input,
      pc_id_input                    => pc_id_input,
      id_ready                       => id_ready,
      ex_ready                       => ex_ready);

  -- clock generation
  clk   <= not clk after 5 ns;
  rst_n <= '1'     after 7 ns;

  -- waveform generation
  wavegen_proc : process
  begin
    wait for 20 ns;
    wait until falling_edge(clk);

    pc_id_input         <= (0 => '1', others => '0');
    instr_reqdata_input <= nop;

    wait until falling_edge(clk);

    pc_id_input         <= (0 => '1', others => '0');
    instr_reqdata_input <= add_r1_plus_r2;

    wait until falling_edge(clk);
    wait;
  end process wavegen_proc;

end architecture test;
