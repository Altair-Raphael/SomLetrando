module debounce #(
    parameter [19:0] tempo_debounce = 20'd999_999
)(
    input clk,
    input reset,
    input entrada,
    output reg saida
);

    reg [19:0] counter = 20'd0;
    reg btn_sync_0 = 1'b0;
    reg btn_sync_1 = 1'b0;

    // Sincroniza o botao no clock
    always @(posedge clk) begin
        if (reset) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
        end else begin
            btn_sync_0 <= entrada;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // Debounce: troca a saida apenas se mantiver estavel por tempo_debounce ciclos
    always @(posedge clk) begin
        if (reset) begin
            saida <= 1'b0;
            counter <= 20'd0;
        end else begin
            if (btn_sync_1 == saida) begin
                counter <= 20'd0;
            end else begin
                if (counter >= tempo_debounce) begin
                    saida <= btn_sync_1;
                    counter <= 20'd0;
                end else begin
                    counter <= counter + 20'd1;
                end
            end
        end
    end

endmodule