1. [ ] Boolean Logic 
2. [ ] Boolean Arithmetic
3. [ ] Memory
    - Register
        - Bit 
            - in, load, out
            - if load(t) -> out(t+1) = in(t), else out(t+1) = out(t)
            - Mux & DFF
        - Register is n-bits
    - Ram
        - DMUX to write, MUX to read
        - in\[n], address\[k], load, -> out\[n]

        |chip | n | k| 
        |----------|---|--| 
        |RAM8 | 8 | 3|
        |RAM64 | 64 | 6|
        |RAM512 | 512 | 9|
        |RAM4K | 4096 | 12|
        |RAM16K | 16384 | 14|
    - Incrementer:
        - An n-bit incrementer can be implemented trivially from an n-bit adder
    - Counter
        -   A counter chip can be implemented by combining the input/output logic of a standard register with the combinatorial logic for adding a constant. Typically, the counter will have to be equipped with some additional functionality, such as possibilities for resetting the count to zero, loading a new counting base, or decrementing instead of incrementing.
        - stores the address of the instruction that should be fetched and executed next.
        - Can be built with Register, Incrementer16, and Mux16 chips
4. [ ] Machine Language
    - Memory Access
        - Direct addressing
            - LOAD R1, 67 (R1<-Memory[67])
            - LOAD R1, <var>
        - Immediate addressing
            - LOADI R1, 64 (R1<-67)
        - Indirect addressing
    - Registers: (2x16-bit registers)
        - D: Used to store data values
        - A: Either as a data value or an address in the data mem, or as an address in the instruction mem.
            can facilitate direct access to the data memory
        - addresses are 15-bits wide. 
    - 2-generic instructions:
        - (A) address instruction
            - The A-instruction is used to set the A register to a 15-bit value:
            - A-instruction: @value
            - \[0vvv]\[vvvv]\[vvvv]\[vvvv]
                - v = 0|1
        - (C) compute instruction
            - dest = comp;jump
            - The comp field instructs the ALU what to compute. The dest field instructs where to store the computed value (ALU output). The jump field specifies a jump condition, namely, which command to fetch and execute next
            - \[1,1,1,a]\[c1,c2,c3,c4]\[c5,c6,d1,d2]\[d3,j1,j2,j3]
                - left-most bit is the c-instruction code, the next 2-bits do nothing
                - a=computed function, c=comp, d=dest, j=jump
        - Computation Specification
            - The (HACK) ALU computes a fixed set of functions on the D, A, and M registers.

            |a=0 | c1 | c2 | c3| c4 | c5 | c6| a=1 | 
            |----|----|--- |---| -- | ---|-- | --- |
            | 0  | 1  | 0 | 1  | 0  | 1 | 0 |  |
            | 1 | 1  | 1 | 1  | 1  | 1 | 1 | |
            | -1  | 1  | 1 | 1  | 0  | 1 | 0 | |
            | D  | 0  | 0 | 1  | 1  | 0 | 0 | |
            | A  | 1  | 1 | 0  | 0  | 0 | 0 | M |
            | !D  | 0  | 0 | 1  | 1  | 0 | 1 | |
            | !A  | 1  | 1 | 0  | 0  | 1 | 1 | !M |
            | -D  | 0  | 0 | 1  | 1  | 1 | 1 | |
            | -A  | 1  | 1 | 0  | 0  | 1 | 1 | -M |
            | D+1  | 0  | 1 | 0  | 0  | 0 | 1 | |
            | A+1  | 1  | 1 | 0  | 1  | 1 | 1 | M+1 | 
            | D-1  | 0  | 0 | 1  | 1  | 1 | 0 | |
            | A-1  | 1  | 0 | 0  | 0  | 1 | 0 | M-1 |
            | D+A  | 0  | 0 | 0  | 0  | 1 | 0 | D+M |
            | D-A  | 0  | 1 | 0  | 0  | 1 | 1 | D-M |
            | A-D | 0  | 0 | 0  | 1  | 1 | 1 | M-D |
            | D&A  | 0  | 0 | 0  | 0  | 0 | 0 | D&M |
            | D\|A | 0 | 1  | 0 | 1  | 0  | 1 | D\|M |
        - Destination Specification
            |d1|d2|d3| Mnemonic| Destination|
            |---|---|---|---|---|
            |0|0|0|null|Value Not stored|
            |0|0|1|M|Memory\[A] (memory register addressed by A)|
            |0|1|0|D|D Register|
            |0|1|1|MD|Memory\[A] and D register|
            |1|0|0|A|A register|
            |1|0|1|AM|A register and Memory\[a]|
            |1|1|0|AD|A register and D register|
            |1|1|1|AMD|A register, Memory\[A], and D register|
            - 
        - Jump Specification
            |j1|j2|j3|Mnemonic|Effect|
            |---|---|---|---|---|
            |0|0|0|null|No jump|
            |0|0|1|JGT|If out > 0 jump|
            |0|1|0|JEQ|If out = 0 jump|
            |0|1|1|JGE|if out >= 0 jump|
            |1|0|0|JLT|If out < 0 jump|
            |1|0|1|JNE|If out != 0 jump|
            |1|1|0|JLE|If ous <= 0 jump|
            |1|1|1|JMP|Jump|



            
5. [ ] Computer Architecture
6. [ ] Assembler
7. [ ] VM 1: Stack Arithmetic
8. [ ] VM 2: Program Control
9. [ ] High-Level Language
10. [ ] Compiler 1: Syntax
11. [ ] Compiler 2: Code Generation
12. [ ] Operating System

