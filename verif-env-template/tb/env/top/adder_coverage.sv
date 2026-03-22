//------------------------------------------------------------------------------
// Coverage collection module for adder
//------------------------------------------------------------------------------
// This module collects functional coverage for the adder environment.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_COVERAGE
`define ADDER_COVERAGE

class adder_coverage#(type T = adder_transaction) extends uvm_subscriber#(T);

  /*
   * Declaration of Local fields
   */
  adder_transaction cov_trans;
  `uvm_component_utils(adder_coverage)

  /*
   * Functional coverage: covergroup for adder
   * Defines coverpoints for various fields of the adder transaction.
   */
  covergroup adder_cg;
    option.per_instance = 1;
    option.goal = 100;

    adder_x: coverpoint cov_trans.x {
      bins x_values[] = {[0:$]};
    }
  
    adder_y: coverpoint cov_trans.y {
      bins y_values[] = {[0:$]};
    }

    adder_cin: coverpoint cov_trans.cin {
      bins cin_1 = {1};
      bins cin_0 = {0};
    }

    adder_sum: coverpoint cov_trans.sum {
      bins sum_values[] = {[0:$]};
    }

    adder_cout: coverpoint cov_trans.cout { 
      bins low = {0};
      bins high = {1};
    }
  endgroup

  /*
   * Constructor
   * Initializes the coverage group and transaction object.
   */
  function new(string name = "adder_ref_model", uvm_component parent);
    super.new(name, parent);
    adder_cg = new();
    cov_trans = new();
  endfunction

  /*
   * Method: write (samples coverage)
   * Samples the coverage for the given transaction.
   */
  function void write(T t);
    this.cov_trans = t;
    adder_cg.sample();
  endfunction

endclass

`endif



