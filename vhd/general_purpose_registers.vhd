library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;

entity general_purpose_registers is

  generic (
    W : natural := 32;                  -- width of each register
    N : natural := 5                    -- number of addressing bits    
    );

  port (
    -- Clock and reset signals
    CLK   : in std_logic;
    RST_n : in std_logic;

    -- Read interface
    ReadEnableA_i  : in  std_logic;
    ReadAddressA_i : in  std_logic_vector(N-1 downto 0);
    ReadDataA_o    : out std_logic_vector(W-1 downto 0);

    ReadEnableB_i  : in  std_logic;
    ReadAddressB_i : in  std_logic_vector(N-1 downto 0);
    ReadDataB_o    : out std_logic_vector(W-1 downto 0);

    -- Write interface
    WriteEnableZ_i  : in std_logic;
    WriteAddressZ_i : in std_logic_vector(N-1 downto 0);
    WriteDataZ_i    : in std_logic_vector(W-1 downto 0));

end entity general_purpose_registers;

architecture behav of general_purpose_registers is
  type register_array is array (0 to 2**N-1) of std_logic_vector(W-1 downto 0);
  signal gpr : register_array;

  signal next_read_data_a : std_logic_vector(W-1 downto 0);
  signal next_read_data_b : std_logic_vector(W-1 downto 0);
begin  -- architecture behav

  -- purpose: Sequential process that refreshes the outputs of the GPR and rewrites the apropriated registers.
  -- type   : sequential
  -- inputs : CLK, RST_n
  -- outputs: ReadDataA_o, ReadDataB_o
  seq_process : process (CLK, RST_n) is
  begin  -- process seq_process

    if RST_n = '0' then                 -- asynchronous reset (active low)
      -- Clears outputs
      ReadDataA_o <= (others => '0');
      ReadDataB_o <= (others => '0');

      -- Clears register bank
      for i in 0 to 2**N-1 loop
        gpr(i) <= (others => '0');
      end loop;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      -- Clears outputs
      ReadDataA_o <= next_read_data_a;
      ReadDataB_o <= next_read_data_b;

      -- Rewrites specific address in register bank
      if (WriteEnableZ_i = '1') then
        if (WriteAddressZ_i /= "00000") then  -- Can not rewrite register r0
          gpr(to_integer(unsigned(WriteAddressZ_i))) <= WriteDataZ_i;
        end if;
      end if;

    end if;
  end process seq_process;

  -- purpose: Monitores willing to read and decides next outputs of registers
  -- type   : combinational
  -- inputs : ReadEnableA_i, ReadAddressA_i, ReadEnableB_i, ReadAddressB_i
  -- outputs: next_read_data_a, next_read_data_b
  comb_proc : process (gpr, ReadAddressA_i, ReadAddressB_i, ReadEnableA_i,
                       ReadEnableB_i) is
  begin  -- process comb_proc
    next_read_data_a <= (others => '0');
    next_read_data_b <= (others => '0');

    if (ReadEnableA_i = '1') then
      next_read_data_a <= gpr(to_integer(unsigned(ReadAddressA_i)));
    end if;
    if (ReadEnableB_i = '1') then
      next_read_data_b <= gpr(to_integer(unsigned(ReadAddressB_i)));
    end if;

  end process comb_proc;

end architecture behav;
