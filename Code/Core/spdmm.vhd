LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Spdmm IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        data_in_r : IN INTEGER;
        data_in_c : IN INTEGER;
        data_in_v : IN INTEGER;
        init_state : IN STD_LOGIC;
        done : OUT STD_LOGIC
    );
END Spdmm;

ARCHITECTURE arch OF Spdmm IS

    -- components
    COMPONENT RFIFO IS
        GENERIC (
            QueueLength : INTEGER := 16
        );
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            enq : IN STD_LOGIC;
            deq : IN STD_LOGIC;
            data_in : IN INTEGER;
            data_out : OUT INTEGER
        );
    END COMPONENT;

    COMPONENT Reg IS
        PORT (
            clk, rst : IN STD_LOGIC;
            din : IN INTEGER;
            dout : OUT INTEGER
        );
    END COMPONENT;
    COMPONENT Mem_X IS
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
    END COMPONENT;

    COMPONENT Mac IS
        PORT (
            clk, rst : IN STD_LOGIC;
            a, b, c : IN INTEGER;
            result : OUT INTEGER
        );
    END COMPONENT;

    COMPONENT Mem_AX2 IS
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
            row_wr : IN INTEGER;
            b_col_wr : IN INTEGER;
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

    -- signals
    SIGNAL fifo_size : INTEGER := 22;
    CONSTANT fifo_size_constant : INTEGER := 22;
    CONSTANT col_block_nums : INTEGER := 2;-- in tedade column block haye x hast.as x/block_size bedast miad

    SIGNAL v1 : INTEGER := 0;
    SIGNAL v2 : INTEGER := 0;
    SIGNAL i1 : INTEGER := 0;
    SIGNAL i2 : INTEGER := 0;
    SIGNAL i3 : INTEGER := 0;
    SIGNAL j1 : INTEGER := 0;
    SIGNAL done1 : STD_LOGIC := '0';
    SIGNAL x0, x1, x2, x3 : INTEGER; --x_out
    SIGNAL d0, d1, d2, d3 : INTEGER; --gemm ax_out
    SIGNAL wr_ax : STD_LOGIC := '0';
    SIGNAL counter : INTEGER := 0;
    SIGNAL done_tmp : STD_LOGIC := '0';
    SIGNAL enq : STD_LOGIC := '1';
    SIGNAL deq : STD_LOGIC := '0';
    SIGNAL b_col1 : INTEGER := 0;
    SIGNAL b_col2 : INTEGER := 0;
    SIGNAL b_col3 : INTEGER := 0;
    SIGNAL mac_in_0, mac_out_0, mac_in_1, mac_out_1, mac_in_2, mac_out_2, mac_in_3, mac_out_3 : INTEGER;
BEGIN

    value : RFIFO
    GENERIC MAP(fifo_size_constant)
    PORT MAP(clk, rst, enq, deq, data_in_v, v1);

    row : RFIFO
    GENERIC MAP(fifo_size_constant)
    PORT MAP(clk, rst, enq, deq, data_in_r, i1);

    column : RFIFO
    GENERIC MAP(fifo_size_constant)
    PORT MAP(clk, rst, enq, deq, data_in_c, j1);

    reg_row_1 : Reg PORT MAP(clk, rst, i1, i2);
    reg_row_2 : Reg PORT MAP(clk, rst, i2, i3);
    reg_bcol_1 : Reg PORT MAP(clk, rst, b_col1, b_col2);
    reg_bcol_2 : Reg PORT MAP(clk, rst, b_col2, b_col3);
    reg_values : Reg PORT MAP(clk, rst, v1, v2);

    -- Mac units (x4)
    mac_in_0 <= mac_out_0 WHEN (i2 = i3) ELSE
        0;
    mac_in_1 <= mac_out_1 WHEN (i3 = i2) ELSE
        0;
    mac_in_2 <= mac_out_2 WHEN (i3 = i2) ELSE
        0;
    mac_in_3 <= mac_out_3 WHEN (i3 = i2) ELSE
        0;
    mac_0 : Mac PORT MAP(clk, rst, v2, x0, mac_in_0, mac_out_0);
    mac_1 : Mac PORT MAP(clk, rst, v2, x1, mac_in_1, mac_out_1);
    mac_2 : Mac PORT MAP(clk, rst, v2, x2, mac_in_2, mac_out_2);
    mac_3 : Mac PORT MAP(clk, rst, v2, x3, mac_in_3, mac_out_3);

    X : Mem_X GENERIC MAP(16, 8, 4)
    PORT MAP(
        clk => (clk),
        rst => (rst),
        row => (j1),
        b_col => (b_col1),
        dout0 => (x0),
        dout1 => (x1),
        dout2 => (x2),
        dout3 => (x3)
    );

    wr_ax <= '0' WHEN (i3 = i2 and done1 = '0') ELSE
        '1';
    AX : Mem_AX2
    GENERIC MAP(16, 8, 4)
    PORT MAP(
        clk => (clk),
        rst => (rst),
        wr => (wr_ax),
        b_row_rd => (0), --gemm
        b_col_rd => (0), --gemm
        b_index_rd => (0), --gemm
        row_wr => (i3),
        b_col_wr => (b_col3),
        din0 => (mac_out_0),
        din1 => (mac_out_1),
        din2 => (mac_out_2),
        din3 => (mac_out_3),
        dout0 => (d0), --gemm
        dout1 => (d1), --gemm
        dout2 => (d2), --gemm
        dout3 => (d3)--gemm
    );

    deq <= NOT init_state;
    enq <= init_state;
    PROCESS (clk, rst)
    BEGIN
        IF (clk'event AND clk = '1' AND rst = '0') THEN
            IF (init_state = '0' AND done1 = '0') THEN
                IF (counter = fifo_size) THEN
                    counter <= 0;
                    IF (b_col1 = col_block_nums - 1) THEN
                        b_col1 <= 0;
                        done1 <= '1';
                    ELSE
                        b_col1 <= b_col1 + 1;
                    END IF;
                ELSE
                    counter <= counter + 1;
                END IF;
            END IF;
        END IF;
        done <= done1;
    END PROCESS;
END ARCHITECTURE;