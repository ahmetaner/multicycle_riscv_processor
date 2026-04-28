module mem(
    input  logic        clk, 
    input  logic        we,
    input  logic [31:0] a, 
    input  logic [31:0] wd,
    output logic [31:0] rd
);

    logic [31:0] RAM[63:0]; 

    // Belleğe başlangıç test kodunun yüklenmesi
    initial begin
        $readmemh("C:/Users/atkay/Desktop/4.3/ileri_sayisal/lab 2/Preliminary_Work_2/riscvtest.txt", RAM); 
    end

    // Word-aligned (kelime hizalı) okuma işlemi
    assign rd = RAM[a[31:2]]; 

    // Saat vuruşunun yükselen kenarında word-aligned yazma işlemi
    always_ff @(posedge clk) begin 
        if (we) RAM[a[31:2]] <= wd;
    end

endmodule