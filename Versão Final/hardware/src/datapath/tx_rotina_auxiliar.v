module tx_rotina_auxiliar ( //LETRA / PALAVRA INTEIRA
    input        clock,
    input        reset,
    input        ajuda,
    input        modo_escolhido,
    input        evento_jogada_parcial,
    input        evento_reset,
    input        evento_jogar,
    input        evento_modo,
    input        evento_erro,
    input  [6:0] jogada_parcial_decodificada,
    input  [6:0] letra_atual,
    input  [7:0] palavra_base,
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

    parameter char_reset        = 7'b1011110; // '^'
    parameter char_jogar        = 7'b0101010; // '*'
    parameter char_modo_facil   = 7'b0111100; // '<'
    parameter char_modo_dificil = 7'b0111110; // '>'
    parameter char_erro         = 7'b1111110; // '~'
    parameter char_ajuda        = 7'b0111111; // '?'

    parameter src_nenhum  = 3'd0;
    parameter src_reset   = 3'd1;
    parameter src_jogar   = 3'd2;
    parameter src_erro    = 3'd3;
    parameter src_modo    = 3'd4;
    parameter src_ajuda   = 3'd5;
    parameter src_parcial = 3'd6;
    parameter src_ajuda_sinal = 3'd7;

    reg [3:0] estado;
    reg       pend_reset;
    reg       pend_jogar;
    reg       pend_parcial;
    reg       pend_ajuda;
    reg       pend_ajuda_sinal;
    reg       pend_modo;
    reg       pend_erro;
    reg       terminador_pendente;
    reg       ajuda_rom_ativa;
    reg [6:0] dado_char;
    reg [6:0] dado_ajuda;
    reg [7:0] endereco_ajuda;
    reg [2:0] fonte_envio;

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
            .address (endereco_ajuda),
      .data_out (letra_ajuda)
    );

    assign tx_aux_start_req = (estado == solicita_caractere) || (estado == ajuda_palavra_solicita_caractere);
    assign tx_aux_data = terminador_pendente ? 7'b0000000 : ((estado == solicita_caractere || estado == espera_fim_caractere) ? dado_char : dado_ajuda);

    task agenda_proximo;
    begin
        if (pend_reset && (fonte_envio != src_reset)) begin
            dado_char <= char_reset;
            fonte_envio <= src_reset;
            estado <= solicita_caractere;
        end else if (pend_jogar && (fonte_envio != src_jogar)) begin
            dado_char <= char_jogar;
            fonte_envio <= src_jogar;
            estado <= solicita_caractere;
        end else if (pend_erro && (fonte_envio != src_erro)) begin
            dado_char <= char_erro;
            fonte_envio <= src_erro;
            estado <= solicita_caractere;
        end else if (pend_modo && (fonte_envio != src_modo)) begin
            dado_char <= modo_escolhido ? char_modo_dificil : char_modo_facil;
            fonte_envio <= src_modo;
            estado <= solicita_caractere;
        end else if (pend_ajuda_sinal && (fonte_envio != src_ajuda_sinal)) begin
            dado_char <= char_ajuda;
            fonte_envio <= src_ajuda_sinal;
            estado <= solicita_caractere;
        end else if (pend_ajuda && (fonte_envio != src_ajuda)) begin
            if (modo_escolhido) begin
                pend_parcial <= 1'b0;
                ajuda_rom_ativa <= 1'b1;
                endereco_ajuda <= palavra_base;
                estado <= ajuda_palavra_inicializa;
            end else begin
                dado_char <= letra_atual;
                fonte_envio <= src_ajuda;
                ajuda_rom_ativa <= 1'b0;
                estado <= solicita_caractere;
            end
        end else if (pend_parcial && (fonte_envio != src_parcial)) begin
            dado_char <= jogada_parcial_decodificada;
            fonte_envio <= src_parcial;
            ajuda_rom_ativa <= 1'b0;
            estado <= solicita_caractere;
        end else begin
            fonte_envio <= src_nenhum;
            estado <= inicial;
        end
    end
    endtask

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            estado <= inicial;
            pend_reset <= 1'b0;
            pend_jogar <= 1'b0;
            pend_parcial <= 1'b0;
            pend_ajuda <= 1'b0;
            pend_ajuda_sinal <= 1'b0;
            pend_modo <= 1'b0;
            pend_erro <= 1'b0;
            terminador_pendente <= 1'b0;
            ajuda_rom_ativa <= 1'b0;
            dado_char <= 7'b0000000;
            dado_ajuda <= 7'b0000000;
            endereco_ajuda <= 8'b00000000;
            fonte_envio <= src_nenhum;
        end else begin
            if (evento_reset) begin
                pend_reset <= 1'b1;
                pend_jogar <= 1'b0;
                pend_parcial <= 1'b0;
                pend_ajuda <= 1'b0;
                pend_ajuda_sinal <= 1'b0;
                pend_modo <= 1'b0;
                pend_erro <= 1'b0;
                terminador_pendente <= 1'b0;
                ajuda_rom_ativa <= 1'b0;

                if (!tx_busy) begin
                    estado <= inicial;
                    fonte_envio <= src_nenhum;
                end
            end else begin
                if (evento_jogar)
                    pend_jogar <= 1'b1;

                if (evento_jogada_parcial)
                    pend_parcial <= 1'b1;

                if (evento_modo)
                    pend_modo <= 1'b1;

                if (evento_erro)
                    pend_erro <= 1'b1;

                if (ajuda_pulso)
                    pend_ajuda_sinal <= 1'b1;

                if (ajuda_pulso)
                    pend_ajuda <= 1'b1;

                case (estado)
                    inicial: begin
                        if (pend_reset && !tx_busy) begin
                            dado_char <= char_reset;
                            fonte_envio <= src_reset;
                            estado <= solicita_caractere;
                        end else if (pend_jogar && !tx_busy) begin
                            dado_char <= char_jogar;
                            fonte_envio <= src_jogar;
                            estado <= solicita_caractere;
                        end else if (pend_erro && !tx_busy) begin
                            dado_char <= char_erro;
                            fonte_envio <= src_erro;
                            estado <= solicita_caractere;
                        end else if (pend_modo && !tx_busy) begin
                            dado_char <= modo_escolhido ? char_modo_dificil : char_modo_facil;
                            fonte_envio <= src_modo;
                            estado <= solicita_caractere;
                        end else if (pend_ajuda_sinal && !tx_busy) begin
                            dado_char <= char_ajuda;
                            fonte_envio <= src_ajuda_sinal;
                            estado <= solicita_caractere;
                        end else if (pend_ajuda && !tx_busy) begin
                            if (modo_escolhido) begin
                                pend_parcial <= 1'b0;
                                ajuda_rom_ativa <= 1'b1;
                                terminador_pendente <= 1'b0;
                                endereco_ajuda <= palavra_base;
                                estado <= ajuda_palavra_inicializa;
                            end else begin
                                dado_char <= letra_atual;
                                fonte_envio <= src_ajuda;
                                ajuda_rom_ativa <= 1'b0;
                                terminador_pendente <= 1'b0;
                                estado <= solicita_caractere;
                            end
                        end else if (pend_parcial && !tx_busy) begin
                            dado_char <= jogada_parcial_decodificada;
                            fonte_envio <= src_parcial;
                            ajuda_rom_ativa <= 1'b0;
                            terminador_pendente <= 1'b0;
                            estado <= solicita_caractere;
                        end
                    end

                    solicita_caractere: begin
                        if (tx_aux_start_ack)
                            estado <= espera_fim_caractere;
                    end

                    espera_fim_caractere: begin
                        if (tx_ready) begin
                            if (terminador_pendente) begin
                                case (fonte_envio)
                                    src_ajuda:   pend_ajuda <= 1'b0;
                                    src_parcial: pend_parcial <= 1'b0;
                                    default: ;
                                endcase

                                terminador_pendente <= 1'b0;
                                ajuda_rom_ativa <= 1'b0;
                                agenda_proximo();
                            end else if ((fonte_envio == src_ajuda || fonte_envio == src_parcial) && !ajuda_rom_ativa) begin
                                terminador_pendente <= 1'b1;
                                dado_char <= 7'b0000000;
                                estado <= solicita_caractere;
                            end else begin
                                case (fonte_envio)
                                    src_reset: begin
                                        pend_reset <= 1'b0;
                                        pend_jogar <= 1'b0;
                                        pend_parcial <= 1'b0;
                                        pend_ajuda <= 1'b0;
                                        pend_modo <= 1'b0;
                                        pend_erro <= 1'b0;
                                    end
                                    src_jogar:   pend_jogar <= 1'b0;
                                    src_erro:    pend_erro <= 1'b0;
                                    src_modo:    pend_modo <= 1'b0;
                                    src_ajuda_sinal: pend_ajuda_sinal <= 1'b0;
                                    default: ;
                                endcase

                                agenda_proximo();
                            end
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
                            dado_ajuda <= 7'b0000000;
                            fonte_envio <= src_ajuda;
                            terminador_pendente <= 1'b1;
                            estado <= ajuda_palavra_solicita_caractere;
                        end else if (!tx_busy) begin
                            dado_ajuda <= letra_ajuda;
                            fonte_envio <= src_ajuda;
                            terminador_pendente <= 1'b0;
                            estado <= ajuda_palavra_solicita_caractere;
                        end
                    end

                    ajuda_palavra_solicita_caractere: begin
                        if (tx_aux_start_ack)
                            estado <= ajuda_palavra_espera_fim;
                    end

                    ajuda_palavra_espera_fim: begin
                        if (tx_ready) begin
                            if (terminador_pendente) begin
                                pend_ajuda <= 1'b0;
                                terminador_pendente <= 1'b0;
                                ajuda_rom_ativa <= 1'b0;
                                agenda_proximo();
                            end else begin
                                endereco_ajuda <= endereco_ajuda + 1'b1;
                                estado <= ajuda_palavra_espera_rom;
                            end
                        end
                    end

                    default: begin
                        estado <= inicial;
                    end
                endcase
            end
        end
    end
endmodule