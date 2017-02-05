# Liste d'instructions pour PULPino #

Les instructions implantees pour PULPino sont organisees ci-dessous, triees par son `OPCODE`. 

## Load and Store Unit ##

* **Loads** : `OPCODE = 000 1011`
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
* **Stores** : `OPCODE = 010 1011`
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
	
