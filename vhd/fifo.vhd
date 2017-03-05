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
    Data_Valid   : out std_logic;
    Empty        : out std_logic;
    Full         : out std_logic);

end entity FIFO;

architecture Behavioural of FIFO is
  constant DEPTH : integer := 2**ADDR_WIDTH;

  type RegisterArray is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal FIFO : RegisterArray := (others => (others => '0'));

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
      Data_Valid   <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      Read_Pointer <= Read_Pointer;
      Data_Output  <= (others => '0');
      Data_Valid   <= '0';

      case Read_Enable is
        when '1' =>
          -- FIFO is not empty. Just reads.
          if (unsigned(Status_Counter) /= 0) then
            Data_Output  <= FIFO(to_integer(unsigned(Read_Pointer)));
            Read_Pointer <= std_logic_vector(unsigned(Read_Pointer) + 1);
            Data_Valid   <= '1';
          -- FIFO is empty, but is trying to write in the same cycle. Relies input and
          -- output directly.
          elsif (Write_Enable = '1') then
            Data_Output <= Data_Input;
            Data_Valid  <= '1';
          end if;

        when others =>
          Data_Output <= (others => '0');
          Data_Valid  <= '0';
      end case;
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
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      Write_Pointer <= Write_Pointer;

      -- Writes, if not Full.
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
      -- Default assignemnt.
      Status_Counter <= Status_Counter;

      -- Only reading, and it is not empty.
      if ((Read_Enable = '1') and (Write_Enable = '0') and (unsigned(Status_Counter) /= 0)) then
        Status_Counter <= std_logic_vector(unsigned(Status_Counter) - 1);
      end if;

      -- Trying to read and write when full: only reads.
      if ((Read_Enable = '1') and (Write_Enable = '1') and (unsigned(Status_Counter) = DEPTH)) then
        Status_Counter <= std_logic_vector(unsigned(Status_Counter) - 1);
      end if;

      -- Only writing, and it is not full.
      if ((Read_Enable = '0') and (Write_Enable = '1') and (unsigned(Status_Counter) /= DEPTH)) then
        Status_Counter <= std_logic_vector(unsigned(Status_Counter) + 1);
      end if;

    -- If trying to read and write on FIFO, and it is empty, both operations
    -- will be made. So Status_Counter <= Status_Counter.
    end if;
  end process StatusCounterProc;

end architecture Behavioural;
