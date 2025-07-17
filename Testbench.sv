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
// Test control signals
    logic test_passed;
    logic test_failed;
    int test_count;
    int pass_count;
    int fail_count;
    
//tasks and functions for future use
//======================================================================
 // Clock generation task
    task automatic clock_gen();
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    endtask
    

    task automatic reset_system();
        $display("[%0t] INFO: Applying system reset", $time);
        @(negedge clk);
        rst_n = 0;
        MOSI = 0;
        SS_N = 1;
        @(negedge clk);
        rst_n = 1;
        @(negedge clk);
        $display("[%0t] INFO: Reset complete", $time);
    endtask
    
   
    task automatic spi_transmit(input logic [9:0] data, input string operation);
        $display("[%0t] INFO: Starting %s operation with data: 0b%b", $time, operation, data);
        
        din_stimulus = data;
        SS_N = 0;
        @(posedge clk);
        
        foreach(din_stimulus[i]) begin
            MOSI = din_stimulus[i];
            @(posedge clk);
        end
        
        @(negedge clk);
        SS_N = 1;
        @(negedge clk);
        
        $display("[%0t] INFO: %s operation complete", $time, operation);
    endtask
    
   
    task automatic spi_write(input logic [ADDR_SIZE-1:0] address, input logic [7:0] data);
        logic [9:0] write_addr_cmd;
        logic [9:0] write_data_cmd;
        
      
        write_addr_cmd = {2'b00, address};
        spi_transmit(write_addr_cmd, "WRITE_ADDRESS");
        
      
        write_data_cmd = {2'b01, data};
        spi_transmit(write_data_cmd, "WRITE_DATA");
        
        $display("[%0t] INFO: Write operation - Address: 0x%h, Data: 0x%h", $time, address, data);
    endtask
    
    
    task automatic spi_read(input logic [ADDR_SIZE-1:0] address, output logic [7:0] read_data);
        logic [9:0] read_addr_cmd;
        logic [9:0] read_data_cmd;
        
        // Read address command (10 + 8-bit address)
        read_addr_cmd = {2'b10, address};
        spi_transmit(read_addr_cmd, "READ_ADDRESS");
        
        // Read data command (11 + don't care bits)
        read_data_cmd = 10'b1100000000;
        
        $display("[%0t] INFO: Starting read data operation", $time);
        din_stimulus = read_data_cmd;
        SS_N = 0;
        
        foreach(din_stimulus[i]) begin
            @(posedge clk);
            MOSI = din_stimulus[i];
        end
        
        @(negedge clk);
        SS_N = 1;
   
        read_data = 8'h00; 
        
        $display("[%0t] INFO: Read operation - Address: 0x%h, Data: 0x%h", $time, address, read_data);
    endtask
    
  
    function automatic void check_result(input logic expected, input logic actual, input string test_name);
        test_count++;
        if (expected === actual) begin
            $display("[%0t] PASS: %s - Expected: %b, Actual: %b", $time, test_name, expected, actual);
            pass_count++;
        end else begin
            $display("[%0t] FAIL: %s - Expected: %b, Actual: %b", $time, test_name, expected, actual);
            fail_count++;
            test_failed = 1;
        end
    endfunction
    
  
    function automatic void verify_data(input logic [7:0] expected, input logic [7:0] actual, input string test_name);
        test_count++;
        if (expected === actual) begin
            $display("[%0t] PASS: %s - Expected: 0x%h, Actual: 0x%h", $time, test_name, expected, actual);
            pass_count++;
        end else begin
            $display("[%0t] FAIL: %s - Expected: 0x%h, Actual: 0x%h", $time, test_name, expected, actual);
            fail_count++;
            test_failed = 1;
        end
    endfunction
    

    function automatic void print_test_summary();
        $display("\n" + "="*50);
        $display("TEST SUMMARY");
        $display("="*50);
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        if (fail_count == 0) begin
            $display("OVERALL RESULT: ALL TESTS PASSED!");
        end else begin
            $display("OVERALL RESULT: %0d TEST(S) FAILED!", fail_count);
        end
        $display("="*50 + "\n");
    endfunction
//======================================================================
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
    //Write_Address
    
    @(negedge clk);
    SS_N = 1;
       @(negedge clk);
    rst_n=1;
    din_stimulus =10'b0011111111;
    SS_N=0;
     @(posedge clk);
    foreach(din_stimulus[i]) begin
       

        MOSI = din_stimulus[i];
        @(posedge clk);
    end

    //Write_Data
    
    @(negedge clk);
    SS_N = 1; // Deactivate slave select
    @(negedge clk);
    rst_n=1;
    din_stimulus =10'b0111111101;
    SS_N=0;
     @(posedge clk);
    foreach(din_stimulus[i]) begin
       

        MOSI = din_stimulus[i];
        @(posedge clk);
    end



    @(negedge clk);
    SS_N = 1; // Deactivate slave select
    //Read_Address
    @(negedge clk);
    rst_n=1;
    din_stimulus =10'b1011111111;
    SS_N=0;
     @(posedge clk);
    foreach(din_stimulus[i]) begin
       

        MOSI = din_stimulus[i];
        @(posedge clk);
    end



    //Read_Data
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