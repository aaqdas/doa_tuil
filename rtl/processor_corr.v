module processor_corr #(parameter DATA_WIDTH_BITS = 12)
                     (
                      input i_clk,
                      input i_reset,
                      input i_x_last,
                      input i_y_last,
                      input i_x_valid,
                      input i_y_valid,
                      input [DATA_WIDTH_BITS-1:0] i_x_r,
                      input [DATA_WIDTH_BITS-1:0] i_x_c,
                      input [DATA_WIDTH_BITS-1:0] i_y_r,
                      input [DATA_WIDTH_BITS-1:0] i_y_c,
                      output [DATA_WIDTH_BITS*2:0] o_r,
                      output [DATA_WIDTH_BITS*2:0] o_c,
                      output o_ready_x,
                      output o_ready_y,
                      output o_valid
);

wire [31:0] s_axis_a_tdata,
            s_axis_b_tdata;

wire [64:0] m_axis_dout_tdata;

wire     s_axis_a_tvalid,
         s_axis_b_tvalid,
         m_axis_dout_tvalid;

wire [31:0] accum_r,
            accum_c;

wire accum_valid_r,
     accum_valid_c;

assign s_axis_a_tdata = {4'b0,i_x_c,4'b0,i_x_r};
assign s_axis_b_tdata = {4'b0,i_y_c,4'b0,i_y_r};

//Complex Multiplier for Correlation
cmpy_0 inst_cmpy_corr (
  .aclk               (i_clk),                  // input wire aclk
  .aresetn            (i_reset),                  // input wire aresetn
  .s_axis_a_tvalid    (i_x_valid),                  // input wire s_axis_a_tvalid
  .s_axis_a_tdata     (s_axis_a_tdata),               // input wire [31 : 0] s_axis_a_tdata
  .s_axis_a_tready    (o_ready_x),                // output wire s_axis_b_tready
  .s_axis_a_tlast     (i_x_last),                        // input wire s_axis_a_tlast
  .s_axis_b_tvalid    (i_y_valid),                      // input wire s_axis_b_tvalid
  .s_axis_b_tready    (o_ready_y),               // output wire s_axis_b_tready
  .s_axis_b_tdata     (s_axis_b_tdata),               // input wire [31 : 0] s_axis_b_tdata
  .s_axis_b_tlast     (i_y_last),                    // input wire s_axis_b_tlast
  .m_axis_dout_tvalid (m_axis_dout_tvalid),         // output wire m_axis_dout_tvalid
  .m_axis_dout_tready (1'b1),                      // input wire m_axis_dout_tready
  .m_axis_dout_tdata  (m_axis_dout_tdata),        // output wire [63 : 0] m_axis_dout_tdata
  .m_axis_dout_tlast  (m_axis_dout_tlast)        // output wire m_axis_dout_tlast
);


// assign o_r = m_axis_dout_tdata[24:0];
// assign o_c = m_axis_dout_tdata[56:32];
// assign o_valid = m_axis_dout_tvalid;


//Real Accumulator
accum_corr inst_accum_corr_real (
  .i_clk    (i_clk),                  //input clock
  .i_resetn (i_resetn),               //input reset negedge
  .i_last   (m_axis_dout_tlast),      //input last element
  .i_x      (m_axis_dout_tdata[24:0]),                    //input operand
  .i_x_valid(m_axis_dout_tvalid),     //input operand validity
  .o_accum  (o_r),                //output accumulator
  .o_valid  (accum_valid_r)                 //output validity
);


//Imaginary Accumulator
accum_corr inst_accum_corr_imag (
  .i_clk    (i_clk),                  //input clock
  .i_resetn (i_resetn),               //input reset negedge
  .i_last   (m_axis_dout_tlast),      //input last element
  .i_x      (m_axis_dout_tdata[56:32]),                    //input operand
  .i_x_valid(m_axis_dout_tvalid),     //input operand validity
  .o_accum  (o_c),                //output accumulator
  .o_valid  (accum_valid_c)                 //output validity
);


assign o_valid = accum_valid_r && accum_valid_c;


endmodule 