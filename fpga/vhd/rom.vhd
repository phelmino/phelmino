library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

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

  type rom_data_type is array (0 to 2**MEMORY_DEPTH-1) of std_logic_vector(width-1 downto 0);
  constant fibonacci : rom_data_type :=
    (0      => x"00000193",             -- li gp, 0
     1      => x"01400f13",             -- li t5, 20
     -- 1      => x"3fc02f03",         -- lw t5, 1020(zero)
     2      => x"040f0663",             -- beqz t5, 54 <end>
     3      => x"20000f93",             -- li t6, 512
     4      => x"00100193",             -- li gp, 1
     5      => x"003fa023",             -- sw gp, 0(t6)
     6      => x"ffff0f13",             -- addi t5, t5, -1
     7      => x"020f0c63",             -- beqz t5, 54 <end>
     8      => x"004f8f93",             -- addi t6, t6, 4
     9      => x"00100193",             -- li gp, 1
     10     => x"003fa023",             -- sw gp, 0(t6)
     11     => x"ffff0f13",             -- addi t5, t5, -1
     12     => x"020f0263",             -- beqz t5, 54 <end>
     13     => x"004f8f93",             -- addi t6, t6, 4
     -- <loop>
     14     => x"ff8fa083",             -- lw ra, -8(t6)
     15     => x"ffcfa103",             -- lw sp, -4(t6)
     16     => x"002081b3",             -- add gp, ra, sp
     17     => x"003fa023",             -- sw gp, 0(t6)
     18     => x"004f8f93",             -- addi t6, t6, 4
     19     => x"ffff0f13",             -- addi t5, t5, -1
     20     => x"fe0f14e3",             -- bnez t5, 20 <loop>
     -- <end>
     21     => x"3e302c23",             -- sw gp, 1016(zero)
     others => NOP);

  constant fibonacci_hard : rom_data_type :=
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
     9      => x"ffcfa103",             -- lw sp, -4(t6)
     10     => x"00208133",             -- add sp, ra, sp
     11     => x"002fa023",             -- sw sp, 0(t6)
     12     => x"004f8f93",             -- addi t6, t6, 4
     13     => x"ffff0f13",             -- addi t5, t5, -1
     14     => x"fe0f14e3",             -- bnez t5, 20 <loop>
     15     => x"3e202c23",             -- sw sp, 1016(zero)
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

  constant meta : rom_data_type :=
    (0      => x"00100093",             -- li ra, 1
     1      => x"20002083",             -- lw ra, 512(zero)
     2      => x"00a08113",             -- addi sp, ra, 10
     others => NOP);

  constant jumperman : rom_data_type :=
    (0      => x"00a00093",             -- li ra, 10
     1      => x"00a08567",             -- jalr a0, 10(ra)
     others => NOP);

  constant broken : rom_data_type :=
    (0      => x"01400f13",             -- li t5, 20
     1      => x"20000f93",             -- li t6, 512
     2      => x"00100093",             -- li ra, 1
     3      => x"001fa023",             -- sw ra, 0(t6)
     4      => x"001f9103",             -- lh sp, 1(t6)
     others => NOP);

  signal next_output : std_logic_vector(width-1 downto 0);

  signal rom        : rom_data_type := (others => NOP);
  file instructions : text open read_mode is "/home/cavalcante/RISCV/phelmino/assembly/phelmino_rom.txt";

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
    next_output <= rom(to_integer(unsigned(address)));
  end process combinational;

  init_rom : process (rst_n) is
    variable read_line  : line;
    variable rom_vector : std_logic_vector(width-1 downto 0);
    variable n          : natural := 0;
  begin  -- process init_rom
    while not endfile(instructions) loop
      readline(instructions, read_line);
      hread(read_line, rom_vector);
      rom(n) <= rom_vector;
      n      := n + 1;
    end loop;
  end process init_rom;
end architecture behavioural;