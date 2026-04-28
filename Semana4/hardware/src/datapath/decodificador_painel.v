module decodificador_painel (
    input [6:0] botoes,
    input [3:0] palavra_selecionada,
    output reg [6:0] jogada_decodificada
);

always @* begin
    jogada_decodificada = 7'b0000000;

    case (palavra_selecionada)
        // Palavra 0 da ROM: "lab"
        4'b0000: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100101; // e
                7'b0000010: jogada_decodificada = 7'b1100010; // b
                7'b0000100: jogada_decodificada = 7'b1100011; // c
                7'b0001000: jogada_decodificada = 7'b1101100; // l
                7'b0010000: jogada_decodificada = 7'b1100110; // f
                7'b0100000: jogada_decodificada = 7'b1100100; // d
                7'b1000000: jogada_decodificada = 7'b1100001; // a
                default:    jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 1 da ROM: "sim"
        4'b0001: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110001; // q
                7'b0000010: jogada_decodificada = 7'b1101101; // m
                7'b0000100: jogada_decodificada = 7'b1101111; // o
                7'b0001000: jogada_decodificada = 7'b1110011; // s
                7'b0010000: jogada_decodificada = 7'b1101110; // n
                7'b0100000: jogada_decodificada = 7'b1101001; // i 
                7'b1000000: jogada_decodificada = 7'b1110000; // p
                default:    jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 2 da ROM: "lar"
        4'b0010: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1110101; // u
                7'b0000010: jogada_decodificada = 7'b1110010; // r
                7'b0000100: jogada_decodificada = 7'b1110011; // s
                7'b0001000: jogada_decodificada = 7'b1100001; // a
                7'b0010000: jogada_decodificada = 7'b1110110; // v
                7'b0100000: jogada_decodificada = 7'b1101100; // l
                7'b1000000: jogada_decodificada = 7'b1110100; // t
                default:    jogada_decodificada = 7'b0000000;
            endcase
        end

        // Palavra 3 da ROM: "asa"
        4'b0011: begin
            case (botoes)
                7'b0000001: jogada_decodificada = 7'b1100010; // b
                7'b0000010: jogada_decodificada = 7'b1100101; // e
                7'b0000100: jogada_decodificada = 7'b1110011; // s
                7'b0001000: jogada_decodificada = 7'b1100011; // c
                7'b0010000: jogada_decodificada = 7'b1100001; // a
                7'b0100000: jogada_decodificada = 7'b1100110; // f
                7'b1000000: jogada_decodificada = 7'b1100100; // d
                default:    jogada_decodificada = 7'b0000000;
            endcase
        end

        default: begin
            jogada_decodificada = 7'b0000000;
        end
    endcase
end

endmodule