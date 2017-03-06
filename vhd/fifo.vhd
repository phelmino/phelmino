library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity fifo is

  generic (
    addr_width : natural := PREFETCH_ADDRESS_WIDTH;
    data_width : natural := WORD_WIDTH);

  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    write_enable : in  std_logic;
    data_input   : in  std_logic_vector(data_width-1 downto 0);
    read_enable  : in  std_logic;
    data_output  : out std_logic_vector(data_width-1 downto 0);
    data_valid   : out std_logic;
    empty        : out std_logic;
    full         : out std_logic);

end entity fifo;

architecture behavioural of fifo is
  constant depth : integer := 2**addr_width;

  type registerarray is array (0 to depth-1) of std_logic_vector(data_width-1 downto 0);
  signal fifo : registerarray;

  signal read_pointer  : std_logic_vector(addr_width-1 downto 0);
  signal write_pointer : std_logic_vector(addr_width-1 downto 0);

  -- difference between the number of writes and the number of reads
  signal status_counter : std_logic_vector(addr_width downto 0);
begin  -- architecture behavioural

  -- empty if number of reads equals number of writes
  empty <= '1' when (unsigned(status_counter) = 0)     else '0';
  -- full if number of writes is equal to the number of reads - depth
  full  <= '1' when (unsigned(status_counter) = depth) else '0';

  -- purpose: updates data_output
  -- type   : sequential
  -- inputs : clk, rst_n, read_enable
  -- outputs: data_output
  readproc : process (clk, rst_n) is
  begin  -- process readproc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      data_output  <= (others => '0');
      read_pointer <= (others => '0');
      data_valid   <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      read_pointer <= read_pointer;
      data_output  <= (others => '0');
      data_valid   <= '0';

      -- reads, if not empty.
      if ((read_enable = '1') and (unsigned(status_counter) /= 0)) then
        data_output  <= fifo(to_integer(unsigned(read_pointer)));
        read_pointer <= std_logic_vector(unsigned(read_pointer) + 1);
        data_valid   <= '1';
      end if;
    end if;
  end process readproc;

  -- purpose: reads data_input
  -- type   : sequential
  -- inputs : clk, rst_n, write_enable, data_input
  -- outputs: 
  writeproc : process (clk, rst_n) is
  begin  -- process writeproc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      write_pointer <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      write_pointer <= write_pointer;

      -- writes, if not full.
      if ((write_enable = '1') and (unsigned(status_counter) /= depth)) then
        fifo(to_integer(unsigned(write_pointer))) <= data_input;
        write_pointer                             <= std_logic_vector(unsigned(write_pointer) + 1);
      end if;
    end if;
  end process writeproc;

  -- purpose: update status counter
  -- type   : sequential
  -- inputs : clk, rst_n, read_enable, write_enable
  -- outputs: status_counter
  statuscounterproc : process (clk, rst_n) is
  begin  -- process statuscounterproc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      status_counter <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- default assignemnt.
      status_counter <= status_counter;

      -- only reading, and it is not empty.
      if ((read_enable = '1') and (write_enable = '0') and (unsigned(status_counter) /= 0)) then
        status_counter <= std_logic_vector(unsigned(status_counter) - 1);
      end if;

      -- trying to read and write when full: only reads.
      if ((read_enable = '1') and (write_enable = '1') and (unsigned(status_counter) = depth)) then
        status_counter <= std_logic_vector(unsigned(status_counter) - 1);
      end if;

      -- only writing, and it is not full.
      if ((read_enable = '0') and (write_enable = '1') and (unsigned(status_counter) /= depth)) then
        status_counter <= std_logic_vector(unsigned(status_counter) + 1);
      end if;

      -- trying to read and write when empty: only writes.
      if ((read_enable = '1') and (write_enable = '1') and (unsigned(status_counter) = 0)) then
        status_counter <= std_logic_vector(unsigned(status_counter) + 1);
      end if;
    end if;
  end process statuscounterproc;

end architecture behavioural;
