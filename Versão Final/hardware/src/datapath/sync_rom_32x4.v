module sync_rom_32x4 (clock, address, data_out);
    input            clock;
    input      [7:0] address;
    output reg [6:0] data_out; //letra em ascii
    always @ (posedge clock)
    begin
        case (address)
            // Palavra 0: bola
            8'd0: data_out <= 7'b1100010;   // b
            8'd1: data_out <= 7'b1101111;   // o
            8'd2: data_out <= 7'b1101100;   // l
            8'd3: data_out <= 7'b1100001;   // a
            8'd4: data_out <= 7'b0000000;   // terminador

            // Palavra 1: casa
            8'd5: data_out <= 7'b1100011;   // c
            8'd6: data_out <= 7'b1100001;   // a
            8'd7: data_out <= 7'b1110011;   // s
            8'd8: data_out <= 7'b1100001;   // a
            8'd9: data_out <= 7'b0000000;   // terminador

            // Palavra 2: gato
            8'd10: data_out <= 7'b1100111;  // g
            8'd11: data_out <= 7'b1100001;  // a
            8'd12: data_out <= 7'b1110100;  // t
            8'd13: data_out <= 7'b1101111;  // o
            8'd14: data_out <= 7'b0000000;  // terminador

            // Palavra 3: pato
            8'd15: data_out <= 7'b1110000;  // p
            8'd16: data_out <= 7'b1100001;  // a
            8'd17: data_out <= 7'b1110100;  // t
            8'd18: data_out <= 7'b1101111;  // o
            8'd19: data_out <= 7'b0000000;  // terminador

            // Palavra 4: dado
            8'd20: data_out <= 7'b1100100;  // d
            8'd21: data_out <= 7'b1100001;  // a
            8'd22: data_out <= 7'b1100100;  // d
            8'd23: data_out <= 7'b1101111;  // o
            8'd24: data_out <= 7'b0000000;  // terminador

            // Palavra 5: fada
            8'd25: data_out <= 7'b1100110;  // f
            8'd26: data_out <= 7'b1100001;  // a
            8'd27: data_out <= 7'b1100100;  // d
            8'd28: data_out <= 7'b1100001;  // a
            8'd29: data_out <= 7'b0000000;  // terminador

            // Palavra 6: lobo
            8'd30: data_out <= 7'b1101100;  // l
            8'd31: data_out <= 7'b1101111;  // o
            8'd32: data_out <= 7'b1100010;  // b
            8'd33: data_out <= 7'b1101111;  // o
            8'd34: data_out <= 7'b0000000;  // terminador

            // Palavra 7: urso
            8'd35: data_out <= 7'b1110101;  // u
            8'd36: data_out <= 7'b1110010;  // r
            8'd37: data_out <= 7'b1110011;  // s
            8'd38: data_out <= 7'b1101111;  // o
            8'd39: data_out <= 7'b0000000;  // terminador

            // Palavra 8: sapo
            8'd40: data_out <= 7'b1110011;  // s
            8'd41: data_out <= 7'b1100001;  // a
            8'd42: data_out <= 7'b1110000;  // p
            8'd43: data_out <= 7'b1101111;  // o
            8'd44: data_out <= 7'b0000000;  // terminador

            // Palavra 9: vaca
            8'd45: data_out <= 7'b1110110;  // v
            8'd46: data_out <= 7'b1100001;  // a
            8'd47: data_out <= 7'b1100011;  // c
            8'd48: data_out <= 7'b1100001;  // a
            8'd49: data_out <= 7'b0000000;  // terminador

            // Palavra 10: leite
            8'd50: data_out <= 7'b1101100;  // l
            8'd51: data_out <= 7'b1100101;  // e
            8'd52: data_out <= 7'b1101001;  // i
            8'd53: data_out <= 7'b1110100;  // t
            8'd54: data_out <= 7'b1100101;  // e
            8'd55: data_out <= 7'b0000000;  // terminador

            // Palavra 11: suco
            8'd56: data_out <= 7'b1110011;  // s
            8'd57: data_out <= 7'b1110101;  // u
            8'd58: data_out <= 7'b1100011;  // c
            8'd59: data_out <= 7'b1101111;  // o
            8'd60: data_out <= 7'b0000000;  // terminador

            // Palavra 12: fruta
            8'd61: data_out <= 7'b1100110;  // f
            8'd62: data_out <= 7'b1110010;  // r
            8'd63: data_out <= 7'b1110101;  // u
            8'd64: data_out <= 7'b1110100;  // t
            8'd65: data_out <= 7'b1100001;  // a
            8'd66: data_out <= 7'b0000000;  // terminador

            // Palavra 13: massa
            8'd67: data_out <= 7'b1101101;  // m
            8'd68: data_out <= 7'b1100001;  // a
            8'd69: data_out <= 7'b1110011;  // s
            8'd70: data_out <= 7'b1110011;  // s
            8'd71: data_out <= 7'b1100001;  // a
            8'd72: data_out <= 7'b0000000;  // terminador

            // Palavra 14: beijo
            8'd73: data_out <= 7'b1100010;  // b
            8'd74: data_out <= 7'b1100101;  // e
            8'd75: data_out <= 7'b1101001;  // i
            8'd76: data_out <= 7'b1101010;  // j
            8'd77: data_out <= 7'b1101111;  // o
            8'd78: data_out <= 7'b0000000;  // terminador

            // Palavra 15: amigo
            8'd79: data_out <= 7'b1100001;  // a
            8'd80: data_out <= 7'b1101101;  // m
            8'd81: data_out <= 7'b1101001;  // i
            8'd82: data_out <= 7'b1100111;  // g
            8'd83: data_out <= 7'b1101111;  // o
            8'd84: data_out <= 7'b0000000;  // terminador

            // Palavra 16: amiga
            8'd85: data_out <= 7'b1100001;  // a
            8'd86: data_out <= 7'b1101101;  // m
            8'd87: data_out <= 7'b1101001;  // i
            8'd88: data_out <= 7'b1100111;  // g
            8'd89: data_out <= 7'b1100001;  // a
            8'd90: data_out <= 7'b0000000;  // terminador

            // Palavra 17: escola
            8'd91: data_out <= 7'b1100101;  // e
            8'd92: data_out <= 7'b1110011;  // s
            8'd93: data_out <= 7'b1100011;  // c
            8'd94: data_out <= 7'b1101111;  // o
            8'd95: data_out <= 7'b1101100;  // l
            8'd96: data_out <= 7'b1100001;  // a
            8'd97: data_out <= 7'b0000000;  // terminador

            // Palavra 18: livro
            8'd98: data_out <= 7'b1101100;  // l
            8'd99: data_out <= 7'b1101001;  // i
            8'd100: data_out <= 7'b1110110; // v
            8'd101: data_out <= 7'b1110010; // r
            8'd102: data_out <= 7'b1101111; // o
            8'd103: data_out <= 7'b0000000; // terminador

            // Palavra 19: caneta
            8'd104: data_out <= 7'b1100011; // c
            8'd105: data_out <= 7'b1100001; // a
            8'd106: data_out <= 7'b1101110; // n
            8'd107: data_out <= 7'b1100101; // e
            8'd108: data_out <= 7'b1110100; // t
            8'd109: data_out <= 7'b1100001; // a
            8'd110: data_out <= 7'b0000000; // terminador

            // Palavra 20: nuvem
            8'd111: data_out <= 7'b1101110; // n
            8'd112: data_out <= 7'b1110101; // u
            8'd113: data_out <= 7'b1110110; // v
            8'd114: data_out <= 7'b1100101; // e
            8'd115: data_out <= 7'b1101101; // m
            8'd116: data_out <= 7'b0000000; // terminador

            // Palavra 21: praia
            8'd117: data_out <= 7'b1110000; // p
            8'd118: data_out <= 7'b1110010; // r
            8'd119: data_out <= 7'b1100001; // a
            8'd120: data_out <= 7'b1101001; // i
            8'd121: data_out <= 7'b1100001; // a
            8'd122: data_out <= 7'b0000000; // terminador

            // Palavra 22: areia
            8'd123: data_out <= 7'b1100001; // a
            8'd124: data_out <= 7'b1110010; // r
            8'd125: data_out <= 7'b1100101; // e
            8'd126: data_out <= 7'b1101001; // i
            8'd127: data_out <= 7'b1100001; // a
            8'd128: data_out <= 7'b0000000; // terminador

            // Palavra 23: pipa
            8'd129: data_out <= 7'b1110000; // p
            8'd130: data_out <= 7'b1101001; // i
            8'd131: data_out <= 7'b1110000; // p
            8'd132: data_out <= 7'b1100001; // a
            8'd133: data_out <= 7'b0000000; // terminador

            // Palavra 24: boneca
            8'd134: data_out <= 7'b1100010; // b
            8'd135: data_out <= 7'b1101111; // o
            8'd136: data_out <= 7'b1101110; // n
            8'd137: data_out <= 7'b1100101; // e
            8'd138: data_out <= 7'b1100011; // c
            8'd139: data_out <= 7'b1100001; // a
            8'd140: data_out <= 7'b0000000; // terminador

            // Palavra 25: carro
            8'd141: data_out <= 7'b1100011; // c
            8'd142: data_out <= 7'b1100001; // a
            8'd143: data_out <= 7'b1110010; // r
            8'd144: data_out <= 7'b1110010; // r
            8'd145: data_out <= 7'b1101111; // o
            8'd146: data_out <= 7'b0000000; // terminador

            // Palavra 26: janela
            8'd147: data_out <= 7'b1101010; // j
            8'd148: data_out <= 7'b1100001; // a
            8'd149: data_out <= 7'b1101110; // n
            8'd150: data_out <= 7'b1100101; // e
            8'd151: data_out <= 7'b1101100; // l
            8'd152: data_out <= 7'b1100001; // a
            8'd153: data_out <= 7'b0000000; // terminador

            // Palavra 27: panela
            8'd154: data_out <= 7'b1110000; // p
            8'd155: data_out <= 7'b1100001; // a
            8'd156: data_out <= 7'b1101110; // n
            8'd157: data_out <= 7'b1100101; // e
            8'd158: data_out <= 7'b1101100; // l
            8'd159: data_out <= 7'b1100001; // a
            8'd160: data_out <= 7'b0000000; // terminador

            // Palavra 28: pirata
            8'd161: data_out <= 7'b1110000; // p
            8'd162: data_out <= 7'b1101001; // i
            8'd163: data_out <= 7'b1110010; // r
            8'd164: data_out <= 7'b1100001; // a
            8'd165: data_out <= 7'b1110100; // t
            8'd166: data_out <= 7'b1100001; // a
            8'd167: data_out <= 7'b0000000; // terminador

            // Palavra 29: parque
            8'd168: data_out <= 7'b1110000; // p
            8'd169: data_out <= 7'b1100001; // a
            8'd170: data_out <= 7'b1110010; // r
            8'd171: data_out <= 7'b1110001; // q
            8'd172: data_out <= 7'b1110101; // u
            8'd173: data_out <= 7'b1100101; // e
            8'd174: data_out <= 7'b0000000; // terminador

            // Palavra 30: tinta
            8'd175: data_out <= 7'b1110100; // t
            8'd176: data_out <= 7'b1101001; // i
            8'd177: data_out <= 7'b1101110; // n
            8'd178: data_out <= 7'b1110100; // t
            8'd179: data_out <= 7'b1100001; // a
            8'd180: data_out <= 7'b0000000; // terminador

            // Palavra 31: giz
            8'd181: data_out <= 7'b1100111; // g
            8'd182: data_out <= 7'b1101001; // i
            8'd183: data_out <= 7'b1111010; // z
            8'd184: data_out <= 7'b0000000; // terminador

            // Palavra 32: circo
            8'd185: data_out <= 7'b1100011; // c
            8'd186: data_out <= 7'b1101001; // i
            8'd187: data_out <= 7'b1110010; // r
            8'd188: data_out <= 7'b1100011; // c
            8'd189: data_out <= 7'b1101111; // o
            8'd190: data_out <= 7'b0000000; // terminador

            // Palavra 33: doce
            8'd191: data_out <= 7'b1100100; // d
            8'd192: data_out <= 7'b1101111; // o
            8'd193: data_out <= 7'b1100011; // c
            8'd194: data_out <= 7'b1100101; // e
            8'd195: data_out <= 7'b0000000; // terminador

            // Palavra 34: festa
            8'd196: data_out <= 7'b1100110; // f
            8'd197: data_out <= 7'b1100101; // e
            8'd198: data_out <= 7'b1110011; // s
            8'd199: data_out <= 7'b1110100; // t
            8'd200: data_out <= 7'b1100001; // a
            8'd201: data_out <= 7'b0000000; // terminador

            // Palavra 35: magia
            8'd202: data_out <= 7'b1101101; // m
            8'd203: data_out <= 7'b1100001; // a
            8'd204: data_out <= 7'b1100111; // g
            8'd205: data_out <= 7'b1101001; // i
            8'd206: data_out <= 7'b1100001; // a
            8'd207: data_out <= 7'b0000000; // terminador

            // Palavra 36: ninho
            8'd208: data_out <= 7'b1101110; // n
            8'd209: data_out <= 7'b1101001; // i
            8'd210: data_out <= 7'b1101110; // n
            8'd211: data_out <= 7'b1101000; // h
            8'd212: data_out <= 7'b1101111; // o
            8'd213: data_out <= 7'b0000000; // terminador

            // Palavra 37: brisa
            8'd214: data_out <= 7'b1100010; // b
            8'd215: data_out <= 7'b1110010; // r
            8'd216: data_out <= 7'b1101001; // i
            8'd217: data_out <= 7'b1110011; // s
            8'd218: data_out <= 7'b1100001; // a
            8'd219: data_out <= 7'b0000000; // terminador

            // Palavra 38: turma
            8'd220: data_out <= 7'b1110100; // t
            8'd221: data_out <= 7'b1110101; // u
            8'd222: data_out <= 7'b1110010; // r
            8'd223: data_out <= 7'b1101101; // m
            8'd224: data_out <= 7'b1100001; // a
            8'd225: data_out <= 7'b0000000; // terminador

            // Palavra 39: risada
            8'd226: data_out <= 7'b1110010; // r
            8'd227: data_out <= 7'b1101001; // i
            8'd228: data_out <= 7'b1110011; // s
            8'd229: data_out <= 7'b1100001; // a
            8'd230: data_out <= 7'b1100100; // d
            8'd231: data_out <= 7'b1100001; // a
            8'd232: data_out <= 7'b0000000; // terminador

            default: data_out <= 7'b0000000;
        endcase
    end
endmodule