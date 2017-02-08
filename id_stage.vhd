library ieee;
use ieee.std_logic_1164.all;

entity id_stage is

  port (
    -- Clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- Data output to EX stage
    instr_rvalid_i : in std_logic;
    instr_rdata_i  : in std_logic_vector(31 downto 0);

    -- ALU Signals
    alu_input_a_ex_o  : out std_logic_vector(31 downto 0);
    alu_input_b_ex_o  : out std_logic_vector(31 downto 0);
    alu_operator_ex_o : out std_logic_vector(5 downto 0);  -- TODO: How many bits?
    -- Pipeline propagation control signals
    id_enable_o       : out std_logic;
    id_valid_o        : out std_logic;
    ex_enable_i       : in  std_logic);

end entity id_stage;
