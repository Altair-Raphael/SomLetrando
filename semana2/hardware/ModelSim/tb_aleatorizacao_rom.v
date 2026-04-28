`timescale 1ns/1ns

module circuito_semana2_tb_2;
    reg         clock_in   = 1;
    reg         reset_in   = 0;
    reg         iniciar_in = 0;
    reg         modo_in    = 0;
    reg         confirmar_in = 0;
    reg  [3:0]  chaves_in  = 4'b0000;
    
    wire        acertou_out;
    wire        errou_out;
    wire        pronto_out;
    wire [3:0]  leds_out;
    wire        db_igual_out;
    wire [6:0]  db_contagem_out;
    wire [6:0]  db_memoria_out;
    wire [6:0]  db_estado_out;
    wire        db_clock_out;
    wire        db_iniciar_out;
    wire        db_tem_jogada_out;
    wire        db_modo_out;
    wire [3:0]  estado_uc_out;
    wire [3:0]  jogada_reg_out;
    wire [3:0]  seletor_rom_contagem_out;
    wire [3:0]  seletor_rom_reg_out;
    wire [3:0]  ponteiro_palavra_out;
    wire [3:0]  endereco_out;
    wire [3:0]  dado_rom_out;

    parameter clockPeriod = 100_000;

    reg [31:0] caso = 0;

    always #((clockPeriod / 2)) clock_in = ~clock_in;

    circuito_jogo_sequencias dut (
      .clock          ( clock_in           ),
      .reset          ( reset_in           ),
      .jogar          ( iniciar_in         ),
      .confirmar      ( confirmar_in       ),
      .modo           ( modo_in            ),
      .botoes         ( chaves_in          ),
      .leds           ( leds_out           ),
      .ganhou         ( acertou_out        ),
      .perdeu         ( errou_out          ),
      .pronto         ( pronto_out         ),
      .db_igual       ( db_igual_out       ),
      .db_contagem    ( db_contagem_out    ),
      .db_memoria     ( db_memoria_out     ),
      .db_estado      ( db_estado_out      ),
      .db_clock       ( db_clock_out       ),
      .db_iniciar     ( db_iniciar_out     ),     
      .db_tem_jogada  ( db_tem_jogada_out  ),
      .db_modo        ( db_modo_out        )
    );

    assign estado_uc_out = dut.estado_wire;
    assign jogada_reg_out = dut.fd.s_jogada;
    assign seletor_rom_contagem_out = dut.fd.seletor_rom_contagem;
    assign seletor_rom_reg_out = dut.fd.seletor_rom_reg;
    assign ponteiro_palavra_out = dut.fd.seletor_palavra;
    assign endereco_out = dut.fd.s_endereco;
    assign dado_rom_out = dut.fd.s_dado;

    initial begin
      caso = 0;
      clock_in = 1;
      reset_in = 0;
      modo_in = 1;
      confirmar_in = 0;
      iniciar_in = 0;
      chaves_in = 4'b0000;
      force dut.fd.contador_rom.Q = 4'b0000;
      #clockPeriod;
      release dut.fd.contador_rom.Q;

      caso = 1;
      @(negedge clock_in);
      reset_in = 1;
      #(clockPeriod);
      #(3*clockPeriod);

      caso = 2;
      @(negedge clock_in);
      reset_in = 0;
      #(3*clockPeriod);

      caso = 3;
      @(negedge clock_in);
      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      #(10*clockPeriod);

      caso = 4;
      @(negedge clock_in);
      iniciar_in = 0;
      #(8*clockPeriod);

      caso = 5;
      @(negedge clock_in);
      reset_in = 1;
      iniciar_in = 0;
      #(2*clockPeriod);
      reset_in = 0;
      #(5*clockPeriod);

      caso = 6;
      @(negedge clock_in);
      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      #(10*clockPeriod);

      caso = 7;
      @(negedge clock_in);
      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      #(9*clockPeriod);

      caso = 99;
      #(20*clockPeriod);
      $stop;
    end
endmodule