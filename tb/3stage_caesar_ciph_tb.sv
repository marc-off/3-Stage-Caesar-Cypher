// -----------------------------------------------------------------------------
// Testbench of Caesar's cipher module for debug and corner cases check
// -----------------------------------------------------------------------------
module caesar_ciph_tb_checks;

//tempo di clock 5 rit.
  reg clk = 1'b0;
  always #5 clk = !clk;
  
  //codice per il segnale di reset
  reg rst_n = 1'b0;
  event reset_deassertion;	// event(s), when asserted, can be used as time trigger(s) to synchronize with
  
  initial begin
    #12.8 rst_n = 1'b1;
    -> reset_deassertion;	// trigger event named 'reset_deassertion'
  end
  
  reg        shift_dir_1;
  reg        shift_dir_3;
  reg  [4:0] shift_N_1;
  reg  [4:0] shift_N_3;
  reg  [7:0] ptxt_char;
  reg     input_valid;
  reg     mode;
  wire [7:0] ctxt_char;
  wire    invalid_key;
  wire    invalid_char;
  wire    ready;

  caesar_cipher INSTANCE_NAME (
      .clk                      (clk)
    ,.rst_n                     (rst_n)
    ,.ptxt_valid                (input_valid)
    ,.mode                      (mode)
    ,.key_shift_dir_1           (shift_dir_1)
    ,.key_shift_dir_3           (shift_dir_3)
    ,.key_shift_num_1           (shift_N_1)
    ,.key_shift_num_3           (shift_N_3)
    ,.ptxt_char                 (ptxt_char)
    ,.ctxt_char                 (ctxt_char)
    ,.err_invalid_key_shift_num (invalid_key)
    ,.err_invalid_ptxt_char     (invalid_char)
    ,.ctx_ready                 (ready)
  );
  
  reg [7:0] EXPECTED_GEN;
  reg [7:0] EXPECTED_CHECK;
  reg [7:0] EXPECTED_QUEUE [$];		// Usage of $ to indicate unpacked dimension makes the array dynamic (similar to a C language dynamic array), that is called queue in SystemVerilog
  
  localparam NUL_CHAR = 8'h00;
  
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  
  wire err_invalid_key_shift_num = shift_N_1 > 26 || shift_N_3 > 26 || shift_N_1 == shift_N_3; // control of the conditions on the shift values

  
  wire ptxt_char_is_uppercase_letter = (ptxt_char >= UPPERCASE_A_CHAR) &&
                                       (ptxt_char <= UPPERCASE_Z_CHAR);   //control if the character is uppercase
                                         
  wire ptxt_char_is_lowercase_letter = (ptxt_char >= LOWERCASE_A_CHAR) &&
                                       (ptxt_char <= LOWERCASE_Z_CHAR); //control if the character is lowercase
                                         
  wire ptxt_char_is_letter = ptxt_char_is_uppercase_letter ||
                             ptxt_char_is_lowercase_letter;
    
  wire err_invalid_ptxt_char = !ptxt_char_is_letter; //error signal
  
  wire shift_N_x =  (shift_N_1 + shift_N_3) < 27 ? (shift_N_1 + shift_N_3) : (shift_N_1 + shift_N_3) - 27; //generation of the key_shift_num_x
  
  
  initial begin //below is a set of encryption or decryption carried out with different keys
    @(reset_deassertion);	// Hook reset deassertion (event)
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		shift_dir_1 = 1'b1;	// Set shift direction of 1st stage to left
		shift_dir_3 = 1'b0;	// Set shift direction of 3rd stage to right
		shift_N_1 = 5'd25;	// Set number of positions to be shifted for 1st stage to 25
		shift_N_3 = 5'd5;	// Set number of positions to be shifted for 3st stage to 5
		input_valid = 1'b1;	// 
		mode = 1'b0;		//
    
    fork
    
      begin: STIMULI_1R
        for(int i = 0; i < 26; i++) begin
			 ptxt_char = "A" + i;
          @(posedge clk);
        end
        
        for(int i = 0; i < 26; i++) begin
			 ptxt_char = "a" + i;
          @(posedge clk);
        end
      end: STIMULI_1R
       $display("Cifratura [1;25] [0;5]");
      begin: CHECK_1R
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
        
          $display("%c", ctxt_char);
      
        end
      end: CHECK_1R
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		shift_dir_1 = 1'b0;	// Set shift direction of 1st stage to right	
		shift_dir_3 = 1'b0;	// Set shift direction of 3rd stage to right
		shift_N_1 = 5'd25;	// Set number of positions to be shifted for 1st stage to 25
		shift_N_3 = 5'd26;	// Set number of positions to be shifted for 3st stage to 26
		input_valid = 1'b1;	// 
		mode = 1'b1;		//
		
    
    fork
    
      begin: STIMULI_1L
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);

        end
        
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);

        end
      end: STIMULI_1L
      $display("Decifratura [0;25] [0;26]");
      begin: CHECK_1L
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
       
          $display("%c", ctxt_char);
        
        end
      end: CHECK_1L
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		shift_dir_1 = 1'b0;	// Set shift direction of 1st stage to right
		shift_dir_3 = 1'b1;	// Set shift direction of 3rd stage to left
		shift_N_1 = 5'd5;	// Set number of positions to be shifted for 1st stage to 5
		shift_N_3 = 5'd6;	// Set number of positions to be shifted for 3st stage to 6
		input_valid = 1'b1;	// 
		mode = 1'b0;		//
    
    fork
    
      begin: STIMULI_5R
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
 
        end
        
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
 
        end
      end: STIMULI_5R
        $display("Cifratura [0;5] [1;6]");
      begin: CHECK_5R
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
      
          $display("%c", ctxt_char);
     
        end
      end: CHECK_5R
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		shift_dir_1 = 1'b1;	// Set shift direction of 1st stage to left
		shift_dir_3 = 1'b0;	// Set shift direction of 3rd stage to right
		shift_N_1 = 5'd10;	// Set number of positions to be shifted for 1st stage to 10
		shift_N_3 = 5'd2;	// Set number of positions to be shifted for 3st stage to 2
		input_valid = 1'b1;	// 
		mode = 1'b1;		//
    
    fork
    
      begin: STIMULI_5L
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
      
        end
        
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
     
        end
      end: STIMULI_5L
        $display("Decifratura [1;10] [0;2]");
      begin: CHECK_5L
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
      
          $display("%c", ctxt_char);
    
        end
      end: CHECK_5L
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		shift_dir_1 = 1'b1;	// Set shift direction of 1st stage to left
		shift_dir_3 = 1'b1;	// Set shift direction of 3rd stage to left
		shift_N_1 = 5'd5;	// Set number of positions to be shifted for 1st stage to 5
		shift_N_3 = 5'd20;	// Set number of positions to be shifted for 3st stage to 20
		input_valid = 1'b1;	// 
		mode = 1'b0;		//
    
    fork
    
      begin: STIMULI_1R_FULL_SWEEP
        for(int i = 0; i < 128; i++) begin
          ptxt_char = 8'h00 + i;
          @(posedge clk);
      
        end
      end: STIMULI_1R_FULL_SWEEP
        $display("Cifratura [1;5] [1;20]");
      begin: CHECK_1R_FULL_SWEEP
        @(posedge clk);
        for(int j = 0; j < 128; j++) begin
          @(posedge clk);
    
          $display("%c", ctxt_char);
     
        end
      end: CHECK_1R_FULL_SWEEP
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		shift_dir_1 = 1'b0;	// Set shift direction of 1st stage to right
		shift_dir_3 = 1'b0;	// Set shift direction of 3rd stage to right
		shift_N_1 = 5'd28;	// Set number of positions to be shifted for 1st stage to 28
		shift_N_3 = 5'd1;	// Set number of positions to be shifted for 3st stage to 1
		input_valid = 1'b1;	// 
		mode = 1'b1;		//
    
    fork
    
      begin: STIMULI_1R_INVALID_SHIFT_N
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "A" + i;
          @(posedge clk);
       
        end
        
        for(int i = 0; i < 26; i++) begin
          ptxt_char = "a" + i;
          @(posedge clk);
     
        end
      end: STIMULI_1R_INVALID_SHIFT_N
        $display("Decifratura [0;28] [0;1]");
      begin: CHECK_1R_INVALID_SHIFT_N
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
      
          $display("%c ", ctxt_char);
       
        end
      end: CHECK_1R_INVALID_SHIFT_N
        
    join
    
    $stop;
    
  end

