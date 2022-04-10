`timescale 1ns/10ps

module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input clk;
input reset;
output reg [13:0] gray_addr;
output reg        gray_req;
input gray_ready;
input [7:0] gray_data;
output reg [13:0] lbp_addr;
output reg	lbp_valid;
output reg [7:0] lbp_data;
output reg	finish;
//====================================================================
reg [2:0] state_cur,state_nxt;
parameter READ_addr = 3'd0;
parameter READ_data = 3'd1;
parameter WRITE = 3'd2;
parameter DONE = 3'd3;
//==================================================================== MAIN FUNCTION
integer i;
reg [7:0] square [8:0];
wire [7:0] LBPvalue;
assign LBPvalue[0] = ( square[0] >= square[4] ) ? 1'b1 : 1'b0;
assign LBPvalue[1] = ( square[1] >= square[4] ) ? 1'b1 : 1'b0; 
assign LBPvalue[2] = ( square[2] >= square[4] ) ? 1'b1 : 1'b0; 
assign LBPvalue[3] = ( square[3] >= square[4] ) ? 1'b1 : 1'b0; 
assign LBPvalue[4] = ( square[5] >= square[4] ) ? 1'b1 : 1'b0; 
assign LBPvalue[5] = ( square[6] >= square[4] ) ? 1'b1 : 1'b0; 
assign LBPvalue[6] = ( square[7] >= square[4] ) ? 1'b1 : 1'b0;
assign LBPvalue[7] = ( square[8] >= square[4] ) ? 1'b1 : 1'b0;

//==================================================================== READ
reg [13:0] curpoint;
reg [3:0] counter;
reg readflag;

//==================================================================== READ
reg writeflag;



//====================================================================
always@(posedge clk or posedge reset)
begin
  if(reset)
  begin
    gray_addr <= 14'b0;
    gray_req <= 1'b0;
    lbp_addr <= 14'b0;
    lbp_valid <= 1'b0;
    lbp_data <= 8'b0;
    finish <= 1'b0;
    
    state_cur <= READ_addr;
    
    for( i = 0; i <= 8; i = i + 1 )
    begin
      square[i] <= 8'b0;
    end
  
    readflag <= 1'b0;
    writeflag <= 1'b0;
    curpoint <= 14'd129;
    counter <= 4'b0;
  end
  else
  begin
    state_cur <= state_nxt;
      
    case(state_cur) 
    READ_addr:
    begin
      if(gray_ready)
      begin
        gray_req <= 1'b1;
        
        case (counter)
        4'd0:
        begin
          gray_addr <= curpoint - 129;
        end
        
        4'd1:
        begin
          gray_addr <= curpoint - 128;          
        end
        
        4'd2:
        begin
          gray_addr <= curpoint - 127;            
        end
        
        4'd3:
        begin
          gray_addr <= curpoint - 1;  
        end
        
        4'd4:
        begin
          gray_addr <= curpoint;            
        end
        
        4'd5:
        begin
          gray_addr <= curpoint + 1;           
        end
        
        4'd6:
        begin
          gray_addr <= curpoint + 127;           
        end
        
        4'd7:
        begin
          gray_addr <= curpoint + 128;           
        end
        
        4'd8:
        begin
          gray_addr <= curpoint + 129;             
        end
        
        default:
        begin
          counter <= counter;
        end
        endcase

        if( counter == 8 )
        begin
          readflag <= 1'b1;
        end
        else
        begin
          readflag <= 1'b0;
        end
      end
      else
      begin
        counter <= 4'b0;
        readflag <= 1'b0;
      end
    end
    
    READ_data:
    begin
      square[counter] <= gray_data;
      if( counter == 8 )
      begin
        counter <= 4'd0;
        gray_req <= 1'b0;
        if( curpoint != 16254 )
        begin
          writeflag <= 1'b0;  
        end
        else
        begin
          writeflag <= 1'b1;
        end
      end
      else
      begin
        counter <= counter + 1;
      end
    end
    
    WRITE:
    begin
      lbp_valid <= 1'b1;
      lbp_addr <= curpoint;
      lbp_data <= LBPvalue;
      if( curpoint % 128 != 126 )
      begin
        curpoint <= curpoint + 1;
      end
      else
      begin
        curpoint <= curpoint + 3;        
      end
    end
    
    DONE:
    begin
      finish <= 1'b1;
    end
    
    default:
    begin
      finish <= 1'b0;
    end
    endcase
  end
end

always@(*)
begin
  case(state_cur)
    
  READ_addr:
  begin
    if(gray_ready)
    begin
      state_nxt = READ_data;
    end
    else
    begin
      state_nxt = READ_addr; 
    end
  end
  
  READ_data:
  begin
    if(!readflag)
    begin
      state_nxt = READ_addr;
    end
    else
    begin
      state_nxt = WRITE; 
    end
  end
  
  WRITE:
  begin
    if(!writeflag)
    begin
      state_nxt = READ_addr;
    end
    else
    begin
      state_nxt = DONE; 
    end
  end
  
  DONE:
  begin
    state_nxt = DONE;
  end
  
  default:
  begin
    state_nxt = READ_addr;
  end
  
  endcase
end
//====================================================================
endmodule