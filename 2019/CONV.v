module  CONV(clk,reset,busy,ready,iaddr,idata,cwr,caddr_wr,cdata_wr,crd,caddr_rd,cdata_rd,csel);
input clk;
input reset;
input ready;
output reg busy;
output reg [11:0] iaddr;
input signed [19:0] idata;
output reg crd;
input [19:0] cdata_rd;
output reg [11:0] caddr_rd;
output reg cwr;
output reg signed [19:0] cdata_wr;
output reg [11:0] caddr_wr;
output reg [2:0] csel;

reg [2:0] cur_state,nxt_state;
reg [3:0] position1;
reg [1:0] position2;

//parameter
parameter IDLE = 3'd0;
parameter READ_CONV = 3'd1;
parameter WRITE_L0 = 3'd2;
parameter READ_L0 = 3'd3;
parameter WRITE_L1 = 3'd4;
parameter FINISH = 3'd5;

parameter UPPERLEFT = 4'd0;
parameter UP = 4'd1;
parameter UPPERRIGHT = 4'd2;
parameter LEFT = 4'd3;
parameter CURRENT = 4'd4;
parameter RIGHT = 4'd5;
parameter LOWERLEFT = 4'd6;
parameter DOWN = 4'd7;
parameter LOWERRIGHT = 4'd8;

parameter UL = 2'd0;
parameter UR = 2'd1;
parameter LL = 2'd2;
parameter LR = 2'd3;

reg [12:0] cur_addr1,cur_addr2;

