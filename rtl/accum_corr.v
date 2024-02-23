module accum_corr(
                    input i_clk,
                    input i_resetn,
                    input i_last,
                    input [30:0] i_data,
                    input i_valid,
                    output [30:0] o_accum,
                    output reg o_valid
);

wire [30:0] sum;
wire valid_st2,
     last_st2;

// pipeline_stage #(.WIDTH(1)) pipeline_inst_valid
//                         (
//                           .i_clk(i_clk),
//                           .i_resetn(i_resetn),
//                           .i_stall(1'b0),
//                           .i_clear(1'b0),
//                           .i_data(i_valid),
//                           .o_data(valid_st2)
//                         );

// pipeline_stage #(.WIDTH(1)) pipeline_inst_last
//                         (
//                           .i_clk(i_clk),
//                           .i_resetn(i_resetn),
//                           .i_stall(1'b0),
//                           .i_clear(1'b0),
//                           .i_data(i_last),
//                           .o_data(last_st2)
//                         );


// c_addsub_0 inst_addsub (
//   .A(i_data),      // input wire [31 : 0] A
//   .B(o_accum),      // input wire [31 : 0] B
//   .S(sum)      // output wire [31 : 0] S
// );
c_accum_0 inst_accum (
  .B(i_data[24:0]),        // input wire [24 : 0] B
  .CLK(i_clk),    // input wire CLK
  .CE(i_valid),  // input wire CE
  .SCLR(o_valid),  // input wire SCLR
  .Q(o_accum)        // output wire [29 : 0] Q
);

// // assign sum = i_data[24:0] + o_accum;


// always @ (posedge i_clk, negedge i_resetn) begin
//     if (~i_resetn) begin
//         o_accum <= 0;
//     end
//     else begin
//         if (i_valid) begin
//             o_accum <= sum;
//         end
//         else begin
//             o_accum <= 0;
//         end
//     end
// end


// Output Validity based on the Last Element from Source

always @ (posedge i_clk, negedge i_resetn) begin
    if (~i_resetn) begin
        o_valid <= 0;
    end
    else begin
        o_valid <= i_last;
    end
end


endmodule 