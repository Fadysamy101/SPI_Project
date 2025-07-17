module SPI_Slave_Interface #(parameter ADDR_SIZE =8)
  ( input MOSI,
    input SS_N,
    input tx_valid,
    input [ADDR_SIZE-1:0]tx_data,
    input clk,rst_n,
    output logic MISO,
    output logic rx_valid,
    output logic [ADDR_SIZE+1:0] rx_data
);
    logic [ADDR_SIZE+1:0] shift_reg ;
   

    logic [ADDR_SIZE-1:0] shift_reg_MISO;
    
   
    logic Has_Read_Address=0;
    logic [$clog2(ADDR_SIZE + 2):0] counter=0;
   
 
    assign rx_data = shift_reg;
    logic tx_valid_d;

     typedef enum  logic[2:0]
    { IDLE,
      CHK_CMD,
      WRITE,
      READ_DATA1,
      READ_DATA2,
      READ_ADD
    } state_t;
    state_t current_state=IDLE,next_state;
   //State_Register
  always_ff @(posedge clk , negedge rst_n) 
  begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;           
    end
 always_ff @(posedge clk, negedge rst_n)
begin
    if (!rst_n)
    begin
        shift_reg <= 0;
        counter <= 0;
        shift_reg_MISO <= 0;
        tx_valid_d <= 0;
        Has_Read_Address <= 0;
    end
    else 
    begin
        // Register for previous tx_valid
        tx_valid_d <= tx_valid;

        if(!SS_N && current_state !== IDLE)
        begin
            counter <= counter + 1;
            shift_reg <= {shift_reg[ADDR_SIZE:0], MOSI}; // SHL
            shift_reg_MISO <= {shift_reg_MISO[ADDR_SIZE-2:0], 1'b0};
        end  
        else
        begin
            counter <= 0;
        end
        
        // Load shift register on tx_valid falling edge
        if(~tx_valid_d && tx_valid)
            shift_reg_MISO <= tx_data;
        
  
        if(current_state == READ_ADD && next_state==IDLE)begin
            Has_Read_Address <= 1;
        end
        else begin
            Has_Read_Address<=Has_Read_Address;
        end
      
    end
end
 

always_comb
begin
    // DEFAULT VALUES - Prevents inferred latches
    next_state = IDLE;
    rx_valid = 0;
    MISO = 0;

    
    case (current_state)
        IDLE:
        begin
            if (!SS_N) // Slave Select Active
            begin
                next_state = CHK_CMD;
            end
            else
            begin
                next_state = IDLE;
            end
        end
        
        CHK_CMD:
        begin
            if (!MOSI)
            begin
                next_state = WRITE;
            end
            else
            begin
                if(Has_Read_Address)
                    next_state = READ_DATA1;
                else
                    next_state = READ_ADD;
            end
        end
        
        WRITE:
        begin
            if(counter == 10)
            begin
                next_state = IDLE;
                rx_valid = 1;
            end
            else
            begin
                next_state = WRITE;

             
            end
        end
        
        READ_ADD:
        begin
            if(counter == 10)
            begin
                
                rx_valid = 1;
                next_state = IDLE;
            end
            else
            begin
                next_state = READ_ADD;
            
            end
        end
        
        READ_DATA1:
        begin
            if(counter == 10)
            begin
                rx_valid = 1;
                next_state = READ_DATA2;
            end
            else
            begin
                next_state = READ_DATA1;
               
            end
        end
        
        READ_DATA2:
        begin
            if(tx_valid)
            begin
                next_state = READ_DATA2;
                MISO = shift_reg_MISO[ADDR_SIZE-1];
            end
            else
            begin
                next_state = IDLE;
            end
        end
        
        default:
        begin
            next_state = IDLE;
        
        end
    endcase
end
   
 
endmodule