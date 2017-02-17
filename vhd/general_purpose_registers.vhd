library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity general_purpose_registers is

  generic (
    W : natural := WORD_WIDTH;      -- width of each register
    N : natural := GPR_ADDRESS_WIDTH    -- number of addressing bits    
    );

  port (
    -- Clock and reset signals
    CLK   : in std_logic;
    RST_n : in std_logic;

    -- Read interface
    Read_Enable_A_Input  : in  std_logic;
    Read_Address_A_Input : in  std_logic_vector(N-1 downto 0);
    Read_Data_A_Output   : out std_logic_vector(W-1 downto 0);

    Read_Enable_B_Input  : in  std_logic;
    Read_Address_B_Input : in  std_logic_vector(N-1 downto 0);
    Read_Data_B_Output   : out std_logic_vector(W-1 downto 0);

    -- Write interface
    Write_Enable_Z_Input  : in std_logic;
    Write_Address_Z_Input : in std_logic_vector(N-1 downto 0);
    Write_Data_Z_Input    : in std_logic_vector(W-1 downto 0));

end entity general_purpose_registers;

architecture Behavioural of general_purpose_registers is
  type Register_Array is array (0 to 2**N-1) of std_logic_vector(W-1 downto 0);
  signal GPR : Register_Array;

  signal Next_Read_Data_A : std_logic_vector(W-1 downto 0);
  signal Next_Read_Data_B : std_logic_vector(W-1 downto 0);
begin  -- architecture Behavioural

  -- purpose: Sequential process that refreshes the outputs of the GPR and rewrites the apropriated registers.
  -- type   : sequential
  -- inputs : CLK, RST_n
  -- outputs: Read_Data_A_Output, Read_Data_B_Output
  seq_process : process (CLK, RST_n) is
  begin  -- process seq_process

    if RST_n = '0' then                 -- asynchronous reset (active low)
      -- Clears outputs
      Read_Data_A_Output <= (others => '0');
      Read_Data_B_Output <= (others => '0');

      -- Clears register bank
      for i in 0 to 2**N-1 loop
        GPR(i) <= (others => '0');
      end loop;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      -- Clears outputs
      Read_Data_A_Output <= Next_Read_Data_A;
      Read_Data_B_Output <= Next_Read_Data_B;

      -- Rewrites specific address in register bank
      if (Write_Enable_Z_Input = '1') then
        if (Write_Address_Z_Input /= "00000") then  -- Can not rewrite register r0
          GPR(to_integer(unsigned(Write_Address_Z_Input))) <= Write_Data_Z_Input;
        end if;
      end if;

    end if;
  end process seq_process;

  -- purpose: Monitores willing to read and decides next outputs of registers
  -- type   : combinational
  -- inputs : Read_Enable_A_Input, Read_Address_A_Input, Read_Enable_B_Input, Read_Address_B_Input
  -- outputs: Next_Read_Data_A, Next_Read_Data_B
  comb_proc : process (GPR, Read_Address_A_Input, Read_Address_B_Input, Read_Enable_A_Input,
                       Read_Enable_B_Input) is
  begin  -- process comb_proc
    Next_Read_Data_A <= (others => '0');
    Next_Read_Data_B <= (others => '0');

    if (Read_Enable_A_Input = '1') then
      Next_Read_Data_A <= GPR(to_integer(unsigned(Read_Address_A_Input)));
    end if;
    if (Read_Enable_B_Input = '1') then
      Next_Read_Data_B <= GPR(to_integer(unsigned(Read_Address_B_Input)));
    end if;

  end process comb_proc;

end architecture Behavioural;
