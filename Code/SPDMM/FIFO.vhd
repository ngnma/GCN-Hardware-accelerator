LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY RFIFO IS
    GENERIC (
        QueueLength : INTEGER := 16 -- Define the length of the queue
    );
    PORT (
        clk : IN STD_LOGIC; -- Clock input
        rst : IN STD_LOGIC; -- Reset input
        enq : IN STD_LOGIC; -- Enqueue signal
        deq : IN STD_LOGIC; -- Dequeue signal
        data_in : IN INTEGER; -- Data input
        data_out : OUT INTEGER -- Data output
    );
END ENTITY RFIFO;

ARCHITECTURE arch OF RFIFO IS
    TYPE QueueType IS ARRAY(0 TO QueueLength - 1) OF INTEGER;
    SIGNAL queue : QueueType;
    SIGNAL front_ptr, rear_ptr : INTEGER := 0;
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            front_ptr <= 0;
            rear_ptr <= 0;
        ELSIF rising_edge(clk) THEN
            IF enq = '1' THEN
                -- Enqueue data_in
                queue(rear_ptr) <= data_in;
                rear_ptr <= (rear_ptr + 1) MOD QueueLength;
            ELSIF deq = '1' THEN
                -- Dequeue data_out
                data_out <= queue(front_ptr);
                front_ptr <= (front_ptr + 1) MOD QueueLength;
            END IF;
        END IF;
    END PROCESS;
END arch;