library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity general_purpose_registers is

  generic (
    W : natural := 32;                  -- width of each register
    N : natural := 5                    -- number of addressing bits    
    );

  port (
    -- Clock and reset signals
    clk   : in std_logic;
    rst_n : in std_logic;

    -- Read interface
    read_enable_a_i : in  std_logic;
    read_addr_a_i   : in  std_logic_vector(N-1 downto 0);
    read_data_a_o   : out std_logic_vector(W-1 downto 0);

    read_enable_b_i : in  std_logic;
    read_addr_b_i   : in  std_logic_vector(N-1 downto 0);
    read_data_b_o   : out std_logic_vector(W-1 downto 0);

    -- Write interface
    write_enable_a_i : in std_logic;
    write_addr_a_i   : in std_logic_vector(N-1 downto 0);
    write_data_a_i   : in std_logic_vector(W-1 downto 0));

end entity general_purpose_registers;

architecture behav of general_purpose_registers is
  type register_array is array (0 to 2**N-1) of std_logic_vector(W-1 downto 0);
  signal gpr : register_array;

  signal next_read_data_a : std_logic_vector(W-1 downto 0);
  signal next_read_data_b : std_logic_vector(W-1 downto 0);
begin  -- architecture behav

  -- purpose: Sequential process that refreshes the outputs of the GPR and rewrites the apropriated registers.
  -- type   : sequential
  -- inputs : clk, rst_n
  -- outputs: read_data_a_o, read_data_b_o
  seq_process : process (clk, rst_n) is
  begin  -- process seq_process

    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- Clears outputs
      read_data_a_o    <= (others => '0');
      read_data_b_o    <= (others => '0');

      -- Clears register bank
      for i in 0 to 2**N-1 loop
        gpr(i) <= (others => '0');
      end loop;
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- Clears outputs
      read_data_a_o    <= next_read_data_a;
      read_data_b_o    <= next_read_data_b;

      -- Rewrites specific address in register bank
      if (write_enable_a_i = '1') then
        if (write_addr_a_i /= "00000") then  -- Can not rewrite register r0
          gpr(to_integer(unsigned(write_addr_a_i))) <= write_data_a_i;
        end if;
      end if;

    end if;
  end process seq_process;

  -- purpose: Monitores willing to read and decides next outputs of registers
  -- type   : combinational
  -- inputs : read_enable_a_i, read_addr_a_i, read_enable_b_i, read_addr_b_i
  -- outputs: next_read_data_a, next_read_data_b
  comb_proc : process (gpr, read_addr_a_i, read_addr_b_i, read_enable_a_i,
                       read_enable_b_i) is
  begin  -- process comb_proc
    next_read_data_a <= (others => '0');
    next_read_data_b <= (others => '0');

    if (read_enable_a_i = '1') then
      next_read_data_a <= gpr(to_integer(unsigned(read_addr_a_i)));
    end if;
    if (read_enable_b_i = '1') then
      next_read_data_b <= gpr(to_integer(unsigned(read_addr_b_i)));
    end if;

  end process comb_proc;

end architecture behav;
