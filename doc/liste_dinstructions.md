# Liste d'instructions pour PULPino #

Les instructions implantees pour PULPino sont organisees ci-dessous, triees par son `OPCODE`. 

## Load and Store Unit ##

### "Classic" RISCV Load/Store Instructions ###

* **Load** : `OPCODE = 000 0011`
    * `FUNC3 = 000` 
        * `lb rD, imm(rs1)`
        * `rD = Sext(mem[rs1 + Sext(imm)]);`
    * `FUNC3 = 001` 
        * `lh rD, imm(rs1)`
        * `rD = Sext(mem[rs1 + Sext(imm)]);`
    * `FUNC3 = 010` 
        * `lw rD, imm(rs1)`
        * `rD = mem[rs1 + Sext(imm)];`
    * `FUNC3 = 100` 
        * `lbu rD, imm(rs1)`
        * `rD = Zext(mem[rs1 + Sext(imm)]);`
    * `FUNC3 = 101` 
        * `lhu rD, imm(rs1)`
        * `rD = Zext(mem[rs1 + Sext(imm)]);`

* **Store** : `OPCODE = 010 0011`
    * `FUNC3 = 000`
        * `sb rs2, imm(rs1)`
        * `mem[rs1 + Sext(imm)] = rs2[7:0];`
    * `FUNC3 = 001`
        * `sh rs2, imm(rs1)`
        * `mem[rs1 + Sext(imm)] = rs2[15:0];`
    * `FUNC3 = 010`
        * `sw rs2, imm(rs1)`
        * `mem[rs1 + Sext(imm)] = rs2[31:0];`

### PULP Post-Incrementing Load/Store Extension ###

Ces instructions executent une operation de chargement/rangement au meme temps qui font une
incrementation de la valeur du registre par un offset specifie. Ces operations servent a 
reduire le nombre d'operations necessaire lorsqu'on execute une boucle, par exemple. 

* **Post-Incrementing Load** : `OPCODE = 000 1011`
    * `FUNC3 = 000` 
        * `lb rD, imm(rs1!)`
        * `rD = Sext(mem[rs1]); rs1 += Sext(imm);`
    * `FUNC3 = 001` 
        * `lh rD, imm(rs1!)`
        * `rD = Sext(mem[rs1]); rs1 += Sext(imm);`
    * `FUNC3 = 010` 
        * `lw rD, imm(rs1!)`
        * `rD = mem[rs1]; rs1 += Sext(imm);`
    * `FUNC3 = 100` 
        * `lbu rD, imm(rs1!)`
        * `rD = Zext(mem[rs1]); rs1 += Sext(imm);`
    * `FUNC3 = 101` 
        * `lhu rD, imm(rs1!)`
        * `rD = Zext(mem[rs1]); rs1 += Sext(imm);`
    * `FUNC3 = 111`
        * `FUNC7 = 000 0000`
            * `lb rD, rs2(rs1!)`
            * `rD = Sext(mem[rs1]); rs1 += rs2;`
        * `FUNC7 = 000 1000`
            * `lh rD, rs2(rs1!)`
            * `rD = Sext(mem[rs1]); rs1 += rs2;`
        * `FUNC7 = 001 0000`
            * `lw rD, rs2(rs1!)`
            * `rD = mem[rs1]; rs1 += rs2;`
        * `FUNC7 = 010 0000`
            * `lbu rD, rs2(rs1!)`
            * `rD = Zext(mem[rs1]); rs1 += rs2;`
        * `FUNC7 = 010 1000`
            * `lhu rD, rs2(rs1!)`
            * `rD = Zext(mem[rs1]); rs1 += rs2;`

* **Post-Incrementing Store** : `OPCODE = 010 1011`
    * `FUNC3 = 000`
        * `sb rs2, imm(rs1!)`
        * `mem[rs1] = rs2[7:0]; rs1 += Sext(imm);`
    * `FUNC3 = 001`
        * `sh rs2, imm(rs1!)`
        * `mem[rs1] = rs2[15:0]; rs1 += Sext(imm);`
    * `FUNC3 = 010`
        * `sw rs2, imm(rs1!)`
        * `mem[rs1] = rs2[31:0]; rs1 += Sext(imm);`
    * `FUNC3 = 100`
        * `sb rs2, rs3(rs1!)`
        * `mem[rs1] = rs2[7:0]; rs1 += rs3;`
        * Bits `31` et `30` sont fixes a `0`. L'adresse `rs3` se trouve entre les bits `29` a `25`.
    * `FUNC3 = 101`
        * `sh rs2, rs3(rs1!)`
        * `mem[rs1] = rs2[15:0]; rs1 += rs3;`
        * Bits `31` et `30` sont fixes a `0`. L'adresse `rs3` se trouve entre les bits `29` a `25`.
    * `FUNC3 = 110`
        * `sw rs2, rs3(rs1!)`
        * `mem[rs1] = rs2[31:0]; rs1 += rs3;`
        * Bits `31` et `30` sont fixes a `0`. L'adresse `rs3` se trouve entre les bits `29` a `25`.
        
