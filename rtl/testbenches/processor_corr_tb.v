module processor_corr_tb();

reg i_clk,i_reset;
reg [11:0] i_x_r;
reg [11:0] i_x_c;
reg [11:0] i_y_r;
reg [11:0] i_y_c;
reg  i_x_valid,
     i_y_valid;
reg  i_x_last,
     i_y_last;
wire [24:0] o_r;
wire [24:0] o_c;
wire o_valid;
wire o_ready_x,
     o_ready_y;
processor_corr inst_processor_corr
                     (
                      .i_clk(i_clk),
                      .i_reset(i_reset),
                      .i_x_last(i_x_last),
                      .i_y_last(i_y_last),
                      .i_x_valid(1'b1),
                      .i_y_valid(1'b1),
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

reg [11:0] x_r [127:0];
reg [11:0] x_c [127:0];
reg [11:0] y_r [127:0];
reg [11:0] y_c [127:0];


initial begin 
    $readmemb(x_r,"../data/x_r.text");
    $readmemb(x_c,"../data/x_c.text");
    $readmemb(y_r,".w./data/y_r.text");
    $readmemb(y_c,"../data/y_c.text");
end

initial begin
    i_reset = 0;
    #10;
    i_reset = 1;
end

reg [6:0] mem_idx;

always @ (posedge i_clk, negedge i_resetn) begin
    if (i_resetn) begin
        mem_idx <= 0;
    end
    else begin
        mem_idx <= mem_idx + 1;
    end
end

assign i_x_last = (mem_idx == 127);
assign i_y_last = (mem_idx == 127);


endmodule 