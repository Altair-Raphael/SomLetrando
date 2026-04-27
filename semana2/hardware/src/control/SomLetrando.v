module SomLetrando (
    //Inputs
    input        clock,
    input        reset,
    input        jogar,
    input        confirmar,
    input        modo,
    input  [7:0] botoes,

    //Outputs
    output       ganhou,
    output       perdeu,
    output       pronto,
    output [7:0] leds,
    //Outputs seriais
    output       saida_serial,
    output       pronto_serial,

    //Depuracao leds
    output       db_igual,
    output       db_clock,
    output       db_iniciar,
    output       db_tem_jogada,
    output       db_modo, 
	output 		 db_confirmar,
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

    wire start_tx_wire;
    wire tx_ready_wire;

    wire [3:0] estado_wire;
    wire [3:0] db_endereco_letra_wire;
    wire [3:0] db_rom_escolhida_wire;
    wire [7:0] jogadafeita_wire;
	wire [3:0] db_contagem_erros_wire;

    wire [7:0] db_letra_wire; //letra em ascii completa a ser enviada serial
    wire [3:0] db_letra_less_wire; //letra em ascii bits menos significativos para display
    wire [3:0] db_letra_more_wire; //letra em ascii bits mais significativos para display
    
	
    unidade_controle uc (
        .clock				(clock),
        .reset				(reset),
        .jogar  			(jogar),
        .jogada			    (jogada_wire),
        .igual				(igual_wire),
        .fim_palavra        (fim_palavra_wire),
        .start_tx           (start_tx_wire),
        .tx_ready           (tx_ready_wire),
        .limite_erros       (limite_erros_wire),
        .zeraSeletor		(zeraSeletor_wire),
		.enable_rom		    (enable_rom_wire),
        .enable_modo	    (enable_modo_wire),
		.zera_contador      (zera_contador_wire),
        .zera_registrador   (zera_registrador_wire),
        .conta_erro         (conta_erro_wire),
        .incrementa_endereco(incrementa_endereco_wire),
        .load_end_inicial   (load_end_inicial_wire),
        .registraR		    (registraR_wire),
        .acertou			(ganhou),
        .errou				(perdeu),
        .pronto			    (pronto),
        .db_estado		    (estado_wire)
    );

    fluxo_dados  fd(
        .clock				(clock),
        .zera_contador      (zera_contador_wire),
        .zera_registrador   (zera_registrador_wire),
        .registraR		    (registraR_wire),
        .zeraSeletor		(zeraSeletor_wire),
		.enable_rom		    (enable_rom_wire),
        .chaves			    (botoes),
        .confirmar			(confirmar),
        .incrementa_endereco(incrementa_endereco_wire),
		.enable_modo	    (enable_modo_wire),
		.load_end_inicial   (load_end_inicial_wire),
		.conta_erro         (conta_erro_wire),
        .igual				(igual_wire),
        .fim_palavra        (fim_palavra_wire),
        .limite_erros       (limite_erros_wire),
        .jogada_feita	    (jogada_wire),
        .db_tem_jogada	    (db_tem_jogada),
		.db_contagem_erros  (db_contagem_erros_wire),
		.db_letra			(db_letra_wire),
        .db_endereco_letra	(db_endereco_letra_wire),
        .db_rom_escolhida	(db_rom_escolhida_wire),
        .db_jogada	    	(jogadafeita_wire)
    );

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
    tx_serial_8N1 transmissao_FPGA_inicial ( 
        //entradas
        .clock           (clock),
        .reset           (reset),
        .partida         (start_tx_wire),
        .dados_ascii     (db_letra_wire),
        //saidas
        .saida_serial    (saida_serial), 
        .pronto          (tx_ready_wire), //indica que a letra foi transmitida e o sistema pode passar para a proxima letra
        .db_clock        (),
        .db_tick         (db_tick_serial),
        .db_partida      (),
        .db_saida_serial (db_saida_serial),
        .db_estado       (db_estado_serial) //ja esta em hexa; será 4 display
    );

    assign db_igual = igual_wire;
	assign db_confirmar = jogada_wire;
    assign leds = jogadafeita_wire;
    assign pronto_serial = tx_ready_wire;
    assign db_clock = clock;
    assign db_iniciar = jogar;
    assign db_modo = modo;

    //letras particionamento
    assign db_letra_less_wire = db_letra_wire[3:0];
    assign db_letra_more_wire = db_letra_wire[7:4];

endmodule

//Modificacoes recentes:
// - Chaves de entrada passaram a ser 8 para permitir jogadas com letras de a-z 
// - Comparador de fim de palavra passou a comparar com 8 bits (letra em ascii completa) 
// - Divisão da letra em ascii completa em dois displays de 4 bits cada para depuracao (db_letra_less e db_letra_more)
// - Adicao de um novo display de depuracao para mostrar a contagem de erros   

// Adicoes pendentes:
// Jogador pedir para reproduzir a palavra ou letra (depende do modo)

// Melhorias semana 4
// jogador escolher a palavra pelo Computador --> FPGA (RX)