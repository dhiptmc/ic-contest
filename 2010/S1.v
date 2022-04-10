`timescale 1ns/100ps

module S1(clk,
	  rst,
	  RB1_RW,
	  RB1_A,
	  RB1_D,
	  RB1_Q,
	  sen,
	  sd);

  input clk, rst;
  output reg RB1_RW;      // control signal for RB1: Read/Write
  output reg [4:0] RB1_A; // control signal for RB1: address
  output reg [7:0] RB1_D; // data path for RB1: input port
  input [7:0] RB1_Q;  // data path for RB1: output port
  output reg sen, sd;
  
reg [2:0] state_cur, state_nxt;
parameter RDRB1 = 3'd0;
parameter WRBUFF = 3'd1;
parameter SEND = 3'd2;
parameter SENDCHANGE = 3'd3;
parameter DONE = 3'd4;

reg [3:0] i;
reg [4:0] j;

reg buffer [7:0][20:0];

//READ
reg readflag;
reg [4:0] addr;
reg [4:0] read_row;

//SEND
reg sendchangeflag;
reg [3:0] send_row;
reg [4:0] send_column;

//SENDCHANGE
reg sendflag;

//DONE
reg S1_done;


always@(posedge clk or posedge rst)
begin
  
  if(rst)
  begin //??S1???RB1_RW?sen?1???(RB1_A?RB1_D?sd)???0
    RB1_RW <= 1'b1;
    sen <= 1'b1;
    RB1_A <= 5'b0;    
    RB1_D <= 8'b0;
    sd <= 1'b0;
    state_cur <= RDRB1;
    readflag <= 1'b0;
    addr <= 5'b0;
    read_row <= 5'b0;
    send_row <= 4'b0;
    send_column <= 5'd20;
    sendchangeflag <= 1'b0;
    sendflag <= 1'b0;   
    S1_done <= 1'b0;
    
    for( i = 0; i <= 7; i = i + 1 )
    begin
      buffer[i][20] <= i[2];
      buffer[i][19] <= i[1];
      buffer[i][18] <= i[0];
      for( j = 0; j <= 17; j = j + 1 )
      begin
        buffer[i][j] <= 1'b0; 
      end
    end        
  end
  
  else
  begin
    state_cur <= state_nxt;
    case(state_cur)
    
    RDRB1:
    begin
      RB1_A <= addr;
      read_row <= RB1_A;
      addr <= addr + 1;
    end
    
    WRBUFF:
    begin
      buffer[0][read_row] <= RB1_Q[7];
      buffer[1][read_row] <= RB1_Q[6];
      buffer[2][read_row] <= RB1_Q[5];            
      buffer[3][read_row] <= RB1_Q[4];      
      buffer[4][read_row] <= RB1_Q[3];      
      buffer[5][read_row] <= RB1_Q[2];      
      buffer[6][read_row] <= RB1_Q[1];      
      buffer[7][read_row] <= RB1_Q[0];
      
      if( read_row < 16 )
      begin
        readflag <= 1'b0;
      end
      else
      begin
        readflag <= 1'b1;
      end          
    end
    
    SEND:
    begin
      sen <= 1'b0;
      sd <= buffer[send_row][send_column];
      
      if(!send_column)
      begin
        sendchangeflag <= 1'b1;
      end
      else
      begin
        send_column <= send_column - 1;
      end
    end
    
    SENDCHANGE:
    begin
      sen <= 1'b1;
      sendchangeflag <= 1'b0;
      if(send_row != 7)
      begin
        send_row <= send_row + 1;
        send_column <= 5'd20;
      end
      else
      begin
        sendflag <= 1'b1;
      end      
    end
    
    DONE:
    begin
      S1_done <= 1'b1;      
    end
    
    default:
    begin
      S1_done <= 1'b0;        
    end
    
    endcase
  end
  
end

always@(*)
begin
  case(state_cur)
  
  RDRB1:
  begin
    state_nxt = WRBUFF;
  end
  
  WRBUFF:
  begin
    state_nxt = (readflag) ? SEND : RDRB1;
  end  
  
  SEND:
  begin
    state_nxt = (sendchangeflag) ? SENDCHANGE : SEND;
  end
  
  SENDCHANGE:
  begin
    state_nxt = (sendflag) ? DONE : SEND;
  end
  
  DONE:
  begin
    state_nxt = DONE;
  end
  
  default:
  begin
    state_nxt = RDRB1;
  end

  endcase
end

endmodule