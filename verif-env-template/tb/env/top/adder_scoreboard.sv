//------------------------------------------------------------------------------
// Scoreboard module for adder
//------------------------------------------------------------------------------
// This module verifies transaction responses for the adder environment.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_SCOREBOARD 
`define ADDER_SCOREBOARD

class adder_scoreboard extends uvm_scoreboard;
 
  /*
   * Declaration of component utilities
   */
  `uvm_component_utils(adder_scoreboard)

  /*
   * Declaration of analysis ports and exports 
   */
  uvm_analysis_export#(adder_transaction) rm2sb_export, mon2sb_export;
  uvm_tlm_analysis_fifo#(adder_transaction) rm2sb_export_fifo, mon2sb_export_fifo;
  adder_transaction exp_trans, act_trans;
  adder_transaction exp_trans_fifo[$], act_trans_fifo[$];
  bit error;

  /*
   * Constructor
   * Initializes the scoreboard with a given name and parent component.
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  /*
   * Build phase: create analysis ports and FIFOs
   * This phase constructs the analysis ports and FIFOs used for communication.
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rm2sb_export = new("rm2sb_export", this);
    mon2sb_export = new("mon2sb_export", this);
    rm2sb_export_fifo = new("rm2sb_export_fifo", this);
    mon2sb_export_fifo = new("mon2sb_export_fifo", this);
  endfunction: build_phase

  /*
   * Connect phase: connect exports to FIFOs
   * This phase connects the analysis exports to the corresponding FIFOs.
   */
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm2sb_export.connect(rm2sb_export_fifo.analysis_export);
    mon2sb_export.connect(mon2sb_export_fifo.analysis_export);
  endfunction: connect_phase

  /*
   * Run phase: compare expected and actual transactions
   * This phase continuously compares the expected and actual transactions.
   */
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      mon2sb_export_fifo.get(act_trans);
      if (act_trans == null) $stop;
      act_trans_fifo.push_back(act_trans);
      rm2sb_export_fifo.get(exp_trans);
      if (exp_trans == null) $stop;
      exp_trans_fifo.push_back(exp_trans);
      compare_trans();
    end
  endtask

  /*
   * Task: compare_trans
   * Compares the expected and actual transactions and logs the results.
   */
  task compare_trans();
    adder_transaction exp_trans, act_trans;
    if (exp_trans_fifo.size != 0) begin
      exp_trans = exp_trans_fifo.pop_front();
      if (act_trans_fifo.size != 0) begin
        act_trans = act_trans_fifo.pop_front();
        `uvm_info(get_full_name(), $sformatf("expected SUM = %d, actual SUM = %d", exp_trans.sum, act_trans.sum), UVM_LOW);
        `uvm_info(get_full_name(), $sformatf("expected cout = %d, actual cout = %d", exp_trans.cout, act_trans.cout), UVM_LOW);
        if (exp_trans.sum == act_trans.sum) begin
          `uvm_info(get_full_name(), "SUM MATCHES", UVM_LOW);
        end else begin
          `uvm_error(get_full_name(), "SUM MIS-MATCHES");
          error = 1;
        end
        if (exp_trans.cout == act_trans.cout) begin
          `uvm_info(get_full_name(), "COUT MATCHES", UVM_LOW);
        end else begin
          `uvm_error(get_full_name(), "COUT MIS-MATCHES");
          error = 1;
        end
      end
    end
  endtask

  /*
   * Report phase: report test status
   * Logs the final test status (PASS/FAIL) based on the comparison results.
   */
  function void report_phase(uvm_phase phase);
    string test_name;
    if (!$value$plusargs("UVM_TESTNAME=%s", test_name)) begin
      test_name = "TEST CASE";
    end

    if (error == 0) begin
      $write("%c[7;32m",27);
      $display("--------------------------------------------------");
      $display("------ INFO : %0s PASSED ------------------", test_name);
      $display("--------------------------------------------------");
      $write("%c[0m",27);
    end else begin
      $write("%c[7;31m",27);
      $display("--------------------------------------------------");
      $display("------ ERROR : %0s FAILED ------------------", test_name);
      $display("--------------------------------------------------");
      $write("%c[0m",27);
    end
  endfunction 

endclass : adder_scoreboard

`endif
