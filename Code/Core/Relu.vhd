LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Relu IS
    PORT (
        din : IN INTEGER;
        dout : OUT INTEGER
    );
END Relu;

ARCHITECTURE arch OF Relu IS

BEGIN
    dout <= din WHEN (din > 0) ELSE
        0;

END ARCHITECTURE;