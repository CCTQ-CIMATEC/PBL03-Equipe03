//------------------------------------------------------------------------------
// Corner test for adder
//------------------------------------------------------------------------------
// This UVM test triggers the corner case sequence using factory overrides.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : February 2026
//------------------------------------------------------------------------------

`ifndef ADDER_CORNER_TEST 
`define ADDER_CORNER_TEST

class adder_corner_test extends adder_basic_test;
 
  /*
   * Declare component utilities for the test-case
   */
  `uvm_component_utils(adder_corner_test)
 
  /*
   * Constructor: new
   */
  function new(string name = "adder_corner_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
 
  /*
   * Build phase: Override the default sequence type specifically for this test
   */
  virtual function void build_phase(uvm_phase phase);
    // When the basic test tries to create "adder_basic_seq", this override forces it 
    // to instantiate the "adder_corner_seq" instead!
    adder_basic_seq::type_id::set_type_override(adder_corner_seq::get_type());
    super.build_phase(phase);
  endfunction : build_phase
 
endclass : adder_corner_test

`endif
