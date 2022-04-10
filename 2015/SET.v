`define abs(a,b) ((a>b)? a-b : b-a )
module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output reg busy;
output reg valid;
output reg [7:0] candidate;

////////////////////////////////
////////Define Somethings///////
////////////////////////////////

wire ctf1,ctf2,ctf3;
reg [3:0] x [3:1];
reg [3:0] y [3:1];
reg [3:0] r [3:1];
reg [3:0] m,n;

wire [7:0] circlecal1,circlecal2,circlecal3;
wire [7:0] square1,square2,square3;
assign circlecal1 = ( `abs(m,x[1]) * `abs(m,x[1]) ) + ( `abs(n,y[1]) * `abs(n,y[1]) );
assign square1 = r[1] * r[1];
assign circlecal2 = ( `abs(m,x[2]) * `abs(m,x[2]) ) + ( `abs(n,y[2]) * `abs(n,y[2]) );
assign square2 = r[2] * r[2];
assign circlecal3 = ( `abs(m,x[3]) * `abs(m,x[3]) ) + ( `abs(n,y[3]) * `abs(n,y[3]) );
assign square3 = r[3] * r[3];

assign ctf1 = ( circlecal1 > square1 ) ? 1'b0 : 1'b1 ;
assign ctf2 = ( circlecal2 > square2 ) ? 1'b0 : 1'b1 ;
assign ctf3 = ( circlecal3 > square3 ) ? 1'b0 : 1'b1 ;

always@(posedge clk or posedge rst)
begin
  if(rst)
  begin
    busy <= 1'b0;
    valid <= 1'b0;
    candidate <= 8'd0;
    m <= 4'd0;
    n <= 4'd0;
  end
  
  else
  begin
    if (en)
    begin
      busy <= 1'b1;
      valid <= 1'b0;
      candidate <= 8'd0;
      x[1] <= central[23:20];
      y[1] <= central[19:16];
      x[2] <= central[15:12];
      y[2] <= central[11:8];
      x[3] <= central[7:4];
      y[3] <= central[3:0];
      r[1] <= radius[11:8];
      r[2] <= radius[7:4];
      r[3] <= radius[3:0];
      m <= 4'd1;
      n <= 4'd1;
    end
  
    if (busy)
    begin
      if (valid)
      begin
        busy <= 1'b0;
      end
      
      else
      begin
      case(mode)
      
      2'd0:
      begin
        
      if( m <= 8 )
      begin
        if( n <= 8 )
        begin
          candidate <= candidate + ctf1;
          n <= n+1;
        end
        else
        begin
          m <= m+1;
          n <= 4'd1;
        end
      end
      
      else
      begin
      valid <= 1'b1;
      end
      
      end
      
      2'd1:
      begin
        
      if( m <= 8 )
      begin
        if( n <= 8 )
        begin
          candidate <= candidate + ( ctf1 & ctf2 );
          n <= n+1;
        end
        else
        begin
          m <= m+1;
          n <= 4'd1;
        end
      end
      
      else
      begin
      valid <= 1'b1;
      end
      
      end
      
      2'd2:
      begin
        
      if( m <= 8 )
      begin
        if( n <= 8 )
        begin
          candidate <= candidate + ctf1 + ctf2 - 2 * ( ctf1 & ctf2 );
          n <= n+1;
        end
        else
        begin
          m <= m+1;
          n <= 4'd1;
        end
      end
      
      else
      begin
      valid <= 1'b1;
      end
      
      end
      
      2'd3:
      begin
        
      if( m <= 8 )
      begin
        if( n <= 8 )
        begin
          candidate <= candidate + ( ctf1 & ctf2 ) + ( ctf2 & ctf3 ) + ( ctf3 & ctf1 ) - 3 * ( ctf1 & ctf2 & ctf3);
          n <= n+1;
        end
        else
        begin
          m <= m+1;
          n <= 4'd1;
        end
      end
      
      else
      begin
      valid <= 1'b1;
      end
      
      end
      
      endcase
      end
      
    end
    
  end
                
end

//function  certificate;
//input [3:0] r,cxpoint,cypoint,xp,yp;
//reg [7:0] circlecal;
//reg [7:0] square;


//begin
  
  //circlecal = ( `abs(xp,cxpoint) * `abs(xp,cxpoint) ) + ( `abs(yp,cypoint) * `abs(yp,cypoint) );
  //square = r * r;
  
  //if( circlecal > square )
  //begin
    //certificate = 1'b0;
  //end
  //else
  //begin
    //certificate = 1'b1;
  //end
  
//end
//endfunction

endmodule