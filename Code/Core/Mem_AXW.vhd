LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Mem_AXW IS
    GENERIC (
        n1 : INTEGER := 16;
        n2 : INTEGER := 16;
        block_size : INTEGER := 4);
    PORT (
        clk, rst : IN STD_LOGIC;
        wr : IN STD_LOGIC;
        b_row : IN INTEGER;
        b_col : IN INTEGER;
        din0 : IN INTEGER;
        din1 : IN INTEGER;
        din2 : IN INTEGER;
        din3 : IN INTEGER;
        din4 : IN INTEGER;
        din5 : IN INTEGER;
        din6 : IN INTEGER;
        din7 : IN INTEGER;
        din8 : IN INTEGER;
        din9 : IN INTEGER;
        din10 : IN INTEGER;
        din11 : IN INTEGER;
        din12 : IN INTEGER;
        din13 : IN INTEGER;
        din14 : IN INTEGER;
        din15 : IN INTEGER
    );
END Mem_AXW;

ARCHITECTURE arch OF Mem_AXW IS
    TYPE BBuffer IS ARRAY (0 TO (n1 * n2) - 1) OF INTEGER;
BEGIN
    PROCESS (clk, rst)
        VARIABLE m : BBuffer := (OTHERS => 0);

        VARIABLE r0, r1, r2, r3 : INTEGER;
    BEGIN
        IF (clk'event AND clk = '1' AND rst = '0') THEN

            r0 := (b_row * block_size) * n2 + b_col * block_size;
            r1 := r0 + n2;
            r2 := r0 + n2 * 2;
            r3 := r0 + n2 * 3;

            -- write 
            IF (wr = '1') THEN
                m(r0) := m(r0) + din0;
                m(r0 + 1) := m(r0 + 1) + din1;
                m(r0 + 2) := m(r0 + 2) + din2;
                m(r0 + 3) := m(r0 + 3) + din3;

                m(r1) := m(r1) + din4;
                m(r1 + 1) := m(r1 + 1) + din5;
                m(r1 + 2) := m(r1 + 2) + din6;
                m(r1 + 3) := m(r1 + 3) + din7;

                m(r2) := m(r2) + din8;
                m(r2 + 1) := m(r2 + 1) + din9;
                m(r2 + 2) := m(r2 + 2) + din10;
                m(r2 + 3) := m(r2 + 3) + din11;

                m(r3) := m(r3) + din12;
                m(r3 + 1) := m(r3 + 1) + din13;
                m(r3 + 2) := m(r3 + 2) + din14;
                m(r3 + 3) := m(r3 + 3) + din15;

            END IF;

        END IF;
    END PROCESS;
END ARCHITECTURE;