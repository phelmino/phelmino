library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity prefetch_buffer is

  generic (
    ADDR_WIDTH : natural := 2;
    DATA_WIDTH : natural := 32);

  port (
    CLK     : in  std_logic;
    RST_n   : in  std_logic;
    WriteEn : in  std_logic;
    DataIn  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    ReadEn  : in  std_logic;
    DataOut : out std_logic_vector(DATA_WIDTH-1 downto 0);
    Empty   : out std_logic;
    Full    : out std_logic);

end entity prefetch_buffer;

architecture behav of prefetch_buffer is
  constant DEPTH : integer := 2**ADDR_WIDTH;

  type RegisterArray is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal FIFO : RegisterArray;

  signal ReadPointer   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal WritePointer  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal StatusCounter : std_logic_vector(DATA_WIDTH downto 0)   := (others => '0');
begin  -- architecture behav

  Empty <= '1' when (unsigned(StatusCounter) = 0)       else '0';
  Full  <= '1' when (unsigned(StatusCounter) = DEPTH-1) else '0';

  -- purpose: Updates DataOut
  -- type   : sequential
  -- inputs : CLK, RST_n, ReadEn
  -- outputs: DataOut
  ReadProc : process (CLK, RST_n) is
  begin  -- process ReadProc
    if RST_n = '0' then                 -- asynchronous reset (active low)
      DataOut     <= (others => '0');
      ReadPointer <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if (ReadEn = '1') then
        DataOut     <= FIFO(to_integer(unsigned(ReadPointer)));
        ReadPointer <= std_logic_vector(unsigned(ReadPointer) + 1);
      else
        DataOut <= (others => '0');
      end if;
    end if;
  end process ReadProc;

  -- purpose: Reads DataIn
  -- type   : sequential
  -- inputs : CLK, RST_n, WriteEn, DataIn
  -- outputs: 
  WriteProc : process (CLK, RST_n) is
  begin  -- process WriteProc
    if RST_n = '0' then                 -- asynchronous reset (active low)
      WritePointer <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if ((WriteEn = '1') and (unsigned(StatusCounter) /= DEPTH-1)) then
        FIFO(to_integer(unsigned(WritePointer))) <= DataIn;
        WritePointer                             <= std_logic_vector(unsigned(WritePointer) + 1);
      end if;
    end if;
  end process WriteProc;

  -- purpose: Update Status Counter
  -- type   : sequential
  -- inputs : CLK, RST_n, ReadEn, WriteEn
  -- outputs: StatusCounter
  StatusCounterProc : process (CLK, RST_n) is
  begin  -- process StatusCounterProc
    if RST_n = '0' then                 -- asynchronous reset (active low)
      StatusCounter <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if ((ReadEn = '1') and (WriteEn = '0') and (unsigned(StatusCounter) /= 0)) then  -- Only reading
        StatusCounter <= std_logic_vector(unsigned(StatusCounter) - 1);
      elsif ((ReadEn = '0') and (WriteEn = '1') and (unsigned(StatusCounter) /= DEPTH-1)) then  -- Only writing
        StatusCounter <= std_logic_vector(unsigned(StatusCounter) + 1);
      end if;
    end if;
  end process StatusCounterProc;

end architecture behav;
