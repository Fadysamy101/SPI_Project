vsim -voptargs=+acc work.SPI_Slave_Interface
# End time: 17:09:06 on Jul 17,2025, Elapsed time: 0:04:40
# Errors: 0, Warnings: 0
# vsim -voptargs="+acc" work.SPI_Slave_Interface 
# Start time: 17:09:06 on Jul 17,2025
# ** Note: (vsim-3812) Design is being optimized...
# ** Warning: SPI_Slave_Interface.sv(85): (vopt-2182) 'Has_Read_Address' might be read before written in always_comb or always @* block.
# ** Note: (vopt-143) Recognized 1 FSM in module "SPI_Slave_Interface(fast)".
# ** Note: (vsim-12126) Error and warning message counts have been restored: Errors=0, Warnings=1.
# Loading sv_std.std
# Loading work.SPI_Slave_Interface(fast)
add wave -position end  sim:/SPI_Slave_Interface/ADDR_SIZE
add wave -position end  sim:/SPI_Slave_Interface/check_read_data_op
add wave -position end  sim:/SPI_Slave_Interface/clk
add wave -position end  sim:/SPI_Slave_Interface/counter
add wave -position end  sim:/SPI_Slave_Interface/current_state
add wave -position end  sim:/SPI_Slave_Interface/din_MSB
add wave -position end  sim:/SPI_Slave_Interface/Has_Read_Address
add wave -position end  sim:/SPI_Slave_Interface/load_shift_reg_MISO
add wave -position end  sim:/SPI_Slave_Interface/MISO
add wave -position end  sim:/SPI_Slave_Interface/MOSI
add wave -position end  sim:/SPI_Slave_Interface/next_state
add wave -position end  sim:/SPI_Slave_Interface/rst_n
add wave -position end  sim:/SPI_Slave_Interface/rx_data
add wave -position end  sim:/SPI_Slave_Interface/rx_valid
add wave -position end  sim:/SPI_Slave_Interface/shift_reg
add wave -position end  sim:/SPI_Slave_Interface/shift_reg_MISO
add wave -position end  sim:/SPI_Slave_Interface/SS_N
add wave -position end  sim:/SPI_Slave_Interface/tx_data
add wave -position end  sim:/SPI_Slave_Interface/tx_valid
force -freeze sim:/SPI_Slave_Interface/clk 1 0, 0 {50 ns} -r 100
run
run
run
run
force -freeze sim:/SPI_Slave_Interface/SS_N 1 0
run
run
run
run
force -freeze sim:/SPI_Slave_Interface/MOSI 1 0
force -freeze sim:/SPI_Slave_Interface/rst_n 1 0
force -freeze sim:/SPI_Slave_Interface/SS_N 0 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run

