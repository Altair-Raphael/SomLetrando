/*
 * ------------------------------------------------------------------
 *  Arquivo   : FD_SomLetrando.v
 *  Projeto   : SomLetrando
 * ------------------------------------------------------------------
 *  Descricao : Circuito do fluxo de dados do projeto SomLetrando
 * ------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      05/02/2026  1.0     T2BB8 (labdig)    versao inicial
 * ------------------------------------------------------------------
 */

module fluxo_dados (
    input        clock,
    input        zera_contador,
    input        zera_registrador,
    input        registraR,
    input        zeraSeletor,
    input  [7:0] chaves,
    input        confirmar,
    input        incrementa_endereco,
    input        enable_modo,
    input        load_end_inicial,
	  input 		   enable_rom,
    input        conta_erro,
    output       igual,
    output       jogada_feita,
    output       fim_palavra,
    output       limite_erros,
    output       db_tem_jogada,
    output [3:0] db_contagem_erros,
    output [3:0] db_endereco_letra,
    output [3:0] db_seletor_rom,
	  output [7:0] db_letra,
    output [3:0] db_jogada
);
    // sinais internos para interligacao dos componentes
   wire   [3:0] s_endereco;
   wire   [7:0] s_letra;
   wire   [7:0] s_jogada;
   wire   [3:0] seletor_rom_contagem;
   wire   [3:0] seletor_palavra;
   wire   [3:0] s_ponteiros_rom;
	 wire   [3:0] db_erros_wire;
	 wire 	[3:0] seletor_rom_reg;
    
   // Contadores
	 // Contador para aleatorizar escolha da ROM
   contador_m #(.M(4), .N(4)) contador_rom (
    .clock	(clock),
    .zera_as(1'b0),
    .zera_s	(1'b0),
    .conta	(1'b1),
    .Q		(seletor_rom_contagem),
    .fim	(),
    .meio	()
   );

    // Contador de erros
    contador_m #(.M(3), .N(4)) contador_erros (
      .clock	(clock),
      .zera_as(1'b0),
      .zera_s	(zera_contador),
      .conta	(conta_erro),
      .Q		(db_erros_wire),
      .fim	(limite_erros),
      .meio	()
   );

    // Contador para endereço das ROMs
    contador_163 endereco_palavra (
      .clock	(clock),
      .clr(~zera_contador),
      .ld   (~load_end_inicial),
      .ent  (1'b1),
      .enp   (incrementa_endereco),
      .D    (seletor_palavra),
      .Q		(s_endereco),
      .rco	()
    );

	// Comparadores
    // comparador_85 (da jogada)
    comparador_85 CompJog (
      .A    ( s_letra ),
      .B    ( s_jogada ),
      .ALBi ( 1'b0 ),
      .AGBi ( 1'b0 ),
      .AEBi ( 1'b1 ),
      .ALBo (  ),
      .AGBo (  ),
      .AEBo ( igual )
    );
    
    // Comparador de fim da palavra
    comparador_85 CompLmt (
      .A    (s_letra),
      .B    (8'b00000000),
      .ALBi ( 1'b0 ),
      .AGBi ( 1'b0 ),
      .AEBi ( 1'b1 ),
      .ALBo (  ),
      .AGBo (  ),
      .AEBo ( fim_palavra )
    );
    

    // Registradores
    //registrador da jogada
    registrador_7 registrador4 (
      .clock  (clock),
      .clear  (zera_registrador),
      .enable (registraR),
      .D      (chaves),
      .Q      (s_jogada)
    );

    // Registrador da palavra escolhida
    registrador_4 registrador_palavra (
      .clock	(clock),
      .clear	(zeraSeletor),
      .enable	(enable_modo),
      .D		(s_ponteiros_rom),
      .Q		(seletor_palavra)
   );
	
	//registrador da memoria escolhida
	 registrador_4 registrador_rom (
    .clock	(clock),
    .clear	(1'b0),
    .enable	(enable_rom),
    .D		(seletor_rom_contagem),
    .Q		(seletor_rom_reg)
   );

    //memoria
    sync_rom_4x4 rom_ponteiros (
      .clock  (clock),
      .address (seletor_rom_reg),
      .data_out    (s_ponteiros_rom)
    ); 

    sync_rom_32x4 rom_palavras (
      .clock  (clock),
      .address ({1'b0,s_endereco}),
      .data_out   (s_letra)
    ); 

    //detector de borda
    edge_detector detector_borda (
      .clock (clock),
      .reset (zera_registrador),
      .sinal (~confirmar),
      .pulso (jogada_feita)
    );

    // saidas de depuracao
    assign db_endereco_letra = s_endereco;
	  assign db_letra = s_letra;
    assign db_tem_jogada = (chaves[0]||chaves[1]||chaves[2]||chaves[3]||chaves[4]||chaves[5]||chaves[6]||chaves[7]);
    assign db_seletor_rom = seletor_rom_reg;
	  assign db_contagem_erros = db_erros_wire;
    assign db_jogada = s_jogada;

endmodule

// Modificacoes recentes:
// - Saida de depuracao db_tem_jogada passou a considerar 8 chaves para indicar se tem jogada ou nao, ao inves de considerar apenas 4 chaves
// - Registrador da jogada passou a ser de 8 bits para armazenar a letra completa em ascii
// - Trocas de nomenclaturas: db_dado --> db_letra, db_contagem --> db_endereco_letra