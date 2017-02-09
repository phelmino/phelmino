library ieee;
use ieee.std_logic_1164.all;

entity general_purpose_registers is

  port (
    -- Clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- Read interface
    read_addr_a_i : in  std_logic_vector(4 downto 0);
    read_data_a_o : out std_logic_vector(31 downto 0);
    read_addr_b_i : in  std_logic_vector(4 downto 0);
    read_data_b_o : out std_logic_vector(31 downto 0);

    -- Write interface
    write_addr_a_i : in std_logic_vector(4 downto 0);
    write_data_a_i : in std_logic_vector(31 downto 0));

end entity general_purpose_registers;
