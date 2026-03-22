//------------------------------------------------------------------------------
// Package for adder reference model components
//------------------------------------------------------------------------------
// This package includes the reference model components for the adder verification.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_REF_MODEL_PKG
`define ADDER_REF_MODEL_PKG

package adder_ref_model_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  /*
   * Importing packages: agent, ref model, register, etc.
   */
  import adder_agent_pkg::*;

  /*
   * Include ref model files 
   */
  `include "adder_ref_model.sv"

endpackage

`endif



