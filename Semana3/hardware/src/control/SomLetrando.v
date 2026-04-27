	module SomLetrando (
		 //Inputs
		 input        clock,
		 input        reset,
		 input        jogar,
		 input        confirmar,
		 input        ajuda,
		 input        modo,
		 input  [6:0] botoes,
		 input        ignora_tx_inicial, //Usado para fins de simula????o
		 //Outputs
		 output       ganhou,
		 output       perdeu,
		 output       pronto,
		 output [6:0] leds,
		 //Outputs seriais
		 output       saida_serial,
		 output       pronto_serial,

		 //Depuracao leds
		 output       db_igual,
		 output       db_clock,
		 output       db_iniciar,
		 output       db_tem_jogada,
		 output       db_modo, 
		 output 		  db_confirmar,
		 //Depuracao displays
		 output [6:0] db_endereco_letra,
		 output [6:0] db_rom_escolhida,
		 output [6:0] db_letra_more,
		 output [6:0] db_letra_less,
		 output [6:0] db_contagem_erros,
		 output [6:0] db_estado,
		 // Depuracao serial
		 output       db_tick_serial,
		 output       db_saida_serial,
		 output [6:0] db_estado_serial
	);

	//  Wires
		 wire zera_contador_wire;
		 wire zera_registrador_wire;
		 wire zeraSeletor_wire;

		 wire igual_wire;
		 wire registraR_wire;
		 wire jogada_wire;
		 wire fim_palavra_wire;
		 wire limite_erros_wire;
		 wire conta_erro_wire;
		 wire incrementa_endereco_wire;
		 wire load_end_inicial_wire;
		 wire enable_rom_wire;
		 wire enable_modo_wire;
		 wire enable_palavra_wire;
		 wire modo_wire;
		 wire zera_contador_erros_wire;

		 wire start_tx_wire;
		 wire start_tx_aux_req_wire;
		 wire start_tx_aux_ack_wire;
		 wire start_tx_mux_wire;
		 wire tx_ready_wire;
		 reg  tx_busy_wire;

		 wire [3:0] estado_wire;
		 wire [3:0] db_endereco_letra_wire;
		 wire [3:0] db_rom_escolhida_wire;
		 wire [6:0] jogadafeita_wire;
		 wire [3:0] db_contagem_erros_wire;

		 wire [6:0] db_letra_wire; //letra em ascii completa a ser enviada serial
		 wire [6:0] tx_data_aux_wire;
		 wire [6:0] tx_data_mux_wire;
		 wire [6:0] jogada_parcial_decodificada_wire;
		 wire [6:0] letra_atual_wire;
		 wire [3:0] palavra_base_wire;
		 wire       evento_jogada_parcial_wire;
		 wire [3:0] db_letra_less_wire; //letra em ascii bits menos significativos para display
		 wire [3:0] db_letra_more_wire; //letra em ascii bits mais significativos para display

		 // Sinais com debounce
		 wire [6:0] botoes_db_wire;
		 wire confirmar_db_wire;
		 wire ajuda_db_wire;

		 // Considerando clock de 50 MHz
		 localparam [19:0] DEBOUNCE_8MS_TICKS = 20'd399_999;
		 localparam [19:0] DEBOUNCE_2MS_TICKS = 20'd99_999;

		 // Debounce dos 7 botoes de fliperama (8 ms)
		 debounce2 #(.tempo_debounce(DEBOUNCE_8MS_TICKS)) db_botao_0 (.clk(clock), .entrada(botoes[0]), .saida(botoes_db_wire[0]));
		 debounce2 #(.tempo_debounce(DEBOUNCE_8MS_TICKS)) db_botao_1 (.clk(clock), .entrada(botoes[1]), .saida(botoes_db_wire[1]));
		 debounce2 #(.tempo_debounce(DEBOUNCE_8MS_TICKS)) db_botao_2 (.clk(clock), .entrada(botoes[2]), .saida(botoes_db_wire[2]));
		 debounce2 #(.tempo_debounce(DEBOUNCE_8MS_TICKS)) db_botao_3 (.clk(clock), .entrada(botoes[3]), .saida(botoes_db_wire[3]));
		 debounce2 #(.tempo_debounce(DEBOUNCE_8MS_TICKS)) db_botao_4 (.clk(clock), .entrada(botoes[4]), .saida(botoes_db_wire[4]));
		 debounce2 #(.tempo_debounce(DEBOUNCE_8MS_TICKS)) db_botao_5 (.clk(clock), .entrada(botoes[5]), .saida(botoes_db_wire[5]));
		 debounce2 #(.tempo_debounce(DEBOUNCE_8MS_TICKS)) db_botao_6 (.clk(clock), .entrada(botoes[6]), .saida(botoes_db_wire[6]));

		 // Debounce dos botoes convencionais (2 ms)
		 debounce2 #(.tempo_debounce(DEBOUNCE_2MS_TICKS)) db_confirmar_btn (.clk(clock), .entrada(confirmar), .saida(confirmar_db_wire));
		 debounce2 #(.tempo_debounce(DEBOUNCE_2MS_TICKS)) db_ajuda     (.clk(clock), .entrada(ajuda),     .saida(ajuda_db_wire));
		 
		
		 unidade_controle uc (
			  .clock					 (clock),
			  .reset					 (reset),
			  .jogar  				 (jogar),
			  .jogada			    (jogada_wire),
			  .igual				    (igual_wire),
			  .fim_palavra        (fim_palavra_wire),
			  .start_tx           (start_tx_wire),
			  .ignora_tx_inicial  (ignora_tx_inicial),
			  .tx_ready           (tx_ready_wire),
			  .limite_erros       (limite_erros_wire),
			  .zeraSeletor			 (zeraSeletor_wire),
			  .enable_rom		    (enable_rom_wire),
			  .modo               (modo_wire),
			  .enable_modo	    	 (enable_modo_wire),
			  .enable_palavra     (enable_palavra_wire),
			  .zera_contador      (zera_contador_wire),
			  .zera_registrador   (zera_registrador_wire),
			  .conta_erro         (conta_erro_wire),
			  .incrementa_endereco(incrementa_endereco_wire),
			  .load_end_inicial   (load_end_inicial_wire),
			  .zera_contador_erros(zera_contador_erros_wire),
			  .registraR		    (registraR_wire),
			  .acertou				 (ganhou),
			  .errou					 (perdeu),
			  .pronto			    (pronto),
			  .db_estado		    (estado_wire)
		 );

		 fluxo_dados  fd(
			  .clock				  			 (clock),
			  .reset             		 (reset),
			  .zera_contador    		    (zera_contador_wire),
			  .zera_registrador  		 (zera_registrador_wire),
			  .registraR		  		    (registraR_wire),
			  .zeraSeletor	    			 (zeraSeletor_wire),
			.enable_rom		  			    (enable_rom_wire),
			  .chaves			    		 (botoes_db_wire),
			  .confirmar		    		 (confirmar_db_wire),
			  .incrementa_endereco		 (incrementa_endereco_wire),
			 .enable_modo	    			 (enable_modo_wire),
			  .enable_palavra      		 (enable_palavra_wire),
			  .modo              		 (modo),
			  .modo_escolhido     		 (modo_wire),
           .zera_contador_erros		 (zera_contador_erros_wire),
		     .load_end_inicial  		 (load_end_inicial_wire),
		     .conta_erro       			 (conta_erro_wire),
			  .igual							 (igual_wire),
			  .fim_palavra       		 (fim_palavra_wire),
			  .limite_erros       			 (limite_erros_wire),
           .jogada_feita	    			 (jogada_wire),
			  .db_tem_jogada	    			 (db_tem_jogada),
		     .db_contagem_erros  			 (db_contagem_erros_wire),
			  .db_letra			   			 (db_letra_wire),
			  .db_endereco_letra				 (db_endereco_letra_wire),
			  .db_rom_escolhida				 (db_rom_escolhida_wire),
			  .db_jogada	    				 (jogadafeita_wire),
			  .evento_jogada_parcial 		 (evento_jogada_parcial_wire),
			  .jogada_parcial_decodificada (jogada_parcial_decodificada_wire),
			.letra_atual						 (letra_atual_wire),
        .palavra_base 					 (palavra_base_wire)
    );

    tx_rotina_auxiliar tx_aux (
        .clock                      (clock),
        .reset                      (reset),
		.ajuda                      (ajuda_db_wire),
        .modo_escolhido             (modo_wire),
        .evento_jogada_parcial      (evento_jogada_parcial_wire),
        .jogada_parcial_decodificada(jogada_parcial_decodificada_wire),
        .letra_atual                (letra_atual_wire),
        .palavra_base               (palavra_base_wire),
        .tx_busy                    (tx_busy_wire),
        .tx_ready                   (tx_ready_wire),
        .tx_aux_start_ack           (start_tx_aux_ack_wire),
        .tx_aux_start_req           (start_tx_aux_req_wire),
        .tx_aux_data                (tx_data_aux_wire)
    );

    // Definicao da prioridade de envio da transmissao serial para o computador externo
	 reg envio_inicial;

	always @(posedge clock or posedge reset) begin
    if (reset)
        envio_inicial <= 0;
	 else if (!tx_busy_wire) begin
        if (start_tx_wire)
            envio_inicial <= 1;
		   else if (start_tx_aux_req_wire) 
            envio_inicial <= 0;
	 end
	end
	
	 assign tx_data_mux_wire = envio_inicial ? db_letra_wire : tx_data_aux_wire;
	 //assign tx_data_mux_wire = (!tx_busy_wire && start_tx_wire) ? db_letra_wire : tx_data_aux_wire; --pode mudar no meio
	 
    assign start_tx_mux_wire = (!tx_busy_wire && start_tx_wire) ? 1'b1 :
                               ((!tx_busy_wire && start_tx_aux_req_wire) ? 1'b1 : 1'b0);

    assign start_tx_aux_ack_wire = (!tx_busy_wire && !start_tx_wire && start_tx_aux_req_wire);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            tx_busy_wire <= 1'b0;
        end 
        
        else begin
            if (!tx_busy_wire && start_tx_mux_wire)
                tx_busy_wire <= 1'b1;
            else if (tx_busy_wire && tx_ready_wire)
                tx_busy_wire <= 1'b0;
        end
    end

    hexa7seg rom_escolhida ( //0
        .hexa(db_rom_escolhida_wire),
        .display(db_rom_escolhida)
    );

    hexa7seg endereco_letra ( //1
        .hexa(db_endereco_letra_wire),
        .display(db_endereco_letra)
    );

    hexa7seg letraless ( //2
        .hexa(db_letra_less_wire), //mostra os bits menos significativos da letra em ascii
        .display(db_letra_less)
    );

    hexa7seg letramore ( //3
        .hexa(db_letra_more_wire), //mostra os bits mais significativos da letra em ascii
        .display(db_letra_more)
    );

	hexa7seg contagem_erros ( //5
        .hexa(db_contagem_erros_wire),
        .display(db_contagem_erros)
    );
	
    hexa7seg estado ( //6
        .hexa(estado_wire),
        .display(db_estado)
    );

    //transmissao que ocorre logo que o jogador escolhe a palavra pra ouvir pela primeira vez
    tx_serial_7N2 transmissao_FPGA_inicial ( 
        //entradas
        .clock           (clock),
        .reset           (reset),
        .partida         (start_tx_mux_wire),
        .dados_ascii     (tx_data_mux_wire),
        //saidas
        .saida_serial    (saida_serial), 
        .pronto          (tx_ready_wire), //indica que a letra foi transmitida e o sistema pode passar para a proxima letra
        .db_clock        (),
        .db_tick         (db_tick_serial),
        .db_partida      (),
        .db_saida_serial (db_saida_serial),
        .db_estado       (db_estado_serial) //ja esta em hexa; ser?? 4 display
    );

    assign db_igual = igual_wire;
	 assign db_confirmar = jogada_wire;
    assign leds = jogadafeita_wire;
    assign pronto_serial = tx_ready_wire;
    assign db_clock = clock;
    assign db_iniciar = jogar;
    assign db_modo = modo_wire;

    //letras particionamento
    assign db_letra_less_wire = db_letra_wire[3:0];
    assign db_letra_more_wire = {1'b0,db_letra_wire[6:4]};

endmodule

