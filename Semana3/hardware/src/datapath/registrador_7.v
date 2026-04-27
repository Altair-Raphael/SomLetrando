//------------------------------------------------------------------
// Arquivo   : registrador_7.v
// Projeto   : SomLetrando
//------------------------------------------------------------------
// Descricao : Registrador de 7 bits
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
    input  [6:0] D,
    output [6:0] Q
);

    reg [6:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule