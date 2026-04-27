//------------------------------------------------------------------
// Arquivo   : registrador_1.v
// Projeto   : Experiencia 4 - Desenvolvimento de Projeto de
//                              Circuitos Digitais com FPGA
//------------------------------------------------------------------
// Descricao : Registrador de 1 bit
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//------------------------------------------------------------------
//
module registrador_1 (
    input        clock,
    input        clear,
    input        enable,
    input        D,
    output       Q
);

    reg IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule