`timescale 1ns / 1ps

module i2c_master(
    output reg scl,
    output reg i2c_clk,
    inout sda,
    input clk,  // 100Mhz clock
    input reset,
    input start
    );
    
reg [2:0] state, next_state;
reg [6:0] shift_reg;
reg [6:0] data_reg;
reg [2:0] bit_count;
reg sda_drive;
reg [7:0] clk_div;

parameter IDLE = 0;
parameter START = 1;
parameter SEND_ADDR = 2;
parameter ACK = 3;
parameter SEND_DATA = 4;
parameter DATA_ACK = 5;
parameter STOP = 6;

assign sda = (sda_drive) ? 1'b0 : 1'bz;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        clk_div <= 0;
        i2c_clk <= 0;
    end
    else
    begin
        if(clk_div == 49)
        begin
            clk_div <= 0;
            i2c_clk <= ~i2c_clk;
        end
        else
            clk_div <= clk_div + 1;
    end
end

always@(posedge i2c_clk or posedge reset)
    begin
        if(reset)
            state <= IDLE;
        else
            state <= next_state;
    end

always@(*)
    begin
        
        next_state = state;
    
        case(state)
        
        IDLE:
            if(start)
                next_state = START;
            else
                next_state = IDLE;
            
        START:
            next_state = SEND_ADDR;
        
        SEND_ADDR:
        begin
            if(bit_count == 6)
                next_state = ACK;
            else
                next_state = SEND_ADDR;
        end
        
        ACK:
        begin
                if(sda == 0)
                    next_state = SEND_DATA;
                else
                    next_state = ACK;
        end
        
        SEND_DATA:
        begin
            if(bit_count == 6)
                next_state = DATA_ACK;
            else
                next_state = SEND_DATA;
        end
        
        DATA_ACK:
        begin
            if(sda == 0)
                next_state = STOP;
            else
                next_state = DATA_ACK;
        end
           
        STOP:
            next_state = IDLE;
            
        default:
            next_state = IDLE;
        endcase
    end
    
always@(*)
    begin
    
    sda_drive = 0;
    scl = 1;
    
        case(state)
        IDLE:
            begin
            sda_drive = 0;
            scl = 1;
            end
            
        START:
            begin
            sda_drive = 1;
            scl = 1;
            end
            
        SEND_ADDR:
            begin
            scl = 0;
            if(shift_reg[6] == 0)
                sda_drive = 1;
            else
                sda_drive = 0;
            end
            
        ACK:
            begin
            scl = 1;
            sda_drive = 0;
            end
        
        SEND_DATA:
        begin
            scl = 0;
            if(data_reg[6] == 0)
                sda_drive = 1;
            else
                sda_drive = 0;
        end
        
        DATA_ACK:
        begin
            scl = 1;
            sda_drive = 0;
        end
        
        STOP:
            begin
            sda_drive = 0;
            scl = 1;
            end
        default:
            begin
            sda_drive = 0;
            scl = 1;
            end
        endcase
    end
    
always @(posedge i2c_clk or posedge reset)
begin
    if(reset)
        begin
            shift_reg <= 0;
            bit_count <= 0;
            data_reg <= 0;
        end
    else
    begin
        if(state == START)
        begin
            shift_reg <= 7'b1010101;
            bit_count <= 0;
        end
        else if(state == SEND_ADDR)
            begin
                shift_reg <= shift_reg << 1;
                bit_count <= bit_count + 1;
            end   
        else if(state == ACK)
            begin
                if(sda == 0)
                begin
                    data_reg <= 7'b1100110;
                    bit_count <= 0;
                end
            end
        else if (state == SEND_DATA)
            begin
                data_reg <= data_reg << 1;
                bit_count <= bit_count + 1;
            end
    end
end

endmodule
