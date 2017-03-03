library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_VHDL;
use lib_VHDL.all;
use lib_VHDL.phelmino_definitions.all;

entity test_general_purpose_registers is
end entity test_general_purpose_registers;

architecture Behavioural of test_general_purpose_registers is

  component general_purpose_registers is
    generic (
      W : natural;
      N : natural);
    port (
      CLK                   : in  std_logic;
      RST_n                 : in  std_logic;
      Read_Address_A_Input  : in  std_logic_vector(N-1 downto 0);
      Read_Data_A_Output    : out std_logic_vector(W-1 downto 0);
      Read_Address_B_Input  : in  std_logic_vector(N-1 downto 0);
      Read_Data_B_Output    : out std_logic_vector(W-1 downto 0);
      Write_Enable_Z_Input  : in  std_logic;
      Write_Address_Z_Input : in  std_logic_vector(N-1 downto 0);
      Write_Data_Z_Input    : in  std_logic_vector(W-1 downto 0));
  end component general_purpose_registers;

  signal CLK                   : std_logic                                      := '0';
  signal RST_n                 : std_logic                                      := '0';
  signal Read_Address_A_Input  : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal Read_Data_A_Output    : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal Read_Address_B_Input  : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal Read_Data_B_Output    : std_logic_vector(WORD_WIDTH-1 downto 0);
  signal Write_Enable_Z_Input  : std_logic                                      := '0';
  signal Write_Address_Z_Input : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  signal Write_Data_Z_Input    : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');

begin  -- architecture Behavioural

  GPR : entity lib_VHDL.general_purpose_registers
    generic map (
      W => WORD_WIDTH,
      N => GPR_ADDRESS_WIDTH)
    port map (
      CLK                   => CLK,
      RST_n                 => RST_n,
      Read_Address_A_Input  => Read_Address_A_Input,
      Read_Data_A_Output    => Read_Data_A_Output,
      Read_Address_B_Input  => Read_Address_B_Input,
      Read_Data_B_Output    => Read_Data_B_Output,
      Write_Enable_Z_Input  => Write_Enable_Z_Input,
      Write_Address_Z_Input => Write_Address_Z_Input,
      Write_Data_Z_Input    => Write_Data_Z_Input);

  CLK   <= not CLK after 5 ns;
  RST_n <= '1'     after 7 ns;

  Stimulus : process is
    variable Read_Counter_A  : std_logic_vector(WORD_WIDTH-1 downto 0)        := (0      => '1', others => '0');
    variable Read_Address_A  : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
    variable Read_Counter_B  : std_logic_vector(WORD_WIDTH-1 downto 0)        := (0      => '1', others => '0');
    variable Read_Address_B  : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
    variable Write_Counter_Z : std_logic_vector(WORD_WIDTH-1 downto 0)        := (others => '0');
    variable Write_Address_Z : std_logic_vector(GPR_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  begin  -- process Stimulus

    Write_Enable_Z_Input <= '0';
    wait for 10 ns;
    wait until falling_edge(CLK);

    for W in 0 to WORD_WIDTH-1 loop
      Write_Enable_Z_Input  <= '1';
      Write_Address_Z_Input <= Write_Address_Z;
      Write_Data_Z_Input    <= Write_Counter_Z;
      Write_Counter_Z       := std_logic_vector(unsigned(Write_Counter_Z) + 1);
      Write_Address_Z       := std_logic_vector(unsigned(Write_Address_Z) + 1);
      wait until falling_edge(CLK);
    end loop;  -- W

    Write_Enable_Z_Input <= '0';
    wait until falling_edge(CLK);

    for RA in 0 to WORD_WIDTH-1 loop
      Read_Address_A_Input <= Read_Address_A;
      wait until falling_edge(CLK);

      if (RA = 0) then
        assert (unsigned(Read_Data_A_Output) = 0) report "Can not write over register 0" severity failure;
      else
        assert (Read_Data_A_Output = std_logic_vector(unsigned(Read_Counter_A))) report "Read error in register A" severity failure;
        Read_Counter_A := std_logic_vector(unsigned(Read_Counter_A) + 1);
      end if;
      Read_Address_A := std_logic_vector(unsigned(Read_Address_A) + 1);
      wait until falling_edge(CLK);
    end loop;  -- RA

    wait for 10 ns;

    for RB in 0 to WORD_WIDTH-1 loop
      Read_Address_B_Input <= Read_Address_B;
      wait until falling_edge(CLK);

      if (RB = 0) then
        assert (unsigned(Read_Data_B_Output) = 0) report "Can not write over register 0" severity failure;
      else
        assert (Read_Data_B_Output = std_logic_vector(unsigned(Read_Counter_B))) report "Read error in register B" severity failure;
        Read_Counter_B := std_logic_vector(unsigned(Read_Counter_B) + 1);
      end if;
      Read_Address_B := std_logic_vector(unsigned(Read_Address_B) + 1);
      wait until falling_edge(CLK);
    end loop;  -- RB

    wait for 10 ns;

    Read_Counter_A := (0      => '1', others => '0');
    Read_Address_A := (others => '0');
    Read_Counter_B := (0      => '1', others => '0');
    Read_Address_B := (others => '0');

    for RC in 0 to WORD_WIDTH-1 loop
      Read_Address_A_Input <= Read_Address_A;
      Read_Address_B_Input <= Read_Address_B;
      wait until falling_edge(CLK);

      if (RC = 0) then
        assert (unsigned(Read_Data_A_Output) = 0) report "Can not write over register 0" severity failure;
        assert (unsigned(Read_Data_B_Output) = 0) report "Can not write over register 0" severity failure;
      else
        assert (Read_Data_A_Output = std_logic_vector(unsigned(Read_Counter_A))) report "Read error in register A" severity failure;
        assert (Read_Data_B_Output = std_logic_vector(unsigned(Read_Counter_B))) report "Read error in register B" severity failure;
        Read_Counter_A := std_logic_vector(unsigned(Read_Counter_A) + 1);
        Read_Counter_B := std_logic_vector(unsigned(Read_Counter_B) + 1);
      end if;
      Read_Address_A := std_logic_vector(unsigned(Read_Address_A) + 1);
      Read_Address_B := std_logic_vector(unsigned(Read_Address_B) + 1);
      wait until falling_edge(CLK);
    end loop;  -- RC
  end process Stimulus;

end architecture Behavioural;
