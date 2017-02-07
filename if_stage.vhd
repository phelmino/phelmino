library ieee;
use ieee.numeric_std.all;

entity if_stage is

  port (
    -- Clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- Instruction interface signals
    instr_req_o    : out std_logic;
    instr_addr_o   : out std_logic_vector(31 downto 0);
    instr_gnt_i    : in  std_logic;
    instr_rvalid_i : in  std_logic;
    instr_rdata_i  : in  std_logic_vector(31 downto 0);

    -- Data output to ID stage
    instr_rvalid_id_o : out std_logic;
    instr_rdata_id_o  : out std_logic_vector(31 downto 0)

    -- Pipeline propagation control signals
    if_enable_o : out std_logic;
    id_enable_i : in  std_logic;
    if_valid_o  : out std_logic);

end entity if_stage;
