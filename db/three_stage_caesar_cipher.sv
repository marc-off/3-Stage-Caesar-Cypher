module three_stage_caesar_cipher (

   input            clk								// Clock signal input
  ,input            rst_n							// Asynchronous active-low reset port
  ,input      [4:0] first_key_shift_number          // Number of positions to shift can range from 0 to 26 (sup|log2(26)|=5)
  ,input      [4:0] third_key_shift_number          // Number of positions to shift can range from 0 to 26 (sup|log2(26)|=5)
  ,input            first_key_shift_direction       // 1'b0 = right direction; 1'b1 = left direction
  ,input            third_key_shift_direction       // 1'b0 = right direction; 1'b1 = left direction
  ,input      [7:0] plaintext_char					// input port which represents the plaintext char to encrypt
  ,input            flag_cipher_operation           // input port to select encryption or decryption mode: 1'b0 = encrypt operation; 1'b1 = decrypt operation
  ,input            flag_valid_plaintext_char       // 1'b0 = invalid char; 1'b1 = valid char
  ,output reg [7:0] ciphertext_char					// output port which represents the ciphertext char of the corresponding plaintext character
  ,output reg       flag_ciphertext_ready			// Flag specifying that the ciphertext character is ready to be sampled by the clock signal
  ,output reg       err_invalid_key_shift_num		// Flag representing error concerning the key (invalid value of position to shift)
  ,output reg       err_invalid_ptxt_char			// Flag representing error concerning the plaintext char (invalid 8-bit ASCII value)
);

  // ---------------------------------------------------------------------------
  // Variables section
  // ---------------------------------------------------------------------------
	localparam NULL_CHAR = 8'h00;
	localparam UPPERCASE_A_CHAR = 8'h41;
	localparam UPPERCASE_Z_CHAR = 8'h5A;
	localparam LOWERCASE_A_CHAR = 8'h61;
	localparam LOWERCASE_Z_CHAR = 8'h7A;

  wire flag_err_invalid_key_shift_num;	// Wire variable for the invalid key error flag (will be used in continuous assignment)
  wire flag_err_invalid_ptxt_char;		// Wire variable for the invalid plaintext character value	(will be used in continuous assignment)
  wire ptxt_char_is_uppercase_letter;
  wire ptxt_char_is_lowercase_letter;
  wire ptxt_char_is_letter;      
  wire  [4:0] second_key_shift_number;     // Wire variable for the number of position to shift for the 2nd round of Caesar Cipher application
  wire second_key_shift_direction;          // Wire variable for the direction of shift operation for the 2nd round of Caesar Cipher application
  reg  [7:0] sub_letter;
  
  // ---------------------------------------------------------------------------
  // Logic Design section
  // ---------------------------------------------------------------------------

  // Checking if the plaintext character is in the range of hex values corresponding to uppercase letters
  assign ptxt_char_is_uppercase_letter = (plaintext_char >= UPPERCASE_A_CHAR) &&
                                         (plaintext_char <= UPPERCASE_Z_CHAR);

  // Checking if the plaintext character is in the range of hex values corresponding to lowercase letters
  assign ptxt_char_is_lowercase_letter = (plaintext_char >= LOWERCASE_A_CHAR) &&
                                         (plaintext_char <= LOWERCASE_Z_CHAR);

  // Checking if the plaintext character is in the range of hex values corresponding to letters (uppercase OR lowercase)                                         
  assign ptxt_char_is_letter = ptxt_char_is_uppercase_letter ||
                               ptxt_char_is_lowercase_letter;

  // Checking if the value of number of positions to shift for 1st and 3rd round of Caesar Cipher application adheres to the specifics constraints
  //	1st constraint: The keys K1 and K3 must be comprised between 0 and 26 
  //	2nd constraint: The keys K1 and K3 must be different
  assign flag_err_invalid_key_shift_num = first_key_shift_number > 26 || third_key_shift_number > 26 || first_key_shift_number==third_key_shift_number;
    
  // Checking if the value of plaintext character adheres to the 8-bit ASCII standard representing uppercase or lowercase letters
  assign flag_err_invalid_ptxt_char = !ptxt_char_is_letter;

  // Accordingly to the specifics, we evaluate K2 as the sum of K1 and K3 modulus 26. 
  assign second_key_shift_number = (first_key_shift_number + third_key_shift_number) < 5'b11010 ?  (first_key_shift_number + third_key_shift_number) :  (first_key_shift_number + third_key_shift_number)  - 5'b11010;
  
  // Accordingly to the specifics, we evaluate D2 as the XOR operation between D1 and D3
  assign second_key_shift_direction = first_key_shift_direction ^ third_key_shift_direction;

  always @ (*)	// Recommended instead of the sensitivity list

	/* Encryption flag = 1'b0 */
    if(!flag_cipher_operation) begin 

		case (first_key_shift_direction)
			1'b0: begin
				sub_letter = plaintext_char + {3'b000, first_key_shift_number}; // Shift
				// -----------------------------------------------------------------
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))
				)							// Check if "overflow" (uppercase and lowercase letter case)...
        			sub_letter -= 8'h1A;	// ... and wrap if so
			end
			1'b1: begin
				sub_letter = plaintext_char - {3'b000, first_key_shift_number};
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))
				)							// Check if "underflow" (uppercase and lowercase letter case)...
        			sub_letter += 8'h1A;	// the same as: sub_letter = sub_letter + 8'h1A
			end
        endcase

		case (second_key_shift_direction)
			1'b0: begin
				sub_letter = sub_letter + {3'b000, second_key_shift_number}; // Shift
				// -----------------------------------------------------------------
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))
				)							// Check if "overflow" (uppercase and lowercase letter case)...
        			sub_letter -= 8'h1A;	// ... and wrap if so
			end
			1'b1: begin
				sub_letter = sub_letter - {3'b000, second_key_shift_number};
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))
				)							// Check if "underflow" (uppercase and lowercase letter case)...
        			sub_letter += 8'h1A;	// the same as: sub_letter = sub_letter + 8'h1A
			end
        endcase
		
		case (third_key_shift_direction)
			1'b0: begin
				sub_letter = sub_letter + {3'b000, third_key_shift_number}; // Shift
				// -----------------------------------------------------------------
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))
				)							// Check if "overflow" (uppercase and lowercase letter case)...
        			sub_letter -= 8'h1A;	// ... and wrap if so
			end
			1'b1: begin
				sub_letter = sub_letter - {3'b000, third_key_shift_number};
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))
				)							// Check if "underflow" (uppercase and lowercase letter case)...
        			sub_letter += 8'h1A;	// the same as: sub_letter = sub_letter + 8'h1A
			end
        endcase

    end
	
	/* Decryption flag = 1'b1 */
    else begin 

        case (third_key_shift_direction)
			1'b0: begin
				sub_letter = plaintext_char - {3'b000, third_key_shift_number}; // Shift
				// -----------------------------------------------------------------
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))
				)							// Check if "underflow" (uppercase and lowercase letter case)...
        			sub_letter += 8'h1A;	// the same as: sub_letter = sub_letter + 8'h1A
			end
			1'b1: begin
				sub_letter = plaintext_char + {3'b000, third_key_shift_number};
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))
				)							// Check if "overflow" (uppercase and lowercase letter case)...
        			sub_letter -= 8'h1A;	// ... and wrap if so
			end
        endcase

		case (second_key_shift_direction)
			1'b0: begin
				sub_letter = sub_letter - {3'b000, second_key_shift_number}; // Shift
				// -----------------------------------------------------------------
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))
				)							// Check if "underflow" (uppercase and lowercase letter case)...
        			sub_letter += 8'h1A;	// the same as: sub_letter = sub_letter + 8'h1A
			end
			1'b1: begin
				sub_letter = sub_letter + {3'b000, second_key_shift_number};
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))
				)							// Check if "overflow" (uppercase and lowercase letter case)...
        			sub_letter -= 8'h1A;	// ... and wrap if so
			end
        endcase
		
		case (first_key_shift_direction)
			1'b0: begin
				sub_letter = sub_letter - {3'b000, first_key_shift_number}; // Shift
				// -----------------------------------------------------------------
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))
				)							// Check if "underflow" (uppercase and lowercase letter case)...
        			sub_letter += 8'h1A;	// the same as: sub_letter = sub_letter + 8'h1A
			end
			1'b1: begin
				sub_letter = sub_letter + {3'b000, first_key_shift_number};
				if(
					(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR)) ||
					(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))
				)							// Check if "overflow" (uppercase and lowercase letter case)...
        			sub_letter -= 8'h1A;	// ... and wrap if so
			end
        endcase
	
    end

	// Elaboration of Output Signals

  always @ (posedge clk or negedge rst_n)
	// Priority to Asynchronous Active-Low Reset
    if(!rst_n)begin
      flag_ciphertext_ready <= 1'b0;
      ciphertext_char <= NULL_CHAR;
      err_invalid_key_shift_num <= 1'b0;
	  err_invalid_ptxt_char <=1'b0;
	  end
	// Setting the proper registers whenever an error condition has been invoked
    else if(flag_err_invalid_ptxt_char || flag_err_invalid_key_shift_num || !flag_valid_plaintext_char) begin
      flag_ciphertext_ready <= 1'b0;
      ciphertext_char <= NULL_CHAR;
	  case (flag_err_invalid_ptxt_char)
        1'b1: begin
            err_invalid_ptxt_char <=1'b1;
        end
        1'b0: begin
            err_invalid_ptxt_char <=1'b0;
        end
      endcase
      case (flag_err_invalid_key_shift_num)
        1'b1: begin
            err_invalid_key_shift_num <= 1'b1;
        end
        1'b0: begin
            err_invalid_key_shift_num <= 1'b0;
        end
      endcase
	  end
	// Safe Case: No errors, Output Char is ready to be sampled!
    else begin
      flag_ciphertext_ready <= 1'b1;
      ciphertext_char <= sub_letter;
	  err_invalid_key_shift_num <= 1'b0;
	  err_invalid_ptxt_char <=1'b0;
	  end
      
      
endmodule
