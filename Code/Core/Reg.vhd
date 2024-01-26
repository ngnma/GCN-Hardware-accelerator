LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Reg IS
    PORT (
        clk, rst : IN STD_LOGIC;
        din : IN INTEGER;
        dout : OUT INTEGER
    );
END Reg;

ARCHITECTURE arch OF Reg IS

BEGIN
    PROCESS (clk, rst, din)
    BEGIN
        IF (clk'event AND clk = '1') THEN
            IF (rst = '1') THEN
                dout <= 0;
            ELSE
                dout <= din;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;