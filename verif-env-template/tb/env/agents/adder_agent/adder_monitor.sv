//------------------------------------------------------------------------------
// Monitor module for adder agent
//------------------------------------------------------------------------------
// This module captures interface activity for the adder agent.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_MONITOR 
`define ADDER_MONITOR

class adder_monitor extends uvm_monitor;
 
  /*
   * Declaration of Virtual interface
   */
  virtual adder_interface vif;

  /*
   * Declaration of Analysis ports and exports 
   */
  uvm_analysis_port #(adder_transaction) mon2sb_port;

  /*
   * Declaration of transaction item 
   */
  adder_transaction act_trans;

  /*
   * Declaration of component utils 
   */
  `uvm_component_utils(adder_monitor)

  /*
   * Constructor
   */
  function new (string name, uvm_component parent);
    super.new(name, parent);
    act_trans = new();
    mon2sb_port = new("mon2sb_port", this);
  endfunction : new

  /*
   * Build phase: construct the components
   * This phase retrieves the virtual interface from the UVM configuration database.
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual adder_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  /*
   * Run phase: Extract the info from DUT via interface 
   * This phase continuously samples the transaction signals from the DUT.
   */
  virtual task run_phase(uvm_phase phase);
    forever begin
      collect_trans();
      mon2sb_port.write(act_trans);
    end
  endtask : run_phase

  /*
   * Task: collect_actual_trans
   * Samples the transaction signals from the DUT.
   */
  task collect_trans();
    wait(!vif.reset);
    @(vif.rc_cb);
    @(vif.rc_cb);
    act_trans.x = vif.rc_cb.x;
    act_trans.y = vif.rc_cb.y;
    act_trans.cin = vif.rc_cb.cin;
    act_trans.sum = vif.rc_cb.sum;
    act_trans.cout = vif.rc_cb.cout;
    `uvm_info(get_full_name(),$sformatf("TRANSACTION FROM MONITOR"),UVM_LOW);
    act_trans.print();
  endtask

endclass : adder_monitor

`endif
