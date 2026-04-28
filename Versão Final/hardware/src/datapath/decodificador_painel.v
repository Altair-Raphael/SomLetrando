module decodificador_painel (
    input [6:0] botoes,
    input [5:0] palavra_selecionada,
    output reg [6:0] jogada_decodificada
);

always @* begin
    jogada_decodificada = 7'b0000000;

    case (palavra_selecionada)
        // Palavra 0: bola
        6'd0: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100001; // a
                7'b0000010: jogada_decodificada = 7'b1100010; // b
                7'b0000100: jogada_decodificada = 7'b1101001; // i
                7'b0001000: jogada_decodificada = 7'b1101100; // l
                7'b0010000: jogada_decodificada = 7'b1110010; // r
                7'b0100000: jogada_decodificada = 7'b1101111; // o
                7'b1000000: jogada_decodificada = 7'b1100101; // e
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 1: casa
        6'd1: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110011; // s
                7'b0000010: jogada_decodificada = 7'b1110010; // r
                7'b0000100: jogada_decodificada = 7'b1100001; // a
                7'b0001000: jogada_decodificada = 7'b1100101; // e
                7'b0010000: jogada_decodificada = 7'b1100011; // c
                7'b0100000: jogada_decodificada = 7'b1101001; // i
                7'b1000000: jogada_decodificada = 7'b1101111; // o
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 2: gato
        6'd2: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101001; // i
                7'b0000010: jogada_decodificada = 7'b1100001; // a
                7'b0000100: jogada_decodificada = 7'b1110010; // r
                7'b0001000: jogada_decodificada = 7'b1100111; // g
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1100101; // e
                7'b1000000: jogada_decodificada = 7'b1110100; // t
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 3: pato
        6'd3: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100101; // e
                7'b0000010: jogada_decodificada = 7'b1110100; // t
                7'b0000100: jogada_decodificada = 7'b1110000; // p
                7'b0001000: jogada_decodificada = 7'b1110010; // r
                7'b0010000: jogada_decodificada = 7'b1100001; // a
                7'b0100000: jogada_decodificada = 7'b1101111; // o
                7'b1000000: jogada_decodificada = 7'b1101001; // i
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 4: dado
        6'd4: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110011; // s
                7'b0000010: jogada_decodificada = 7'b1100101; // e
                7'b0000100: jogada_decodificada = 7'b1100001; // a
                7'b0001000: jogada_decodificada = 7'b1110010; // r
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1100100; // d
                7'b1000000: jogada_decodificada = 7'b1101001; // i
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 5: fada
        6'd5: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100001; // a
                7'b0000010: jogada_decodificada = 7'b1101001; // i
                7'b0000100: jogada_decodificada = 7'b1101111; // o
                7'b0001000: jogada_decodificada = 7'b1100110; // f
                7'b0010000: jogada_decodificada = 7'b1100101; // e
                7'b0100000: jogada_decodificada = 7'b1110010; // r
                7'b1000000: jogada_decodificada = 7'b1100100; // d
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 6: lobo
        6'd6: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101100; // l
                7'b0000010: jogada_decodificada = 7'b1100101; // e
                7'b0000100: jogada_decodificada = 7'b1100010; // b
                7'b0001000: jogada_decodificada = 7'b1110010; // r
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1100001; // a
                7'b1000000: jogada_decodificada = 7'b1101001; // i
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 7: urso
        6'd7: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100101; // e
                7'b0000010: jogada_decodificada = 7'b1110011; // s
                7'b0000100: jogada_decodificada = 7'b1101001; // i
                7'b0001000: jogada_decodificada = 7'b1110010; // r
                7'b0010000: jogada_decodificada = 7'b1100001; // a
                7'b0100000: jogada_decodificada = 7'b1110101; // u
                7'b1000000: jogada_decodificada = 7'b1101111; // o
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 8: sapo
        6'd8: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101111; // o
                7'b0000010: jogada_decodificada = 7'b1110010; // r
                7'b0000100: jogada_decodificada = 7'b1110011; // s
                7'b0001000: jogada_decodificada = 7'b1100101; // e
                7'b0010000: jogada_decodificada = 7'b1100001; // a
                7'b0100000: jogada_decodificada = 7'b1101001; // i
                7'b1000000: jogada_decodificada = 7'b1110000; // p
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 9: vaca
        6'd9: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100011; // c
                7'b0000010: jogada_decodificada = 7'b1100101; // e
                7'b0000100: jogada_decodificada = 7'b1100001; // a
                7'b0001000: jogada_decodificada = 7'b1110010; // r
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1110110; // v
                7'b1000000: jogada_decodificada = 7'b1101001; // i
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 10: leite
        6'd10: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110010; // r
                7'b0000010: jogada_decodificada = 7'b1100101; // e
                7'b0000100: jogada_decodificada = 7'b1100001; // a
                7'b0001000: jogada_decodificada = 7'b1101100; // l
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1101001; // i
                7'b1000000: jogada_decodificada = 7'b1110100; // t
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 11: suco
        6'd11: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110011; // s
                7'b0000010: jogada_decodificada = 7'b1101111; // o
                7'b0000100: jogada_decodificada = 7'b1100101; // e
                7'b0001000: jogada_decodificada = 7'b1100011; // c
                7'b0010000: jogada_decodificada = 7'b1101001; // i
                7'b0100000: jogada_decodificada = 7'b1110101; // u
                7'b1000000: jogada_decodificada = 7'b1100001; // a
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 12: fruta
        6'd12: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100001; // a
                7'b0000010: jogada_decodificada = 7'b1100110; // f
                7'b0000100: jogada_decodificada = 7'b1110101; // u
                7'b0001000: jogada_decodificada = 7'b1101111; // o
                7'b0010000: jogada_decodificada = 7'b1110010; // r
                7'b0100000: jogada_decodificada = 7'b1100101; // e
                7'b1000000: jogada_decodificada = 7'b1110100; // t
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 13: massa
        6'd13: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100001; // a
                7'b0000010: jogada_decodificada = 7'b1110010; // r
                7'b0000100: jogada_decodificada = 7'b1101111; // o
                7'b0001000: jogada_decodificada = 7'b1100101; // e
                7'b0010000: jogada_decodificada = 7'b1101101; // m
                7'b0100000: jogada_decodificada = 7'b1110011; // s
                7'b1000000: jogada_decodificada = 7'b1101001; // i
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 14: beijo
        6'd14: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100001; // a
                7'b0000010: jogada_decodificada = 7'b1101001; // i
                7'b0000100: jogada_decodificada = 7'b1100010; // b
                7'b0001000: jogada_decodificada = 7'b1110010; // r
                7'b0010000: jogada_decodificada = 7'b1101010; // j
                7'b0100000: jogada_decodificada = 7'b1100101; // e
                7'b1000000: jogada_decodificada = 7'b1101111; // o
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 15: amigo
        6'd15: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100111; // g
                7'b0000010: jogada_decodificada = 7'b1100101; // e
                7'b0000100: jogada_decodificada = 7'b1101101; // m
                7'b0001000: jogada_decodificada = 7'b1100001; // a
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1110010; // r
                7'b1000000: jogada_decodificada = 7'b1101001; // i
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 16: amiga
        6'd16: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110010; // r
                7'b0000010: jogada_decodificada = 7'b1100001; // a
                7'b0000100: jogada_decodificada = 7'b1100101; // e
                7'b0001000: jogada_decodificada = 7'b1101001; // i
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1101101; // m
                7'b1000000: jogada_decodificada = 7'b1100111; // g
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 17: escola
        6'd17: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100011; // c
                7'b0000010: jogada_decodificada = 7'b1100001; // a
                7'b0000100: jogada_decodificada = 7'b1101001; // i
                7'b0001000: jogada_decodificada = 7'b1110011; // s
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1101100; // l
                7'b1000000: jogada_decodificada = 7'b1100101; // e
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 18: livro
        6'd18: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101111; // o
                7'b0000010: jogada_decodificada = 7'b1101001; // i
                7'b0000100: jogada_decodificada = 7'b1110010; // r
                7'b0001000: jogada_decodificada = 7'b1100101; // e
                7'b0010000: jogada_decodificada = 7'b1101100; // l
                7'b0100000: jogada_decodificada = 7'b1100001; // a
                7'b1000000: jogada_decodificada = 7'b1110110; // v
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 19: caneta
        6'd19: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100011; // c
                7'b0000010: jogada_decodificada = 7'b1101001; // i
                7'b0000100: jogada_decodificada = 7'b1101110; // n
                7'b0001000: jogada_decodificada = 7'b1110100; // t
                7'b0010000: jogada_decodificada = 7'b1100001; // a
                7'b0100000: jogada_decodificada = 7'b1100101; // e
                7'b1000000: jogada_decodificada = 7'b1101111; // o
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 20: nuvem
        6'd20: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100001; // a
                7'b0000010: jogada_decodificada = 7'b1100101; // e
                7'b0000100: jogada_decodificada = 7'b1101110; // n
                7'b0001000: jogada_decodificada = 7'b1110101; // u
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1110110; // v
                7'b1000000: jogada_decodificada = 7'b1101101; // m
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 21: praia
        6'd21: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110010; // r
                7'b0000010: jogada_decodificada = 7'b1101111; // o
                7'b0000100: jogada_decodificada = 7'b1100101; // e
                7'b0001000: jogada_decodificada = 7'b1101001; // i
                7'b0010000: jogada_decodificada = 7'b1100001; // a
                7'b0100000: jogada_decodificada = 7'b1110000; // p
                7'b1000000: jogada_decodificada = 7'b1110011; // s
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 22: areia
        6'd22: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101110; // n
                7'b0000010: jogada_decodificada = 7'b1100101; // e
                7'b0000100: jogada_decodificada = 7'b1101111; // o
                7'b0001000: jogada_decodificada = 7'b1100001; // a
                7'b0010000: jogada_decodificada = 7'b1110011; // s
                7'b0100000: jogada_decodificada = 7'b1101001; // i
                7'b1000000: jogada_decodificada = 7'b1110010; // r
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 23: pipa
        6'd23: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101111; // o
                7'b0000010: jogada_decodificada = 7'b1110000; // p
                7'b0000100: jogada_decodificada = 7'b1110011; // s
                7'b0001000: jogada_decodificada = 7'b1110010; // r
                7'b0010000: jogada_decodificada = 7'b1101001; // i
                7'b0100000: jogada_decodificada = 7'b1100101; // e
                7'b1000000: jogada_decodificada = 7'b1100001; // a
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 24: boneca
        6'd24: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101110; // n
                7'b0000010: jogada_decodificada = 7'b1101001; // i
                7'b0000100: jogada_decodificada = 7'b1101111; // o
                7'b0001000: jogada_decodificada = 7'b1100101; // e
                7'b0010000: jogada_decodificada = 7'b1100011; // c
                7'b0100000: jogada_decodificada = 7'b1100010; // b
                7'b1000000: jogada_decodificada = 7'b1100001; // a
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 25: carro
        6'd25: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100101; // e
                7'b0000010: jogada_decodificada = 7'b1100001; // a
                7'b0000100: jogada_decodificada = 7'b1101001; // i
                7'b0001000: jogada_decodificada = 7'b1110010; // r
                7'b0010000: jogada_decodificada = 7'b1100011; // c
                7'b0100000: jogada_decodificada = 7'b1110011; // s
                7'b1000000: jogada_decodificada = 7'b1101111; // o
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 26: janela
        6'd26: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101010; // j
                7'b0000010: jogada_decodificada = 7'b1101111; // o
                7'b0000100: jogada_decodificada = 7'b1100101; // e
                7'b0001000: jogada_decodificada = 7'b1101001; // i
                7'b0010000: jogada_decodificada = 7'b1101110; // n
                7'b0100000: jogada_decodificada = 7'b1100001; // a
                7'b1000000: jogada_decodificada = 7'b1101100; // l
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 27: panela
        6'd27: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101001; // i
                7'b0000010: jogada_decodificada = 7'b1100101; // e
                7'b0000100: jogada_decodificada = 7'b1101110; // n
                7'b0001000: jogada_decodificada = 7'b1100001; // a
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1101100; // l
                7'b1000000: jogada_decodificada = 7'b1110000; // p
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 28: pirata
        6'd28: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101001; // i
                7'b0000010: jogada_decodificada = 7'b1110000; // p
                7'b0000100: jogada_decodificada = 7'b1110100; // t
                7'b0001000: jogada_decodificada = 7'b1101111; // o
                7'b0010000: jogada_decodificada = 7'b1100001; // a
                7'b0100000: jogada_decodificada = 7'b1110010; // r
                7'b1000000: jogada_decodificada = 7'b1100101; // e
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 29: parque
        6'd29: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100101; // e
                7'b0000010: jogada_decodificada = 7'b1110101; // u
                7'b0000100: jogada_decodificada = 7'b1101111; // o
                7'b0001000: jogada_decodificada = 7'b1110000; // p
                7'b0010000: jogada_decodificada = 7'b1110010; // r
                7'b0100000: jogada_decodificada = 7'b1100001; // a
                7'b1000000: jogada_decodificada = 7'b1110001; // q
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 30: tinta
        6'd30: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100001; // a
                7'b0000010: jogada_decodificada = 7'b1101110; // n
                7'b0000100: jogada_decodificada = 7'b1101001; // i
                7'b0001000: jogada_decodificada = 7'b1101111; // o
                7'b0010000: jogada_decodificada = 7'b1110010; // r
                7'b0100000: jogada_decodificada = 7'b1100101; // e
                7'b1000000: jogada_decodificada = 7'b1110100; // t
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 31: giz
        6'd31: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100111; // g
                7'b0000010: jogada_decodificada = 7'b1110010; // r
                7'b0000100: jogada_decodificada = 7'b1100101; // e
                7'b0001000: jogada_decodificada = 7'b1100001; // a
                7'b0010000: jogada_decodificada = 7'b1101001; // i
                7'b0100000: jogada_decodificada = 7'b1101111; // o
                7'b1000000: jogada_decodificada = 7'b1111010; // z
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 32: circo
        6'd32: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110010; // r
                7'b0000010: jogada_decodificada = 7'b1101001; // i
                7'b0000100: jogada_decodificada = 7'b1100011; // c
                7'b0001000: jogada_decodificada = 7'b1110011; // s
                7'b0010000: jogada_decodificada = 7'b1100001; // a
                7'b0100000: jogada_decodificada = 7'b1101111; // o
                7'b1000000: jogada_decodificada = 7'b1100101; // e
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 33: doce
        6'd33: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100001; // a
                7'b0000010: jogada_decodificada = 7'b1101001; // i
                7'b0000100: jogada_decodificada = 7'b1100011; // c
                7'b0001000: jogada_decodificada = 7'b1101111; // o
                7'b0010000: jogada_decodificada = 7'b1100101; // e
                7'b0100000: jogada_decodificada = 7'b1110010; // r
                7'b1000000: jogada_decodificada = 7'b1100100; // d
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 34: festa
        6'd34: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101001; // i
                7'b0000010: jogada_decodificada = 7'b1100110; // f
                7'b0000100: jogada_decodificada = 7'b1110100; // t
                7'b0001000: jogada_decodificada = 7'b1110011; // s
                7'b0010000: jogada_decodificada = 7'b1101111; // o
                7'b0100000: jogada_decodificada = 7'b1100101; // e
                7'b1000000: jogada_decodificada = 7'b1100001; // a
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 35: magia
        6'd35: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100001; // a
                7'b0000010: jogada_decodificada = 7'b1101001; // i
                7'b0000100: jogada_decodificada = 7'b1101111; // o
                7'b0001000: jogada_decodificada = 7'b1101101; // m
                7'b0010000: jogada_decodificada = 7'b1100111; // g
                7'b0100000: jogada_decodificada = 7'b1100101; // e
                7'b1000000: jogada_decodificada = 7'b1110010; // r
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 36: ninho
        6'd36: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100101; // e
                7'b0000010: jogada_decodificada = 7'b1110010; // r
                7'b0000100: jogada_decodificada = 7'b1101001; // i
                7'b0001000: jogada_decodificada = 7'b1101000; // h
                7'b0010000: jogada_decodificada = 7'b1101110; // n
                7'b0100000: jogada_decodificada = 7'b1100001; // a
                7'b1000000: jogada_decodificada = 7'b1101111; // o
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 37: brisa
        6'd37: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100010; // b
                7'b0000010: jogada_decodificada = 7'b1101001; // i
                7'b0000100: jogada_decodificada = 7'b1100101; // e
                7'b0001000: jogada_decodificada = 7'b1110011; // s
                7'b0010000: jogada_decodificada = 7'b1100001; // a
                7'b0100000: jogada_decodificada = 7'b1110010; // r
                7'b1000000: jogada_decodificada = 7'b1101111; // o
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 38: turma
        6'd38: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1101101; // m
                7'b0000010: jogada_decodificada = 7'b1100001; // a
                7'b0000100: jogada_decodificada = 7'b1101111; // o
                7'b0001000: jogada_decodificada = 7'b1110101; // u
                7'b0010000: jogada_decodificada = 7'b1110100; // t
                7'b0100000: jogada_decodificada = 7'b1100101; // e
                7'b1000000: jogada_decodificada = 7'b1110010; // r
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 39: risada
        6'd39: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110011; // s
                7'b0000010: jogada_decodificada = 7'b1101111; // o
                7'b0000100: jogada_decodificada = 7'b1110010; // r
                7'b0001000: jogada_decodificada = 7'b1100100; // d
                7'b0010000: jogada_decodificada = 7'b1100101; // e
                7'b0100000: jogada_decodificada = 7'b1100001; // a
                7'b1000000: jogada_decodificada = 7'b1101001; // i
                default: jogada_decodificada = 7'b0000000;
            endcase
        end

        default: begin
            jogada_decodificada = 7'b0000000;
        end
    endcase
end

endmodule
