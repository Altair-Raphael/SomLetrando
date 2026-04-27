module sync_rom_32x4 (clock, address, data_out);
    input            clock;
    input      [4:0] address;
    output reg [7:0] data_out; //letra em ascii

    always @ (posedge clock)
    begin
        case (address)
            // Palavra 0 (inicio em 0) //labd
            5'b00000: data_out = 8'b01101100; // 'l'
            5'b00001: data_out = 8'b01100001; // 'a'
            5'b00010: data_out = 8'b01100010; // 'b'
            5'b00011: data_out = 8'b00000000; // ' '

            // Palavra 1 (inicio em 4)
            5'b00100: data_out = 8'b01100110; // 'f'
            5'b00101: data_out = 8'b01101010; // 'j'
            5'b00110: data_out = 8'b01110000; // 'p'
            5'b00111: data_out = 8'b00000000; // ' '

            // Palavra 2 (inicio em 8)
            5'b01000: data_out = 8'b00000010; // '2'
            5'b01001: data_out = 8'b00000111; // '7'
            5'b01010: data_out = 8'b00011110; // 'e'
            5'b01011: data_out = 8'b00000000; // ' '

            // Palavra 3 (inicio em 12)
            5'b01100: data_out = 8'b00000100; // '4'
            5'b01101: data_out = 8'b00001000; // '8'
            5'b01110: data_out = 8'b00001101; // 'd'
            5'b01111: data_out = 8'b00000000; // ' '

            // Espaco livre para futuras palavras
            5'b10000: data_out = 8'b00000000; // ' '
            5'b10001: data_out = 8'b00000000; // ' '
            5'b10010: data_out = 8'b00000000; // ' '
            5'b10011: data_out = 8'b00000000; // ' '
            5'b10100: data_out = 8'b00000000; // ' '
            5'b10101: data_out = 8'b00000000; // ' '
            5'b10110: data_out = 8'b00000000; // ' '
            5'b10111: data_out = 8'b00000000; // ' '
            5'b11000: data_out = 8'b00000000; // ' '
            5'b11001: data_out = 8'b00000000; // ' '
            5'b11010: data_out = 8'b00000000; // ' '
            5'b11011: data_out = 8'b00000000; // ' '
            5'b11100: data_out = 8'b00000000; // ' '
            5'b11101: data_out = 8'b00000000; // ' '
            5'b11110: data_out = 8'b00000000; // ' '
            5'b11111: data_out = 8'b00000000; // ' '

            default:  data_out = 8'b00000000; // ' '
        endcase
    end
endmodule