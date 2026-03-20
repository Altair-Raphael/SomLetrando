module mux_4_n #(parameter bits = 1) (
    input       [bits-1:0] sinal_0,
    input       [bits-1:0] sinal_1,
    input       [bits-1:0] sinal_2,
    input       [bits-1:0] sinal_3,
    input       [1:0]      sel,
    output      [bits-1:0] saida
);

wire [bits-1:0] saida_0;
wire [bits-1:0] saida_1;

mux_n #(.bits(bits)) mux_0 (
    .sinal_1    (sinal_0),
    .sinal_2    (sinal_1),
    .sel        (sel[0]),
    .saida      (saida_0)
);

mux_n #(.bits(bits)) mux_1 (
    .sinal_1    (sinal_2),
    .sinal_2    (sinal_3),
    .sel        (sel[0]),
    .saida      (saida_1)
);

mux_n #(.bits(bits)) mux_2 (
    .sinal_1    (saida_0),
    .sinal_2    (saida_1),
    .sel        (sel[1]),
    .saida      (saida)
);

endmodule