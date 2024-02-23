`timescale 1ns/100ps

// `define time_lim  64// Total Timestamps
// `define  anta_lim  8 // Antenna Array Number
module processor_corr_tb();
parameter integer time_lim = 64;// Total Timestamps
parameter integer anta_lim = 8; // Antenna Array Number
reg i_clk,i_reset;
reg [11:0] i_x_r;
reg [11:0] i_x_c;
reg [11:0] i_y_r;
reg [11:0] i_y_c;
wire  i_x_valid,
      i_y_valid;
wire  i_x_last,
     i_y_last;
wire [30:0] o_r;
wire [30:0] o_c;
wire o_valid;
wire o_ready_x,
     o_ready_y;

reg [1:0] counter_state, counter_n_state;
parameter [1:0] ready = 0, compute = 1, inc_x = 2, inc_y = 3;


reg [6:0] time_idx;

reg [3:0] x_idx;
reg [3:0] y_idx;

wire x_idx_last,
     y_idx_last;

processor_corr inst_processor_corr
                     (
                      .i_clk(i_clk),
                      .i_reset(i_reset),
                      .i_x_last(i_x_last),
                      .i_y_last(i_y_last),
                      .i_x_valid(i_x_valid),
                      .i_y_valid(i_y_valid),
                      .i_x_r(i_x_r),
                      .i_x_c(i_x_c),
                      .i_y_r(i_y_r),
                      .i_y_c(i_y_c),
                      .o_r(o_r),
                      .o_c(o_c),
                      .o_valid(o_valid),
                      .o_ready_x(o_ready_x),
                      .o_ready_y(o_ready_y)
);

initial i_clk = 0;
initial forever #10 i_clk = ~i_clk;

reg [11:0] s_real [511:0];
reg [11:0] s_imag [511:0];
reg [24:0] cov_real [7:0];
reg [24:0] cov_imag [7:0];

integer f_real,f_imag;
initial begin
    f_real = $fopen("E:/GitHub/doa_tuil/matlab/dataset/covariance_matrix_real_hw.txt","w");
    f_imag = $fopen("E:/GitHub/doa_tuil/matlab/dataset/covariance_matrix_imag_hw.txt","w");
end



wire latch_end;

d_latch inst_latch_end(.d(1'b1),
                       .en(x_idx_last && y_idx_last && i_x_last && i_y_last),
                       .rstn(1'b1),
                       .q(latch_end));

wire [30:0] o_r_fwrite,o_c_fwrite;

assign o_r_fwrite = {{$clog2(time_lim){o_r[30]}},o_r} >>> $clog2(time_lim);
assign o_c_fwrite = {{$clog2(time_lim){o_c[30]}},o_c} >>> $clog2(time_lim);

always @ (posedge i_clk, negedge i_reset) begin
    if (~i_reset) begin
        $display("Reset...");
    end
    else if (latch_end && o_valid) begin
        $fwrite(f_real,"%h\n",o_r_fwrite);
        $fwrite(f_imag,"%h\n",o_c_fwrite);
        $fclose(f_real);
        $fclose(f_imag);
        $finish();
    end
    else if (o_valid) begin
        $fwrite(f_real,"%h\n",o_r_fwrite);
        $fwrite(f_imag,"%h\n",o_c_fwrite);
    end
end

// always @ (posedge i_clk, negedge i_reset) begin
//     if (~i_reset) begin
//         $display("Reset...");
//     end
//     else if (o_valid) begin
//         $fwrite(f_real,"%h\n",o_r_fwrite);
//         $fwrite(f_imag,"%h\n",o_c_fwrite);
//     end
//     else if (x_idx_last && y_idx_last && i_x_last && i_y_last) begin
//         $fclose(f_real);
//         $fclose(f_imag);
//         $finish();
//     end
// end


initial begin 
    $readmemh("E:/GitHub/doa_tuil/matlab/dataset/baseband_source_real.txt",s_real);
    $readmemh("E:/GitHub/doa_tuil/matlab/dataset/baseband_source_imag.txt",s_imag);
end

initial begin
    i_reset = 1;
    #2;
    i_reset = 0;
    #5;
    i_reset = 1;
end

assign i_x_valid = (counter_state == compute);
assign i_y_valid = (counter_state == compute);


// Memory Indexing for Data Operands
always @ (*) begin
    i_x_r = s_real[time_idx + {time_lim * x_idx}];
    i_x_c = s_imag[time_idx + {time_lim * x_idx}];

    i_y_r = s_real[time_idx + {time_lim * y_idx}];
    i_y_c = ~s_imag[time_idx + {time_lim * y_idx}] + 1;

end


// State Machine for Controlling Counters 

always @ (*) begin
    case({x_idx_last,y_idx_last,i_x_last,i_y_last})
    4'b0000: counter_n_state = compute;
    4'b0011: counter_n_state = inc_y;
    4'b0111: counter_n_state = inc_x;
    4'b1111: counter_n_state = ready;
    default: counter_n_state = compute;
    endcase
end

always @ (posedge i_clk, negedge i_reset) begin
    if (~i_reset) begin
        counter_state <= ready;
    end
    else begin
        counter_state <= counter_n_state;
    end
end


// Counter for Memory Indexing Sensor Data


always @ (posedge i_clk, negedge i_reset) begin
    if (~i_reset) begin
        x_idx <= 0;
    end
    else begin
        if      (counter_state == inc_x & (o_ready_x & o_ready_y)) x_idx <=  x_idx + 1;
        else if (counter_state == ready) x_idx <= 0;
        else                             x_idx <= x_idx;
    end
end

always @ (posedge i_clk, negedge i_reset) begin
    if (~i_reset) begin
        y_idx <= 0;
    end
    else begin
        if      (counter_state == inc_y & (o_ready_x & o_ready_y)) y_idx <=  y_idx + 1;
        else if (counter_state == inc_x) y_idx <=  x_idx + 1;
        else if (counter_state == ready) y_idx <= 0;
        else                             y_idx <= y_idx;
    end
end

assign y_idx_last = (y_idx == anta_lim -1);
assign x_idx_last = (x_idx == anta_lim -1);

// Counter for Memory Indexing Timestamps per Sensor Data

always @ (posedge i_clk, negedge i_reset) begin
    if (~i_reset) begin
        time_idx <= 0;
    end
    else begin
        if (o_ready_x & o_ready_y)  time_idx <= (counter_state != compute) ? 0: time_idx + 1;
    end
end

assign i_x_last = (time_idx == time_lim - 1);
assign i_y_last = (time_idx == time_lim - 1);


endmodule 