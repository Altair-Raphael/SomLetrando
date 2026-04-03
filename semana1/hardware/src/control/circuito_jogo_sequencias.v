/*
 * ------------------------------------------------------------------
 *  Arquivo   : circuito_jogo_sequencias.v
 *  Projeto   : SomLetrando
 * ------------------------------------------------------------------
 *  Descricao : Adaptação do top-level da Experiência 5 para o projeto
 * ------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      05/02/2026  1.0     T2BB8 (labdig)    versao inicial
 * ------------------------------------------------------------------
 */

module circuito_jogo_sequencias (
    input        clock,
    input        reset,
    input        jogar,
    input        confirmar,
    input        modo,
    input  [3:0] botoes,
    output [3:0] leds,
    output       ganhou,
    output       perdeu,
    output       pronto,
    output       timeout, 
    output       db_igual,
    output [6:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_estado,
	 output [6:0] db_jogada,
    output       db_clock,
    output       db_iniciar,
    output       db_tem_jogada,
	 output       db_timeout,
	 output       db_modo,
	 output [6:0] db_limite,
    output       db_enderecoIgualLimite
);
 
    wire zeraC_wire;
    wire zeraL_wire;
    wire contaC_wire;
    wire contaL_wire;
    wire fimL_wire;
    wire zeraR_wire;
    wire igual_wire;
    wire registraR_wire;
	 wire jogada_wire;	
    wire [3:0] estado_wire;
    wire [3:0] contagem_wire;
    wire [3:0] memoria_wire;
    wire [3:0] jogadafeita_wire;
	 wire fim_temp_wire;
	 wire conta_wire;
	 wire zera_temp_wire;
    wire zeraSeletor_wire;
	 wire enable_modo_wire;
	 wire [3:0] db_limite_wire;
	 wire enderecoIgualLimite_wire;
	 

    unidade_controle uc (
        .clock				(clock),
        .reset				(reset),
        .jogar  			(jogar),
        .fimL				(fimL_wire),
        .jogada			    (jogada_wire),
        .igual				(igual_wire),
		.fim_temp			(fim_temp_wire),
		.enderecoIgualLimite(enderecoIgualLimite_wire),
		.conta				(conta_wire),
		.zera_contagem	    (zera_temp_wire),
        .zeraSeletor		(zeraSeletor_wire),
		.enable_modo	    (enable_modo_wire),
		.zeraL              (zeraL_wire),
        .zeraC				(zeraC_wire),
        .contaC			    (contaC_wire),
        .contaL             (contaL_wire),
        .zeraR				(zeraR_wire),
        .registraR		    (registraR_wire),
        .acertou			(ganhou),
        .errou				(perdeu),
        .pronto			    (pronto),
        .db_estado		    (estado_wire),
		.timeout			(timeout)
    );


    fluxo_dados  fd(
        .clock				(clock),
        .zeraL              (zeraL_wire), 
        .zeraC				(zeraC_wire),
        .contaC			    (contaC_wire),
        .contaL             (contaL_wire),
        .zeraR				(zeraR_wire),
        .registraR		    (registraR_wire),
        .zeraSeletor		(zeraSeletor_wire),
        .chaves			    (botoes),
        .confirmar			(~confirmar),
		.conta				(conta_wire),
		.zera_contagem	    (zera_temp_wire),
		.modo               (modo),
		.enable_modo	    (enable_modo_wire),
		.fim_temp			(fim_temp_wire),
        .igual				(igual_wire),
        .fimL				(fimL_wire),
        .jogada_feita	    (jogada_wire),
        .enderecoIgualLimite(enderecoIgualLimite_wire),
        .db_tem_jogada	    (db_tem_jogada),
        .db_contagem		(contagem_wire),
        .db_memoria	    	(memoria_wire),
        .db_jogada	    	(jogadafeita_wire),
        .db_limite          (db_limite_wire)
    );

    hexa7seg estado (
        .hexa(estado_wire),
        .display(db_estado)
    );

    hexa7seg contagem (
        .hexa(contagem_wire),
        .display(db_contagem)
    );

    hexa7seg memoria (
        .hexa(memoria_wire),
        .display(db_memoria)
    );

    hexa7seg limite_db (
        .hexa(db_limite_wire),
        .display(db_limite)
    );
	 
	 hexa7seg jogada_db (
        .hexa(jogadafeita_wire),
        .display(db_jogada)
    );
    

    assign db_igual = igual_wire;
    assign leds = jogadafeita_wire;
    assign db_clock = clock;
    assign db_iniciar = jogar;
    assign db_modo = modo;
    assign db_enderecoIgualLimite = enderecoIgualLimite_wire;
	 assign db_timeout = timeout;

endmodule