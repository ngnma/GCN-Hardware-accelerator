LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb IS
END tb;

ARCHITECTURE arch OF tb IS

    CONSTANT NumElements : INTEGER := 22;

    TYPE RowsArrayType IS ARRAY(0 TO NumElements - 1) OF INTEGER;
    CONSTANT rows : RowsArrayType := (1, 1, 1, 2, 2, 2, 3, 3, 4, 6, 7, 7, 7, 9, 9, 11, 12, 12, 12, 13, 14, 15);
    CONSTANT columns : RowsArrayType := (2, 7, 8, 4, 7, 8, 5, 11, 0, 3, 3, 7, 9, 5, 7, 8, 0, 11, 15, 1, 7, 11);
    CONSTANT values : RowsArrayType := (5, 5, 3, 4, 10, 6, 7, 6, 6, 10, 5, 8, 4, 5, 5, 8, 1, 3, 4, 5, 1, 2);

    COMPONENT Spdmm IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            data_in_r : IN INTEGER;
            data_in_c : IN INTEGER;
            data_in_v : IN INTEGER;
            init_state : IN STD_LOGIC;
            done : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '1';
    SIGNAL rst : STD_LOGIC;
    SIGNAL init_state : STD_LOGIC := '1';
    SIGNAL data_in_r, data_in_c, data_in_v : INTEGER;
    SIGNAL done : STD_LOGIC;
BEGIN

    clk <= NOT clk AFTER 5 ns;
    u : Spdmm PORT MAP(clk, rst, data_in_r, data_in_c, data_in_v, init_state, done);
    PROCESS
    BEGIN
        rst <= '1'; -- Reset initially
        WAIT FOR 10 ns;
        rst <= '0'; -- Release reset

        FOR i IN 0 TO NumElements - 1 LOOP
        
            data_in_r <= rows(i); -- Insert data from rows array
            data_in_c <= columns(i); -- Insert data from rows array
            data_in_v <= values(i); -- Insert data from rows array
            WAIT FOR 10 ns;
        END LOOP;
        init_state <= '0';
        WAIT;
    END PROCESS;
END ARCHITECTURE;