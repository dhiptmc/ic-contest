module avg(din, reset, clk, ready, dout);
input reset, clk;
input [15:0] din;
output reg ready; 
output reg [15:0] dout;

// ==========================================
//  Enter your design below
// ==========================================

reg state_cur,state_nxt;
reg [3:0] index;
reg [15:0] store [11:0];



always@(posedge clk or posedge reset)
begin
  
  if(reset)
  begin
    state_cur <= 4'd0;
    ready <= 1'b0;
    dout <= 16'd0;
    index <= 4'd0;  
  end
  
  else
  begin
    state_cur <= state_nxt;
    case(state_cur)
    
    1'b0:
    begin
      
      if (index!=11)
      begin
      store[index] <= din;
      index <= index+1;
      end
      
      else
      begin
      store[index] <= din;
      index <= index+1;
      ready <= 1'b1;
      end   
        
    end
    
    1'b1:
    begin
      {store[0],store[1],store[2],store[3],store[4],store[5],store[6],store[7],store[8],store[9],store[10],dout} <= naverage(store[0],store[1],store[2],store[3],store[4],store[5],store[6],store[7],store[8],store[9],store[10],store[11]);
      store[11] <= din;
    end
    
  
    endcase
    
  end

end

always@(*)
begin
  case (state_cur)
    
  1'b0:
  begin
    state_nxt = ( index == 11 ) ? 1'b1 : 1'b0;    
  end
  
  1'b1:
  begin
    state_nxt = ( ready == 1 ) ? 1'b1 : 1'b0;
  end
    
  endcase
  
end

function [191:0] naverage;
input [15:0] in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11;
reg [15:0] i [11:0];
reg [19:0] sum;
reg [15:0] sumavg;
reg [15:0] sumdiff [11:0];
integer m;
integer n;

begin
  m=0;
  i[0]=in0;
  i[1]=in1;
  i[2]=in2;
  i[3]=in3;
  i[4]=in4;
  i[5]=in5;
  i[6]=in6;
  i[7]=in7;
  i[8]=in8;
  i[9]=in9;
  i[10]=in10;
  i[11]=in11;
  sum = i[0]+i[1]+i[2]+i[3]+i[4]+i[5]+i[6]+i[7]+i[8]+i[9]+i[10]+i[11];
  sumavg = sum/12;
  sumdiff[0] = ( sumavg >= i[0] ) ?  ( sumavg - i[0] ) : ( i[0] - sumavg ) ;
  sumdiff[1] = ( sumavg >= i[1] ) ?  ( sumavg - i[1] ) : ( i[1] - sumavg ) ;
  sumdiff[2] = ( sumavg >= i[2] ) ?  ( sumavg - i[2] ) : ( i[2] - sumavg ) ;
  sumdiff[3] = ( sumavg >= i[3] ) ?  ( sumavg - i[3] ) : ( i[3] - sumavg ) ;
  sumdiff[4] = ( sumavg >= i[4] ) ?  ( sumavg - i[4] ) : ( i[4] - sumavg ) ;
  sumdiff[5] = ( sumavg >= i[5] ) ?  ( sumavg - i[5] ) : ( i[5] - sumavg ) ;
  sumdiff[6] = ( sumavg >= i[6] ) ?  ( sumavg - i[6] ) : ( i[6] - sumavg ) ;
  sumdiff[7] = ( sumavg >= i[7] ) ?  ( sumavg - i[7] ) : ( i[7] - sumavg ) ;
  sumdiff[8] = ( sumavg >= i[8] ) ?  ( sumavg - i[8] ) : ( i[8] - sumavg ) ;
  sumdiff[9] = ( sumavg >= i[9] ) ?  ( sumavg - i[9] ) : ( i[9] - sumavg ) ;
  sumdiff[10] = ( sumavg >= i[10] ) ?  ( sumavg - i[10] ) : ( i[10] - sumavg ) ;
  sumdiff[11] = ( sumavg >= i[11] ) ?  ( sumavg - i[11] ) : ( i[11] - sumavg ) ;
  
  for( n=1 ; n<12 ; n=n+1 )
  begin
    if( sumdiff[m] < sumdiff[n] )
    begin
      m = m;
    end
    
    else if( sumdiff[m] > sumdiff[n] )
    begin
      m = n;
    end
    
    else
    begin
      if( i[m] <= i[n] )
      begin
        m = m;
      end
      else
      begin
        m = n ;
      end
    end
  end
  
  naverage = {i[1],i[2],i[3],i[4],i[5],i[6],i[7],i[8],i[9],i[10],i[11],i[m]};

end

endfunction

endmodule