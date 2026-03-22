//------------------------------------------------------------------------------
// Corner sequence for adder
//------------------------------------------------------------------------------
// This sequence generates corner-case transactions for the adder (zeros, maxes).
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : February 2026
//------------------------------------------------------------------------------

`ifndef ADDER_CORNER_SEQ 
`define ADDER_CORNER_SEQ

class adder_corner_seq extends adder_basic_seq;
   
  /*
   * Declaration of sequence utilities
   */
  `uvm_object_utils(adder_corner_seq)
 
  /*
   * Sequence constructor
   */
  function new(string name = "adder_corner_seq");
    super.new(name);
  endfunction
 
  /*
   * Body method: Sends corner case transactions via the sequencer
   */
  virtual task body();
    // Test known corner cases for a 4-bit adder
    int unsigned corners_x[]   = '{0, 4'hF, 0,    4'hF, 4'hA, 4'h5};
    int unsigned corners_y[]   = '{0, 0,    4'hF, 4'hF, 4'h5, 4'hA};
    int unsigned corners_cin[] = '{0, 0,    0,    1,    1,    0};

    foreach(corners_x[i]) begin
      req = adder_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
         x == corners_x[i];
         y == corners_y[i];
         cin == corners_cin[i];
      });
      `uvm_info(get_full_name(), $sformatf("CORNER TRANSACTION SENT FROM SEQUENCE"), UVM_LOW);
      req.print();
      finish_item(req);
      get_response(rsp);
    end
  endtask
   
endclass

`endif
