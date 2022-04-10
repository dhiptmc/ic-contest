module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;

input [7:0] IROM_Q;
output reg IROM_rd;
output reg [5:0] IROM_A;

output reg IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
reg [6:0] addr;

output reg busy;
output reg done;

reg [7:0] data [63:0];

wire [3:0] cmd_cur;
assign cmd_cur = cmd;
reg valid;

reg [2:0] opx,opy;


wire [5:0] aul,aur,all,alr;
assign alr = ( 8 * opy + opx );
assign all = ( 8 * opy + opx - 1 );
assign aur = ( 8 * opy + opx - 8 );
assign aul = ( 8 * opy + opx - 9 ); 

wire [7:0] dul,dur,dll,dlr;
assign dul = data[aul];
assign dur = data[aur];
assign dll = data[all];
assign dlr = data[alr];

wire [7:0] cp1max,cp2max,cp1min,cp2min,max,min,avedata;
assign cp1max = ( ( dul >= dur ) ? dul : dur );
assign cp2max = ( ( dll >= dlr ) ? dll : dlr );
assign cp1min = ( ( dul <= dur ) ? dul : dur );
assign cp2min = ( ( dll <= dlr ) ? dll : dlr );
assign max = ( ( cp1max >= cp2max ) ? cp1max : cp2max );
assign min = ( ( cp1min <= cp2min ) ? cp1min : cp2min );
assign avedata = ( ( dul + dur + dll + dlr ) / 4 );

always@( posedge clk or posedge reset )
begin
  if( reset )
  begin
    IROM_rd <= 1'b1;
    busy <= 1'b1;
    IROM_A <= 6'd0;
    IRAM_A <= 6'd0;
    addr <= 7'd0;
    opx <= 3'd4;
    opy <= 3'd4;
    done <= 1'b0;
  end
  
  else if ( IROM_rd )
  begin
    data[IROM_A] <= IROM_Q;
    
    if( IROM_A < 63 )
    begin
      IROM_A <= IROM_A + 1;
    end
    
    else
    begin
      IROM_rd <= 1'b0;      
      busy <= 1'b0;
    end
  end
  
  else if ( ( cmd_valid == 1 ) & ( busy == 0 ) )
  begin
    busy <= 1'b1;
    valid <= 1'b1;
  end
  
  else if ( valid )
  begin
    case( cmd_cur )
      
    4'b0000: //Write
    begin
      IRAM_valid <= 1'b1;
      IRAM_D <= data[addr];
      IRAM_A <= addr;
    
      if( addr[6] != 1 )
      begin
        addr <= IRAM_A + 1;
      end
    
      else
      begin
        IRAM_valid <= 1'b0;      
        busy <= 1'b0;
        valid <= 1'b0;
        done <= 1'b1;
      end
    end
    
    4'b0001: //Shift Up
    begin
      if( opy != 1 )
      begin
        opy <= opy - 1;
      end
      
      else
      begin
        opy <= 3'd1;
      end
      
      busy <= 1'b0;
      valid <= 1'b0;
    end
    
    4'b0010: //Shift Down
    begin
      if( opy != 7 )
      begin
        opy <= opy + 1;
      end
      
      else
      begin
        opy <= 3'd7;
      end
      
      busy <= 1'b0;
      valid <= 1'b0;          
    end
    
    4'b0011: //Shift Left
    begin
      if( opx != 1 )
      begin
        opx <= opx - 1;
      end
      
      else
      begin
        opx <= 3'd1;
      end
      
      busy <= 1'b0;
      valid <= 1'b0;          
    end
    
    4'b0100: //Shift Right
    begin
      if( opx != 7 )
      begin
        opx <= opx + 1;
      end
      
      else
      begin
        opx <= 3'd7;
      end
      
      busy <= 1'b0;
      valid <= 1'b0;          
    end
    
    4'b0101: //Max
    begin
      data[aul] <= max;
      data[aur] <= max;
      data[all] <= max;
      data[alr] <= max;
      busy <= 1'b0;
      valid <= 1'b0;      
    end
    
    4'b0110: //Min
    begin
      data[aul] <= min;
      data[aur] <= min;
      data[all] <= min;
      data[alr] <= min;
      busy <= 1'b0;
      valid <= 1'b0; 
    end
    
    4'b0111: //Average
    begin
      data[aul] <= avedata;
      data[aur] <= avedata;
      data[all] <= avedata;
      data[alr] <= avedata;
      busy <= 1'b0;
      valid <= 1'b0; 
    end
    
    4'b1000: //Counterclockwise Rotation
    begin
      data[aul] <= dur;
      data[aur] <= dlr;
      data[all] <= dul;
      data[alr] <= dll;
      busy <= 1'b0;
      valid <= 1'b0;       
    end
    
    4'b1001: //Clockwise Rotation
    begin
      data[aul] <= dll;
      data[aur] <= dul;
      data[all] <= dlr;
      data[alr] <= dur;
      busy <= 1'b0;
      valid <= 1'b0;  
    end
    
    4'b1010: //Mirror X
    begin
      data[aul] <= dll;
      data[aur] <= dlr;
      data[all] <= dul;
      data[alr] <= dur;
      busy <= 1'b0;
      valid <= 1'b0;        
    end
    
    4'b1011: //Mirror Y
    begin
      data[aul] <= dur;
      data[aur] <= dul;
      data[all] <= dlr;
      data[alr] <= dll;
      busy <= 1'b0;
      valid <= 1'b0;        
    end
    
    default: // Others
    begin
    busy <= 1'b0;
    valid <= 1'b0;
    end
    
    endcase
  end
end

endmodule