`timescale 1ns/1ns

module tb_debounce;
    reg clock_in   = 1'b1;
    reg entrada_in = 1'b0;
    wire saida_out;

    parameter clockPeriod    = 20;
    parameter debounce_ticks = 4;

    reg [31:0] caso = 0;

    wire [19:0] counter_out;
    wire        btn_sync_0_out;
    wire        btn_sync_1_out;

    always #((clockPeriod / 2)) clock_in = ~clock_in;

    debounce #(
        .tempo_debounce(debounce_ticks)
    ) dut (
        .clk    (clock_in),
        .entrada(entrada_in),
        .saida  (saida_out)
    );

    assign counter_out    = dut.counter;
    assign btn_sync_0_out = dut.btn_sync_0;
    assign btn_sync_1_out = dut.btn_sync_1;

    initial begin
        caso = 0;
        entrada_in = 1'b0;
        #(5*clockPeriod);

        caso = 1;
        @(negedge clock_in);
        entrada_in = 1'b1;
        #(clockPeriod/2);
        entrada_in = 1'b0;
        #(clockPeriod/2);
        entrada_in = 1'b1;
        #(clockPeriod/2);
        entrada_in = 1'b0;
        #(clockPeriod/2);


        caso = 2;
        @(negedge clock_in);
        entrada_in = 1'b1;
        #(7*clockPeriod);


        caso = 3;
        @(negedge clock_in);
        entrada_in = 1'b0;
        #(clockPeriod/2);
        entrada_in = 1'b1;
        #(clockPeriod/2);
        entrada_in = 1'b0;
        #(clockPeriod/2);
        entrada_in = 1'b1;
        #(clockPeriod/2);


        caso = 4;
        @(negedge clock_in);
        entrada_in = 1'b0;
        #(7*clockPeriod);


        caso = 99;
        #(5*clockPeriod);
        $stop;
    end
endmodule
