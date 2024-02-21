module pipeline_stage #(parameter WIDTH = 8)
                        (
                            input i_clk,
                            input i_resetn,
                            input i_stall,
                            input i_clear,
                            input [WIDTH-1:0]  i_data,
                            output reg [WIDTH-1:0] o_data
                        );

always @ (posedge i_clk, negedge i_resetn) begin
    if (~i_resetn) begin
        o_data <= 0;
    end
    else begin
        if (i_stall) o_data <= o_data;
        else if (i_clear) o_data <= 0;
        else o_data <= i_data;
    end
end

endmodule 