## Arithmetic-Logic Unit ##

### "Classic" RISCV Integer Computational Instructions ###

* **Operations avec Immediates** : `OPCODE = 001 0011`

    * `FUNC3 = 000`
        * `addi rD, rs1, imm`
        * `rD = rs1 + Sext(imm)`
    * `FUNC3 = 001`
        * `FUNC7 = 000 0000`
        * `slli rD, rs1, shamt`
        * `rD = rs1 << shamt` (logique)
    * `FUNC3 = 010`
        * `slti rD, rs1, imm`
        * `rD = (rs1 < Sext(imm)) ? -1 : 0`
        * Les valeurs sont traites comme des unsignees
    * `FUNC3 = 011`
        * `stliu rD, rs1, imm`
        * `rD = (rs1 < Sext(imm)) ? -1 : 0`
        * Les valeurs sont traites comme des signees
    * `FUNC3 = 100`
        * `xori rD, rs1, imm`
        * `rD = rs1 XOR Sext(imm)`
        * L'instruction `xori rd, rs1, -1` est equivalente a `not rd, rs`
    * `FUNC3 = 101`
        * `FUNC7 = 000 0000`
            * `srli rD, rs1, shamt`
            * `rD = rs1 >> shamt` (logique)
        * `FUNC7 = 010 0000`
            * `srai rD, rs1, shamt`
            * `rD = rs1 >> shamt`
            * Le bit de signe original est copie dans les bits de poids fort vides
    * `FUNC3 = 110`
        * `ori rD, rs1, imm` 
        * `rD = rs1 OR Sext(imm)`
    * `FUNC3 = 111`
        * `andi rD, rs1, imm`
        * `rD = rs1 AND Sext(imm)`

* **Operations arithmetiques registre-registre** : `OPCODE = 011 0011`

    * `FUNC3 = 000`
        * `FUNC7 = 000 0000`
            * `add rD, rs1, rs2`
            * `rD = rs1 + rs2`
        * `FUNC7 = 010 0000`
            * `sub rD, rs1, rs2`
            * `rD = rs1 - rs2`
    * `FUNC3 = 001`
        * `FUNC7 = 000 0000`
        * `sll rD, rs1, rs2`
        * `rD = rs1 << rs2[4:0]` (logique)
    * `FUNC3 = 010`
        * `slt rD, rs1, rs2`
        * `rD = (rs1 < rs2) ? -1 : 0`
        * Les valeurs sont traites comme des unsignees
    * `FUNC3 = 011`
        * `stlu rD, rs1, rs2`
        * `rD = (rs1 < rs2) ? -1 : 0`
        * Les valeurs sont traites comme des signees
    * `FUNC3 = 100`
        * `xor rD, rs1, rs2`
        * `rD = rs1 XOR rs2`
    * `FUNC3 = 101`
        * `FUNC7 = 000 0000`
            * `srl rD, rs1, rs2`
            * `rD = rs1 >> rs2[4:0]` (logique)
        * `FUNC7 = 010 0000`
            * `sra rD, rs1, rs2`
            * `rD = rs1 >> rs2[4:0]`
            * Le bit de signe original est copie dans les bits de poids fort vides
    * `FUNC3 = 110`
        * `or rD, rs1, rs2` 
        * `rD = rs1 OR rs2`
    * `FUNC3 = 111`
        * `and rD, rs1, rs2`
        * `rD = rs1 AND rs2`

### PULP ALU Extensions ###

* `OPCODE = 011 0011`
    * `FUNC7 = 000 0010`
        * `FUNC3 = 000`
            * `p.avg rD, rs1, rs2`
            * `rD = (rs1 + rs2) >> 1` (arithmetic)
        * `FUNC3 = 001`
            * `p.avgu rD, rs1, rs2`
            * `rD = (rs1 + rs2) >> 1` (logique)
        * `FUNC3 = 010`
            * `p.slet rD, rs1, rs2`
            * `rD = (rs1 <= rs2) ? -1 : 0`
            * Les valeurs sont traitees comme des signes
        * `FUNC3 = 011`
            * `p.sletu rD, rs1, rs2`
            * `rD = (rs1 <= rs2) ? -1 : 0`
            * Les valeurs sont traitees comme des unsignes
        * `FUNC3 = 100`
            * `p.min rD, rs1, rs2`
            * `rD = (rs1 < rs2) ? rs1 : rs2`
            * Les valeurs sont traitees comme des signes
        * `FUNC3 = 101`
            * `p.minu rD, rs1, rs2`
            * `rD = (rs1 < rs2) ? rs1 : rs2`
            * Les valeurs sont traitees comme des unsignes
        * `FUNC3 = 110`
            * `p.max rD, rs1, rs2`
            * `rD = (rs1 > rs2) ? rs1 : rs2`
            * Les valeurs sont traitees comme des signes
        * `FUNC3 = 111`
            * `p.maxu rD, rs1, rs2`
            * `rD = (rs1 > rs2) ? rs1 : rs2`
            * Les valeurs sont traitees comme des unsignes
                
