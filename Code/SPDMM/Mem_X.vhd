LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Mem_X IS
    GENERIC (
        n1 : INTEGER := 16;
        n2 : INTEGER := 16;
        block_size : INTEGER := 4);
    PORT (
        clk, rst : IN STD_LOGIC;
        row : IN INTEGER;
        b_col : IN INTEGER;
        dout0 : OUT INTEGER;
        dout1 : OUT INTEGER;
        dout2 : OUT INTEGER;
        dout3 : OUT INTEGER
    );
END Mem_X;

ARCHITECTURE arch OF Mem_X IS
    TYPE BBuffer IS ARRAY (0 TO (n1 * n2) - 1) OF INTEGER;
BEGIN
    PROCESS (clk, rst)
        VARIABLE my_buffer : BBuffer := (
            57, 93, 48, 63,     86, 34, 25, 59,
            33, 36, 40, 53,     40, 36, 68, 79,
            90, 83, 57, 60,     86, 47, 44, 48,
            77, 21, 10, 85,     90, 13, 12, 29,

            22, 75, 85, 91,     24, 81, 70, 56,
            38, 91, 97, 23,     22, 79, 41, 99,
            94, 55, 26, 51,     82, 66, 80, 66,
            96, 54, 93, 57,     59, 28, 95, 56,
            
            47, 48, 17, 77,     15, 57, 57, 25,
            44, 20, 38, 14,     92, 99, 65, 88,
            33, 60, 72, 65,     94, 10, 43, 31,
            81, 78, 91, 62,     74, 95, 51, 11,
            
            24, 13, 40, 22,     83, 29, 36, 78,
            74, 32, 66, 94,     18, 54, 34, 25,
            82, 12, 26, 12,     89, 77, 56, 67,
            65, 46, 98, 43,     52, 12, 97, 94
        );
        VARIABLE addr : INTEGER;
    BEGIN
        IF (clk'event AND clk = '1' AND rst = '0') THEN
            addr := row * n2 + b_col * block_size;
            -- read
            dout0 <= my_buffer(addr);
            dout1 <= my_buffer(addr + 1);
            dout2 <= my_buffer(addr + 2);
            dout3 <= my_buffer(addr + 3);

        END IF;
    END PROCESS;
END ARCHITECTURE;