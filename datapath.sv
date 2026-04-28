module datapath(
    input  logic        clk, reset,
    
    // Bellek (Memory) Bağlantıları
    output logic [31:0] Adr,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData,
    
    // Kontrolcüden (Controller) Gelen Sinyaller
    input  logic        PCWrite, AdrSrc, IRWrite,
    input  logic [1:0]  ResultSrc,
    input  logic [1:0]  ALUSrcA, ALUSrcB,
    input  logic [1:0]  ImmSrc,
    input  logic [2:0]  ALUControl,
    input  logic        RegWrite,
    
    // Kontrolcüye (Controller) Giden Sinyaller
    output logic [6:0]  op,
    output logic [2:0]  funct3,
    output logic        funct7b5,
    output logic        Zero
);

    // Ara kablolar ve yazmaç (register) çıkışları
    logic [31:0] PC, OldPC, Instr, Data;
    logic [31:0] RD1, RD2, A, ALUResult, ALUOut;
    logic [31:0] SrcA, SrcB, Result, ImmExt;

    // --- 1. Bellek Adresi Seçimi (Fetch / Memory) ---
    // AdrSrc: 0 = PC, 1 = ALUOut
    mux2 #(32) adrmux(PC, ALUOut, AdrSrc, Adr);

    // --- 2. Bellek Ara Yazmaçları (IR ve MDR) ---
    // IR (Instruction Register): Yalnızca Fetch aşamasında (IRWrite=1) güncellenir
    flopenr #(32) irreg(clk, reset, IRWrite, ReadData, Instr);
    // MDR (Memory Data Register): Bellekten okunan veriyi tutar
    flopr #(32)   mdrreg(clk, reset, ReadData, Data);

    // Komut parçalarını kontrolcüye (decoder) iletmek için ayırıyoruz
    assign op       = Instr[6:0];
    assign funct3   = Instr[14:12];
    assign funct7b5 = Instr[30];

    // --- 3. Program Counter (PC) ve OldPC Yazmaçları ---
    flopenr #(32) pcreg(clk, reset, PCWrite, Result, PC);
    // Branch (Dallanma) hesaplamaları için komutun okunduğu PC değerini saklar
    flopenr #(32) oldpcreg(clk, reset, IRWrite, PC, OldPC);

    // --- 4. Register File (Yazmaç Öbeği) ---
    regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, RD1, RD2);

    // --- 5. İşaret Uzatma (Sign Extension) ---
    extend ext(Instr[31:7], ImmSrc, ImmExt);

    // --- 6. A ve B Ara Yazmaçları ---
    flopr #(32) areg(clk, reset, RD1, A);
    // B yazmacının çıkışı aynı zamanda belleğe yazılacak veri (WriteData) olarak kullanılır
    flopr #(32) breg(clk, reset, RD2, WriteData); 

    // --- 7. ALU Giriş Multiplexer'ları ---
    // ALUSrcA: 00 = PC, 01 = OldPC, 10 = A yazmacı
    mux3 #(32) srcamux(PC, OldPC, A, ALUSrcA, SrcA);

    // ALUSrcB: 00 = B yazmacı (WriteData), 01 = 4 (PC+4 için), 10 = ImmExt
    mux3 #(32) srcbmux(WriteData, 32'd4, ImmExt, ALUSrcB, SrcB);

    // --- 8. ALU ---
    alu alu_inst(SrcA, SrcB, ALUControl, ALUResult, Zero);

    // --- 9. ALU Çıkış Yazmacı (ALUOut) ---
    flopr #(32) aluoutreg(clk, reset, ALUResult, ALUOut);

    // --- 10. Sonuç (Result) MUX'u ---
    // ResultSrc: 00 = ALUOut, 01 = Data (MDR), 10 = ALUResult (PC'ye doğrudan yazmak için)
    mux3 #(32) resultmux(ALUOut, Data, ALUResult, ResultSrc, Result);

endmodule