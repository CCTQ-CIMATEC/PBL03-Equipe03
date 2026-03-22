//------------------------------------------------------------------------------
// Basic test for adder
//------------------------------------------------------------------------------
// This UVM test sets up the environment and sequence for the adder verification.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_BASIC_TEST 
`define ADDER_BASIC_TEST

class adder_basic_test extends uvm_test;
 
  /*
   * Declare component utilities for the test-case
   */
  `uvm_component_utils(adder_basic_test)
 
  adder_environment env;
  adder_basic_seq   seq;
 
  /*
   * Constructor: new
   * Initializes the test with a given name and parent component.
   */
  function new(string name = "adder_basic_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
 
  /*
   * Build phase: Instantiate environment and sequence
   * This phase constructs the environment and sequence components.
   */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = adder_environment::type_id::create("env", this);
    seq = adder_basic_seq::type_id::create("seq");
  endfunction : build_phase
 
  /*
   * Run phase: Start the sequence on the agent’s sequencer
   * This phase starts the sequence, which generates and sends transactions to the DUT.
   */
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.adder_agnt.sequencer);
    phase.drop_objection(this);
  endtask : run_phase
 
endclass : adder_basic_test

`endif












