module geofence (clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output reg valid;
output reg is_inside;

//integer i;
reg [9:0] Xreg [6:0];
reg [9:0] Yreg [6:0];
reg [3:0] counterrd;

reg [2:0] index;
reg [2:0] index_cur;

wire signed [10:0] Ax,Ay,Bx,By;
wire signed [20:0] cross_product;
reg fenceflag;
assign Ax = {1'b0,Xreg[index]} - {1'b0,Xreg[(!fenceflag)]};
assign Ay = {1'b0,Yreg[index]} - {1'b0,Yreg[(!fenceflag)]};
assign Bx = {1'b0,Xreg[index%6 + (!fenceflag) + fenceflag]} - {1'b0,Xreg[ (!fenceflag) + index*fenceflag ]};
assign By = {1'b0,Yreg[index%6 + (!fenceflag) + fenceflag]} - {1'b0,Yreg[ (!fenceflag) + index*fenceflag ]};
assign cross_product = Ax*By - Bx*Ay;

reg ngflag,psflag;

always@(posedge clk or posedge reset)
begin
    if(reset)
    begin
        valid <= 1'b0;
        is_inside <= 1'b0;
        counterrd <= 4'b0;
        index <= 3'd2;
        index_cur <= 3'd2;
        fenceflag <= 1'b0;
        ngflag <= 1'b0;
        psflag <= 1'b0;
    end

    else
    begin
        if( counterrd <= 6 ) // rd (x,y)
        begin
            if(valid)
            begin
                valid <= 1'b0;
            end
            else
            begin
                Xreg[counterrd] <= X;
                Yreg[counterrd] <= Y;
                counterrd <= counterrd + 1;
            end
        end

        else // calculate
        begin
            if(!fenceflag)
            begin
                if( index_cur <= 5 )
                begin
                    if( cross_product[20] == 1 )
                    begin
                        index <= index_cur + 1;
                        index_cur <= index_cur + 1;
                    end
                    else
                    begin
                        Xreg[index+1] <= Xreg[index];
                        Xreg[index] <= Xreg[index+1];                  
                        Yreg[index+1] <= Yreg[index];
                        Yreg[index] <= Yreg[index+1];
                        
                        if(index > 2)
                        begin  
                            index <= index - 1;
                        end
                        else
                        begin
                            index <= index_cur + 1;
                            index_cur <= index_cur + 1;                       
                        end
                    end
                end
                else
                begin
                    fenceflag <= 1'b1;
                    index <= 3'd1;
                end
            end

            else
            begin
                if( index <= 6 )
                begin
                    if( cross_product[20] == 1 )
                    begin
                        ngflag <= 1'b1;
                    end
                    else
                    begin
                        psflag <= 1'b1;
                    end
                    index <= index + 1;
                end
                else
                begin
                    valid <= 1'b1;
                    counterrd <= 4'b0;
                    index <= 3'd2;
                    index_cur <= 3'd2;
                    fenceflag <= 1'b0;
                    ngflag <= 1'b0;
                    psflag <= 1'b0;

                    if( (ngflag) & (psflag) )
                    begin
                        is_inside <= 1'b0;
                    end
                    else
                    begin
                        is_inside <= 1'b1;
                    end
                end
            end
        end
    end
end

endmodule