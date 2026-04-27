module sync_rom_32x4 (clock, address, data_out);
    input            clock;
    input      [4:0] address;
    output reg [6:0] data_out; //letra em ascii

    always @ (posedge clock)
    begin
        case (address)
            // Palavra 0 (inicio em 0) //lab
            5'b00000: data_out = 7'b1101100; // 'l'
            5'b00001: data_out = 7'b1100001; // 'a'
            5'b00010: data_out = 7'b1100010; // 'b'
            5'b00011: data_out = 7'b0000000; // ' '

            // Palavra 1 (inicio em 4)
            5'b00100: data_out = 7'b1110011; // 's'
            5'b00101: data_out = 7'b1101001; // 'i'
            5'b00110: data_out = 7'b1101101; // 'm'
            5'b00111: data_out = 7'b0000000; // ' '

            // Palavra 2 (inicio em 8)
            5'b01000: data_out = 7'b1101100; // 'l'
            5'b01001: data_out = 7'b1100001; // 'a'
            5'b01010: data_out = 7'b1110010; // 'r'
            5'b01011: data_out = 7'b0000000; // ' '

            // Palavra 3 (inicio em 12)
            5'b01100: data_out = 7'b1100001; // 'a'
            5'b01101: data_out = 7'b1110011; // 's'
            5'b01110: data_out = 7'b1100001; // 'a'
            5'b01111: data_out = 7'b0000000; // ' '

            // Espaco livre para futuras palavras
            5'b10000: data_out = 7'b0000000; // ' '
            5'b10001: data_out = 7'b0000000; // ' '
            5'b10010: data_out = 7'b0000000; // ' '
            5'b10011: data_out = 7'b0000000; // ' '
            5'b10100: data_out = 7'b0000000; // ' '
            5'b10101: data_out = 7'b0000000; // ' '
            5'b10110: data_out = 7'b0000000; // ' '
            5'b10111: data_out = 7'b0000000; // ' '
            5'b11000: data_out = 7'b0000000; // ' '
            5'b11001: data_out = 7'b0000000; // ' '
            5'b11010: data_out = 7'b0000000; // ' '
            5'b11011: data_out = 7'b0000000; // ' '
            5'b11100: data_out = 7'b0000000; // ' '
            5'b11101: data_out = 7'b0000000; // ' '
            5'b11110: data_out = 7'b0000000; // ' '
            5'b11111: data_out = 7'b0000000; // ' '

            default:  data_out = 7'b0000000; // ' '
        endcase
    end
endmodule