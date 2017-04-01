library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity ram is

  generic (
    depth : natural := MEMORY_DEPTH;
    width : natural := MEMORY_WIDTH);

  port (
    clk            : in  std_logic;
    rst_n          : in  std_logic;
    address_a      : in  std_logic_vector(depth-1 downto 0);
    address_b      : in  std_logic_vector(depth-1 downto 0);
    input          : in  std_logic_vector(width-1 downto 0);
    output_a       : out std_logic_vector(width-1 downto 0);
    output_b       : out std_logic_vector(width-1 downto 0);
    output_hex     : out std_logic_vector(width-1 downto 0);
    write_enable_b : in  std_logic);

end entity ram;

architecture behavioural of ram is

  type ram_data_type is array (0 to 2**depth-1) of std_logic_vector(width-1 downto 0);

  signal next_output_a   : std_logic_vector(width-1 downto 0);
  signal next_output_b   : std_logic_vector(width-1 downto 0);
  signal next_output_hex : std_logic_vector(width-1 downto 0);

  constant instructions : string := "/home/cavalcante/RISCV/phelmino/assembly/phelmino_rom.txt";

  impure function init_ram_from_file (ram_file_name : in string) return ram_data_type is
    file ram_file       : text open read_mode is ram_file_name;
    variable read_line  : line;
    variable ram_vector : std_logic_vector(width-1 downto 0);
    variable ram_data   : ram_data_type;
    variable n          : natural := 0;
  begin
    while not endfile(ram_file) loop
      readline(ram_file, read_line);
      hread(read_line, ram_vector);
      ram_data(n) := ram_vector;
      n           := n + 1;
    end loop;
    return ram_data;
  end function;

  signal ram_data : ram_data_type := init_ram_from_file(instructions);

begin  -- architecture behavioural

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      output_a   <= (others => '0');
      output_b   <= (others => '0');
      output_hex <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      output_a   <= next_output_a;
      output_hex <= next_output_hex;
      case write_enable_b is
        when '0' =>
          output_b <= next_output_b;

        when others =>
          output_b                                  <= (others => '0');
          ram_data(to_integer(unsigned(address_b))) <= input;
      end case;
    end if;
  end process sequential;

  combinational : process (address_a, address_b, ram_data) is
  begin  -- process combinational
    next_output_a   <= ram_data(to_integer(unsigned(address_a)));
    next_output_b   <= ram_data(to_integer(unsigned(address_b)));
    next_output_hex <= ram_data(HEX_ADDR - RAM_BEGIN);
  end process combinational;

end architecture behavioural;
