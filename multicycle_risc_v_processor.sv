module multicycle_risc_v_processor(
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] Adr,
    output logic [31:0] WriteData,
    output logic        MemWrite,
    input  logic [31:0] ReadData
);

    // --- Ara Bağlantı Sinyalleri ---
    // Datapath'ten Controller'a giden komut ve durum sinyalleri
    logic [6:0] op;
    logic [2:0] funct3;
    logic       funct7b5;
    logic       zero;
    
    // Controller'dan Datapath'e giden kontrol sinyalleri
    logic [1:0] immsrc;
    logic [1:0] alusrca, alusrcb;
    logic [1:0] resultsrc;
    logic       adrsrc;
    logic [2:0] alucontrol;
    logic       irwrite, pcwrite;
    logic       regwrite;

    // --- Controller Modülü Örneklendirmesi (Instantiation) ---
    controller c (
        .clk(clk),
        .reset(reset),
        .op(op),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .zero(zero),
        .immsrc(immsrc),
        .alusrca(alusrca),
        .alusrcb(alusrcb),
        .resultsrc(resultsrc),
        .adrsrc(adrsrc),
        .alucontrol(alucontrol),
        .irwrite(irwrite),
        .pcwrite(pcwrite),
        .regwrite(regwrite),
        .memwrite(MemWrite) // Dış belleğe yazma izni
    );

    // --- Datapath Modülü Örneklendirmesi (Instantiation) ---
    datapath dp (
        .clk(clk),
        .reset(reset),
        .Adr(Adr),               // Dış belleğe giden adres
        .WriteData(WriteData),   // Dış belleğe yazılacak veri
        .ReadData(ReadData),     // Dış bellekten okunan veri
        .PCWrite(pcwrite),
        .AdrSrc(adrsrc),
        .IRWrite(irwrite),
        .ResultSrc(resultsrc),
        .ALUSrcA(alusrca),
        .ALUSrcB(alusrcb),
        .ImmSrc(immsrc),
        .ALUControl(alucontrol),
        .RegWrite(regwrite),
        .op(op),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .Zero(zero)
    );

endmodule