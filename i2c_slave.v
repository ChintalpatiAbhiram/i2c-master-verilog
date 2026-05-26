module i2c_slave(
input scl,
inout sda,
input i2c_clk,
input reset
);

reg [2:0] state, next_state;
reg [6:0] received_addr;
reg [6:0] received_data;
reg [2:0] bit_count;
reg sda_drive;

parameter IDLE = 0;
parameter RECEIVE_ADDR = 1;
parameter CHECK_ADDR = 2;
parameter SEND_ACK = 3;
parameter RECEIVE_DATA = 4;
parameter SEND_DATA_ACK = 5;

assign sda = (sda_drive) ? 1'b0 : 1'bz;

always@(posedge i2c_clk or posedge reset)
    begin
    if(reset)
        begin
            state <= IDLE;
            received_addr <= 0;
            received_data <= 0;
            bit_count <= 0;
        end
        
    else
        begin
            state <= next_state;
            
            if(state == RECEIVE_ADDR)
            begin
                received_addr <= {received_addr[5:0], sda};
                bit_count <= bit_count + 1;
            end
            
            else if(state == RECEIVE_DATA)
            begin
                received_data <= {received_data[5:0], sda};
                bit_count <= bit_count + 1;
            end
            
            if(state == SEND_ACK)
            begin
                bit_count <= 0;
                received_data <= 0;
            end
            
            if(state == SEND_DATA_ACK)
                bit_count <= 0;
        end
    end

always@(*)
    begin
    
        next_state = state;
        
        case(state)
            IDLE:
            begin
                if(sda == 0)
                    next_state = RECEIVE_ADDR;
                else
                    next_state = IDLE;
            end
            
            RECEIVE_ADDR:
                begin
                    if(bit_count == 6)
                        next_state = CHECK_ADDR;
                    else
                        next_state = RECEIVE_ADDR;
                end
            CHECK_ADDR:
                begin
                    if(received_addr == 7'b1010101)
                        next_state = SEND_ACK;
                    else
                        next_state = RECEIVE_ADDR;
                end
            
            SEND_ACK:
                next_state = RECEIVE_DATA;
            
            RECEIVE_DATA:
                begin
                    if(bit_count == 6)
                        next_state = SEND_DATA_ACK;
                    else
                        next_state = RECEIVE_DATA;
                end
                
            SEND_DATA_ACK:
                next_state = IDLE;
                
            default:
                next_state = IDLE;
                
        endcase
    end
    
always@(*)
    begin
        
        sda_drive = 0;
        
        case(state)
            
            SEND_ACK:
                sda_drive = 1;
            
            SEND_DATA_ACK:
                sda_drive = 1;
                
        endcase
    end
endmodule