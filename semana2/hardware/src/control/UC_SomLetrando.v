/*
 * ------------------------------------------------------------------
 *  Arquivo   : UC_SomLetrando.v
 *  Projeto   : SomLetrando
 * ------------------------------------------------------------------
 *  Descricao : Unidade de controle projetada para o jogo SomLetrando
 * ------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      28/01/2026  1.0     T2BB8 (labdig)    versao inicial
 *      25/03/2026  2.0     T2BB8 (labdig)    ajustes na logica de controle
 * ------------------------------------------------------------------
 */
module unidade_controle (
    input           clock,
    input           reset,
    input           jogar,
    input           jogada,
    input           igual,
    input           fim_palavra,
    input           limite_erros,
    input           tx_ready,
	output reg      enable_rom,
    output reg      zeraSeletor,
    output reg      start_tx,
    output reg      enable_modo,
    output reg      zera_contador,
    output reg      zera_registrador,
    output reg      conta_erro,
    output reg      incrementa_endereco,
    output reg      registraR,
    output reg      load_end_inicial,
    output reg      acertou,
    output reg      errou,
    output reg      pronto,
    output reg [3:0] db_estado
);

    parameter inicial       	= 4'b0000;  // 0
    parameter preparacao   	    = 4'b0001;  // 1
	parameter load_ponteiro 	= 4'b0010;  // 2
	parameter load_rom		 	= 4'b0011;  // 3
    parameter espera        	= 4'b0100;  // 4
    parameter registra      	= 4'b0101;  // 5
    parameter comparacao    	= 4'b0110;  // 6
	parameter incrementa_reg 	= 4'b0111;  // 7
	parameter muda_dado 		= 4'b1000;  // 8
    parameter proximo       	= 4'b1001;  // 9
    parameter envia_letra     	= 4'b1010;  // A
    parameter espera_tx       	= 4'b1011;  // B
    parameter errado        	= 4'b1110;  // E
    parameter vitoria    		= 4'b1100;  // C
    parameter derrota    		= 4'b1111;  // F

    reg modo_transmissao;
    reg [3:0] Eatual, Eprox;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            Eatual <= inicial;
            modo_transmissao <= 1'b0;
        end begin else
            Eatual <= Eprox;
            if (Eatual == preparacao) 
                modo_transmissao <= 1;

            if (Eatual == proximo && modo_transmissao && fim_palavra)
                modo_transmissao <= 0;
        end
    end

    always @* begin
        case (Eatual)
            inicial:        Eprox = jogar ? preparacao : inicial;
            preparacao:     Eprox = load_ponteiro;
			load_ponteiro:  Eprox = load_rom;
			load_rom:	    Eprox = modo_transmissao ? envia_letra : espera;
            // Desvio para transmissao serial
            envia_letra:    Eprox = espera_tx;
            espera_tx:      Eprox = tx_ready ? incrementa_reg : espera_tx;
            //
            espera:         Eprox = jogada ? registra : espera;
            registra:       Eprox = comparacao;
            comparacao:     Eprox = ~igual ? errado : incrementa_reg;
            // Utilizo estados existentes tanto na transmissao quanto no jogo
			incrementa_reg: Eprox = muda_dado;
			muda_dado:      Eprox = proximo;
            proximo:        Eprox = modo_transmissao ? (fim_palavra ? load_rom : envia_letra) : (fim_palavra ? vitoria : espera);
            //
            errado:         Eprox = limite_erros ? derrota : espera;
            derrota:        Eprox = jogar ? inicial : derrota;
            vitoria:        Eprox = jogar ? inicial : vitoria;
            default:        Eprox = inicial;
        endcase
    end

    always @* begin
        zera_contador        = (Eatual == inicial) ? 1'b1 : 1'b0;
        zera_registrador     = (Eatual == preparacao || Eatual == inicial) ? 1'b1 : 1'b0;
        zeraSeletor          = (Eatual == inicial ) ? 1'b1 : 1'b0;
        registraR            = (Eatual == registra) ? 1'b1 : 1'b0;
        enable_modo          = (Eatual == load_ponteiro) ? 1'b1 : 1'b0;
		enable_rom           = (Eatual == inicial) ? 1'b1 : 1'b0;
        pronto               = (Eatual == vitoria || Eatual == derrota) ? 1'b1 : 1'b0;
        acertou              = (Eatual == vitoria) ? 1'b1 : 1'b0;
        errou                = (Eatual == derrota) ? 1'b1 : 1'b0; 
        conta_erro           = (Eatual == errado) ? 1'b1 : 1'b0;
        incrementa_endereco  = (Eatual == incrementa_reg) ? 1'b1 : 1'b0;  
        load_end_inicial     = (Eatual == load_rom) ? 1'b1 : 1'b0;
        start_tx             = (Eatual == envia_letra) ? 1'b1 : 1'b0;

        case (Eatual)
            inicial:     	db_estado = 4'b0000;  // 0
            preparacao:  	db_estado = 4'b0001;  // 1
			load_ponteiro:  db_estado = 4'b0010;  // 2
			load_rom: 		db_estado = 4'b0011;  // 3
            espera:      	db_estado = 4'b0100;  // 4
            registra:    	db_estado = 4'b0101;  // 5
            comparacao:  	db_estado = 4'b0110;  // 6
			incrementa_reg: db_estado = 4'b0111;  // 7
			muda_dado: 		db_estado = 4'b1000;  // 8
            proximo:     	db_estado = 4'b1001;  // 9
            envia_letra:   	db_estado = 4'b1010;  // A
            espera_tx:     	db_estado = 4'b1011;  // B
            errado:      	db_estado = 4'b1110;  // E
            vitoria:     	db_estado = 4'b1100;  // C
            derrota:     	db_estado = 4'b1111;  // F 
            default:     	db_estado = 4'b0000;        
        endcase
    end

endmodule

// Features
// Estados para mandar palavras para o PC (transmissao serial)