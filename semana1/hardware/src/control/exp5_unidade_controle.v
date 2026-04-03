/*
 * ------------------------------------------------------------------
 *  Arquivo   : exp5_unidade_controle.v
 *  Projeto   : Experiencia 5 - Projeto de um Jogo de Sequências de Jogadas
 * ------------------------------------------------------------------
 *  Descricao : Unidade de controle projetada para a Atividade 5 baseada na UC da atividade 4 com adi
 * ------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      28/01/2026  1.0     T2BB8 (labdig)    versao inicial
 * ------------------------------------------------------------------
 */
module unidade_controle (
    input           clock,
    input           reset,
    input           jogar,
    input           fimL,
    input           jogada,
    input           igual,
    input 			fim_temp, 
    input           enderecoIgualLimite,
	output reg      conta,
	output reg      zera_contagem,
    output reg      zeraSeletor,
    output reg      enable_modo,
    output reg      zeraL,
    output reg      zeraC,
    output reg      contaC,
    output reg      contaL,
    output reg      zeraR,
    output reg      registraR,
    output reg      acertou,
    output reg      errou,
    output reg      pronto,
    output reg      timeout,
    output reg [3:0] db_estado
);

    parameter inicial    = 4'b0000;  // 0
    parameter preparacao = 4'b0001;  // 1
    parameter rodada_n   = 4'b0010;  // 2
    parameter espera     = 4'b0011;  // 3
    parameter registra   = 4'b0100;  // 4
    parameter comparacao = 4'b0101;  // 5
    parameter proximo    = 4'b0110;  // 6
    parameter acerto     = 4'b1100;  // C
    parameter erro       = 4'b1110;  // E
    parameter erro_temp  = 4'b1111;  // F

    reg [3:0] Eatual, Eprox;

    always @(posedge clock or posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox;
    end

    always @* begin
        case (Eatual)
            inicial:     Eprox = jogar ? preparacao : inicial;
            preparacao:  Eprox = espera;
            rodada_n:    Eprox = espera;
            espera:      Eprox = jogada ? registra : espera;
            registra:    Eprox = comparacao;
            comparacao:  Eprox = ~igual ? erro : proximo;
            proximo:     Eprox = fimL ? acerto : enderecoIgualLimite ? rodada_n : espera;
            erro:        Eprox = jogar ? preparacao : erro;
            acerto:      Eprox = jogar ? preparacao : acerto;  
            erro_temp:   Eprox = jogar ? preparacao : erro_temp;
            default:     Eprox = inicial;
        endcase
    end

    always @* begin
        zeraL     = (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0;
        zeraC     = (Eatual == inicial || Eatual == preparacao || Eatual == rodada_n) ? 1'b1 : 1'b0; 
        zeraR     = (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0;
        zeraSeletor = reset ? 1'b1 : 1'b0;
        conta     = (Eatual == espera) ? 1'b1 : 1'b0;
		zera_contagem = (Eatual == registra || Eatual == preparacao) ? 1'b1 : 1'b0;
        registraR = (Eatual == registra) ? 1'b1 : 1'b0;
        enable_modo = (Eatual == preparacao) ? 1'b1 : 1'b0;
        contaL    = (Eatual == rodada_n) ? 1'b1 : 1'b0;
        contaC    = (Eatual == proximo) ? 1'b1 : 1'b0;
        pronto    = (Eatual == acerto || Eatual == erro || Eatual == erro_temp) ? 1'b1 : 1'b0;
        acertou    = (Eatual == acerto) ? 1'b1 : 1'b0;
        errou      = (Eatual == erro) ? 1'b1 : 1'b0; 
        timeout    = (Eatual == erro_temp) ? 1'b1 : 1'b0;
        
        // Saida de depuracao (estado)
        case (Eatual)
            inicial:     db_estado = 4'b0000;  // 0
            preparacao:  db_estado = 4'b0001;  // 1
            rodada_n:    db_estado = 4'b0010;  // 2  
            espera:      db_estado = 4'b0011;  // 3
            registra:    db_estado = 4'b0100;  // 4
            comparacao:  db_estado = 4'b0101;  // 5
            proximo:     db_estado = 4'b0110;  // 6
            acerto:      db_estado = 4'b1100;  // C
            erro:        db_estado = 4'b1110;  // E
            erro_temp:   db_estado = 4'b1111;  // F 
            default:     db_estado = 4'b0000;     
        endcase
		  
    end

endmodule
