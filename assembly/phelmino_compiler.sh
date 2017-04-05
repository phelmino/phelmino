#!/bin/bash

depth=65536

> phelmino_ram_A.txt 
> phelmino_ram_B.txt 
> phelmino_ram_C.txt 
> phelmino_ram_D.txt 

if [[ $# -lt 2 ]]; then
   echo "Usage: phelmino_compiler.sh [option] [file]";
   echo "  Compile Assembly or C code into hex file for ROM memory intialization";
   echo "  The options are:";
   echo "  -s   when input file is of extension .S (assembly code)";
   echo "  -c   when input file is of extension .c (C code)";
else
   case $1 in
           "-s") riscv32-unknown-elf-as -fPIC -o riscv_raw_elf $2 ;;
           "-c") riscv32-unknown-elf-gcc -Wl,-Map=mapping -fPIC -o riscv_raw_elf $2 -lm
   esac

   elf2hex 1 262144 riscv_raw_elf > riscv_hex 

   sed -n '1~4p' riscv_hex | head -n 20480 | tail -n 4096 >> phelmino_ram_A.txt 
   sed -n '2~4p' riscv_hex | head -n 20480 | tail -n 4096 >> phelmino_ram_B.txt 
   sed -n '3~4p' riscv_hex | head -n 20480 | tail -n 4096 >> phelmino_ram_C.txt 
   sed -n '4~4p' riscv_hex | head -n 20480 | tail -n 4096 >> phelmino_ram_D.txt 

fi;
