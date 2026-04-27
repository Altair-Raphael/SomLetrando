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
  input        reset,
    input        zera_contador,
    input        zera_registrador,
    input        registraR,
    input        zeraSeletor,
    input  [6:0] chaves,
    input        confirmar,
    input        incrementa_endereco,
    input        zera_contador_erros,
    input        enable_modo,
    input        enable_palavra,
    input        load_end_inicial,
	  input 		   enable_rom,
    input        conta_erro,
    input        modo,
    output       igual,
    output       jogada_feita,
    output       fim_palavra,
    output       modo_escolhido,
    output       limite_erros,
    output       db_tem_jogada,
	  output [3:0] db_rom_escolhida, 
    output [3:0] db_contagem_erros,
    output [3:0] db_endereco_letra,
	  output [6:0] db_letra,
    output [6:0] db_jogada,
    output       evento_jogada_parcial,
    output [6:0] jogada_parcial_decodificada,
    output [6:0] letra_atual,
    output [3:0] palavra_base
);
    // sinais internos para interligacao dos componentes
   wire   [3:0] s_endereco;
   wire   [6:0] s_letra;
   wire   [6:0] s_jogada;
   wire   [3:0] seletor_rom_contagem;
   wire   [3:0] seletor_palavra;
   wire   [3:0] s_ponteiros_rom;
	wire   [3:0] db_erros_wire;
	wire   [3:0] seletor_rom_reg;
  wire   [6:0] s_jogada_parcial;
  wire         tem_jogada_wire;
  wire         muda_jogada_wire;
  wire         atualiza_jogada_parcial_wire;
  wire   [6:0] s_jogada_decodificada;
   // Contadores
	 // Contador para aleatorizar escolha da ROM
   contador_m #(.M(4), .N(4)) contador_rom (
    .clock	(clock),
    .zera_as(reset),
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
      .zera_s	(zera_contador_erros),
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
      .A    ( {1'b0, s_letra} ),
      .B    ( {1'b0, s_jogada} ),
      .ALBi ( 1'b0 ),
      .AGBi ( 1'b0 ),
      .AEBi ( 1'b1 ),
      .ALBo (  ),
      .AGBo (  ),
      .AEBo ( igual )
    );
    
    // Comparador de fim da palavra
    comparador_85 CompLmt (
      .A    ({1'b0, s_letra}),
      .B    (8'b00000000),
      .ALBi ( 1'b0 ),
      .AGBi ( 1'b0 ),
      .AEBi ( 1'b1 ),
      .ALBo (  ),
      .AGBo (  ),
      .AEBo ( fim_palavra )
    );
    

    // Registradores
    // Registrador da jogada parcial
    registrador_7 registrador_jogada_parcial (
      .clock  (clock),
      .clear  (zera_registrador),
      .enable (atualiza_jogada_parcial_wire),
      .D      (chaves),
      .Q      (s_jogada_parcial)
    );

    // Registrador da jogada confirmada pela UC no estado registra.
    registrador_7 registrador7 (
      .clock  (clock),
      .clear  (zera_registrador),
      .enable (registraR),
      .D      (s_jogada_decodificada),
      .Q      (s_jogada)
    );

    // Registrador da palavra escolhida
    registrador_4 registrador_palavra (
      .clock	(clock),
      .clear	(zeraSeletor),
      .enable	(enable_palavra),
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
  //registrador do modo escolhido
	 registrador_1 registrador_modo (
    .clock	(clock),
    .clear	(zera_registrador),
    .enable	(enable_modo),
    .D		(modo),
    .Q		(modo_escolhido)
   );
    //memoria
    sync_rom_4x4 rom_ponteiros (
      .clock  (clock),
      .address (seletor_rom_reg[1:0]),
      .data_out    (s_ponteiros_rom)
    ); 

    sync_rom_32x4 rom_palavras (
      .clock  (clock),
      .address ({1'b0,s_endereco}),
      .data_out   (s_letra)
    ); 

    // Detector de borda do painel de botões
    edge_detector detector_borda_jogada_parcial (
      .clock (clock),
      .reset (zera_registrador),
      .sinal (muda_jogada_wire),
      .pulso (atualiza_jogada_parcial_wire)
    );

    //detector de borda
    edge_detector detector_borda (
      .clock (clock),
      .reset (zera_registrador),
      .sinal (~confirmar),
      .pulso (jogada_feita)
    );

    decodificador_painel decodificador (
      .botoes (s_jogada_parcial),
      .palavra_selecionada (seletor_rom_reg),
      .jogada_decodificada (s_jogada_decodificada)
    );

    // saidas de depuracao
    assign db_endereco_letra = s_endereco;
	  assign db_letra = s_letra;
    assign tem_jogada_wire = (chaves[0]||chaves[1]||chaves[2]||chaves[3]||chaves[4]||chaves[5]||chaves[6]);
    assign muda_jogada_wire = tem_jogada_wire && (chaves != s_jogada_parcial);
    assign db_tem_jogada = tem_jogada_wire;
    assign db_rom_escolhida = seletor_rom_reg;
	  assign db_contagem_erros = db_erros_wire;
    assign db_jogada = s_jogada;
    assign evento_jogada_parcial = atualiza_jogada_parcial_wire;
    assign jogada_parcial_decodificada = s_jogada_decodificada;
    assign letra_atual = s_letra;
    assign palavra_base = seletor_palavra;

endmodule

// Modificacoes recentes:
// - Adicao de registrador de jogada parcial (one-hot de 7 botoes) com captura por detector de borda no painel.
// - Registrador final da jogada passou a registrar a jogada parcial, removendo a necessidade de apertar simultaneamente tecla+confirmar.
// - Saida de depuracao db_tem_jogada passou a considerar 7 chaves.