/*
 * ------------------------------------------------------------------
 *  Arquivo   : mux.v
 *  Projeto   : Experiencia 4 - Desenvolvimento de Projeto de
 *                              Circuitos Digitais com FPGA
 * ------------------------------------------------------------------
 *  Descricao : Multiplexador simples 2:1
 * ------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      02/02/2026  1.0     T2BB8 (labdig)    versao inicial
 * ------------------------------------------------------------------
 */

module mux_n #(parameter bits = 1) (
    input       [bits-1:0] sinal_1,
    input       [bits-1:0] sinal_2,
    input       sel,
    output reg  [bits-1:0] saida
);

always @* begin
    if (sel == 0) begin
        saida <= sinal_1;
    end else begin 
        saida <= sinal_2;
    end 
end 

endmodule