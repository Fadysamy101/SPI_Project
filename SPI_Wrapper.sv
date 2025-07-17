module SPI_Wrapper #(parameter MEM_DEPTH=256,parameter ADDR_SIZE=8)
(   input clk,rst_n,
    input MOSI,
    output MISO,
    input SS_N
);
    // Data signals
    logic [ADDR_SIZE-1:0] din;        // Data input to RAM
    logic [ADDR_SIZE-1:0] dout;       // Data output from RAM
    logic [ADDR_SIZE+1:0] rx_data; // Data received from SPI

    // Control signals
    logic rx_valid;    // Valid signal for received data (SPI to RAM)
    logic tx_valid;    // Valid signal for transmit data (RAM to SPI)

Single_port_Async_RAM #(
    .MEM_DEPTH (MEM_DEPTH ),
    .ADDR_SIZE (ADDR_SIZE )
)u_Single_port_Async_RAM(
    .clk      (clk      ),
    .rst_n    (rst_n    ),
    .din      (rx_data  ),
    .rx_valid (rx_valid ),
    .dout     (dout     ),
    .tx_valid (tx_valid )
);

SPI_Slave_Interface #(.ADDR_SIZE(ADDR_SIZE)
) u_SPI_Slave_Interface(
    .MOSI     (MOSI     ),
    .tx_valid (tx_valid ),
    .tx_data  (dout ),
    .clk      (clk      ),
    .rst_n    (rst_n    ),
    .MISO     (MISO     ),
    .rx_valid (rx_valid ),
    .rx_data  (rx_data  )
);

    
endmodule