endmodule
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// Testbench for file encryption
// -----------------------------------------------------------------------------

module caesar_ciph_tb_file_enc;

  reg clk = 1'b0;
  always #5 clk = !clk;
  
  reg rst_n = 1'b0;
  event reset_deassertion;
  
  initial begin
    #12.8 rst_n = 1'b1;
    -> reset_deassertion;
  end
  
  reg        shift_dir_1;
  reg        shift_dir_3;
  reg  [4:0] shift_N_1;
  reg  [4:0] shift_N_3;
  reg  [7:0] ptxt_char;
  reg     input_valid;
  reg     mode;
  wire [7:0] ctxt_char;
  wire    invalid_key;
  wire    invalid_char;
  wire    ready;

  caesar_cipher INSTANCE_NAME (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.ptxt_valid         (input_valid)
    ,.mode            (mode)
    ,.key_shift_dir_1             (shift_dir_1)
    ,.key_shift_dir_3             (shift_dir_3)
    ,.key_shift_num_1            (shift_N_1)
    ,.key_shift_num_3            (shift_N_3)
    ,.ptxt_char                 (ptxt_char)
    ,.ctxt_char                 (ctxt_char)
    ,.err_invalid_key_shift_num (invalid_key)
    ,.err_invalid_ptxt_char     (invalid_char)
    ,.ctx_ready         (ready)
  );
 
  
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  localparam NUL_CHAR = 8'h20;
  
  int FP_PTXT;
  int FP_CTXT;
  string char;

  //buffers used to contain the encrypted and decrypted characters and those present in the source files of model C

  //test 1
  reg [7:0] CTXT [$];
  reg [7:0] PTXT [$];
  reg [7:0] PTXT_source [$];
  reg [7:0] CTXT_source [$];
  
  //test 2
  reg [7:0] CTXT2 [$];
  reg [7:0] PTXT2 [$];
  reg [7:0] PTXT_source2 [$];
  reg [7:0] CTXT_source2 [$];
  
  
  
  initial begin
    @(reset_deassertion);
    
    @(posedge clk);
    FP_PTXT = $fopen("model/prova.txt", "r");  //the file containing the text to be encrypted is opened
    $write("Encrypting file 'model/prova.txt' to 'tv/ctxt_HW.txt'... ");
   	shift_dir_1 = 1'b1;
		shift_dir_3 = 1'b0;
		shift_N_1 = 5'd16;
		shift_N_3 = 5'd1;
		input_valid = 1'b1;
		mode = 1'b0;
    
    while($fscanf(FP_PTXT, "%c", char) == 1) begin  //the characters of the file are encrypted and placed in a buffer
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        CTXT.push_back(ctxt_char);
      end
      else begin
        CTXT.push_back(NUL_CHAR);
		end;
    end
    $fclose(FP_PTXT);
    
    FP_CTXT = $fopen("tv/ctxt_HW.txt", "w"); //the file to write the ciphertext is opened and the cypher was written
    foreach(CTXT[i])
      $fwrite(FP_CTXT, "%c", CTXT[i]);
    $fclose(FP_CTXT);
    
    $display("Encrypt Done!");
	
	FP_PTXT = $fopen("model/enc.txt", "r"); //the file containing the encrypted text by the C module is opened
	while($fscanf(FP_PTXT, "%c", char) == 1) begin //the characters of the file are placed in a buffer
      ptxt_char = int'(char);
      begin
		CTXT_source.push_back(ptxt_char);
      end
    end;
    $fclose(FP_PTXT);
		
	if(CTXT != CTXT_source)begin //the characters encrypted by the hardware module and the C module are compared
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
	
	 $display("Compare Done model/enc.txt - tv/enc_HW.txt!");
    
    @(posedge clk);
    FP_CTXT = $fopen("tv/ctxt_HW.txt", "r"); //the file containing the encrypted text is opened
    $write("Decrypting file 'tv/ctxt_HW.txt' to 'tv/dec_HW.txt'... ");
		mode = 1'b1;
    
    while($fscanf(FP_CTXT, "%c", char) == 1) begin //the characters of the file are decrypted and placed in a buffer
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        PTXT.push_back(ctxt_char);
      end
      else
        PTXT.push_back(NUL_CHAR);
    end
    $fclose(FP_CTXT);
    
    FP_PTXT = $fopen("tv/dec_HW.txt", "w"); //the file to write the decrypted text is opened and the decryption was written
    foreach(PTXT[i])
      $fwrite(FP_PTXT, "%c", PTXT[i]);
    $fclose(FP_PTXT);
	
	$display("Decrypt Done!");
	
	FP_PTXT = $fopen("model/dec.txt", "r"); //the file containing the decrypted text by the C module is opened
	while($fscanf(FP_PTXT, "%c", char) == 1) begin //the characters of the file are placed in a buffer
      ptxt_char = int'(char);
      begin
		PTXT_source.push_back(ptxt_char);
      end
    end;
    $fclose(FP_PTXT);

	 
	if(PTXT != PTXT_source)begin //the characters decrypted by the hardware module and the C module are compared
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
    
    $display("Compare Done model/dec.txt - tv/dec_HW.txt!");
	

  
  /*-------------------test 2----------------------------*/
    
    @(posedge clk);
    FP_PTXT = $fopen("model/prova2.txt", "r");
    $write("Encrypting file 'model/prova2.txt' to 'tv/ctxt_HW2.txt'... ");
   		shift_dir_1 = 1'b1;
		shift_dir_3 = 1'b0;
		shift_N_1 = 5'd16;
		shift_N_3 = 5'd1;
		input_valid = 1'b1;
		mode = 1'b0;
    
    while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        CTXT2.push_back(ctxt_char);
      end
      else begin
        CTXT2.push_back(NUL_CHAR);
		end;
    end
    $fclose(FP_PTXT);
    
    FP_CTXT = $fopen("tv/ctxt_HW2.txt", "w");
    foreach(CTXT2[i])
      $fwrite(FP_CTXT, "%c", CTXT2[i]);
    $fclose(FP_CTXT);
    
    $display("Encrypt Done!");
	
	FP_PTXT = $fopen("model/enc2.txt", "r");
	while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      begin
		CTXT_source2.push_back(ptxt_char);
      end
    end;
    $fclose(FP_PTXT);
		
	if(CTXT2 != CTXT_source2)begin
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
	
	 $display("Compare Done model/enc2.txt - tv/enc_HW2.txt!");
    
    @(posedge clk);
    FP_CTXT = $fopen("tv/ctxt_HW2.txt", "r");
    $write("Decrypting file 'tv/ctxt_HW2.txt' to 'tv/dec_HW2.txt'... ");
		mode = 1'b1;
    
    while($fscanf(FP_CTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      @(posedge clk);
      if(
        ((ptxt_char >= UPPERCASE_A_CHAR ) && (ptxt_char <= UPPERCASE_Z_CHAR)) ||
        ((ptxt_char >= LOWERCASE_A_CHAR ) && (ptxt_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        PTXT2.push_back(ctxt_char);
      end
      else
        PTXT2.push_back(NUL_CHAR);
    end
    $fclose(FP_CTXT);
    
    FP_PTXT = $fopen("tv/dec_HW2.txt", "w");
    foreach(PTXT2[i])
      $fwrite(FP_PTXT, "%c", PTXT2[i]);
    $fclose(FP_PTXT);
	
	$display("Decrypt Done!");
	
	FP_PTXT = $fopen("model/dec2.txt", "r");
	while($fscanf(FP_PTXT, "%c", char) == 1) begin
      ptxt_char = int'(char);
      begin
		PTXT_source2.push_back(ptxt_char);
      end
    end;
    $fclose(FP_PTXT);

	 
	if(PTXT2 != PTXT_source2)begin
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
    
    $display("Compare Done model/dec2.txt - tv/dec_HW2.txt!");
    
    $stop;
  end

endmodule

// -----------------------------------------------------------------------------
