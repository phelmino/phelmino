library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vhdl;
use lib_vhdl.phelmino_definitions.all;

library lib_fpga;
use lib_fpga.memory_definitions.all;

entity rom is

  generic (
    depth : natural := MEMORY_DEPTH;
    width : natural := MEMORY_WIDTH);

  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    address : in  std_logic_vector(depth-1 downto 0);
    output  : out std_logic_vector(width-1 downto 0));

end entity rom;

architecture behavioural of rom is

  type     rom_data_type is array (0 to 2**MEMORY_DEPTH-1) of std_logic_vector(width-1 downto 0);
  constant fibonacci : rom_data_type :=
    (0      => x"01400f13",             -- li t5, 20
     1      => x"20000f93",             -- li t6, 512
     2      => x"00100093",             -- li ra, 1
     3      => x"001fa023",             -- sw ra, 0(t6)
     4      => x"004f8f93",             -- addi t6, t6, 4
     5      => x"00100113",             -- li sp, 1
     6      => x"002fa023",             -- sw sp, 0(t6)
     7      => x"004f8f93",             -- addi t6, t6, 4
                                        -- <loop>
     8      => x"ff8fa083",             -- lw ra, -8(t6)
     9      => x"002081b3",             -- add gp, ra, sp
     10     => x"003fa023",             -- sw gp, 0(t6)
     11     => x"004f8f93",             -- addi t6, t6, 4
     12     => x"ffff0f13",             -- addi t5, t5, -1
     13     => x"00018113",             -- mv sp, gp
     14     => x"fe0f12e3",             -- bnez t5, 20 <loop>
     15     => x"3e302c23",             -- sw gp, 1016(zero)
     others => NOP);

  constant baby : rom_data_type :=
    (0      => x"20000f93",             -- li t6, 512
     1      => x"00100093",             -- li ra, 1
     2      => x"001fa023",             -- sw ra, 0(t6)
     others => NOP);

  constant test_hazard : rom_data_type :=
    (0      => x"00100093",             -- li ra, 1
     1      => x"00108133",             -- add sp, ra, ra
     2      => x"002101b3",             -- add gp, sp, sp
     3      => x"00318233",             -- add tp, gp, gp
     4      => x"004202b3",             -- add t0, tp, tp
     5      => x"00528333",             -- add t1, t0, t0
     others => NOP);

  constant mini : rom_data_type :=
    (0      => x"00100093",             -- li ra, 1
     1      => x"08000f93",             -- li t6, 128
     5      => x"181fa023",             -- sw ra, 384(t6)
     others => NOP);

  signal next_output : std_logic_vector(width-1 downto 0);

begin  -- architecture behavioural

  sequential : process (clk, rst_n) is
  begin  -- process sequential
    if rst_n = '0' then                 -- asynchronous reset (active low)
      output <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      output <= next_output;
    end if;
  end process sequential;

  combinational : process (address) is
  begin  -- process combinational
    next_output <= fibonacci(to_integer(unsigned(address)));
  end process combinational;

end architecture behavioural;
