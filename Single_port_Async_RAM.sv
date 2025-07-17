module Single_port_Async_RAM #( parameter MEM_DEPTH=256,parameter ADDR_SIZE=8)
(input clk,rst_n,
 input  [ADDR_SIZE+1:0] din, //2 bits for selection of type of din
 input rx_valid,
 output logic  [ADDR_SIZE-1:0] dout,
 output logic tx_valid
);
logic [ADDR_SIZE-1:0] RAM [0:MEM_DEPTH-1]; 
logic [1:0] Operation_Type;
assign Operation_Type = din[ADDR_SIZE+1:ADDR_SIZE];
logic [ADDR_SIZE-1:0]Write_Address,Read_Address=0;
logic [$clog2(ADDR_SIZE + 2):0] counter=0;

always @(posedge clk, negedge rst_n) 
begin
    if(rst_n == 0)
    begin
        dout <= 0;
        Read_Address <= 0;
        Write_Address <= 0;  
        tx_valid <= 0;
        counter <= 0;
    end
    else 
    begin
        // Default: handle counter and tx_valid timeout
        if(tx_valid && counter < 8) begin
            counter <= counter + 1;
        end
        else if(tx_valid && counter >= 8) begin
            tx_valid <= 0;
            counter <= 0;
        end
        
        // Handle new operations
        if(rx_valid) 
        begin
            case(Operation_Type)
                2'b00:
                begin
                    Write_Address <= din[ADDR_SIZE-1:0]; // Write Address
                    dout <= 0;
                    tx_valid <= 0;
                    counter <= 0;
                end
                2'b01:
                begin
                    RAM[Write_Address] <= din[ADDR_SIZE-1:0]; // Write Data
                    dout <= 0;
                    tx_valid <= 0;
                    counter <= 0;
                end
                2'b10:
                begin
                    Read_Address <= din[ADDR_SIZE-1:0]; // Read Address
                    dout <= 0;
                    tx_valid <= 0;
                    counter <= 0;
                end
                2'b11: 
                begin
                    dout <= RAM[Read_Address]; // Read Data
                    tx_valid <= 1;
                    counter <= 0;
                end
                default:
                begin
                    dout <= 0;
                    tx_valid <= 0;
                    counter <= 0;
                end  
            endcase
        end
    end
end
endmodule