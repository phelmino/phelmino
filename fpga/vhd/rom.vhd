library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

entity rom is

  generic (
    depth : natural := MEMORY_DEPTH;
    width : natural := MEMORY_WIDTH);

  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    address : in  std_logic_vector(depth-1 downto 0);
    output  : out std_logic_vector(width-1 downto 0));

end entity rom;

architecture behavioural of rom is

  type rom_data_type is array (0 to ROM_DEPTH) of std_logic_vector(width-1 downto 0);
  constant rom_data : rom_data_type :=
    (0      => x"00100093",             -- li x1, 1
     1      => x"08102023",             -- sw x1, 512(x0)
     2      => x"00100113",             -- li x2, 1
     3      => x"08202223",             -- sw x2, 516(x0)
     others => x"0000FFFF");

  signal next_output : std_logic_vector(width-1 downto 0);

begin  -- architecture behavioural

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      output <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      output <= next_output;
    end if;
  end process sequential;

  combinational : process (address) is
  begin  -- process combinational
    next_output <= rom_data(to_integer(unsigned(address)));
  end process combinational;

end architecture behavioural;
