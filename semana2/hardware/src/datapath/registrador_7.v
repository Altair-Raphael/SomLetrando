//------------------------------------------------------------------
// Arquivo   : registrador_7.v
// Projeto   : SomLetrando
//------------------------------------------------------------------
// Descricao : Registrador de 8 bits
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//------------------------------------------------------------------
//
module registrador_7 (
    input        clock,
    input        clear,
    input        enable,
    input  [7:0] D,
    output [7:0] Q
);

    reg [7:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule