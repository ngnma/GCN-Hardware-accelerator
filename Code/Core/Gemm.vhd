LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Gemm_iterator IS
    GENERIC (
        xw_n1 : INTEGER := 3; 
        xw_n2 : INTEGER := 2;
        xw_n3 : INTEGER := 4);
    PORT (
        clk, rst : IN STD_LOGIC;
        xw_i1 : OUT INTEGER;
        xw_i2 : OUT INTEGER;
        xw_i3 : OUT INTEGER;
        xw_index : OUT INTEGER;
        done : OUT STD_LOGIC
    );
END Gemm_iterator;

ARCHITECTURE arch OF Gemm_iterator IS
    -- matrix dimentions (block)
    -- xw_n1 : x_row
    -- xw_n2 : x_col & w_row
    -- xw_n3 : w_col

    CONSTANT block_size : INTEGER := 4;

    -- loop iteratior
    SIGNAL xw_i1_tmp : INTEGER := 0;
    SIGNAL xw_i2_tmp : INTEGER := 0;
    SIGNAL xw_i3_tmp : INTEGER := 0;
    SIGNAL xw_index_tmp : INTEGER := 0; 

    -- helper signals
    SIGNAL done_tmp : STD_LOGIC := '0';
BEGIN

    index_generator : PROCESS (clk, rst)
    BEGIN
        IF (clk'event AND clk = '1' AND done_tmp = '0') THEN
            IF (rst = '1') THEN
                done_tmp <= '0';
            ELSE
                IF xw_index_tmp = block_size - 1 THEN
                    -- End of a block
                    xw_index_tmp <= 0;
                    xw_i3_tmp <= xw_i3_tmp + 1;
                    IF xw_i3_tmp = xw_n3 - 1 THEN
                        -- End of row of W
                        -- rows of W are finished. computation of current block from X is finished and we should load next block for X
                        xw_i3_tmp <= 0;
                        xw_i1_tmp <= xw_i1_tmp + 1;
                        IF xw_i1_tmp = xw_n1 - 1 THEN
                            -- End of row of X
                            -- a columns of blocks in X has finished. we should load the first block of next column of X
                            xw_i1_tmp <= 0;
                            xw_i2_tmp <= xw_i2_tmp + 1;
                            IF xw_i2_tmp = xw_n2 - 1 THEN
                                -- End of column of X
                                -- That was the last block of X - Finish GEMM computation
                                done_tmp <= '1';
                            ELSE
                                done_tmp <= '0';
                            END IF;
                        ELSE
                            xw_i1_tmp <= xw_i1_tmp + 1;
                        END IF;
                    ELSE
                        xw_i3_tmp <= xw_i3_tmp + 1;
                    END IF;
                ELSE
                    xw_index_tmp <= xw_index_tmp + 1;
                END IF;
            END IF;
        END IF;
        xw_i1 <= xw_i1_tmp;
        xw_i2 <= xw_i2_tmp;
        xw_i3 <= xw_i3_tmp;
        xw_index <= xw_index_tmp;
        done <= done_tmp;
    END PROCESS; -- index_generator

END ARCHITECTURE;