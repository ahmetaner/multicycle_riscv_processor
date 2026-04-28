module alu(input  logic [31:0] a, b,
           input  logic [ 2:0] alucontrol,
           output logic [31:0] result,
           output logic        zero);

    always_comb
        case(alucontrol)
            3'b010: result = a + b;                   // Toplama (Add)
            3'b110: result = a - b;                   // Çıkarma (Subtract)
            3'b000: result = a & b;                   // VE (AND)
            3'b001: result = a | b;                   // VEYA (OR)
            3'b111: result = (a < b) ? 32'd1 : 32'd0; // Küçüktür (SLT)
            default: result = 32'bx;
        endcase

    assign zero = (result == 32'b0);

endmodule