module controller(
   input  logic       clk, 
   input  logic       reset,   
   input  logic [6:0] op, 
   input  logic [2:0] funct3, 
   input  logic       funct7b5, 
   input  logic       zero, 
   output logic [1:0] immsrc, 
   output logic [1:0] alusrca, alusrcb, 
   output logic [1:0] resultsrc,  
   output logic       adrsrc, 
   output logic [2:0] alucontrol, 
   output logic       irwrite, pcwrite,  
   output logic       regwrite, memwrite
); 

    // 1. ARA KABLOLAR (Alt modülleri birbirine bağlamak için)
    logic [1:0] aluop;
    logic       branch;
    logic       pcupdate;

    // 2. MAIN FSM BAĞLANTISI (Aşçıbaşı)
    main_fsm fsm_inst (
        .clk(clk),
        .reset(reset),
        .op(op),
        .adrsrc(adrsrc),
        .irwrite(irwrite),
        .alusrca(alusrca),
        .alusrcb(alusrcb),
        .aluop(aluop),             // İç kabloya bağlandı
        .resultsrc(resultsrc),
        .pcupdate(pcupdate),       // İç kabloya bağlandı
        .branch(branch),           // İç kabloya bağlandı
        .regwrite(regwrite),
        .memwrite(memwrite)
    );

    // 3. ALU DECODER BAĞLANTISI [cite: 201-214]
    aludec aludec_inst (
        .opb5(op[5]),              // Opcode'un 5. biti doğrudan bağlanıyor 
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(aluop),             // FSM'nin ürettiği aluop sinyalini alıyor
        .ALUControl(alucontrol)
    );

    // 4. INSTRUCTION DECODER BAĞLANTISI [cite: 245-250]
    instrdec instrdec_inst (
        .op(op),
        .ImmSrc(immsrc)
    );

    // 5. PCWRITE MANTIK KAPILARI 
    // FSM'den gelen branch ve pcupdate sinyallerini kullanarak dışarıya pcwrite'ı veriyoruz.
    assign pcwrite = pcupdate | (branch & zero);

endmodule
