#!/usr/bin/perl

open (READ_FILE, 'riscv_hex_instructions.txt');
open (WRITE_FILE, '>>phelmino_rom.txt');

$end_of_line = "..O...O...O.";

while (<READ_FILE>) {
chomp;
($garbage_1, $instruction_1, $instruction_2, $instruction_3, $instruction_4, $garbage_2 ) = split(" ");
if($instruction_1 ne $end_of_line) { print WRITE_FILE "$instruction_1\n"; }
if($instruction_2 ne $end_of_line) { print WRITE_FILE "$instruction_2\n"; }
if($instruction_3 ne $end_of_line) { print WRITE_FILE "$instruction_3\n"; }
if($instruction_4 ne $end_of_line) { print WRITE_FILE "$instruction_4\n"; }
}
close (READ_FILE);
close (WRITE_FILE);
exit;
