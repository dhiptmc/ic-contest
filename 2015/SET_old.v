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

reg [3:0] x [3:1];
reg [3:0] y [3:1];
reg [3:0] r [3:1];
reg [3:0] m,n;


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
          candidate <= candidate + certificate(r[1],x[1],y[1],m,n);
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
          candidate <= candidate + ( certificate(r[1],x[1],y[1],m,n) & certificate(r[2],x[2],y[2],m,n) );
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
          candidate <= candidate + certificate(r[1],x[1],y[1],m,n) + certificate(r[2],x[2],y[2],m,n) - 2 * ( certificate(r[1],x[1],y[1],m,n) & certificate(r[2],x[2],y[2],m,n) );
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
          candidate <= candidate + ( certificate(r[1],x[1],y[1],m,n) & certificate(r[2],x[2],y[2],m,n) ) + ( certificate(r[2],x[2],y[2],m,n) & certificate(r[3],x[3],y[3],m,n) ) + ( certificate(r[3],x[3],y[3],m,n) & certificate(r[1],x[1],y[1],m,n) ) - 3 * ( certificate(r[1],x[1],y[1],m,n) & certificate(r[2],x[2],y[2],m,n) & certificate(r[3],x[3],y[3],m,n));
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

function  certificate;
input [3:0] r,cxpoint,cypoint,xp,yp;
reg [7:0] circlecal;
reg [7:0] square;


begin
  
  circlecal = ( `abs(xp,cxpoint) * `abs(xp,cxpoint) ) + ( `abs(yp,cypoint) * `abs(yp,cypoint) );
  square = r * r;
  
  if( circlecal > square )
  begin
    certificate = 1'b0;
  end
  else
  begin
    certificate = 1'b1;
  end
  
end
endfunction

endmodule