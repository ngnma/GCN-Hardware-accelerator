LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Mem_W IS
    GENERIC (
        n1 : INTEGER := 16;
        n2 : INTEGER := 16;
        block_size : INTEGER := 4);
    PORT (
        clk, rst : IN STD_LOGIC;
        b_row : IN INTEGER;
        b_col : IN INTEGER;
        b_index : IN INTEGER;
        dout0 : OUT INTEGER;
        dout1 : OUT INTEGER;
        dout2 : OUT INTEGER;
        dout3 : OUT INTEGER
    );
END Mem_W;

ARCHITECTURE arch OF Mem_W IS
    TYPE BBuffer IS ARRAY (0 TO (n1 * n2) - 1) OF INTEGER;
BEGIN
    PROCESS (clk, rst)
        VARIABLE my_buffer : BBuffer := (
            76, 27, 93, 67, 96, 57, 83, 42, 56, 35, 93, 88,
            46, 90, 78, 59, 65, 77, 12, 94, 49, 76, 94, 57,
            71, 58, 17, 62, 95, 37, 44, 86, 50, 13, 79, 74,
            85, 44, 68, 20, 32, 87, 28, 25, 37, 40, 62, 80,

            36, 90, 16, 24, 85, 64, 81, 11, 53, 68, 65, 35,
            60, 94, 66, 59, 22, 28, 91, 11, 61, 54, 58, 66,
            59, 96, 13, 77, 21, 31, 99, 13, 21, 13, 16, 19,
            97, 24, 93, 80, 22, 64, 37, 48, 27, 71, 84, 75
        );

        VARIABLE addr : INTEGER;
    BEGIN
        IF (clk'event AND clk = '1' AND rst = '0') THEN
            addr := (b_row * block_size + b_index) * n2 + b_col * block_size;
            dout0 <= my_buffer(addr);
            dout1 <= my_buffer(addr + 1);
            dout2 <= my_buffer(addr + 2);
            dout3 <= my_buffer(addr + 3);
        END IF;
    END PROCESS;
END ARCHITECTURE;