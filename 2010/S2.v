`timescale 1ns/100ps

module S2(clk,
	  rst,
	  S2_done,
	  RB2_RW,
	  RB2_A,
	  RB2_D,
	  RB2_Q,
	  sen,
	  sd);

input clk, rst;
output reg S2_done, RB2_RW;
output reg [2:0] RB2_A;
output reg [17:0] RB2_D;
input [17:0] RB2_Q;
input sen, sd;

reg [2:0] state_cur, state_nxt;
parameter COLLECT = 3'd0;
parameter WRITE = 3'd1;
parameter DONE = 3'd2;

reg buffer [7:0][20:0];
reg [3:0] i;
reg [4:0] j;

//COLLECT
reg collectchangeflag;
reg [3:0] collect_row;
reg [4:0] collect_column;
//COLLECTCHANGE
reg collectflag;

//WRITE
reg writeflag;
reg [3:0] addr;
reg [4:0] k;


always@(posedge clk or posedge rst)
begin
  if(rst)
  begin//??S2????RB2_RW?1???(RB2_A?RB2_D?S2_done)???0
    RB2_RW <= 1'b1;
    RB2_A <= 1'b0;  
    RB2_D <= 1'b0;   
    S2_done <= 1'b0;
    state_cur <= COLLECT;
    collectflag <= 1'b0;   
    collectchangeflag <= 1'b0;
    collect_row <= 4'b0;
    collect_column <= 5'd20;  
    writeflag <= 1'b0;
    addr <= 4'b0;
    
    for( i = 0; i <= 7; i = i + 1 )
    begin
      for( j = 0; j <= 20; j = j + 1 )
      begin
        buffer[i][j] <= 1'b0; 
      end
    end
  end
  
  else
  begin
    state_cur <= state_nxt;
    
    case(state_cur)
    
    COLLECT:
    begin
      if(!sen)
      begin
        buffer[collect_row][collect_column] <= sd;
        if(!collect_column)
        begin
          collectchangeflag <= 1'b1;
        end
        else
        begin
          collect_column <= collect_column - 1;
        end
      end
      
      else if( (sen) && (collectchangeflag) )
      begin
        collectchangeflag <= 1'b0;
        if(collect_row != 7)
        begin
          collect_row <= collect_row + 1;
          collect_column <= 5'd20;
        end
        else
        begin
          collectflag <= 1'b1;
          RB2_RW <= 1'b0;
        end  
      end
      
      else
      begin
        collectflag <= 1'b0;
      end
    end
    
    WRITE:
    begin
      if(!writeflag)
      begin
        RB2_A <= addr;
      
        for( k = 0; k <= 17; k = k + 1 )
        begin
          RB2_D[k] <= buffer[addr][k];
        end
      
        addr <= addr + 1;
      
        if(addr == 7)
        begin
          writeflag <= 1'b1;
        end
        else
        begin
          writeflag <= 1'b0;          
        end
      end
      
      else
      begin
        RB2_RW <= 1'b1;
      end
    end
    
    DONE:
    begin
      S2_done <= 1'b1;      
    end
    
    default:
    begin
      S2_done <= 1'b0;        
    end 
    
    endcase 
  end
end

always@(*)
begin
  case(state_cur)
    
  COLLECT:
  begin
    state_nxt = (collectflag) ? WRITE : COLLECT;
  end

  WRITE:
  begin
    state_nxt = (writeflag) ? DONE : WRITE;
  end
  
  DONE:
  begin
    state_nxt = DONE;
  end
  
  default:
  begin
    state_nxt = COLLECT;
  end
  
  endcase
end

endmodule