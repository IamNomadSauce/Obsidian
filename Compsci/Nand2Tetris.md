1. [ ] Boolean Logic 
2. [ ] Boolean Arithmetic
3. [ ] Memory
    - Register
        - Bit
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
5. [ ] Computer Architecture
6. [ ] Assembler
7. [ ] VM 1: Stack Arithmetic
8. [ ] VM 2: Program Control
9. [ ] High-Level Language
10. [ ] Compiler 1: Syntax
11. [ ] Compiler 2: Code Generation
12. [ ] Operating System

