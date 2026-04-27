module sync_rom_4x4 (clock, address, data_out);
    input            clock;
    input      [1:0] address;
    output reg [3:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            // Ponteiros de inicio na ROM de palavras (sync_rom_32x4)
            2'b00: data_out = 4'b0000;
            2'b01: data_out = 4'b0100;
            2'b10: data_out = 4'b1000;
            2'b11: data_out = 4'b1100;
            default: data_out = 4'b0000;
        endcase
    end
endmodule
