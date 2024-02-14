module accum_corr(
                    input i_clk,
                    input i_resetn,
                    input i_last,
                    input [31:0] i_x,
                    input i_x_valid,
                    output reg [31:0] o_accum,
                    output reg o_valid
);

wire [31:0] sum;

c_addsub_0 your_instance_name (
  .A(i_x),      // input wire [31 : 0] A
  .B(accum),      // input wire [31 : 0] B
  .CLK(i_clk),  // input wire CLK
  .S(sum)      // output wire [31 : 0] S
);

always @ (posedge i_clk, negedge i_resetn) begin
    if (i_resetn) begin
        o_accum <= 0;
    end
    else begin
        if (i_x_valid) begin
            o_accum <= i_last ? 0 : sum;
        end
    end
end


// Output Validity based on the Last Element from Source

always @ (posedge i_clk, negedge i_resetn) begin
    if (i_resetn) begin
        o_valid <= 0;
    end
    else begin
        o_valid <= i_last
    end
end


endmodule 