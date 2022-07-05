module caesar_cipher (

   input            clk
  ,input            rst_n
  ,input            ptxt_valid // 1'b0 = not valid; 1'b1 = valid char
  ,input            mode // 1'b0 = encr; 1'b1 = decr
  ,input            key_shift_dir_1 // 1'b0 = right shift; 1'b1 = left shift
  ,input            key_shift_dir_3 // 1'b0 = right shift; 1'b1 = left shift
  ,input      [4:0] key_shift_num_1 // range 0-26
  ,input      [4:0] key_shift_num_3 // range 0-26
  ,input      [7:0] ptxt_char
  ,output reg [7:0] ctxt_char
  ,output reg       err_invalid_key_shift_num
  ,output reg       err_invalid_ptxt_char
  ,output reg       ctx_ready

);

  // ---------------------------------------------------------------------------
  // Variables
  // ---------------------------------------------------------------------------

  localparam NUL_CHAR = 8'h00;
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  
  wire       ptxt_char_is_uppercase_letter;
  wire       ptxt_char_is_lowercase_letter;
  wire       ptxt_char_is_letter;
  wire	     err_invalid_key_shift_num_wire;
  wire 	     err_invalid_ptxt_char_wire;

  wire  [4:0] key_shift_num_x; //value of the second shift
  
  reg  [7:0] sub_letter;
  
  // ---------------------------------------------------------------------------
  // Logic Design
  // ---------------------------------------------------------------------------

  //checks if shift_1 and shift_3 are valid
  assign err_invalid_key_shift_num_wire = key_shift_num_1 > 26 || key_shift_num_3 > 26 || key_shift_num_1==key_shift_num_3;
  
  
  assign ptxt_char_is_uppercase_letter = (ptxt_char >= UPPERCASE_A_CHAR) &&
                                         (ptxt_char <= UPPERCASE_Z_CHAR);
                                         
  assign ptxt_char_is_lowercase_letter = (ptxt_char >= LOWERCASE_A_CHAR) &&
                                         (ptxt_char <= LOWERCASE_Z_CHAR);
                                         
  assign ptxt_char_is_letter = ptxt_char_is_uppercase_letter ||
                               ptxt_char_is_lowercase_letter;
    
  //set err_invalid_ptxt_char_wire if char is not a letter
  assign err_invalid_ptxt_char_wire = !ptxt_char_is_letter;

  //Calculate the value of key_shift_num_x; if the value is greater than 27, it takes the module 
  assign key_shift_num_x = (key_shift_num_1 + key_shift_num_3) < 27 ?  (key_shift_num_1 + key_shift_num_3) :  (key_shift_num_1 + key_shift_num_3)  -  5'b11011;
  
  always @ (*)

    if(!mode) begin //Encr.

        /* caso d1 = 0, d3 = 0*/
        if(!key_shift_dir_1 && !key_shift_dir_3) begin
            sub_letter = ptxt_char + {3'b000, key_shift_num_1} + {3'b000, key_shift_num_x} + {3'b000, key_shift_num_3};
            if(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
				if(sub_letter > UPPERCASE_Z_CHAR)begin
					sub_letter -= 8'h1A;
					if(sub_letter > UPPERCASE_Z_CHAR)
						sub_letter -= 8'h1A;
						else 
							sub_letter = sub_letter;
				end
				else 
					sub_letter = sub_letter;
			end 
			else sub_letter = sub_letter;
			
            if(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
				 if(sub_letter > LOWERCASE_Z_CHAR)begin
					sub_letter -= 8'h1A;
					if(sub_letter > LOWERCASE_Z_CHAR)
						sub_letter -= 8'h1A;
					else 
						sub_letter = sub_letter;
				end
				 else 
					sub_letter = sub_letter;
			end
			else
				sub_letter = sub_letter;
        end

        /* caso d1 = 0, d3 = 1*/
        else if(!key_shift_dir_1 && key_shift_dir_3) begin
            sub_letter = ptxt_char + {3'b000, key_shift_num_1} - {3'b000, key_shift_num_x} - {3'b000, key_shift_num_3};
            if(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
                if(sub_letter > UPPERCASE_Z_CHAR)
                    sub_letter -= 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
                if(sub_letter > LOWERCASE_Z_CHAR)
                    sub_letter -= 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR)) begin
                sub_letter += 8'h1A;
                if(sub_letter < UPPERCASE_A_CHAR)
                    sub_letter += 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
                if(sub_letter < LOWERCASE_A_CHAR)
                    sub_letter += 8'h1A;
                else
                    sub_letter = sub_letter;
			end
			else 
				sub_letter = sub_letter;
        end

        /* caso d1 = 1, d3 = 0*/
        else if(key_shift_dir_1 && !key_shift_dir_3) begin
            sub_letter = ptxt_char - {3'b000, key_shift_num_1} - {3'b000, key_shift_num_x} + {3'b000, key_shift_num_3};
            if(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
                if(sub_letter > UPPERCASE_Z_CHAR)
                    sub_letter -= 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
                if(sub_letter > LOWERCASE_Z_CHAR)
                    sub_letter -= 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
                if(sub_letter < UPPERCASE_A_CHAR)
                    sub_letter += 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
                if(sub_letter < LOWERCASE_A_CHAR)
                    sub_letter += 8'h1A;
                else
                    sub_letter = sub_letter;
            end
			else 
				sub_letter = sub_letter;
        end

        /* caso d1 = 1, d3 = 1*/
		else if(key_shift_dir_1 && key_shift_dir_3) begin
            sub_letter = ptxt_char - {3'b000, key_shift_num_1} + {3'b000, key_shift_num_x} - {3'b000, key_shift_num_3};
            if(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
				 if((sub_letter < UPPERCASE_A_CHAR))
					sub_letter += 8'h1A;
				else
					sub_letter = sub_letter;
			end
			else
				sub_letter = sub_letter;
            if(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
				  if((sub_letter < LOWERCASE_A_CHAR))
					sub_letter += 8'h1A;
				  else
					sub_letter = sub_letter;
			end
			else
				sub_letter = sub_letter;
        end
		else
			sub_letter = NUL_CHAR;

    end
    else begin //decr.

        /* caso d1 = 0, d3 = 0*/
        if(!key_shift_dir_1 && !key_shift_dir_3) begin
            sub_letter = ptxt_char - {3'b000, key_shift_num_1} - {3'b000, key_shift_num_x} - {3'b000, key_shift_num_3};
			
            if(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR || sub_letter > 200))begin
                sub_letter += 8'h1A;
				 if(sub_letter < UPPERCASE_A_CHAR  || sub_letter > 200)begin
					sub_letter += 8'h1A;
					if(sub_letter < UPPERCASE_A_CHAR  || sub_letter > 200 )
						sub_letter += 8'h1A;
					else
						sub_letter = sub_letter;
				end
				else
					sub_letter = sub_letter;
			end
			else
				sub_letter = sub_letter;
					
            if(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
				if(sub_letter < LOWERCASE_A_CHAR)begin
					sub_letter += 8'h1A;
					if(sub_letter < LOWERCASE_A_CHAR)
						sub_letter += 8'h1A;
					else
						sub_letter = sub_letter;
				end
				else
					sub_letter = sub_letter;
			end
			else
				sub_letter = sub_letter;			
        end

        /* caso d1 = 0, d3 = 1*/
        else if(!key_shift_dir_1 && key_shift_dir_3) begin
            sub_letter = ptxt_char - {3'b000, key_shift_num_1} + {3'b000, key_shift_num_x} + {3'b000, key_shift_num_3};
            if(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
                if(sub_letter > UPPERCASE_Z_CHAR)
                    sub_letter -= 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
                if(sub_letter > LOWERCASE_Z_CHAR)
                    sub_letter -= 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
                if(sub_letter < UPPERCASE_A_CHAR)
                    sub_letter += 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
                if(sub_letter < LOWERCASE_A_CHAR)
                    sub_letter += 8'h1A;
                else
                    sub_letter = sub_letter;
            end
			else
				sub_letter = sub_letter;
        end
		

        /* caso d1 = 1, d3 = 0*/
        else if(key_shift_dir_1 && !key_shift_dir_3) begin
            sub_letter = ptxt_char + {3'b000, key_shift_num_1} + {3'b000, key_shift_num_x} - {3'b000, key_shift_num_3};
            if(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
                if(sub_letter > UPPERCASE_Z_CHAR)
                    sub_letter -= 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
                if(sub_letter > LOWERCASE_Z_CHAR)
                    sub_letter -= 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_uppercase_letter && (sub_letter < UPPERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
                if(sub_letter < UPPERCASE_A_CHAR)
                    sub_letter += 8'h1A;
                else
                    sub_letter = sub_letter;
            end
            else if(ptxt_char_is_lowercase_letter && (sub_letter < LOWERCASE_A_CHAR))begin
                sub_letter += 8'h1A;
                if(sub_letter < LOWERCASE_A_CHAR)
                    sub_letter += 8'h1A;
                else
                    sub_letter = sub_letter;
            end
			else
				sub_letter = sub_letter;
        end

        /* caso d1 = 1, d3 = 1*/
        else if(key_shift_dir_1 && key_shift_dir_3) begin
            sub_letter = ptxt_char + {3'b000, key_shift_num_1} - {3'b000, key_shift_num_x} + {3'b000, key_shift_num_3};
             if(ptxt_char_is_uppercase_letter && (sub_letter > UPPERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
				if((sub_letter > UPPERCASE_Z_CHAR))
					sub_letter -= 8'h1A;
				else
					sub_letter = sub_letter;
			end
			else
				sub_letter = sub_letter;
            if(ptxt_char_is_lowercase_letter && (sub_letter > LOWERCASE_Z_CHAR))begin
                sub_letter -= 8'h1A;
				 if((sub_letter > LOWERCASE_Z_CHAR))
					sub_letter -= 8'h1A;
				 else
					sub_letter = sub_letter;
			end
			else
				sub_letter = sub_letter;
        end
		else
			sub_letter = NUL_CHAR;
	
    end

  // Output char 

  always @ (posedge clk or negedge rst_n)
	//default value at reset
    if(!rst_n)begin
      ctx_ready <= 1'b0;
      ctxt_char <= NUL_CHAR;
      err_invalid_key_shift_num <= 1'b0;
	  err_invalid_ptxt_char <=1'b0;
	  end
	 //set registers in case of errors
    else if(err_invalid_ptxt_char_wire || err_invalid_key_shift_num_wire || !ptxt_valid) begin
      ctx_ready <= 1'b0;
      ctxt_char <= NUL_CHAR;
	  err_invalid_key_shift_num <= 1'b1;
	  err_invalid_ptxt_char <=1'b1;
	  end
    else begin
      ctx_ready <= 1'b1;
      ctxt_char <= sub_letter;
	  err_invalid_key_shift_num <= 1'b0;
	  err_invalid_ptxt_char <=1'b0;
	  end
      
      
endmodule
