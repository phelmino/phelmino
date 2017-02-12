library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.all;

entity test_general_purpose_registers is
end entity test_general_purpose_registers;

architecture behav of test_general_purpose_registers is

  component general_purpose_registers is
    generic (
      W : natural;
      N : natural); 
    port (
      clk             : in  std_logic;
      rst_n           : in  std_logic;
      read_addr_a_en  : in  std_logic;
      read_addr_a_i   : in  std_logic_vector(N-1 downto 0);
      read_data_a_o   : out std_logic_vector(W-1 downto 0);
      read_addr_b_en  : in  std_logic;
      read_addr_b_i   : in  std_logic_vector(N-1 downto 0);
      read_data_b_o   : out std_logic_vector(W-1 downto 0);
      write_addr_a_en : in  std_logic;
      write_addr_a_i  : in  std_logic_vector(N-1 downto 0);
      write_data_a_i  : in  std_logic_vector(W-1 downto 0);
      write_data_gnt  : out std_logic); 
  end component general_purpose_registers;
  
  signal clk             : std_logic;
  signal rst_n           : std_logic;
  signal read_addr_a_en  : std_logic;
  signal read_addr_a_i   : std_logic_vector(4 downto 0);
  signal read_data_a_o   : std_logic_vector(31 downto 0);
  signal read_addr_b_en  : std_logic;
  signal read_addr_b_i   : std_logic_vector(4 downto 0);
  signal read_data_b_o   : std_logic_vector(31 downto 0);
  signal write_addr_a_en : std_logic;
  signal write_addr_a_i  : std_logic_vector(4 downto 0);
  signal write_data_a_i  : std_logic_vector(31 downto 0);
  signal write_data_gnt  : std_logic;

begin  -- architecture behav

  -- instance "GPR"
  GPR : entity lib_VHDL.general_purpose_registers
    generic map (
      W => 32,
      N => 5)
    port map (
      clk             => clk,
      rst_n           => rst_n,
      read_addr_a_en  => read_addr_a_en,
      read_addr_a_i   => read_addr_a_i,
      read_data_a_o   => read_data_a_o,
      read_addr_b_en  => read_addr_b_en,
      read_addr_b_i   => read_addr_b_i,
      read_data_b_o   => read_data_b_o,
      write_addr_a_en => write_addr_a_en,
      write_addr_a_i  => write_addr_a_i,
      write_data_a_i  => write_data_a_i,
      write_data_gnt  => write_data_gnt);

end architecture behav;
