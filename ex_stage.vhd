library ieee;
use ieee.std_logic_1164.all;

entity ex_stage is

  port (
    -- Clock and reset signals
    clk               : in  std_logic;
    rst_n             : in  std_logic;

    -- ALU
    alu_input_a_ex_i  : in  std_logic_vector(31 downto 0);
    alu_input_b_ex_i  : in  std_logic_vector(31 downto 0);
    alu_operator_ex_i : in  std_logic_vector(5 downto 0);

    -- Pipeline propagation control signals
    ex_enable_o       : out std_logic;
    ex_ready_o        : out std_logic;
    wb_enable_i       : in  std_logic);
    
end entity ex_stage;