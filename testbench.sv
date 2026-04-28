module testbench();

  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;
  logic [31:0] ReadData;

  // İşlemci Modülü
  multicycle_risc_v_processor dut (
      .clk(clk),
      .reset(reset),
      .Adr(DataAdr),
      .WriteData(WriteData),
      .MemWrite(MemWrite),
      .ReadData(ReadData)
  );

  // --- BELLEK (RAM) EKLENTİSİ BAŞLANGICI ---
  logic [31:0] RAM[63:0]; // 64 kelimelik (256 byte) bir hafıza bloğu

  // Simülasyon başlarken txt dosyasındaki komutları RAM'e yükle
  initial begin
    // Dosya yolunu kendi bilgisayarına göre tam yol olarak da yazabilirsin
    $readmemh("C:/Users/atkay/Desktop/4.2/ileri_sayisal/lab 3/preliminary work/riscvtest.txt", RAM); 
  end

  // Bellekten okuma (Asenkron veya Senkron olabilir, genelde okuma adres verilince anında yapılır)
  // RISC-V adresleri byte bazlıdır (0, 4, 8, C...), bu yüzden [31:2] ile word adresine çeviriyoruz
  assign ReadData = RAM[DataAdr[31:2]]; 

  // Belleğe yazma (Senkron)
  always_ff @(posedge clk) begin
    if (MemWrite) begin
      RAM[DataAdr[31:2]] <= WriteData;
    end
  end
  // --- BELLEK (RAM) EKLENTİSİ SONU ---

  // initial test bloğu
  initial begin
    reset <= 1; # 22;
    reset <= 0;
  end

  // clock üretimi
  always begin
    clk <= 1; # 5; 
    clk <= 0; # 5;
  end

  // Sonuç kontrolü
  always @(negedge clk) begin
    if(MemWrite) begin
      if(DataAdr === 100 & WriteData === 25) begin
        $display("Simulation succeeded");
        $stop;
      end else if (DataAdr !== 96) begin
        $display("Simulation failed");
        $stop;
      end
    end
  end

endmodule