reg signed [19:0] dataUL,dataU,dataUR,dataL,dataC,dataR,dataLL,dataD,dataLR;
wire signed [43:0] convresult;
wire signed [43:0] biasresult;
wire signed [20:0] roundresult;
assign convresult = dataUL * $signed(20'h0A89E) + dataU * $signed(20'h092D5) + dataUR * $signed(20'h06D43) + dataL * $signed(20'h01004) + dataC * $signed(20'hF8F71) + dataR * $signed(20'hF6E54) + dataLL * $signed(20'hFA6D7) + dataD * $signed(20'hFC834) + dataLR * $signed(20'hFAC19);
assign biasresult = convresult + $signed({20'h01310,16'd0});
assign roundresult = biasresult[35:15] + biasresult[15];

reg signed [19:0] data4UL,data4UR,data4LL,data4LR;
wire signed [19:0] bs1,bs2;
assign bs1 = ( data4UL >= data4UR ) ? data4UL : data4UR;
assign bs2 = ( data4LL >= data4LR ) ? data4LL : data4LR;
wire signed [19:0] max;
assign max = ( bs1 >= bs2 ) ? bs1 : bs2;

reg [5:0] chgsig;
reg [11:0] addr4;

reg final;
reg readsig;
reg readsig2;

always@(posedge clk or posedge reset)
begin
  if(reset)
  begin
    cur_state <= IDLE;
    busy <= 1'b0;
    iaddr <= 12'd0;
    position1 <= UPPERLEFT;
    cur_addr1 <= 13'd0;
    cur_addr2 <= 13'd0;    
    dataUL <= 20'd0;
    dataU <= 20'd0;
    dataUR <= 20'd0;
    dataL <= 20'd0;
    dataC <= 20'd0;
    dataR <= 20'd0;
    dataLL <= 20'd0;
    dataD <= 20'd0;
    dataLR <= 20'd0;
    data4UL <= 20'd0;
    data4UR <= 20'd0;
    data4LL <= 20'd0;
    data4LR <= 20'd0;
    csel <= 3'b0;
    caddr_wr <= 12'd0;
    cwr <= 1'b0;
    crd <= 1'b0;
    position2 <= UL;
    cdata_wr <= 20'd0;
    caddr_rd <= 12'd0;
    chgsig <= 6'd0;
    addr4 <= 12'd0;
    final <= 1'b0;
    readsig <= 1'b0;
    readsig2 <= 1'b0;
  end
  
  else
  begin
    cur_state <= nxt_state;
    
    case(cur_state)
    
    READ_CONV:
    begin
      busy <= 1'b1;
      
      begin
      
      case(position1)
        
      UPPERLEFT:
      begin
      
      if(!readsig)
      begin 
        if( ( cur_addr1 < 64 ) | ( cur_addr1 % 64 == 0 ) )
        begin
          dataUL <= 20'd0;
          position1 <= UP;
        end
        else
        begin
          iaddr <= cur_addr1 - 65;
          readsig <= 1'b1;
        end
      end
      
      else
      begin
        position1 <= UP;
        readsig <= 1'b0;
        dataUL <= idata;
      end
      
      end
      
      UP:
      begin
        
      if(!readsig)
      begin     
        if( cur_addr1 < 64 )
        begin
          dataU <= 20'd0;
          position1 <= UPPERRIGHT;
        end
        else
        begin
          iaddr <= cur_addr1 - 64;
          readsig <= 1'b1;
        end
      end
      
      else
      begin
        position1 <= UPPERRIGHT;
        readsig <= 1'b0;
        dataU <= idata;        
      end
      
      end

      UPPERRIGHT:
      begin
      
      if(!readsig)
      begin     
        if( ( cur_addr1 < 64 ) | ( cur_addr1 % 64 == 63 ) )
        begin
          dataUR <= 20'd0;
          position1 <= LEFT;
        end
        else
        begin
          iaddr <= cur_addr1 - 63;
          readsig <= 1'b1;
        end
        end
      
        else
        begin
          position1 <= LEFT;
          readsig <= 1'b0;
          dataUR <= idata;           
        end
      end

      LEFT:
      begin
      
      if(!readsig)
      begin
        if( cur_addr1 % 64 == 0 )
        begin          
          dataL <= 20'd0;
          position1 <= CURRENT;
        end
        else
        begin
          iaddr <= cur_addr1 - 1;
          readsig <= 1'b1;
        end
      end
      
      else
      begin
        position1 <= CURRENT;
        readsig <= 1'b0;
        dataL <= idata;           
      end
      
      end

      CURRENT:
      begin
        
      if(!readsig)
      begin
        iaddr <= cur_addr1;
        readsig <= 1'b1;
      end
      
      else
      begin
        position1 <= RIGHT;
        readsig <= 1'b0;
        dataC <= idata;       
      end
      
      end
      
      RIGHT:
      begin

      if(!readsig)
      begin
        if( cur_addr1 % 64 == 63 )
        begin
          dataR <= 20'd0;
          position1 <= LOWERLEFT;
        end
        else
        begin
          iaddr <= cur_addr1 + 1;
          readsig <= 1'b1;
        end
      end
      
      else
      begin
        position1 <= LOWERLEFT;
        readsig <= 1'b0;
        dataR <= idata;          
      end
      
      end
      
      LOWERLEFT:
      begin

      if(!readsig)
      begin
        if( ( ( cur_addr1 > 4031 ) & ( cur_addr1 <= 4095 ) ) | ( cur_addr1 % 64 == 0 ) )
        begin
          dataLL <= 20'd0;
          position1 <= DOWN;
        end
        else
        begin
          iaddr <= cur_addr1 + 63;
          readsig <= 1'b1;
        end
      end
      
      else
      begin
        position1 <= DOWN;
        readsig <= 1'b0;
        dataLL <= idata;            
      end
      
      end
      
      DOWN:
      begin

      if(!readsig)
      begin
        if( ( cur_addr1 > 4031 ) & ( cur_addr1 <= 4095 ) )
        begin
          dataD <= 20'd0;
          position1 <= LOWERRIGHT;
        end
        else
        begin
          iaddr <= cur_addr1 + 64;
          readsig <= 1'b1;
        end
      end
      
      else
      begin
        position1 <= LOWERRIGHT;
        readsig <= 1'b0;
        dataD <= idata;
      end
      
      end
      
      LOWERRIGHT:
      begin 
      
      if(!readsig)
      begin 
        if( ( ( cur_addr1 > 4031 ) & ( cur_addr1 <= 4095 ) ) | ( cur_addr1 % 64 == 63 ) )
        begin
          dataLR <= 20'd0;
          cwr <= 1'b1;
        end
        else
        begin
          iaddr <= cur_addr1 + 65;
          readsig <= 1'b1;
        end
      end
      
      else
      begin
        readsig <= 1'b0;        
        dataLR <= idata;
        cwr <= 1'b1;           
      end
           
      end
      
      endcase
      
      end

    end

    WRITE_L0:
    begin
      readsig <= 1'b0;
      position1 <= UPPERLEFT;        
      cwr <= 1'b0;
      csel <= 3'b001;
      caddr_wr <= cur_addr1;
      if(roundresult[20]==1)
        cdata_wr <= 20'd0;
      else
        cdata_wr <= roundresult[20:1];
        
      if( cur_addr1 < 4095 )
        cur_addr1 <= cur_addr1 + 1;
      else
      begin
        //cur_addr1 <= 13'd0;
        crd <= 1'b1;
      end
      
    end
    
    READ_L0:
    begin
      case(position2)
        
      UL:
      begin
      
      if(!readsig2)
      begin
      caddr_rd <= cur_addr2;
      readsig2 <= 1'b1;
      end
      
      else
      begin
      data4UL <= cdata_rd;
      position2 <= UR;
      readsig2 <= 1'b0;
      end
      
      end
      
      UR:
      begin
        
      if(!readsig2)
      begin
      caddr_rd <= cur_addr2 + 1;
      readsig2 <= 1'b1;
      end
      
      else
      begin
      data4UR <= cdata_rd;          
      position2 <= LL;
      readsig2 <= 1'b0;      
      end
              
      end
      
      LL:
      begin
      
      if(!readsig2)
      begin
      caddr_rd <= cur_addr2 + 64;
      readsig2 <= 1'b1; 
      end
      
      else
      begin
      data4LL <= cdata_rd;
      position2 <= LR;      
      readsig2 <= 1'b0;      
      end
         
      end
      
      LR:
      begin
        
      if(!readsig2)
      begin
      caddr_rd <= cur_addr2 + 65;
      readsig2 <= 1'b1; 
      end
      
      else
      begin
      data4LR <= cdata_rd;
      readsig2 <= 1'b0; 
      
      crd <= 1'b0;
      cwr <= 1'b1;
      csel <= 3'b011;       
      end
      
      end
      
      endcase
    
    end
    
    WRITE_L1:
    begin
      position2 <= UL;
      readsig2 <= 1'b0;
      cwr <= 1'b0;
      csel <= 3'b001;
      caddr_wr <= addr4;
      cdata_wr <= max;
      
      if( cur_addr2 != 4030 )
      begin
        if( chgsig < 31 )
        begin
          cur_addr2 <= cur_addr2 + 2;
          chgsig <= chgsig + 1;
        end
        else
        begin
          chgsig <= 6'd0;
          cur_addr2 <= cur_addr2 + 66;
        end
        addr4 <= addr4 + 1;
        crd <= 1'b1;
      end
      else
      begin
        chgsig <= 6'd0;
        cur_addr2 <= 13'd0;
        addr4 <= 12'd0;
        final <= 1'b1;
      end
    end
    
    FINISH:
    begin
      final <= 1'b0;
      busy <= 1'b0;
    end
    
    default:
    begin
    iaddr <= 12'd0;
    position1 <= UPPERLEFT;
    cur_addr1 <= 13'd0;
    cur_addr2 <= 13'd0;    
    dataUL <= 20'd0;
    dataU <= 20'd0;
    dataUR <= 20'd0;
    dataL <= 20'd0;
    dataC <= 20'd0;
    dataR <= 20'd0;
    dataLL <= 20'd0;
    dataD <= 20'd0;
    dataLR <= 20'd0;
    data4UL <= 20'd0;
    data4UR <= 20'd0;
    data4LL <= 20'd0;
    data4LR <= 20'd0;
    csel <= 3'b0;
    caddr_wr <= 12'd0;
    cwr <= 1'b0;
    crd <= 1'b0;
    position2 <= UL;
    cdata_wr <= 20'd0;
    caddr_rd <= 12'd0;
    chgsig <= 6'd0;
    addr4 <= 12'd0;
    final <= 1'b0;
    readsig <= 1'b0;
    readsig2 <= 1'b0;
    end
    
    endcase
    
  end
end

always@(*)
begin
  case(cur_state)
    IDLE:
    begin
      if(ready == 1'd1)
        nxt_state = READ_CONV;
      else
        nxt_state = IDLE; 
    end
    
    READ_CONV:
    begin
      if(cwr)
        nxt_state = WRITE_L0;
      else
        nxt_state = READ_CONV;
    end

    WRITE_L0:
    begin
      if(crd)
        nxt_state = READ_L0;
      else
        nxt_state = READ_CONV;
    end
    
    READ_L0:
    begin
      if(cwr)
        nxt_state = WRITE_L1;
      else
        nxt_state = READ_L0;
    end
    
    WRITE_L1:
    begin
      if(final)
        nxt_state = FINISH;
      else
        nxt_state = READ_L0;
    end
    
    FINISH:
      nxt_state = FINISH;
    
    default:
      nxt_state = IDLE;
    
  endcase
end

endmodule