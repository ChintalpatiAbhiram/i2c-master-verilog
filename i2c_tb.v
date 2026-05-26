`timescale 1ns / 1ps

module i2c_tb;

wire sda;
wire scl;
wire i2c_clk;

reg clk;
reg reset;
reg start;

pullup(sda);

i2c_master master (
    .scl(scl),
    .sda(sda),
    .clk(clk),
    .i2c_clk(i2c_clk),
    .reset(reset),
    .start(start)
);

i2c_slave slave(
    .scl(scl),
    .sda(sda),
    .i2c_clk(i2c_clk),
    .reset(reset)
);

//////////////////////////////////////////////////
// CLOCK GENERATION
//////////////////////////////////////////////////

always #5 clk = ~clk;

//////////////////////////////////////////////////
// MONITOR SIGNALS
//////////////////////////////////////////////////

initial
begin
    $monitor(
        "TIME=%0t | M_STATE=%0d | S_STATE=%0d | SDA=%b | SCL=%b | M_ADDR=%b | R_ADDR=%b | M_COUNT=%0d | S_COUNT=%0d | M_DATA=%b | S_DATA=%b",
        $time,
        master.state,
        slave.state,
        sda,
        scl,
        master.shift_reg,
        slave.received_addr,
        master.bit_count,
        slave.bit_count,
        master.data_reg,
        slave.received_data
    );
end

//////////////////////////////////////////////////
// TEST SEQUENCE
//////////////////////////////////////////////////

initial
begin

    clk = 0;
    start = 0;
    reset = 1;

    // hold reset
    #5000;
    reset = 0;

    // start transaction
    #20;
    start = 1;

    // remove start pulse
    #5000;
    start = 0;

    // let simulation run
    #50000;

    $finish;

end

endmodule