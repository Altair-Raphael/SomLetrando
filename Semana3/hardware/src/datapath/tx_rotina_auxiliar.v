module tx_rotina_auxiliar ( //LETRA / PALAVRA INTEIRA
    input        clock,
    input        reset,
    input        ajuda,
    input        modo_escolhido,
    input        evento_jogada_parcial,
    input  [6:0] jogada_parcial_decodificada,
    input  [6:0] letra_atual,
    input  [3:0] palavra_base,
    input        tx_busy,
    input        tx_ready,
    input        tx_aux_start_ack,
    output       tx_aux_start_req,
    output [6:0] tx_aux_data
);
    parameter inicial                         = 4'd0;
    parameter solicita_caractere              = 4'd1;
    parameter espera_fim_caractere            = 4'd2;
    parameter ajuda_palavra_inicializa        = 4'd3;
    parameter ajuda_palavra_espera_rom        = 4'd4;
    parameter ajuda_palavra_verifica          = 4'd5;
    parameter ajuda_palavra_solicita_caractere= 4'd6;
    parameter ajuda_palavra_espera_fim        = 4'd7;

    reg [3:0] estado;
    reg       pend_parcial;
    reg       pend_ajuda;
    reg [6:0] dado_char;
    reg [3:0] endereco_ajuda;

    wire ajuda_pulso;
    wire [6:0] letra_ajuda;

    edge_detector detector_borda_ajuda (
      .clock (clock),
      .reset (reset),
      .sinal (ajuda),
      .pulso (ajuda_pulso)
    );

    sync_rom_32x4 rom_palavras_ajuda (
      .clock (clock),
      .address ({1'b0, endereco_ajuda}),
      .data_out (letra_ajuda)
    );

    assign tx_aux_start_req = (estado == solicita_caractere) || (estado == ajuda_palavra_solicita_caractere);
    assign tx_aux_data = (estado == ajuda_palavra_solicita_caractere) ? letra_ajuda : dado_char;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            estado <= inicial;
            pend_parcial <= 1'b0;
            pend_ajuda <= 1'b0;
            dado_char <= 7'b0000000;
            endereco_ajuda <= 4'b0000;
        end else begin
            if (evento_jogada_parcial)
                pend_parcial <= 1'b1;

            if (ajuda_pulso)
                pend_ajuda <= 1'b1;

            case (estado)
                inicial: begin
                    if (pend_ajuda && !tx_busy) begin
                        if (modo_escolhido) begin
                           // Modo dificil: ajuda envia a palavra inteira (sem o terminador 0000000).
									 endereco_ajuda <= palavra_base;
                            estado <= ajuda_palavra_inicializa;
                        end else begin
									// Modo facil: ajuda envia somente a letra atual.
                            dado_char <= letra_atual;
                            estado <= solicita_caractere;
                        end
                    end else if (pend_parcial && !tx_busy) begin
                        dado_char <= jogada_parcial_decodificada;
                        estado <= solicita_caractere;
                    end
                end

                solicita_caractere: begin
                    if (tx_aux_start_ack)
                        estado <= espera_fim_caractere;
                end

                espera_fim_caractere: begin
                    if (tx_ready) begin
                        if (pend_ajuda)
                            pend_ajuda <= 1'b0;
                        else if (pend_parcial)
                            pend_parcial <= 1'b0;
                        estado <= inicial;
                    end
                end

                ajuda_palavra_inicializa: begin
                    estado <= ajuda_palavra_espera_rom;
                end

                ajuda_palavra_espera_rom: begin
                    estado <= ajuda_palavra_verifica;
                end

                ajuda_palavra_verifica: begin
                    if (letra_ajuda == 7'b0000000) begin
                        pend_ajuda <= 1'b0;
                        estado <= inicial;
                    end else if (!tx_busy) begin
                        estado <= ajuda_palavra_solicita_caractere;
                    end
                end

                ajuda_palavra_solicita_caractere: begin
                    if (tx_aux_start_ack)
                        estado <= ajuda_palavra_espera_fim;
                end

                ajuda_palavra_espera_fim: begin
                    if (tx_ready) begin
                        endereco_ajuda <= endereco_ajuda + 1'b1;
                        estado <= ajuda_palavra_espera_rom;
                    end
                end

                default: begin
                    estado <= inicial;
                end
            endcase
        end
    end
endmodule
