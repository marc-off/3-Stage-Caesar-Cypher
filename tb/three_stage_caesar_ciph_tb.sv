// -----------------------------------------------------------------------------
// Testbench of Caesar's cipher module for debug and corner cases check
// -----------------------------------------------------------------------------
module caesar_ciph_tb_checks;

  // Clock time 5ns
  reg clk = 1'b0;
  always #5 clk = !clk;
  
  // Code for the reset signal
  reg rst_n = 1'b0;
  event reset_deassertion;	// event(s), when asserted, can be used as time trigger(s) to synchronize with
  
  initial begin
    #12.8 rst_n = 1'b1;
    -> reset_deassertion;	// trigger event named 'reset_deassertion'
  end
  
  reg        first_shift_direction;       // 1'b0 = right direction; 1'b1 = left direction          
  reg        third_shift_direction;       // 1'b0 = right direction; 1'b1 = left direction
  reg  [4:0] first_shift_number;          // Number of positions to shift can range from 0 to 26 (sup|log2(26)|=5)
  reg  [4:0] third_shift_number;          // Number of positions to shift can range from 0 to 26 (sup|log2(26)|=5)
  reg  [7:0] plaintext_char;              // input port which represents the plaintext char to encrypt
  reg     input_valid;                    // 1'b0 = invalid char; 1'b1 = valid char
  reg     flag_cipher_operation;          // input port to select encryption or decryption mode: 1'b0 = encrypt operation; 1'b1 = decrypt operation
  wire [7:0] ciphertext_char;             // output port which represents the ciphertext char of the corresponding plaintext character
  wire    invalid_key;                    // Flag representing error concerning the key (invalid value of position to shift)
  wire    invalid_char;                   // Flag representing error concerning the plaintext char (invalid 8-bit ASCII value)
  wire    ready;                          // Flag specifying that the ciphertext character is ready to be sampled by the clock signal

  three_stage_caesar_cipher INSTANCE_NAME (
      .clk                      (clk)
    ,.rst_n                     (rst_n)
    ,.flag_valid_plaintext_char                (input_valid)
    ,.flag_cipher_operation                      (flag_cipher_operation)
    ,.first_key_shift_direction            (first_shift_direction)
    ,.third_key_shift_direction            (third_shift_direction)
    ,.first_key_shift_number           (first_shift_number)
    ,.third_key_shift_number           (third_shift_number)
    ,.plaintext_char                 (plaintext_char)
    ,.ciphertext_char                 (ciphertext_char)
    ,.err_invalid_key_shift_num (invalid_key)
    ,.err_invalid_ptxt_char     (invalid_char)
    ,.flag_ciphertext_ready                 (ready)
  );
  
  reg [7:0] EXPECTED_GEN;
  reg [7:0] EXPECTED_CHECK;
  reg [7:0] EXPECTED_QUEUE [$];		// Usage of $ to indicate unpacked dimension makes the array dynamic (similar to a C language dynamic array), that is called queue in SystemVerilog

  localparam NULL_CHAR = 8'h00;
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  
  wire err_invalid_key_shift_num = first_shift_number > 26 || third_shift_number > 26 || first_shift_number == third_shift_number; // control of the conditions on the shift values

  
  wire ptxt_char_is_uppercase_letter = (plaintext_char >= UPPERCASE_A_CHAR) &&
                                       (plaintext_char <= UPPERCASE_Z_CHAR);   //control if the character is uppercase
                                         
  wire ptxt_char_is_lowercase_letter = (plaintext_char >= LOWERCASE_A_CHAR) &&
                                       (plaintext_char <= LOWERCASE_Z_CHAR); //control if the character is lowercase
                                         
  wire ptxt_char_is_letter = ptxt_char_is_uppercase_letter ||
                             ptxt_char_is_lowercase_letter;
    
  wire err_invalid_ptxt_char = !ptxt_char_is_letter; //error signal
  
  wire second_shift_number =  (first_shift_number + third_shift_number) < 26 ? (first_shift_number + third_shift_number) : (first_shift_number + third_shift_number) - 26; //generation of the key_shift_num_x
  
  
  initial begin //below is a set of encryption or decryption carried out with different keys
    @(reset_deassertion);	// Hook reset deassertion (event)
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		first_shift_direction = 1'b1;	// Set shift direction of 1st stage to left
		third_shift_direction = 1'b0;	// Set shift direction of 3rd stage to right
		first_shift_number = 5'd16;	// Set number of positions to be shifted for 1st stage to 16
		third_shift_number = 5'd8;	// Set number of positions to be shifted for 3st stage to 8
		input_valid = 1'b1;	// Setting the plaintext input valid port to 1'b1 : true 
		flag_cipher_operation = 1'b0;		// Setting the cipher operation flag into 1'b0 : encrypt mode
    
    $display("D1: %b - K1: %d - D3: %b - K3: %d - Plaintext Valid Port: %b - Cipher Operation Flag: %b"
            ,first_shift_direction
            ,first_shift_number
            ,third_shift_direction
            ,third_shift_number
            ,input_valid
            ,flag_cipher_operation);

    fork
    
      begin: STIMULI_1R
        for(int i = 0; i < 26; i++) begin
			 plaintext_char = "A" + i;
          @(posedge clk);
        end
        
        for(int i = 0; i < 26; i++) begin
			 plaintext_char = "a" + i;
          @(posedge clk);
        end
      end: STIMULI_1R
      
      $display("Cifratura Di,Ki = <[1;16], [1;24] ,[0;8]>");

      begin: CHECK_1R
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
        
          $display("[ERR_FLAG] Shift Number: %b - [ERR_FLAG] Invalid Char: %b - Encrypted char: (hex)%h - (char)%c", invalid_key, invalid_char, ciphertext_char, ciphertext_char);
      
        end
      end: CHECK_1R
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		first_shift_direction = 1'b0;	// Set shift direction of 1st stage to right	
		third_shift_direction = 1'b0;	// Set shift direction of 3rd stage to right
		first_shift_number = 5'd26;	// Set number of positions to be shifted for 1st stage to 26
		third_shift_number = 5'd3;	// Set number of positions to be shifted for 3st stage to 3
		input_valid = 1'b1;	// Setting the plaintext input valid port to 1'b1 : true
		flag_cipher_operation = 1'b1;	// Setting the cipher operation flag into 1'b1 : decrypt mode
		
    $display("D1: %b - K1: %d - D3: %b - K3: %d - Plaintext Valid Port: %b - Cipher Operation Flag: %b"
            ,first_shift_direction
            ,first_shift_number
            ,third_shift_direction
            ,third_shift_number
            ,input_valid
            ,flag_cipher_operation);
    
    fork
    
      begin: STIMULI_1L
        for(int i = 0; i < 26; i++) begin
          plaintext_char = "A" + i;
          @(posedge clk);

        end
        
        for(int i = 0; i < 26; i++) begin
          plaintext_char = "a" + i;
          @(posedge clk);

        end
      end: STIMULI_1L

      $display("Decifratura Di,Ki = <[0;26], [0;3] ,[0;3]>");

      begin: CHECK_1L
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
       
          $display("[ERR_FLAG] Shift Number: %b - [ERR_FLAG] Invalid Char: %b - Encrypted char: (hex)%h - (char)%c", invalid_key, invalid_char, ciphertext_char, ciphertext_char);
        
        end
      end: CHECK_1L
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		first_shift_direction = 1'b0;	// Set shift direction of 1st stage to right
		third_shift_direction = 1'b1;	// Set shift direction of 3rd stage to left
		first_shift_number = 5'd10;	// Set number of positions to be shifted for 1st stage to 10
		third_shift_number = 5'd7;	// Set number of positions to be shifted for 3st stage to 7
		input_valid = 1'b1;	// Setting the plaintext input valid port to 1'b1 : true
		flag_cipher_operation = 1'b0;		// Setting the cipher operation flag into 1'b0 : encrypt mode
    
    $display("D1: %b - K1: %d - D3: %b - K3: %d - Plaintext Valid Port: %b - Cipher Operation Flag: %b"
            ,first_shift_direction
            ,first_shift_number
            ,third_shift_direction
            ,third_shift_number
            ,input_valid
            ,flag_cipher_operation);

    fork
    
      begin: STIMULI_5R
        for(int i = 0; i < 26; i++) begin
          plaintext_char = "A" + i;
          @(posedge clk);
 
        end
        
        for(int i = 0; i < 26; i++) begin
          plaintext_char = "a" + i;
          @(posedge clk);
 
        end
      end: STIMULI_5R

      $display("Cifratura Di,Ki = <[0;10], [1;17] ,[1;7]>");
      
      begin: CHECK_5R
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);
          $display("[ERR_FLAG] Shift Number: %b - [ERR_FLAG] Invalid Char: %b - Encrypted char: (hex)%h - (char)%c", invalid_key, invalid_char, ciphertext_char, ciphertext_char);
        end
      end: CHECK_5R
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		first_shift_direction = 1'b1;	// Set shift direction of 1st stage to left
		third_shift_direction = 1'b0;	// Set shift direction of 3rd stage to right
		first_shift_number = 5'd14;	// Set number of positions to be shifted for 1st stage to 14
		third_shift_number = 5'd22;	// Set number of positions to be shifted for 3st stage to 22
		input_valid = 1'b1;	// Setting the plaintext input valid port to 1'b1 : true
		flag_cipher_operation = 1'b1;		// Setting the cipher operation flag into 1'b1 : decrypt mode
    
    $display("D1: %b - K1: %d - D3: %b - K3: %d - Plaintext Valid Port: %b - Cipher Operation Flag: %b"
            ,first_shift_direction
            ,first_shift_number
            ,third_shift_direction
            ,third_shift_number
            ,input_valid
            ,flag_cipher_operation);
    
    fork
    
      begin: STIMULI_5L
        for(int i = 0; i < 26; i++) begin
          plaintext_char = "A" + i;
          @(posedge clk);
        end
        
        for(int i = 0; i < 26; i++) begin
          plaintext_char = "a" + i;
          @(posedge clk);
        end
      end: STIMULI_5L

      $display("Decifratura Di,Ki = <[1;14], [1;10] ,[0;22]>");
      
      begin: CHECK_5L
        @(posedge clk);
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);      
          $display("[ERR_FLAG] Shift Number: %b - [ERR_FLAG] Invalid Char: %b - Encrypted char: (hex)%h - (char)%c", 
                    invalid_key, invalid_char, ciphertext_char, ciphertext_char);
        end
      end: CHECK_5L
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		first_shift_direction = 1'b1;	// Set shift direction of 1st stage to left
		third_shift_direction = 1'b1;	// Set shift direction of 3rd stage to left
		first_shift_number = 5'd2;	// Set number of positions to be shifted for 1st stage to 2
		third_shift_number = 5'd7;	// Set number of positions to be shifted for 3st stage to 7
		input_valid = 1'b1;	// Setting the plaintext input valid port to 1'b1 : true
		flag_cipher_operation = 1'b0;	// Setting the cipher operation flag into 1'b0 : encrypt mode
    
    $display("D1: %b - K1: %d - D3: %b - K3: %d - Plaintext Valid Port: %b - Cipher Operation Flag: %b"
            ,first_shift_direction
            ,first_shift_number
            ,third_shift_direction
            ,third_shift_number
            ,input_valid
            ,flag_cipher_operation);

    fork
    
      begin: STIMULI_1R_FULL_SWEEP
        for(int i = 0; i < 128; i++) begin
          plaintext_char = 8'h00 + i;
          @(posedge clk);
        end
      end: STIMULI_1R_FULL_SWEEP

      $display("Cifratura Di,Ki = <[1;2], [0;9] ,[1;7]>");
      
      begin: CHECK_1R_FULL_SWEEP
        @(posedge clk);
        for(int j = 0; j < 128; j++) begin
          @(posedge clk);
          $display("[ERR_FLAG] Shift Number: %b - [ERR_FLAG] Invalid Char: %b - Encrypted char: (hex)%h - (char)%c", invalid_key, invalid_char, ciphertext_char, ciphertext_char);
        end
      end: CHECK_1R_FULL_SWEEP
        
    join
    
    @(posedge clk);	// Hook next rising edge of signal clk (used as clock)
		first_shift_direction = 1'b0;	// Set shift direction of 1st stage to right
		third_shift_direction = 1'b0;	// Set shift direction of 3rd stage to right
		first_shift_number = 5'd28;	// Set number of positions to be shifted for 1st stage to 28
		third_shift_number = 5'd1;	// Set number of positions to be shifted for 3st stage to 1
		input_valid = 1'b1;	// Setting the plaintext input valid port to 1'b1 : true 
		flag_cipher_operation = 1'b1;		// Setting the cipher operation flag into 1'b1 : decrypt mode
    
    $display("D1: %b - K1: %d - D3: %b - K3: %d - Plaintext Valid Port: %b - Cipher Operation Flag: %b"
            ,first_shift_direction
            ,first_shift_number
            ,third_shift_direction
            ,third_shift_number
            ,input_valid
            ,flag_cipher_operation);

    fork
    
      begin: STIMULI_1R_INVALID_SHIFT_N
        for(int i = 0; i < 26; i++) begin
          plaintext_char = "A" + i;
          @(posedge clk);
        end
        for(int i = 0; i < 26; i++) begin
          plaintext_char = "a" + i;
          @(posedge clk);
        end
      end: STIMULI_1R_INVALID_SHIFT_N

      $display("Decifratura Di,Ki = <[0;28], [0;3] ,[0;1]>");
      
      begin: CHECK_1R_INVALID_SHIFT_N
        @(posedge clk);  
        for(int j = 0; j < 52; j++) begin
          @(posedge clk);     
          $display("[ERR_FLAG] Shift Number: %b - [ERR_FLAG] Invalid Char: %b - Encrypted char: (hex)%h - (char)%c", invalid_key, invalid_char, ciphertext_char, ciphertext_char);
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
  
  reg        first_shift_direction;
  reg        third_shift_direction;
  reg  [4:0] first_shift_number;
  reg  [4:0] third_shift_number;
  reg  [7:0] plaintext_char;
  reg     input_valid;
  reg     flag_cipher_operation;
  wire [7:0] ciphertext_char;
  wire    invalid_key;
  wire    invalid_char;
  wire    ready;

  three_stage_caesar_cipher INSTANCE_NAME (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.flag_valid_plaintext_char         (input_valid)
    ,.flag_cipher_operation            (flag_cipher_operation)
    ,.first_key_shift_direction              (first_shift_direction)
    ,.third_key_shift_direction              (third_shift_direction)
    ,.first_key_shift_number            (first_shift_number)
    ,.third_key_shift_number            (third_shift_number)
    ,.plaintext_char                 (plaintext_char)
    ,.ciphertext_char                 (ciphertext_char)
    ,.err_invalid_key_shift_num (invalid_key)
    ,.err_invalid_ptxt_char     (invalid_char)
    ,.flag_ciphertext_ready         (ready)
  );
 
  
  int FP_PTXT; // File descriptor for plaintext file
  int FP_CTXT; // File descriptor for ciphertext file
  string char; // String which contains the character read

  //test 1
  reg [7:0] CTXT [$]; // Dynamic buffer which contains all the encrypted chars
  reg [7:0] PTXT [$]; // Dynamic buffer which contains all the plaintext chars
  reg [7:0] PTXT_source [$]; // Dynamic buffer which contains all the plaintext chars from the original plaintext file
  reg [7:0] CTXT_source [$]; // Dynamic buffer which containts all the ciphertext chars from the proper file
  
  //test 2 (Same as before)
  reg [7:0] CTXT2 [$];
  reg [7:0] PTXT2 [$];
  reg [7:0] PTXT_source2 [$];
  reg [7:0] CTXT_source2 [$];

  localparam NULL_CHAR = 8'h00;
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  
  initial begin
    @(reset_deassertion);
    
    @(posedge clk);
    FP_PTXT = $fopen("tv/ptxt1.txt", "r");  //the file containing the text to be encrypted is opened
    $write("Encrypting File: 'tv/ptxt1.txt' --> 'tv/ctxt1.txt' ...");
   	first_shift_direction = 1'b1;     // Set shift direction of 1st stage to left
		third_shift_direction = 1'b0;     // Set shift direction of 3rd stage to right
		first_shift_number = 5'd16;       // Set number of positions to be shifted for 1st stage to 16
		third_shift_number = 5'd1;        // Set number of positions to be shifted for 3st stage to 1
		input_valid = 1'b1;             // Setting the plaintext input valid port to 1'b1 : true 
		flag_cipher_operation = 1'b0;   // Setting the cipher operation flag into 1'b0 : encrypt mode
    
    while($fscanf(FP_PTXT, "%c", char) == 1) begin  // the characters of the file are encrypted and placed in a buffer
      plaintext_char = int'(char);
      @(posedge clk);
      if(
        ((plaintext_char >= UPPERCASE_A_CHAR ) && (plaintext_char <= UPPERCASE_Z_CHAR)) ||
        ((plaintext_char >= LOWERCASE_A_CHAR ) && (plaintext_char <= LOWERCASE_Z_CHAR))
      ) begin
        @(posedge clk);
        CTXT.push_back(ciphertext_char);
      end
      else begin
        CTXT.push_back(NULL_CHAR);
		end;
    end
    $fclose(FP_PTXT);
    
    FP_CTXT = $fopen("tv/ctxt1.txt", "w"); //the file to write the ciphertext is opened and the cypher was written
    foreach(CTXT[i])
      $fwrite(FP_CTXT, "%c", CTXT[i]);
    $fclose(FP_CTXT);
    
    $display("Encrypt Operation Performed Succesfully!");
	
	FP_PTXT = $fopen("tv/expected_ctxt1.txt", "r"); 
	while($fscanf(FP_PTXT, "%c", char) == 1) begin //the characters of the file are placed in a buffer
      plaintext_char = int'(char);
      begin
		CTXT_source.push_back(plaintext_char);  // stores the read characters from file into buffer CTXT_source
      end
    end;
    $fclose(FP_PTXT);
		
	if(CTXT != CTXT_source)begin 
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
	
	 $display("Compare Performed Succesfully: 'tv/expected_ctxt1.txt' == 'tv/ctxt1.txt'");
    
    @(posedge clk);
    FP_CTXT = $fopen("tv/ctxt1.txt", "r"); //the file containing the encrypted text is opened
    $write("Decrypting File: 'tv/ctxt1.txt' --> 'tv/decrypted_ctxt1.txt' ...");
		flag_cipher_operation = 1'b1;
    
    while($fscanf(FP_CTXT, "%c", char) == 1) begin // the characters of the file are decrypted and placed in a buffer
      plaintext_char = int'(char);
      @(posedge clk);
      if(
        ((plaintext_char >= UPPERCASE_A_CHAR ) && (plaintext_char <= UPPERCASE_Z_CHAR)) ||
        ((plaintext_char >= LOWERCASE_A_CHAR ) && (plaintext_char <= LOWERCASE_Z_CHAR))
      ) begin // Check 
        @(posedge clk);
        PTXT.push_back(ciphertext_char);
      end
      else
        PTXT.push_back(NULL_CHAR);
    end
    $fclose(FP_CTXT);
    
    FP_PTXT = $fopen("tv/decrypted_ctxt1.txt", "w"); //the file to write the decrypted text is opened and the decryption was written
    foreach(PTXT[i])
      $fwrite(FP_PTXT, "%c", PTXT[i]);
    $fclose(FP_PTXT);
	
	$display("Decrypt Operation Performed Succesfully!");
	
	FP_PTXT = $fopen("tv/ptxt1.txt", "r"); 
	while($fscanf(FP_PTXT, "%c", char) == 1) begin //the characters of the file are placed in a buffer
      plaintext_char = int'(char);
      begin
		PTXT_source.push_back(plaintext_char);  // stores the read characters from file into buffer PTXT_source
      end
    end;
    $fclose(FP_PTXT);

	 
	if(PTXT != PTXT_source)begin  // Check if the contents of the original plaintext (PTXT_source) is equal to the plaintext obtainted from the decryption of the ciphertext (PTXT)
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
    
    $display("Compare Performed Succesfully: 'tv/decrypted_ctxt1.txt' == 'tv/ptxt1.txt'");
	

  
  /*-------------------test 2----------------------------*/
    
    @(posedge clk);
    FP_PTXT = $fopen("tv/ptxt2.txt", "r"); // Open the plaintext 2
    $write("Encrypting File: 'tv/ptxt2.txt' --> 'tv/ctxt2.txt' ...");
   	
    first_shift_direction = 1'b1; // Set shift direction of 1st stage to left
		third_shift_direction = 1'b0; // Set shift direction of 3rd stage to right
		first_shift_number = 5'd16;  // Set number of positions to be shifted for 1st stage to 16
		third_shift_number = 5'd1;  // Set number of positions to be shifted for 3st stage to 1
		input_valid = 1'b1;  // Setting the plaintext input valid port to 1'b1 : true 
		flag_cipher_operation = 1'b0;  // Setting the cipher operation flag into 1'b0 : encrypt mode
    
    while($fscanf(FP_PTXT, "%c", char) == 1) begin // Read character from the file opened
      plaintext_char = int'(char); 
      @(posedge clk);
      if(
        ((plaintext_char >= UPPERCASE_A_CHAR ) && (plaintext_char <= UPPERCASE_Z_CHAR)) ||
        ((plaintext_char >= LOWERCASE_A_CHAR ) && (plaintext_char <= LOWERCASE_Z_CHAR))
      ) begin // If the character read is valid
        @(posedge clk); 
        CTXT2.push_back(ciphertext_char); // write the ciphertext_char in the buffer CTXT2
      end
      else begin // otherwise write NULL_CHAR in the buffer CTXT2
        CTXT2.push_back(NULL_CHAR);
		end;
    end
    $fclose(FP_PTXT); // If there is no char to read, it closes the file
    
    FP_CTXT = $fopen("tv/ctxt2.txt", "w");
    foreach(CTXT2[i]) // We write the contents of the encrypted characters to the proper file 
      $fwrite(FP_CTXT, "%c", CTXT2[i]);
    $fclose(FP_CTXT);
    
    $display("Encrypt Operation Performed Succesfully!");
	
	FP_PTXT = $fopen("tv/expected_ctxt2.txt", "r");
	while($fscanf(FP_PTXT, "%c", char) == 1) begin
      plaintext_char = int'(char);
      begin
		CTXT_source2.push_back(plaintext_char); // stores the read characters from file into buffer CTXT_source2
      end
    end;
    $fclose(FP_PTXT);
		
	if(CTXT2 != CTXT_source2)begin  // Check each character encrypted has been properly stored into the file
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
	
	 $display("Compare Performed Succesfully: 'tv/ctxt2.txt' --> 'tv/expected_ctxt2.txt'");
    
    @(posedge clk);
    FP_CTXT = $fopen("tv/ctxt2.txt", "r");
    $write("Decrypting File: 'tv/ctxt2.txt' --> 'tv/decrypted_ctxt2.txt' ...");
		flag_cipher_operation = 1'b1;
    
    while($fscanf(FP_CTXT, "%c", char) == 1) begin  // Read character from the file opened
      plaintext_char = int'(char);
      @(posedge clk);
      if(
        ((plaintext_char >= UPPERCASE_A_CHAR ) && (plaintext_char <= UPPERCASE_Z_CHAR)) ||
        ((plaintext_char >= LOWERCASE_A_CHAR ) && (plaintext_char <= LOWERCASE_Z_CHAR))
      ) begin // If the character read is valid
        @(posedge clk);
        PTXT2.push_back(ciphertext_char); // write the ciphertext_char decrypted in the buffer PTXT2
      end
      else   
        PTXT2.push_back(NULL_CHAR); // otherwise write NULL_CHAR in the buffer PTXT2
    end
    $fclose(FP_CTXT);
    
    // Write the decrypted chars in the proper file
    FP_PTXT = $fopen("tv/decrypted_ctxt2.txt", "w");
    foreach(PTXT2[i])
      $fwrite(FP_PTXT, "%c", PTXT2[i]);
    $fclose(FP_PTXT);
	
	$display("Decrypt Operation Performed Succesfully!");
	
	FP_PTXT = $fopen("tv/ptxt2.txt", "r");
	while($fscanf(FP_PTXT, "%c", char) == 1) begin
      plaintext_char = int'(char);
      begin
		PTXT_source2.push_back(plaintext_char);   // stores the read characters from file into buffer PTXT2_source2
      end
    end;
    $fclose(FP_PTXT);

	 
	if(PTXT2 != PTXT_source2)begin // Check if the contents of PTXT_source2 (the original plaintext) is equal to the plaintext obtainted from the decryption of the ciphertext (PTXT2)
		$display("ERROR");
		$stop;
	end
    $fclose(FP_PTXT);
    
    $display("Compare Performed Succesfully: 'tv/decrypted_ctxt2.txt' == 'tv/ptxt2.txt'");
    
    $stop;
  end

endmodule

// -----------------------------------------------------------------------------
