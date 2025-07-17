module SPI_Slave_Interface #(parameter ADDR_SIZE =8)
  ( input MOSI,
    input SS_N,
    input tx_valid,
    input [ADDR_SIZE-1:0]tx_data,
    input clk,rst_n,
    output logic MISO,
    output logic rx_valid,
    output logic [9:0] rx_data
);
    logic [ADDR_SIZE+1:0] shift_reg ;
   

    logic [ADDR_SIZE-1:0] shift_reg_MISO;
    
    logic load_shift_reg_MISO;
    logic Has_Read_Address=0;
    logic [$clog2(ADDR_SIZE + 2):0] counter=0;
    logic din_MSB;
    logic check_read_data_op;

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
    end
    else if(!SS_N)
    begin
      counter<=counter+1;
      shift_reg<={MOSI,shift_reg[ADDR_SIZE:0]}; 
      if(load_shift_reg_MISO)
       shift_reg_MISO<=tx_data;  
      shift_reg_MISO<={shift_reg_MISO[ADDR_SIZE-2:0],1'b0};
    end  
    else
     counter <=0;
    

  end    
  always_comb 
  begin
        case (current_state)
            IDLE: 
            begin
                rx_valid = 0;
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
                din_MSB = MOSI;
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
              next_state = IDLE;
             else
             next_state = WRITE; 
            end
            
            READ_ADD: 
            begin
             if(counter == 10)
             begin
             Has_Read_Address = 1;
             next_state = IDLE;
             end
             else
             next_state = READ_ADD; 
              
            end
            
            READ_DATA1: 
            begin
               check_read_data_op = {din_MSB,MOSI};
              if(check_read_data_op == 2'b11) // Read Data Operation
              begin
                if(counter == 10 )
                begin
                rx_valid = 1;
                next_state = READ_DATA2;
                end 
                else
                next_state = READ_ADD;
              end
              else
              next_state = READ_ADD;  
            end
            READ_DATA2:
            begin
              rx_valid = 0;
              if(tx_valid)
              begin
                MISO =shift_reg_MISO[7];
              end
              //else  
              end  
          
            
            default: 
            begin
                next_state = IDLE;
            end
            
        endcase
       //load_shift_reg_MISO LOGIc
       if (counter ==11 && tx_valid) 
        load_shift_reg_MISO = 1;
        else 
        load_shift_reg_MISO = 0; 

        
    end 
     
  
 
endmodule