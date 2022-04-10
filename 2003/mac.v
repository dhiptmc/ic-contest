`define mul(a,b) (a*b)

module mac (instruction, multiplier, multiplicand, stall, clk, reset_n, result, protect);
input signed [15:0] multiplier;
input signed [15:0] multiplicand; 
input  clk;
input  reset_n;
input  stall;
input  [2:0] instruction;
output reg [31:0] result;
output reg [7:0] protect;

//Add you design here
reg signed [15:0] multer, multcand; 

reg [31:0] resultreg;
reg [7:0] protectreg;

reg [2:0] instruct;
wire signed [39:0] cal40;
assign cal40 = `mul(multer,multcand);

wire signed [7:0] multer_1,multer_2,multcand_1,multcand_2;
assign multer_1 = multer[7:0];
assign multer_2 = multer[15:8];
assign multcand_1 = multcand[7:0];
assign multcand_2 = multcand[15:8];
wire signed [19:0] cal20_1;
wire signed [19:0] cal20_2;
assign cal20_1 = `mul(multer_1,multcand_1);
assign cal20_2 = `mul(multer_2,multcand_2);
reg i;
 

always@(posedge clk or negedge reset_n)
begin
  if(!reset_n)
  begin
    result <= 32'b0;
    protect <= 8'b0;
    
    multer <= 16'b0;
    multcand <= 16'b0;
    
    resultreg <= 32'b0;
    protectreg <= 8'b0;
    
    instruct <= 3'b0;   
  end
  
  else if (stall)
  begin
    result <= result;
    protect <= protect;
    
    multer <= multer;
    multcand <= multcand;
    
    resultreg <= resultreg;
    protectreg <= protectreg;
    
    instruct <= instruct;   
  end
  
  else
  begin
    instruct <= instruction;
    
    multer <= multiplier;
    multcand <= multiplicand;
    
    case(instruct)
      
    3'b000:
    begin
      resultreg <= 32'h0;
      protectreg <= 8'h0;     
    end
    
    3'b001:
    begin
      {protectreg,resultreg} <= cal40;
    end
        
    3'b010:
    begin
      {protectreg,resultreg} <= {protectreg,resultreg} + cal40;
    end

    3'b011:
    begin
      if( $signed({protectreg,resultreg}) > $signed(40'h007fffffff) )
      begin
        resultreg <= 32'h7fffffff; // largest positive in 32-bit
      end
      
      else if( $signed({protectreg,resultreg}) < $signed(40'hff80000000) )
      begin
        resultreg <= 32'h80000000; // smallest negative in 32-bit
      end
      
      else
      begin
        resultreg <= resultreg; // truncate the MSB, value not altered
      end
      
      protectreg <= protectreg;
    end
    
    3'b100:
    begin
      resultreg <= 32'h0;
      protectreg <= 8'h0;
    end

    3'b101:
    begin
      {protectreg[3:0],resultreg[15:0]} <= cal20_1;
      {protectreg[7:4],resultreg[31:16]} <= cal20_2;
    end

    3'b110:
    begin
      {protectreg[3:0],resultreg[15:0]} <= {protectreg[3:0],resultreg[15:0]} + cal20_1;
      {protectreg[7:4],resultreg[31:16]} <= {protectreg[7:4],resultreg[31:16]} + cal20_2;
    end
    
    3'b111:
    begin
      for( i=0 ; i<1 ; i=i+1 )
      begin
        
      if( $signed({protectreg[3:0],resultreg[15:0]}) > $signed(20'h07fff) )
      begin
        resultreg[15:0] <= 16'h7fff; // largest positive in 16-bit
      end
      
      else if( $signed({protectreg[3:0],resultreg[15:0]}) < $signed(20'hf8000) )
      begin
        resultreg[15:0] <= 16'h8000; // smallest negative in 16-bit
      end
      
      else
      begin
        resultreg[15:0] <= resultreg[15:0]; // truncate the MSB, value not altered
      end
      
      if( $signed({protectreg[7:4],resultreg[31:16]}) > $signed(20'h07fff) )
      begin
        resultreg[31:16] <= 16'h7fff; // largest positive in 16-bit
      end
      
      else if( $signed({protectreg[7:4],resultreg[31:16]}) < $signed(20'hf8000) )
      begin
        resultreg[31:16] <= 16'h8000; // smallest negative in 16-bit
      end
      
      else
      begin
        resultreg[31:16] <= resultreg[31:16]; // truncate the MSB, value not altered
      end          
      
      protectreg <= protectreg;
      end
    end
    
    endcase
    
    result <= resultreg;
    protect <= protectreg;
    
  end

end

endmodule        