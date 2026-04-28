module registrador_3 (
    input        clock,
    input        clear,
    input        enable,
    input  [2:0] D,
    output [2:0] Q
);

    reg [2:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule
