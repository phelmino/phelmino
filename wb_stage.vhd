library ieee;
use ieee.std_logic_1164.all;

library lib_VHDL;

entity wb_stage is

  port (
    -- Clock and reset signals
    clk	  : in std_logic;
    rst_n : in std_logic;

    -- Data interface signals 
    data_req_o	  : out std_logic;
    data_gnt_i	  : in	std_logic;
    data_rvalid_i : in	std_logic;
    data_addr_o	  : out std_logic_vector(31 downto 0);
    data_we_o	  : out std_logic;
    data_be_o	  : out std_logic_vector(3 downto 0);
    data_wdata_o  : out std_logic_vector(31 downto 0);
    data_rdata_i  : in	std_logic_vector(31 downto 0);

    -- Pipeline propagation control signals
    ex_valid_i : in std_logic);

end entity wb_stage;
