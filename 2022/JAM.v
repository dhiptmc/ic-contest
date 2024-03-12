module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

reg [2:0] cur_state,nxt_state;

integer m,n;
reg [6:0] costtable [7:0] [7:0];
reg tableflag;

reg [2:0] index [7:0];

reg [9:0] minicost;
reg [3:0] minicount;
wire [9:0] costtotal;
assign costtotal = costtable [0] [index[7]] + costtable [1] [index[6]] + costtable [2] [index[5]] + costtable [3] [index[4]] + costtable [4] [index[3]] + costtable [5] [index[2]] + costtable [6] [index[1]] + costtable [7] [index[0]];

reg finalflag;

integer i;
reg changeflag;

wire [7:0] finalcheck;
assign finalcheck [7] = ( index[7] == 3'd7 ) ? 1'b1 : 1'b0;
assign finalcheck [6] = ( index[6] == 3'd6 ) ? 1'b1 : 1'b0;
assign finalcheck [5] = ( index[5] == 3'd5 ) ? 1'b1 : 1'b0;
assign finalcheck [4] = ( index[4] == 3'd4 ) ? 1'b1 : 1'b0;
assign finalcheck [3] = ( index[3] == 3'd3 ) ? 1'b1 : 1'b0;
assign finalcheck [2] = ( index[2] == 3'd2 ) ? 1'b1 : 1'b0;
assign finalcheck [1] = ( index[1] == 3'd1 ) ? 1'b1 : 1'b0;
assign finalcheck [0] = ( index[0] == 3'd0 ) ? 1'b1 : 1'b0;

always@(posedge CLK or posedge RST)
begin
    if(rst)
    begin
        W <= 3'd0;
        J <= 3'd0;
        cur_state <= 3'd0;
        MatchCount <= 4'b0;
        MinCost <= 10'b0;
        Valid <= 1'b0;

        for ( m = 0; m <= 7; m = m + 1)
        begin
            for ( n = 0; n <= 7; n = n + 1)
            begin
                costtable [m] [n] <= 7'd0;
            end
        end
        tableflag <= 1'b0;

        index[7] <= 3'd0;
        index[6] <= 3'd1;
        index[5] <= 3'd2;
        index[4] <= 3'd3;
        index[3] <= 3'd4;
        index[2] <= 3'd5;
        index[1] <= 3'd6;
        index[0] <= 3'd7;

        minicost <= 10'd0;
        minicount <= 4'd1;
        
        i <= 0;
        changeflag <= 1'b0;
    end
    else
    begin
        cur_state <= nxt_state;

        case(cur_state)
        3'd0:
        begin
            costtable [W] [J] <= Cost;
            if( J != 3'd7 )
            begin
                J <= J + 1;
            end
            else
            begin
                J <= 3'd0;
                if( W != 3'd7 )
                begin
                    W <= W + 1;
                end
                else
                begin
                    tableflag <= 1'b1;
                end
            end
        end

        3'd1:
        begin
            if( tableflag )
            begin
                minicost <= costtotal;
                tableflag <= 1'b0;
            end
            else
            begin
                if( costtotal < minicost )
                begin
                    minicost <= costtotal;
                    minicount<= 4'd1;
                end
                else
                begin
                    minicount <= minicount + 1;
                end
            end
        end

        3'd2:
        begin
            if ( finalcheck == 8'b11111111 )
            begin
                finalflag <= 1'b1;
            end
            else
            begin
                finalflag <= 1'b0;
            end           
        end

        3'd3:
        begin
            if (!changeflag)
            begin
                if( index[i] > index[i+1] )
                begin
                    index[i] <= index[i+1];
                    index[i+1] <= index[i];
                    changeflag <= 1'b1;
                end
                else
                begin
                    i <= i + 1;
                end
            end
            else
            begin
                i = 0;
            end                 
        end

        3'd4:
        begin
            MatchCount <= minicount;
            MinCost <= minicost;
            Valid <= 1'b1;
        end

        default:
        begin
            Valid <= 1'b0;
        end

        endcase
    end
end

always@(*)
begin
    case(cur_state)

    3'd0:
    begin
        nxt_state = ( tableflag ) ? 3'd1 : 3'd0;
    end

    3'd1:
    begin
        nxt_state = 3'd2;
    end

    3'd2:
    begin
        nxt_state = ( finalflag ) ? 3'd4 : 3'd3; 
    end

    3'd3:
    begin
        nxt_state = ( changeflag ) ? 3'd1 : 3'd3; 
    end

    3'd4:
    begin
        nxt_state = 3'd4;
    end

    default:
    begin
        nxt_state = 3'd0;
    end

    endcase
end


endmodule
