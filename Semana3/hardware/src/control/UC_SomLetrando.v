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
module unidade_controle  (
    input           clock,
    input           reset,
    input           jogar,
    input           jogada,
    input           igual,
    input           modo,
    input           fim_palavra,
    input           limite_erros,
    input           tx_ready,
    input           ignora_tx_inicial,
    output reg      enable_rom,
    output reg      zeraSeletor,
    output reg      start_tx,
    output reg      enable_modo,
    output reg      enable_palavra,
    output reg      zera_contador,
    output reg      zera_registrador,
    output reg      conta_erro,
    output reg      incrementa_endereco,
    output reg      registraR,
    output reg      load_end_inicial,
    output reg      acertou,
    output reg      zera_contador_erros,
    output reg      errou,
    output reg      pronto,
    output reg [3:0] db_estado
);

    parameter inicial          = 5'b00000;  // 0
    parameter preparacao       = 5'b00001;  // 1
    parameter load_ponteiro    = 5'b00010;  // 2
    parameter load_rom         = 5'b00011;  // 3
    parameter espera_memoria   = 5'b00100;  // 4
    parameter espera_contador  = 5'b00101;  // 5
    parameter espera           = 5'b00110;  // 6
    parameter registra         = 5'b00111;  // 7
    parameter comparacao       = 5'b01000;  // 8
    parameter incrementa_reg   = 5'b01001;  // 9
    parameter muda_dado        = 5'b01010;  // A
    parameter proximo          = 5'b01011;  // B
    parameter envia_letra      = 5'b01100;  // C
    parameter espera_tx        = 5'b01101;  // D
    parameter vitoria          = 5'b01110;  // E
    parameter derrota          = 5'b01111;  // F
    parameter errado           = 5'b10000;  // 10

    reg modo_transmissao;
    reg [4:0] Eatual, Eprox;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            Eatual <= inicial;
            modo_transmissao <= 1'b0;
        end else begin
            Eatual <= Eprox;
            if (Eatual == preparacao)
                modo_transmissao <= ignora_tx_inicial ? 1'b0 : 1'b1;
            // Encerra o modo de transmissao somente apos transmitir o caractere de parada (0000000).
            else if (Eatual == espera_tx && modo_transmissao && tx_ready && fim_palavra)
                modo_transmissao <= 1'b0;
        end
    end

    always @* begin
        case (Eatual)
            inicial:         Eprox = jogar ? preparacao : inicial;
            preparacao:      Eprox = load_ponteiro;
            load_ponteiro:   Eprox = load_rom;
            load_rom:        Eprox = espera_memoria;
            espera_memoria:  Eprox = espera_contador;
            espera_contador: Eprox = (ignora_tx_inicial ? 1'b0 : modo_transmissao) ? envia_letra : espera;

            // Desvio para transmissao serial
            envia_letra:     Eprox = espera_tx;
            // Se a letra transmitida foi o terminador, finaliza o modo de transmissao.
            espera_tx:       Eprox = tx_ready ? (fim_palavra ? espera_contador : incrementa_reg) : espera_tx;

            // Fluxo de jogada
            espera:          Eprox = jogada ? registra : espera;
            registra:        Eprox = comparacao;
            comparacao:      Eprox = ~igual ? errado : incrementa_reg;
            incrementa_reg:  Eprox = muda_dado;
            muda_dado:       Eprox = proximo;
            // Em modo de transmissao inicial, sempre envia a proxima letra (inclui terminador).
            proximo:         Eprox = modo_transmissao ? envia_letra: (fim_palavra ? vitoria : espera);
            errado:          Eprox = limite_erros ? derrota : espera;
            derrota:         Eprox = jogar ? inicial : derrota;
            vitoria:         Eprox = jogar ? inicial : vitoria;
            default:         Eprox = inicial;
        endcase
    end

    always @* begin
        zera_contador        = (Eatual == inicial) ? 1'b1 : 1'b0;
        zera_registrador     = (Eatual == preparacao || Eatual == inicial) ? 1'b1 : 1'b0;
        zeraSeletor          = (Eatual == inicial) ? 1'b1 : 1'b0;
        registraR            = (Eatual == registra) ? 1'b1 : 1'b0;
        enable_modo          = (Eatual == load_ponteiro) ? 1'b1 : 1'b0;
        enable_rom           = (Eatual == preparacao) ? 1'b1 : 1'b0;
        enable_palavra       = (Eatual == load_rom) ? 1'b1 : 1'b0;
        pronto               = (Eatual == vitoria || Eatual == derrota) ? 1'b1 : 1'b0;
        acertou              = (Eatual == vitoria) ? 1'b1 : 1'b0;
        errou                = (Eatual == derrota) ? 1'b1 : 1'b0;
        conta_erro           = (Eatual == errado) ? 1'b1 : 1'b0;
        incrementa_endereco  = (Eatual == incrementa_reg) ? 1'b1 : 1'b0;
        load_end_inicial     = (Eatual == espera_contador) ? 1'b1 : 1'b0;
        start_tx             = (Eatual == envia_letra) ? 1'b1 : 1'b0;
        zera_contador_erros  = (Eatual == inicial || Eatual == preparacao || (Eatual == proximo && ~modo)) ? 1'b1 : 1'b0;
        case (Eatual)
            inicial:         db_estado = 4'b0000;  // 0
            preparacao:      db_estado = 4'b0001;  // 1
            load_ponteiro:   db_estado = 4'b0010;  // 2
            load_rom:        db_estado = 4'b0011;  // 3
            espera_memoria:  db_estado = 4'b0100;  // 4
            espera_contador: db_estado = 4'b0101;  // 5
            espera:          db_estado = 4'b0110;  // 6
            registra:        db_estado = 4'b0111;  // 7
            comparacao:      db_estado = 4'b1000;  // 8
            incrementa_reg:  db_estado = 4'b1001;  // 9
            muda_dado:       db_estado = 4'b1010;  // A
            proximo:         db_estado = 4'b1011;  // B
            envia_letra:     db_estado = 4'b1100;  // C
            espera_tx:       db_estado = 4'b1101;  // D
            vitoria:         db_estado = 4'b1110;  // E
            derrota:         db_estado = 4'b1111;  // F
            errado:          db_estado = 4'b1111;  // F
            default:         db_estado = 4'b0000;
        endcase
    end

endmodule

// Features
// Estados para mandar palavras para o PC (transmissao serial)

