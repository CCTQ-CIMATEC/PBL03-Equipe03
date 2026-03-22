//------------------------------------------------------------------------------
// UVM agent for adder transactions
//------------------------------------------------------------------------------
// This agent handles the driver, monitor, and sequencer for adder transactions.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_AGENT 
`define ADDER_AGENT

class adder_agent extends uvm_agent;

  /*
   * Declaration of UVC components such as driver, monitor, sequencer, etc.
   */
  adder_driver    driver;
  adder_sequencer sequencer;
  adder_monitor   monitor;

  /*
   * Declaration of component utils 
   */
  `uvm_component_utils(adder_agent)

  /*
   * Constructor
   */
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  /*
   * Build phase: construct the components such as driver, monitor, sequencer, etc.
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = adder_driver::type_id::create("driver", this);
    sequencer = adder_sequencer::type_id::create("sequencer", this);
    monitor = adder_monitor::type_id::create("monitor", this);
  endfunction : build_phase

  /*
   * Connect phase: connect TLM ports and exports (e.g., analysis port/exports)
   */
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase
 
endclass : adder_agent

`endif
