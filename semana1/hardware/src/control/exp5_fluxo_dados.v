/*
 * ------------------------------------------------------------------
 *  Arquivo   : exp5_fluxo_dados.v
 *  Projeto   : SomLetrando
 * ------------------------------------------------------------------
 *  Descricao : Uso do FD da Experiência 5 para o projeto
 * ------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      05/02/2026  1.0     T2BB8 (labdig)    versao inicial
 * ------------------------------------------------------------------
 */

module fluxo_dados (
    input        clock,
    input        zeraL,
    input        zeraC,
    input        contaC,
    input        contaL,
    input        zeraR,
    input        registraR,
  input        zeraSeletor,
    input  [3:0] chaves,
	input        confirmar,
	input        conta,
	input 		 zera_contagem,
	input        modo,
	input 		 enable_modo,
	output       fim_temp, 
    output       igual,
    output       fimL,
    output       jogada_feita,
    output       enderecoIgualLimite,
    output       db_tem_jogada,
    output [3:0] db_contagem,
    output [3:0] db_memoria,
    output [3:0] db_jogada,
    output [3:0] db_limite
);
    // sinais internos para interligacao dos componentes
    wire   [3:0] s_endereco;
   wire   [3:0] s_dado;
   wire   [3:0] s_dado_rom_0;
   wire   [3:0] s_dado_rom_1;
   wire   [3:0] s_dado_rom_2;
   wire   [3:0] s_dado_rom_3;
	 wire   [3:0] contagem_m0;
	 wire   [3:0] contagem_m1;
	 wire   [3:0] s_limite; 
	 wire   [3:0] s_limite_0;
	 wire   [3:0] s_limite_1;
	 wire   [3:0] s_jogada;
	 wire   fimC0;
	 wire   fimC1;
	 wire   fimC;
	 wire   fimL0;
	 wire   fimL1;
	 wire   modo_wire;
   wire   [1:0] seletor_rom_contagem;
   wire   [3:0] seletor_rom_reg;
   wire   [1:0] seletor_rom;
    
     // Contadores
     // contador do temporizador 
     contador_m   #(.M(3000), .N(12)) temporizador (
		.clock(clock),
		.zera_as(1'b0),
		.zera_s(zera_contagem),
		.conta(conta),
		.Q(),
		.fim(fim_temp),
		.meio() 
	 );
	 
	 // contador_163 (modo = 0)
    contador_163 contador (
      .clock( clock ),
      .clr  ( ~zeraC ),
      .ld   ( 1'b1 ),
      .ent  ( 1'b1 ),
      .enp  ( contaC ),
      .D    ( 4'd0 ),
      .Q    ( contagem_m0 ),
      .rco  ( fimC0 )
    );
	 
	 // contador até 4 (modo = 1)
	contador_m #(.M(4), .N(4)) contador_2  (
		.clock	(clock),
		.zera_as(1'b0),
		.zera_s	(zeraC),
		.conta	(contaC),
		.Q		(contagem_m1),
		.fim	(fimC1),
		.meio	() 
	 );
	 
	 // contador da rodada (modo = 0)
	 contador_m #(.M(16), .N(4)) ContLmt0  (
		.clock	(clock),
		.zera_as(1'b0),
		.zera_s	(zeraL),
		.conta	(contaL),
		.Q		(s_limite_0),
		.fim	(fimL0),
		.meio	() 
	 );
	 
	 // contador da rodada (modo = 1)
	 contador_m #(.M(4), .N(4)) ContLmt1 (
		.clock	(clock),
		.zera_as(1'b0),
		.zera_s	(zeraL),
		.conta	(contaL),
		.Q		(s_limite_1),
		.fim	(fimL1),
		.meio	() 
	 );
	 
	// Comparadores
    // comparador_85 (da jogada)
    comparador_85 CompJog (
      .A    ( s_dado ),
      .B    ( s_jogada ),
      .ALBi ( 1'b0 ),
      .AGBi ( 1'b0 ),
      .AEBi ( 1'b1 ),
      .ALBo (  ),
      .AGBo (  ),
      .AEBo ( igual )
    );
    
    // Comparador de término de rodada
    comparador_85 CompLmt (
      .A    ( s_limite ),
      .B    ( s_endereco ),
      .ALBi ( 1'b0 ),
      .AGBi ( 1'b0 ),
      .AEBi ( 1'b1 ),
      .ALBo (  ),
      .AGBo (  ),
      .AEBo ( enderecoIgualLimite )
    );
    
    //MUX 
	 mux_n  #(.bits(1)) sinal_fim (
        .sinal_1    (fimC0),
        .sinal_2    (fimC1),
        .sel        (modo_wire),
    	.saida      (fimC)
    );
    mux_n #(.bits(4)) contagem  (
        .sinal_1    (contagem_m0),
        .sinal_2    (contagem_m1),
        .sel        (modo_wire),
    	.saida      (s_endereco)
    );
    
    mux_n #(.bits(1)) sinal_fimL  (
        .sinal_1    (fimL0),
        .sinal_2    (fimL1),
        .sel        (modo_wire),
    	.saida      (fimL)
    );
	 
	 mux_n #(.bits(4)) sinal_limiterodada (
        .sinal_1    (s_limite_0),
        .sinal_2    (s_limite_1),
        .sel        (modo_wire),
    	.saida      (s_limite)
    ); 
    
    // Registradores
    //registrador de 4 bits
    registrador_4 registrador4 (
      .clock  (clock),
      .clear  (zeraR),
      .enable (registraR),
      .D      (chaves),
      .Q      (s_jogada)
    );
	  
	 //registrador pra modo 
	 registrador_1 registrador_modo (
      .clock  (clock),
      .clear  (1'b0),

      .enable (enable_modo),
      .D      (modo),
      .Q      (modo_wire)
    );

   contador_m #(.M(4), .N(2)) contador_rom (
    .clock	(clock),
    .zera_as(zeraSeletor),
    .zera_s	(1'b0),
    .conta	(1'b1),
    .Q		(seletor_rom_contagem),
    .fim	(),
    .meio	()
   );

   registrador_4 registrador_rom (
    .clock	(clock),
    .clear	(zeraSeletor),
    .enable	(enable_modo),
    .D		({2'b00, seletor_rom_contagem}),
    .Q		(seletor_rom_reg)
   );

    //memoria
    sync_rom_16x4 memoria_0 (
      .clock    (clock),
      .address  (s_endereco),
      .data_out (s_dado_rom_0)
    );

   sync_rom_16x4_1 memoria_1 (
    .clock    (clock),
    .address  (s_endereco),
    .data_out (s_dado_rom_1)
   );

   sync_rom_16x4_2 memoria_2 (
    .clock    (clock),
    .address  (s_endereco),
    .data_out (s_dado_rom_2)
   );

   sync_rom_16x4_3 memoria_3 (
    .clock    (clock),
    .address  (s_endereco),
    .data_out (s_dado_rom_3)
    );

   mux_4_n #(.bits(4)) seletor_memoria_jogo (
    .sinal_0    (s_dado_rom_0),
    .sinal_1    (s_dado_rom_1),
    .sinal_2    (s_dado_rom_2),
    .sinal_3    (s_dado_rom_3),
    .sel        (seletor_rom),
    .saida      (s_dado)
   );

    //detector de borda
    edge_detector detector_borda (
      .clock (clock),
      .reset (zeraR),
      .sinal (confirmar),
      .pulso (jogada_feita)
    );
	 
	 assign seletor_rom = seletor_rom_reg[1:0];

    // saidas de depuracao
    assign db_contagem = s_endereco;
    assign db_tem_jogada = (chaves[0]||chaves[1]||chaves[2]||chaves[3]);
    assign db_memoria = s_dado;
    assign db_jogada = s_jogada;
    assign db_limite = s_limite;

endmodule