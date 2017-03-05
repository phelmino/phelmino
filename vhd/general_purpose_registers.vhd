library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

entity general_purpose_registers is

  generic (
    w : natural := WORD_WIDTH;          -- width of each register
    n : natural := GPR_ADDRESS_WIDTH    -- number of addressing bits    
    );

  port (
    -- clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- read interface
    read_address_a_input : in  std_logic_vector(n-1 downto 0);
    read_data_a_output   : out std_logic_vector(w-1 downto 0);

    read_address_b_input : in  std_logic_vector(n-1 downto 0);
    read_data_b_output   : out std_logic_vector(w-1 downto 0);

    -- write interface
    write_enable_y_input  : in std_logic;
    write_address_y_input : in std_logic_vector(n-1 downto 0);
    write_data_y_input    : in std_logic_vector(w-1 downto 0);

    write_enable_z_input  : in std_logic;
    write_address_z_input : in std_logic_vector(n-1 downto 0);
    write_data_z_input    : in std_logic_vector(w-1 downto 0));

end entity general_purpose_registers;

architecture behavioural of general_purpose_registers is
  type register_array is array (0 to 2**n-1) of std_logic_vector(w-1 downto 0);
  signal gpr : register_array;

  signal next_read_data_a : std_logic_vector(w-1 downto 0);
  signal next_read_data_b : std_logic_vector(w-1 downto 0);
begin  -- architecture behavioural

  -- purpose: sequential process that refreshes the outputs of the gpr and rewrites the apropriated registers.
  -- type   : sequential
  -- inputs : clk, rst_n
  -- outputs: read_data_a_output, read_data_b_output
  seq_process : process (clk, rst_n) is
  begin  -- process seq_process

    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- clears outputs
      read_data_a_output <= (others => '0');
      read_data_b_output <= (others => '0');

      -- clears register bank
      for i in 0 to 2**n-1 loop
        gpr(i) <= (others => '0');
        -- gpr(i) <= std_logic_vector(to_unsigned(i, gpr(i)'length));
      end loop;
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- clears outputs
      read_data_a_output <= next_read_data_a;
      read_data_b_output <= next_read_data_b;

      -- rewrites specific address in register bank
      -- can not rewrite register r0
      if (write_enable_z_input = '1' and (write_address_z_input /= "00000")) then
        gpr(to_integer(unsigned(write_address_z_input))) <= write_data_z_input;
      end if;

      if (write_enable_y_input = '1' and (write_address_y_input /= "00000")) then
        -- bus z has priority over bus y. howerver the decoding unit should
        -- never let that the same register is written at the same time.
        if (write_enable_z_input = '0' or write_address_y_input /= write_address_z_input) then
          gpr(to_integer(unsigned(write_address_y_input))) <= write_data_y_input;
        end if;
      end if;

    end if;
  end process seq_process;

  -- purpose: monitores willing to read and decides next outputs of registers
  -- type   : combinational
  -- inputs : read_address_a_input, read_address_b_input
  -- outputs: next_read_data_a, next_read_data_b
  comb_proc : process (gpr, read_address_a_input, read_address_b_input) is
  begin  -- process comb_proc
    next_read_data_a <= gpr(to_integer(unsigned(read_address_a_input)));
    next_read_data_b <= gpr(to_integer(unsigned(read_address_b_input)));
  end process comb_proc;

end architecture behavioural;
