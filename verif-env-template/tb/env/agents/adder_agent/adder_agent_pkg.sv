//------------------------------------------------------------------------------
// Package for adder agent components
//------------------------------------------------------------------------------
// This package includes the components and declarations for the adder agent.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_AGENT_PKG
`define ADDER_AGENT_PKG

package adder_agent_pkg;
 
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  /*
   * Include Agent components: driver, monitor, sequencer
   */
  `include "adder_defines.svh"
  `include "adder_transaction.sv"
  `include "adder_sequencer.sv"
  `include "adder_driver.sv"
  `include "adder_monitor.sv"
  `include "adder_agent.sv"

endpackage

`endif



