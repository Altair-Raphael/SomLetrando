`timescale 1ns/1ns
// Testbench de cenarios de dificuldade, com alternancia de modo e validacao de derrota por erros.

module tb_dificuldade;
    reg         clock_in     = 1;
    reg         reset_in     = 1;
    reg         iniciar_in   = 0;
    reg         modo_in      = 0;
    reg         ajuda_in     = 0;
    reg         confirmar_in = 0;
    reg  [6:0]  chaves_in    = 7'b0000000;

    wire        acertou_out;
    wire        errou_out;
    wire        pronto_out;
    wire [6:0]  leds_out;
    wire        db_igual_out;
    wire [6:0]  db_contagem_erros_out;
    wire [6:0]  db_rom_escolhida_out;
    wire [6:0]  db_endereco_letra_out;
    wire [6:0]  db_letra_more_out;
    wire [6:0]  db_letra_less_out;
    wire [6:0]  db_estado_out;
    wire        db_clock_out;
    wire        db_iniciar_out;
    wire        db_tem_jogada_out;
    wire        db_modo_out;
    wire        db_confirmar_out;

    wire [3:0]  seletor_rom_contagem_out;
    wire [3:0]  seletor_rom_reg_out;
    wire [6:0]  jogada_parcial_out;
    wire [6:0]  jogada_decodificada_out;
    wire [6:0]  jogada_registrada_out;
    wire [4:0]  estado_uc_out;

    parameter clockPeriod = 20;
    reg [31:0] caso = 0;

    always #((clockPeriod / 2)) clock_in = ~clock_in;

    SomLetrando dut (
      .clock             ( clock_in               ),
      .reset             ( reset_in               ),
      .jogar             ( iniciar_in             ),
      .confirmar         ( confirmar_in           ),
      .ajuda             ( ajuda_in               ),
      .modo              ( modo_in                ),
      .ignora_tx_inicial ( 1'b1                   ),
      .botoes            ( chaves_in              ),
      .ganhou            ( acertou_out            ),
      .perdeu            ( errou_out              ),
      .pronto            ( pronto_out             ),
      .leds              ( leds_out               ),
      .saida_serial      (                        ),
      .pronto_serial     (                        ),
      .db_igual          ( db_igual_out           ),
      .db_clock          ( db_clock_out           ),
      .db_iniciar        ( db_iniciar_out         ),
      .db_tem_jogada     ( db_tem_jogada_out      ),
      .db_modo           ( db_modo_out            ),
      .db_confirmar      ( db_confirmar_out       ),
      .db_endereco_letra ( db_endereco_letra_out  ),
      .db_rom_escolhida  ( db_rom_escolhida_out   ),
      .db_letra_more     ( db_letra_more_out      ),
      .db_letra_less     ( db_letra_less_out      ),
      .db_contagem_erros ( db_contagem_erros_out  ),
      .db_estado         ( db_estado_out          ),
      .db_tick_serial    (                        ),
      .db_saida_serial   (                        ),
      .db_estado_serial  (                        )
    );

    assign seletor_rom_contagem_out = dut.fd.seletor_rom_contagem;
    assign seletor_rom_reg_out      = dut.fd.seletor_rom_reg;
    assign jogada_parcial_out       = dut.fd.s_jogada_parcial;
    assign jogada_decodificada_out  = dut.fd.s_jogada_decodificada;
    assign jogada_registrada_out    = dut.fd.s_jogada;
    assign estado_uc_out            = dut.uc.Eatual;

    initial begin
      caso = 0;
      clock_in = 1;
      reset_in = 1;
      modo_in = 0;
      ajuda_in = 0;
      confirmar_in = 0;
      iniciar_in = 0;
      chaves_in = 7'b0000000;
      #(4*clockPeriod);

      caso = 1;
      @(negedge clock_in);
      reset_in = 0;

      caso = 2;
      modo_in = 0;
      @(negedge clock_in);
      if (seletor_rom_contagem_out == 4'd1) begin
      end else if (seletor_rom_contagem_out == 4'd2) begin
        @(posedge clock_in);
        @(posedge clock_in);
        @(posedge clock_in);
      end else if (seletor_rom_contagem_out == 4'd3) begin
        @(posedge clock_in);
        @(posedge clock_in);
      end else begin
        @(posedge clock_in);
      end
      @(negedge clock_in);
      iniciar_in = 1;
      #(clockPeriod);
      iniciar_in = 0;
      #(20*clockPeriod);
      if (seletor_rom_reg_out !== 4'd2)

      caso = 3;
      @(negedge clock_in);
      chaves_in = 7'b0000001;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(20*clockPeriod);

      caso = 4;
      modo_in = 1'b1;
      @(negedge clock_in);
      chaves_in = 7'b0100000;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(20*clockPeriod);

      caso = 5;
      @(negedge clock_in);
      chaves_in = 7'b0000001;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(20*clockPeriod);

      caso = 6;
      @(negedge clock_in);
      chaves_in = 7'b0000001;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(20*clockPeriod);

      caso = 7;
      @(negedge clock_in);
      chaves_in = 7'b0000001;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(30*clockPeriod);

      caso = 8;
      modo_in = 1'b1;
      @(negedge clock_in);
      iniciar_in = 1'b1;
      #(clockPeriod);
      iniciar_in = 1'b0;

      @(negedge clock_in);
      if (seletor_rom_contagem_out == 4'd0) begin
      end else if (seletor_rom_contagem_out == 4'd1) begin
        @(posedge clock_in);
        @(posedge clock_in);
        @(posedge clock_in);
      end else if (seletor_rom_contagem_out == 4'd2) begin
        @(posedge clock_in);
        @(posedge clock_in);
      end else begin
        @(posedge clock_in);
      end

      @(negedge clock_in);
      iniciar_in = 1'b1;
      #(clockPeriod);
      iniciar_in = 1'b0;
      #(20*clockPeriod);
      if (seletor_rom_reg_out !== 4'd1)

      caso = 9;
      @(negedge clock_in);
      chaves_in = 7'b0000001;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(20*clockPeriod);

      caso = 10;
      @(negedge clock_in);
      chaves_in = 7'b0001000;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(20*clockPeriod);

      caso = 11;
      @(negedge clock_in);
      chaves_in = 7'b0000001;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(20*clockPeriod);

      caso = 12;
      @(negedge clock_in);
      chaves_in = 7'b0100000;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(20*clockPeriod);

      caso = 13;
      modo_in = 1'b0;
      #(5*clockPeriod);

      caso = 14;
      @(negedge clock_in);
      chaves_in = 7'b0000001;
      #(3*clockPeriod);
      @(negedge clock_in);
      chaves_in = 7'b0000000;
      #(clockPeriod);
      @(negedge clock_in);
      confirmar_in = 1'b1;
      #(clockPeriod);
      confirmar_in = 1'b0;
      #(40*clockPeriod);
      if (errou_out !== 1'b1)
caso = 15;
caso = 99;
      #(30*clockPeriod);
      $stop;
    end
endmodule


