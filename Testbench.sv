module Testbench;

// Parameters
parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;
parameter  CLK_PERIOD =100 ;

// Testbench signals
logic clk;
logic rst_n;
logic MOSI;
logic MISO;
logic SS_N;
logic [ADDR_SIZE+1:0] din_stimulus;

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;  // 10ns period
end

// DUT instantiation
SPI_Wrapper #(
    .MEM_DEPTH(MEM_DEPTH),
    .ADDR_SIZE(ADDR_SIZE)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .MOSI(MOSI),
    .MISO(MISO),
    .SS_N(SS_N)
);

// Test stimulus
initial begin
    @(negedge clk);
    rst_n = 0;
    MOSI = 0;
    SS_N = 1;
    dut.u_Single_port_Async_RAM.RAM[8'hff]=8'hab;
    @(negedge clk);
    rst_n=1;
    din_stimulus =10'b1011111111;
    SS_N=0;
     @(posedge clk);
    foreach(din_stimulus[i]) begin
       

        MOSI = din_stimulus[i];
        @(posedge clk);

    end
    @(negedge clk);
    SS_N = 1; // Deactivate slave select
       @(negedge clk);
    SS_N = 0; // Deactivate slave select
    din_stimulus = 10'b1100000000; 
    foreach(din_stimulus[i]) begin
        @(posedge clk);
        MOSI = din_stimulus[i];
        SS_N = 0; // Activate slave select
    end
    


   
    
    $stop;
end
   
    // Monitor important signals
    initial begin
        $monitor("Time=%0t, SS_N=%b, MOSI=%b, MISO=%b, State=%s, Counter=%0d, rx_valid=%b, tx_valid=%b", 
                $time, SS_N, MOSI, MISO, 
                dut.u_SPI_Slave_Interface.current_state.name(),
                dut.u_SPI_Slave_Interface.counter,
                dut.u_SPI_Slave_Interface.rx_valid,
                dut.u_Single_port_Async_RAM.tx_valid);
    end
    
    // Timeout watchdog
    initial begin
        #(CLK_PERIOD * 10000);
        $display("TIMEOUT: Test took too long to complete!");
        $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("spi_read_test.vcd");
        $dumpvars(0, Testbench);
    end

endmodule