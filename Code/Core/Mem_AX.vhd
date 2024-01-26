LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Mem_AX IS
    GENERIC (
        n1 : INTEGER := 16;
        n2 : INTEGER := 16;
        block_size : INTEGER := 4);
    PORT (
        clk, rst : IN STD_LOGIC;
        wr : IN STD_LOGIC;
        b_row_rd : IN INTEGER;
        b_col_rd : IN INTEGER;
        b_index_rd : IN INTEGER;
        b_row_wr : IN INTEGER;
        b_col_wr : IN INTEGER;
        b_index_wr : IN INTEGER;
        din0 : IN INTEGER;
        din1 : IN INTEGER;
        din2 : IN INTEGER;
        din3 : IN INTEGER;
        dout0 : OUT INTEGER;
        dout1 : OUT INTEGER;
        dout2 : OUT INTEGER;
        dout3 : OUT INTEGER
    );
END Mem_AX;

ARCHITECTURE arch OF Mem_AX IS
    TYPE BBuffer IS ARRAY (0 TO (n1 * n2) - 1) OF INTEGER;
BEGIN
    PROCESS (clk, rst)
        VARIABLE my_buffer : BBuffer := (
            57, 93, 48, 63, 86, 34, 25, 59,
            33, 36, 40, 53, 40, 36, 68, 79,
            90, 83, 57, 60, 86, 47, 44, 48,
            77, 21, 10, 85, 90, 13, 12, 29,
            22, 75, 85, 91, 24, 81, 70, 56,
            38, 91, 97, 23, 22, 79, 41, 99,
            94, 55, 26, 51, 82, 66, 80, 66,
            96, 54, 93, 57, 59, 28, 95, 56,
            47, 48, 17, 77, 15, 57, 57, 25,
            44, 20, 38, 14, 92, 99, 65, 88,
            33, 60, 72, 65, 94, 10, 43, 31,
            81, 78, 91, 62, 74, 95, 51, 11,
            24, 13, 40, 22, 83, 29, 36, 78,
            74, 32, 66, 94, 18, 54, 34, 25,
            82, 12, 26, 12, 89, 77, 56, 67,
            65, 46, 98, 43, 52, 12, 97, 94
        );

        VARIABLE wr_addr : INTEGER;
        VARIABLE rd_addr : INTEGER;
    BEGIN
        IF (clk'event AND clk = '1' AND rst = '0') THEN

            wr_addr := (b_row_wr * block_size + b_index_wr) * n2 + b_col_wr * block_size;
            rd_addr := (b_row_rd * block_size * n2) + (b_col_rd * block_size) + b_index_rd;

            -- write 
            IF (wr = '1') THEN
                my_buffer(wr_addr) := din0;
                my_buffer(wr_addr + 1) := din1;
                my_buffer(wr_addr + 2) := din2;
                my_buffer(wr_addr + 3) := din3;
            END IF;
            -- read
            dout0 <= my_buffer(rd_addr);
            dout1 <= my_buffer(rd_addr + n2);
            dout2 <= my_buffer(rd_addr + n2 * 2);
            dout3 <= my_buffer(rd_addr + n2 * 3);

        END IF;
    END PROCESS;
END ARCHITECTURE;