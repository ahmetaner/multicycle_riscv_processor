module top(
    input  logic        clk, 
    input  logic        reset, 
    output logic [31:0] WriteData, 
    output logic [31:0] Adr, 
    output logic        MemWrite
);

    logic [31:0] ReadData;

    
    multicycle_risc_v_processor rvmulti (
        .clk(clk),
        .reset(reset),
        .Adr(Adr),                
        .WriteData(WriteData),    
        .MemWrite(MemWrite),
        .ReadData(ReadData)  
    );

  
    mem memory (
        .clk(clk),
        .we(MemWrite),        
        .a(Adr),              
        .wd(WriteData),       
        .rd(ReadData)          
    );

endmodule