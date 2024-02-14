module basic_testbench();

wire [7:0] o_c;
reg  [7:0] i_a,i_b;

basic_test inst_basic_test(  .i_a(i_a)
                            ,.i_b(i_b)
                            ,.o_c(o_c));


initial begin
    i_a = 0;
    i_b = 0;
    #10;
    i_a = 0;
    i_b = 1;
    #10;
    i_a = 2;
    i_b = 0;
    #10;
    i_a = 1;
    i_b = 2;
    #10;
    

end


endmodule 