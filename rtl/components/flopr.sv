//Flop genérico com rst assíncrono
module flopr #(
    parameter WIDTH = 32  
)(
    input  logic clk,
    input  logic rst_,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk or negedge rst_) begin
        if (!rst_)
            q <= {WIDTH{1'b0}};
        else
            q <= d;
    end
endmodule