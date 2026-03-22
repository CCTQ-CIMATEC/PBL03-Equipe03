//------------------------------------------------------------------------------
// Basic sequence for adder
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the adder UVM verification.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_BASIC_SEQ 
`define ADDER_BASIC_SEQ

class adder_basic_seq extends uvm_sequence#(adder_transaction);
   
  /*
   * Declaration of sequence utilities
   */
  `uvm_object_utils(adder_basic_seq)
 
  /*
   * Sequence constructor
   */
  function new(string name = "adder_basic_seq");
    super.new(name);
  endfunction
 
  /*
   * Body method: Sends randomized transactions via the sequencer
   * This method generates a series of randomized transactions and sends them
   * to the driver through the sequencer. Each transaction is created, randomized,
   * and sent to the driver, which then drives the transaction to the DUT.
   */
  virtual task body();
    for (int i = 0; i < `NO_OF_TRANSACTIONS; i++) begin
      req = adder_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION FROM SEQUENCE"), UVM_LOW);
      req.print();
      finish_item(req);
      get_response(rsp);
    end
  endtask
   
endclass

`endif


