library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library lib_VHDL;
use lib_VHDL.phelmino_definitions.all;

entity FIFO is

  generic (
    ADDR_WIDTH : natural := PREFETCH_ADDRESS_WIDTH;
    DATA_WIDTH : natural := WORD_WIDTH);

  port (
    CLK          : in  std_logic;
    RST_n        : in  std_logic;
    Write_Enable : in  std_logic;
    Data_Input   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    Read_Enable  : in  std_logic;
    Data_Output  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    Empty        : out std_logic;
    Full         : out std_logic);

end entity FIFO;

architecture Behavioural of FIFO is
  constant DEPTH : integer := 2**ADDR_WIDTH;

  type RegisterArray is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal FIFO : RegisterArray;

  signal Read_Pointer  : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal Write_Pointer : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

  -- Difference between the number of writes and the number of reads
  signal Status_Counter : std_logic_vector(ADDR_WIDTH downto 0) := (others => '0');
begin  -- architecture Behavioural

  -- Empty if number of reads equals number of writes
  Empty <= '1' when (unsigned(Status_Counter) = 0)     else '0';
  -- Full if number of writes is equal to the number of reads - DEPTH
  Full  <= '1' when (unsigned(Status_Counter) = DEPTH) else '0';

  -- purpose: Updates Data_Output
  -- type   : sequential
  -- inputs : CLK, RST_n, Read_Enable
  -- outputs: Data_Output
  ReadProc : process (CLK, RST_n) is
  begin  -- process ReadProc
    if RST_n = '0' then                 -- asynchronous reset (active low)
      Data_Output  <= (others => '0');
      Read_Pointer <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if (Read_Enable = '1' and (unsigned(Status_Counter) /= 0)) then
        Data_Output  <= FIFO(to_integer(unsigned(Read_Pointer)));
        Read_Pointer <= std_logic_vector(unsigned(Read_Pointer) + 1);
      else
        Data_Output <= (others => '0');
      end if;
    end if;
  end process ReadProc;

  -- purpose: Reads Data_Input
  -- type   : sequential
  -- inputs : CLK, RST_n, Write_Enable, Data_Input
  -- outputs: 
  WriteProc : process (CLK, RST_n) is
  begin  -- process WriteProc
    if RST_n = '0' then                 -- asynchronous reset (active low)
      Write_Pointer <= (others => '0');
      for I in 0 to DEPTH-1 loop
        FIFO(I) <= (others => '0');
      end loop;  -- I
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if ((Write_Enable = '1') and (unsigned(Status_Counter) /= DEPTH)) then
        FIFO(to_integer(unsigned(Write_Pointer))) <= Data_Input;
        Write_Pointer                             <= std_logic_vector(unsigned(Write_Pointer) + 1);
      end if;
    end if;
  end process WriteProc;

  -- purpose: Update Status Counter
  -- type   : sequential
  -- inputs : CLK, RST_n, Read_Enable, Write_Enable
  -- outputs: Status_Counter
  StatusCounterProc : process (CLK, RST_n) is
  begin  -- process StatusCounterProc
    if RST_n = '0' then                 -- asynchronous reset (active low)
      Status_Counter <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if ((Read_Enable = '1') and (Write_Enable = '0') and (unsigned(Status_Counter) /= 0)) then  -- Only reading
        Status_Counter <= std_logic_vector(unsigned(Status_Counter) - 1);
      elsif ((Read_Enable = '0') and (Write_Enable = '1') and (unsigned(Status_Counter) /= DEPTH)) then  -- Only writing
        Status_Counter <= std_logic_vector(unsigned(Status_Counter) + 1);
      elsif ((Read_Enable = '1') and (Write_Enable = '1') and (unsigned(Status_Counter) = DEPTH)) then  -- Trying to read and write when full : only does the read operation.
        Status_Counter <= std_logic_vector(unsigned(Status_Counter) - 1);
      end if;
    end if;
  end process StatusCounterProc;

end architecture Behavioural;
