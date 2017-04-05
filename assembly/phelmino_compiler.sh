#!/bin/bash

depth=4096

> phelmino_rom.mif

if [[ $# -lt 2 ]]; then
   echo "Usage: phelmino_compiler.sh [option] [file]";
   echo "  Compile Assembly or C code into hex file for ROM memory intialization";
   echo "  The options are:";
   echo "  -s   when input file is of extension .S (assembly code)";
   echo "  -c   when input file is of extension .c (C code)";
else
   case $1 in
           "-s") riscv32-unknown-elf-as -fPIC -o riscv_raw_elf $2 ;;
           "-c") riscv32-unknown-elf-gcc -fPIC -o riscv_raw_elf $2 -lm
   esac

   riscv32-unknown-elf-strip riscv_raw_elf
   riscv32-unknown-elf-objcopy -I elf32-littleriscv -O binary riscv_raw_elf riscv_elf
   xxd -c 4 -e riscv_elf | cut -d' ' -f 2 > riscv_hex
   nlines=`wc -l riscv_hex | cut -d' ' -f 1`

   if (( "$depth" > "$nlines" )); then
       echo "DEPTH = ${depth};" >> phelmino_rom.mif
       echo "WIDTH = 32;" >> phelmino_rom.mif
       echo "ADDRESS_RADIX = UNS;" >> phelmino_rom.mif 
       echo "DATA_RADIX = HEX;" >> phelmino_rom.mif
       echo "CONTENT" >> phelmino_rom.mif
       echo "BEGIN" >> phelmino_rom.mif

       for nl in `seq 1 $nlines`; do
           echo "$(( nl - 1)) : `sed "${nl}q;d" riscv_hex`;" >> phelmino_rom.mif 
       done
       for nl in `seq $(( nlines + 2 )) $depth`; do
           echo "$(( nl - 1 )) : 00000000;" >> phelmino_rom.mif 
       done
       
       echo "END;" >> phelmino_rom.mif 
   fi;
fi;
