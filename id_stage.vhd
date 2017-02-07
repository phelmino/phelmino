library ieee;
use ieee.numeric_std.all;

entity id_stage is

  port (
    -- Clock and reset signals
    clk	  : in std_logic;
    rst_n : in std_logic;

    -- Data output to EX stage
    instr_rvalid_i : in std_logic;
    instr_rdata_i  : in std_logic_vector(31 downto 0);

    -- Pipeline propagation control signals
    id_enable_o : out std_logic;
    id_clear_o	: out std_logic;  	-- TODO: What is the clear?
    ex_enable_i : in  std_logic;

    -- ALU Signals
    alu_input_a_ex_o : out std_logic_vector(31 downto 0);
    alu_input_b_ex_o : out std_logic_vector(31 downto 0);
    alu_operator_ex_o : out std_logic_vector(5 downto 0);  -- TODO: How many bits?

    )

end entity id_stage;
