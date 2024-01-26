LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Testbench IS
END Testbench;

ARCHITECTURE arch OF Testbench IS
    COMPONENT Mem_AX
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
    END COMPONENT;

    COMPONENT Gemm_iterator IS
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
    END COMPONENT;

    COMPONENT Mem_W IS
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
    END COMPONENT;

    COMPONENT MAC IS
        PORT (
            clk, rst : IN STD_LOGIC;
            a, b, c : IN INTEGER;
            result : OUT INTEGER
        );
    END COMPONENT;

    SIGNAL xw_i1, xw_i2, xw_i3, xw_index : INTEGER;
    SIGNAL done : STD_LOGIC;

    SIGNAL dx0, dx1, dx2, dx3 : INTEGER;
    SIGNAL dw0, dw1, dw2, dw3 : INTEGER;

    SIGNAL clk : STD_LOGIC := '1';
    SIGNAL rst : STD_LOGIC;
    -- GEMM --------------------------------------------------------------------------------------
    TYPE ARR IS ARRAY (0 TO 3) OF INTEGER;
    TYPE matrix_mac IS ARRAY (0 TO 3, 0 TO 3) OF INTEGER;

    SIGNAL arr_x : ARR := (OTHERS => 0);
    SIGNAL arr_w : ARR := (OTHERS => 0);
    SIGNAL macs : matrix_mac := (OTHERS => (OTHERS => 0));

    SIGNAL wr_axw : STD_LOGIC;
    SIGNAL rst_mac : STD_LOGIC := '1';

    COMPONENT Mem_AXW IS
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
    END COMPONENT;

    COMPONENT Reg IS
        PORT (
            clk, rst : IN STD_LOGIC;
            din : IN INTEGER;
            dout : OUT INTEGER
        );
    END COMPONENT;
    SIGNAL axw_row, axw_col,axw_col2,axw_row2 : INTEGER;
    -- END GEMM ----------------------------------------------------------------------------------

BEGIN

    ax : Mem_AX GENERIC MAP(16, 8, 4)
    PORT MAP(
        clk => (clk),
        rst => (rst),
        wr => ('0'),
        b_row_rd => (xw_i1),
        b_col_rd => (xw_i2),
        b_index_rd => (xw_index),
        b_row_wr => (0),
        b_col_wr => (0),
        b_index_wr => (0),
        din0 => (0),
        din1 => (0),
        din2 => (0),
        din3 => (0),
        dout0 => (dx0),
        dout1 => (dx1),
        dout2 => (dx2),
        dout3 => (dx3)
    );

    w : Mem_W GENERIC MAP(8, 12, 4)
    PORT MAP(
        clk => (clk),
        rst => (rst),
        b_row => (xw_i2),
        b_col => (xw_i3),
        b_index => (xw_index),
        dout0 => (dw0),
        dout1 => (dw1),
        dout2 => (dw2),
        dout3 => (dw3)
    );

    index_generator : Gemm_iterator GENERIC MAP(4, 2, 3)
    PORT MAP(
        clk => (clk),
        rst => (rst),
        xw_i1 => (xw_i1),
        xw_i2 => (xw_i2),
        xw_i3 => (xw_i3),
        xw_index => (xw_index),
        done => (done)
    );

    clk <= NOT clk AFTER 5 ns;
    rst <= '1', '0' AFTER 20 ns;
    -- GEMM --------------------------------------------------------------------------------------

    arr_x(0) <= dx0;
    arr_x(1) <= dx1;
    arr_x(2) <= dx2;
    arr_x(3) <= dx3;

    arr_w(0) <= dw0;
    arr_w(1) <= dw1;
    arr_w(2) <= dw2;
    arr_w(3) <= dw3;

    row : FOR i IN 0 TO 3 GENERATE
        col : FOR j IN 0 TO 3 GENERATE
            m : MAC PORT MAP(clk, rst_mac, arr_x(i), arr_w(j), macs(i, j), macs(i, j));
        END GENERATE col; -- col
    END GENERATE row; -- row

    row_reg : Reg PORT MAP(clk, rst, xw_i1, axw_row);
    row_reg2 : Reg PORT MAP(clk, rst, axw_row, axw_row2);
    col_reg : Reg PORT MAP(clk, rst, xw_i3, axw_col);
    col_reg2 : Reg PORT MAP(clk, rst, axw_col, axw_col2);

    wr_axw <= '1' WHEN xw_index = 1 ELSE
        '0';

    rst_mac <= '1' WHEN (xw_index = 1 or rst = '1') ELSE
        '0';

    axw : Mem_AXW GENERIC MAP(16, 12, 4)
    PORT MAP(
        clk,
        rst,
        wr_axw,
        axw_row2,
        axw_col2,
        macs(0, 0),
        macs(0, 1),
        macs(0, 2),
        macs(0, 3),

        macs(1, 0),
        macs(1, 1),
        macs(1, 2),
        macs(1, 3),

        macs(2, 0),
        macs(2, 1),
        macs(2, 2),
        macs(2, 3),

        macs(3, 0),
        macs(3, 1),
        macs(3, 2),
        macs(3, 3)
    );

    -- END GEMM ----------------------------------------------------------------------------------
END ARCHITECTURE;