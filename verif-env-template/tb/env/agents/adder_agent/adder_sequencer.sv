//------------------------------------------------------------------------------
// Sequencer module for adder agent
//------------------------------------------------------------------------------
// This module defines the sequencer for the adder agent.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_SEQUENCER
`define ADDER_SEQUENCER

class adder_sequencer extends uvm_sequencer#(adder_transaction);
 
  `uvm_component_utils(adder_sequencer)
 
  /*
   * Constructor
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
   
endclass

`endif




