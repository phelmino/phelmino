library ieee;
use ieee.std_logic_1164.all;

entity wb_stage is

  port (
    -- clock and reset signals
    clk	  : in std_logic;
    rst_n : in std_logic;

    -- data interface signals 
    data_rvalid_i : in	std_logic;
    data_rdata_i  : in	std_logic_vector(31 downto 0);

    -- pipeline propagation control signals
    ex_valid_i : in std_logic);

end entity wb_stage;
