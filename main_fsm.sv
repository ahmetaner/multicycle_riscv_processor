module main_fsm(
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] op,
    output logic       adrsrc,
    output logic       irwrite,
    output logic [1:0] alusrca,
    output logic [1:0] alusrcb,
    output logic [1:0] aluop,
    output logic [1:0] resultsrc,
    output logic       pcupdate,
    output logic       branch,
    output logic       regwrite,
    output logic       memwrite
);

    typedef enum logic [3:0]{
        Fetch    = 4'b0000,
        Decode   = 4'b0001,
        MemAdr   = 4'b0010,
        MemRead  = 4'b0011,
        MemWB    = 4'b0100,
        MemWrite = 4'b0101,
        ExecuteR = 4'b0110,
        ALUWB    = 4'b0111,
        Executel = 4'b1000,
        JAL      = 4'b1001,
        BEQ      = 4'b1010
    } main_fsm_state;
    
    main_fsm_state next_state, current_state;	

    // main_fsm register
    always_ff @(posedge clk or posedge reset)
        if(reset) begin
            current_state <= Fetch;
        end else begin
            current_state <= next_state;
        end

    // combinational logic
    always_comb begin 
        // default assigns
        adrsrc    = 1'b0;
        irwrite   = 1'b0;
        alusrca   = 2'b00;
        alusrcb   = 2'b00;
        aluop     = 2'b00;
        resultsrc = 2'b00;
        pcupdate  = 1'b0;
        branch    = 1'b0;
        regwrite  = 1'b0;
        memwrite  = 1'b0;
        next_state = current_state;
        
        unique case(current_state)
            Fetch: begin
                adrsrc    = 1'b0;
                irwrite   = 1'b1;
                alusrca   = 2'b00; // PC
                alusrcb   = 2'b01; // DÜZELTİLDİ: 4 seçilmeli (PC+4 için)
                aluop     = 2'b00;
                resultsrc = 2'b10; // ALUResult
                pcupdate  = 1'b1;
                next_state = Decode;
            end
            
            Decode: begin
                alusrca = 2'b01; // OldPC
                alusrcb = 2'b10; // DÜZELTİLDİ: ImmExt (Branch/JAL hedefi hesaplamak için)
                aluop   = 2'b00;
                
                if(op == 7'b0000011 || op == 7'b0100011) begin
                    next_state = MemAdr;
                end else if(op == 7'b0110011) begin
                    next_state = ExecuteR;
                end else if(op == 7'b0010011) begin
                    next_state = Executel;
                end else if(op == 7'b1101111) begin
                    next_state = JAL;
                end else if(op == 7'b1100011) begin
                    next_state = BEQ;
                end
            end
            
            MemAdr: begin
                alusrca = 2'b10; // A yazmacı
                alusrcb = 2'b10; // DÜZELTİLDİ: ImmExt (Base + Offset için)
                aluop   = 2'b00;
                
                if(op == 7'b0000011) begin
                    next_state = MemRead;
                end else if(op == 7'b0100011) begin
                    next_state = MemWrite;
                end
            end
            
            MemRead: begin
                resultsrc = 2'b00;
                adrsrc    = 1'b1;
                next_state = MemWB;
            end
            
            MemWB: begin
                resultsrc = 2'b01;
                regwrite  = 1'b1;
                next_state = Fetch;
            end
            
            MemWrite: begin
                resultsrc = 2'b00;
                adrsrc    = 1'b1;
                memwrite  = 1'b1;
                next_state = Fetch;
            end
            
            ExecuteR: begin
                alusrca = 2'b10;
                alusrcb = 2'b00;
                aluop   = 2'b10;
                next_state = ALUWB;
            end
            
            ALUWB: begin
                resultsrc = 2'b00; // ALUOut
                regwrite  = 1'b1;
                next_state = Fetch;
            end
            
            Executel: begin
                alusrca = 2'b10; // A yazmacı
                alusrcb = 2'b10; // DÜZELTİLDİ: ImmExt (I-Type anlık veri)
                aluop   = 2'b10;
                next_state = ALUWB;
            end
            
            JAL: begin
                alusrca   = 2'b01; // OldPC
                alusrcb   = 2'b01; // DÜZELTİLDİ: 4 (Dönüş adresi OldPC+4 hesaplanacak)
                aluop     = 2'b00; 
                resultsrc = 2'b00; // DÜZELTİLDİ: Decode'da hesaplanan ALUOut (Hedef Adres) PC'ye yazılır
                pcupdate  = 1'b1;
                next_state = ALUWB; // Bir sonraki döngüde OldPC+4 değeri rd yazmacına yazılır
            end
            
            BEQ: begin
                alusrca   = 2'b10;
                alusrcb   = 2'b00;
                aluop     = 2'b01; // Çıkarma (Comparison)
                resultsrc = 2'b00; // ALUOut (Branch Hedef Adresi)
                branch    = 1'b1;
                next_state = Fetch;
            end
            
        endcase
    end
endmodule