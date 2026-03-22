//------------------------------------------------------------------------------
// Package for adder environment classes
//------------------------------------------------------------------------------
// This package includes the environment classes and declarations for the adder verification.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_ENV_PKG
`define ADDER_ENV_PKG

package adder_env_pkg;
   
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  /*
   * Importing packages: agent, ref model, register, etc.
   */
  import adder_agent_pkg::*;
  import adder_ref_model_pkg::*;

  /*
   * Include top env files 
   */
  `include "adder_coverage.sv"
  `include "adder_scoreboard.sv"
  `include "adder_env.sv"

endpackage

`endif


