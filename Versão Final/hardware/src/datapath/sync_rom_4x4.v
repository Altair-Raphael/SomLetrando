module sync_rom_4x4 (clock, address, data_out);
    input            clock;
    input      [5:0] address;
    output reg [7:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            // Ponteiros de inicio das palavras na ROM compactada (terminada por 0x00)
            6'd0:  data_out <= 8'd0;
            6'd1:  data_out <= 8'd5;
            6'd2:  data_out <= 8'd10;
            6'd3:  data_out <= 8'd15;
            6'd4:  data_out <= 8'd20;
            6'd5:  data_out <= 8'd25;
            6'd6:  data_out <= 8'd30;
            6'd7:  data_out <= 8'd35;
            6'd8:  data_out <= 8'd40;
            6'd9:  data_out <= 8'd45;
            6'd10: data_out <= 8'd50;
            6'd11: data_out <= 8'd56;
            6'd12: data_out <= 8'd61;
            6'd13: data_out <= 8'd67;
            6'd14: data_out <= 8'd73;
            6'd15: data_out <= 8'd79;
            6'd16: data_out <= 8'd85;
            6'd17: data_out <= 8'd91;
            6'd18: data_out <= 8'd98;
            6'd19: data_out <= 8'd104;
            6'd20: data_out <= 8'd111;
            6'd21: data_out <= 8'd117;
            6'd22: data_out <= 8'd123;
            6'd23: data_out <= 8'd129;
            6'd24: data_out <= 8'd134;
            6'd25: data_out <= 8'd141;
            6'd26: data_out <= 8'd147;
            6'd27: data_out <= 8'd154;
            6'd28: data_out <= 8'd161;
            6'd29: data_out <= 8'd168;
            6'd30: data_out <= 8'd175;
            6'd31: data_out <= 8'd181;
            6'd32: data_out <= 8'd185;
            6'd33: data_out <= 8'd191;
            6'd34: data_out <= 8'd196;
            6'd35: data_out <= 8'd202;
            6'd36: data_out <= 8'd208;
            6'd37: data_out <= 8'd214;
            6'd38: data_out <= 8'd220;
            6'd39: data_out <= 8'd226;
            default: data_out <= 8'd0;
        endcase
    end
endmodule
