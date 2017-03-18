library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity ram is

  generic (
    depth : natural := MEMORY_DEPTH;
    width : natural := MEMORY_WIDTH);

  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    address      : in  std_logic_vector(depth-1 downto 0);
    input        : in  std_logic_vector(width-1 downto 0);
    output       : out std_logic_vector(width-1 downto 0);
    write_enable : in  std_logic);

end entity ram;

architecture behavioural of ram is

  type ram_data_type is array (0 to 2**depth-1) of std_logic_vector(width-1 downto 0);
  signal ram_data : ram_data_type := (others => (others => '0'));

  signal next_output : std_logic_vector(width-1 downto 0);

begin  -- architecture behavioural

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      output <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      case write_enable is
        when '0' =>
          output <= next_output;

        when others =>
          output                                  <= (others => '0');
          ram_data(to_integer(unsigned(address))) <= input;
      end case;
    end if;
  end process sequential;

  combinational : process (address, ram_data) is
  begin  -- process combinational
    next_output <= ram_data(to_integer(unsigned(address)));
  end process combinational;

end architecture behavioural;
