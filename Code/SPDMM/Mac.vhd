LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Mac IS
    PORT (
        clk, rst : IN STD_LOGIC;
        a, b, c : IN INTEGER;
        result : OUT INTEGER
    );
END Mac;

ARCHITECTURE arch OF Mac IS

BEGIN
    PROCESS (clk, rst, a, b, c)
    BEGIN
        IF (clk'event AND clk = '1') THEN
            IF (rst = '1') THEN
                result <= 0;
            ELSE
                result <= (a * b) + c;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;