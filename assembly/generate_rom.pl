#!/usr/bin/perl

open (READ_FILE, 'riscv_hex_instructions.txt');
open (WRITE_FILE, '>>phelmino_rom.txt');

$end_of_line = "..O...O...O.";

while (<READ_FILE>) {
chomp;
($garbage_1, $instruction, $garbage_2 ) = split(" ");
if($instruction ne $end_of_line) { print WRITE_FILE "$instruction\n"; }
}
close (READ_FILE);
close (WRITE_FILE);
exit;
