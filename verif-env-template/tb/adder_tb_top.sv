//------------------------------------------------------------------------------
// Top-level testbench for adder
//------------------------------------------------------------------------------
// This module instantiates the DUT, generates clock/reset, and starts UVM phases.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_TB_TOP
`define ADDER_TB_TOP
`include "uvm_macros.svh"
`include "adder_interface.sv"
import uvm_pkg::*;

module adder_tb_top;
   
  import adder_test_list_pkg::*;

  /*
   * Local signal declarations and parameter definitions
   */
  parameter cycle = 10;
  bit clk;
  bit reset;
  
  /*
   * Clock generation process
   * Generates a clock signal with a period defined by the cycle parameter.
   */
  initial begin
    clk = 0;
    forever #(cycle/2) clk = ~clk;
  end

  /*
   * Reset generation process
   * Generates a reset signal that is asserted for a few clock cycles.
   */
  initial begin
    reset = 1;
    #(cycle*5) reset = 0;
  end
  
  /*
   * Instantiate interface to connect DUT and testbench elements
   * The interface connects the DUT to the testbench components.
   */
  adder_interface adder_intf(clk, reset);
  
  /*
   * DUT instantiation for adder
   * Instantiates the adder DUT and connects it to the interface signals.
   */
  adder dut_inst(
    .x(adder_intf.x),
    .y(adder_intf.y),
    .cin(adder_intf.cin),
    .sum(adder_intf.sum),
    .cout(adder_intf.cout)
  );
  
  /*
   * Start UVM test phases
   * Initiates the UVM test phases.
   */
  initial begin
    run_test();
  end
  
  /*
   * Set the interface instance in the UVM configuration database
   * Registers the interface instance with the UVM configuration database.
   */
  initial begin
    uvm_config_db#(virtual adder_interface)::set(uvm_root::get(), "*", "intf", adder_intf);
  end

endmodule

`endif



