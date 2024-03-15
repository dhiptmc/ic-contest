module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

/*****
    The application of the Job Assignment Machine (JAM) is quite extensive.  
    When there are n tasks to be completed, and n workers have varying costs for each task,
    determining how to assign each worker to a task in order to minimize the overall cost
    is the primary objective of the JAM.  

    The most straightforward approach to solving the job assignment problem is to
    calculate the cost for all possible combinations and then
    identify the combination with the lowest cost.  

    In this question, input data regarding worker task costs will be provided,
    and participants are required to enumerate all possible pairings using an exhaustive search method. 

    Subsequently, they should find the lowest cost and determine the number of combinations
    that achieve this lowest cost.
*****/

reg [1:0] cur_state, nxt_state;
parameter   IDLE = 2'd0,
            CAL  = 2'd1,
            QUEUE= 2'd2,
            FINAL= 2'd3;

reg [2:0] a, b, c, d, e, f, g, h;

wire [2:0] gh, fgh, efgh, defgh, cdefgh, bcdefgh;
// assign gh = (g < h) ? ((f < g) ? g : h) : ((f < h) ? h : g);
// assign fgh = (gh < f) ? ((e < gh) ? gh : f) : ((e < f) ? f : gh);
// assign efgh = (fgh < e) ? ((d < fgh) ? fgh : e) : ((d < e) ? e : fgh);
// assign defgh = (efgh < d) ? ((c < efgh) ? efgh : d) : ((c < d) ? d : efgh);
// assign cdefgh = (defgh < c) ? ((b < defgh) ? defgh : c) : ((b < c) ? c : defgh); 
// assign bcdefgh = (cdefgh < b) ? ((a < cdefgh) ? cdefgh : b) : ((a < b) ? b : cdefgh); 

assign gh = (g < h) ? ((f < g) ? g : h) : ((f < h) ? h : g);

wire [3:0]fgh1, fgh2, fgh3, fgh4;
assign fgh1= (e < f) ? f : 8;
assign fgh2= (e < g) ? g : 8;
assign fgh3= (e < h) ? h : 8;
assign fgh4= (fgh1 < fgh2) ? fgh1 : fgh2;
assign fgh = (fgh4 < fgh3) ? fgh4 : fgh3;

wire [3:0]efgh1, efgh2, efgh3, efgh4, efgh5, efgh6;
assign efgh1= (d < e) ? e : 8;
assign efgh2= (d < f) ? f : 8;
assign efgh3= (d < g) ? g : 8;
assign efgh4= (d < h) ? h : 8;
assign efgh5= (efgh1 < efgh2) ? efgh1 : efgh2;
assign efgh6= (efgh3 < efgh4) ? efgh3 : efgh4;
assign efgh = (efgh5 < efgh6) ? efgh5 : efgh6;

wire [3:0] defgh1, defgh2, defgh3, defgh4, defgh5, defgh6, defgh7, defgh8;
assign defgh1= (c < d) ? d : 8;
assign defgh2= (c < e) ? e : 8;
assign defgh3= (c < f) ? f : 8;
assign defgh4= (c < g) ? g : 8;
assign defgh5= (c < h) ? h : 8;
assign defgh6= (defgh1 < defgh2) ? defgh1 : defgh2;
assign defgh7= (defgh3 < defgh4) ? defgh3 : defgh4;
assign defgh8= (defgh6 < defgh7) ? defgh6 : defgh7;
assign defgh = (defgh5 < defgh8) ? defgh5 : defgh8;

wire [3:0] cdefgh1, cdefgh2, cdefgh3, cdefgh4, cdefgh5, cdefgh6, cdefgh7, cdefgh8, cdefgh9, cdefgh10;
assign cdefgh1 = (b < c) ? c : 8;
assign cdefgh2 = (b < d) ? d : 8;
assign cdefgh3 = (b < e) ? e : 8;
assign cdefgh4 = (b < f) ? f : 8;
assign cdefgh5 = (b < g) ? g : 8;
assign cdefgh6 = (b < h) ? h : 8;
assign cdefgh7 = (cdefgh1 < cdefgh2) ? cdefgh1 : cdefgh2;
assign cdefgh8 = (cdefgh3 < cdefgh4) ? cdefgh3 : cdefgh4;
assign cdefgh9 = (cdefgh5 < cdefgh6) ? cdefgh5 : cdefgh6;
assign cdefgh10= (cdefgh7 < cdefgh8) ? cdefgh7 : cdefgh8;
assign cdefgh  = (cdefgh9 < cdefgh10) ? cdefgh9 : cdefgh10;

wire [3:0] bcdefgh1, bcdefgh2, bcdefgh3, bcdefgh4, bcdefgh5, bcdefgh6, bcdefgh7, bcdefgh8, bcdefgh9, bcdefgh10, bcdefgh11, bcdefgh12;
assign bcdefgh1 = (a < b) ? b : 8;
assign bcdefgh2 = (a < c) ? c : 8;
assign bcdefgh3 = (a < d) ? d : 8;
assign bcdefgh4 = (a < e) ? e : 8;
assign bcdefgh5 = (a < f) ? f : 8;
assign bcdefgh6 = (a < g) ? g : 8;
assign bcdefgh7 = (a < h) ? h : 8;
assign bcdefgh8 = (bcdefgh1 < bcdefgh2) ? bcdefgh1 : bcdefgh2;
assign bcdefgh9 = (bcdefgh3 < bcdefgh4) ? bcdefgh3 : bcdefgh4;
assign bcdefgh10= (bcdefgh5 < bcdefgh6) ? bcdefgh5 : bcdefgh6;
assign bcdefgh11= (bcdefgh7 < bcdefgh8) ? bcdefgh7 : bcdefgh8;
assign bcdefgh12= (bcdefgh9 < bcdefgh10)? bcdefgh9 : bcdefgh10;
assign bcdefgh  = (bcdefgh11< bcdefgh12)? bcdefgh11: bcdefgh12;

reg read;
reg [9:0] Cost_reg;
reg [3:0] w;


always@(posedge CLK or posedge RST)
begin
    if(RST)
        cur_state <= IDLE; 
    else
        cur_state <= nxt_state;
end

always@(*)
begin
    case(cur_state)
    IDLE:
        nxt_state = CAL;

    CAL:
        nxt_state = (w==8)? QUEUE : CAL;

    QUEUE:
        nxt_state = CAL;

    default:
        nxt_state = IDLE;

    endcase
end

always@(posedge CLK or posedge RST)
begin
    if(RST) 
    begin
        a <= 0;
        b <= 1;
        c <= 2;
        d <= 3;
        e <= 4;
        f <= 5;
        g <= 6;
        h <= 7;

        w <= 0;
        W <= 0;
        J <= a;
        Cost_reg <= 0;

        MatchCount <= 1;            
        MinCost <= 10'b1111111111;
        Valid <= 0;
    end
    else
    begin
        case(cur_state)
        IDLE:
        begin
            a <= 0;
            b <= 1;
            c <= 2;
            d <= 3;
            e <= 4;
            f <= 5;
            g <= 6;
            h <= 7;

            w <= 0;
            W <= 0;
            J <= a;
            Cost_reg <= 0;

            MatchCount <= 1;            
            MinCost <= 10'b1111111111;

            Valid <= 0;
        end

        CAL:
        begin
            case(W)
            0: J <= b;
            1: J <= c;
            2: J <= d;
            3: J <= e;
            4: J <= f;
            5: J <= g;
            6: J <= h;
            default: J <= a;
            endcase
            
            w <= w + 1;
            W <= W + 1;

            if((w >= 1) && (w < 8))
                Cost_reg <= Cost_reg + Cost;

            else if(w == 8)
            begin
                if( Cost_reg + Cost < MinCost )
                begin
                    MatchCount <= 1;
                    MinCost <= Cost_reg + Cost;
                end
                else if( Cost_reg + Cost == MinCost )
                    MatchCount <= MatchCount + 1;
                else;
            end     
        end

        QUEUE:
        begin
            w <= 0;
            W <= 0;
            J <= a;
            Cost_reg <= 0;

            if(g < h) // 0 1 2 3 4 5 6 7 -> 0 1 2 3 4 5 7 6
            begin
                h <= g;
                g <= h;
            end

            else if (f < g) // 0 1 2 3 4 5 7 6 -> 0 1 2 3 4 6 7 5 -> 0 1 2 3 4 6 5 7
            begin
                f <= gh;
                case(gh)
                g:
                begin
                    g <= h;
                    h <= f;
                end

                h:
                begin
                    g <= f;
                    h <= g;                    
                end
                endcase
            end

            else if (e < f) // 0 1 2 3 4 7 6 5
            begin
                e <= fgh;
                case(fgh)
                f:
                begin
                    f <= h;
                    //g <= g;
                    h <= e;
                end

                g:
                begin
                    f <= h;
                    g <= e;
                    h <= f;
                end

                h:
                begin
                    f <= e;
                    //g <= g;
                    h <= f;
                end
                endcase
            end

            else if (d < e)
            begin
                d <= efgh;
                case(efgh)
                e:
                begin
                    e <= h;
                    f <= g;
                    g <= f;
                    h <= d;
                end

                f:
                begin
                    e <= h;
                    f <= g;
                    g <= d;
                    h <= e;
                end

                g:
                begin
                    e <= h;
                    f <= d;
                    g <= f;
                    h <= e;
                end

                h:
                begin
                    e <= d;
                    f <= g;
                    g <= f;
                    h <= e;                 
                end
                endcase
            end

            else if (c < d)
            begin
                c <= defgh;
                case(defgh)
                d:
                begin
                    d <= h;
                    e <= g;
                    //f <= f;
                    g <= e;
                    h <= c;
                end

                e:
                begin
                    d <= h;
                    e <= g;
                    //f <= f; 
                    g <= c;
                    h <= d;
                end

                f:
                begin
                    d <= h;
                    e <= g;
                    f <= c;
                    g <= e;
                    h <= d;
                end

                g:
                begin
                    d <= h;
                    e <= c;
                    //f <= f;
                    g <= e;
                    h <= d;
                end

                h:
                begin
                    d <= c;
                    e <= g;
                    //f <= f;
                    g <= e;
                    h <= d;                  
                end
                endcase                
            end
            
            else if (b < c)
            begin
                b <= cdefgh;
                case(cdefgh)
                c:
                begin
                    c <= h;
                    d <= g;
                    e <= f;
                    f <= e;
                    g <= d;
                    h <= b;
                end

                d:
                begin
                    c <= h;
                    d <= g;
                    e <= f;
                    f <= e;
                    g <= b;
                    h <= c;
                end

                e:
                begin
                    c <= h;
                    d <= g;
                    e <= f;
                    f <= b;
                    g <= d;
                    h <= c;
                end

                f:
                begin
                    c <= h;
                    d <= g;
                    e <= b;
                    f <= e;
                    g <= d;
                    h <= c;
                end

                g:
                begin
                    c <= h;
                    d <= b;
                    e <= f;
                    f <= e;
                    g <= d;
                    h <= c;
                end

                h:
                begin
                    c <= b;
                    d <= g;
                    e <= f;
                    f <= e;
                    g <= d;
                    h <= c;                    
                end
                endcase                 
            end

            else if (a < b)
            begin
                a <= bcdefgh;
                case(bcdefgh)
                b:
                begin
                    b <= h;
                    c <= g;
                    d <= f;
                    //e <= e;
                    f <= d;
                    g <= c;
                    h <= a;                    
                end

                c:
                begin
                    b <= h;
                    c <= g;
                    d <= f;
                    //e <= e;
                    f <= d;
                    g <= a;
                    h <= b; 
                end

                d:
                begin
                    b <= h;
                    c <= g;
                    d <= f;
                    //e <= e;
                    f <= a;
                    g <= c;
                    h <= b; 
                end

                e:
                begin
                    b <= h;
                    c <= g;
                    d <= f;
                    e <= a;
                    f <= d;
                    g <= c;
                    h <= b; 
                end

                f:
                begin
                    b <= h;
                    c <= g;
                    d <= a;
                    //e <= e;
                    f <= d;
                    g <= c;
                    h <= b; 
                end

                g:
                begin
                    b <= h;
                    c <= a;
                    d <= f;
                    //e <= e;
                    f <= d;
                    g <= c;
                    h <= b; 
                end

                h:
                begin
                    b <= a;
                    c <= g;
                    d <= f;
                    //e <= e;
                    f <= d;
                    g <= c;
                    h <= b;                     
                end
                endcase 
            end
            else
            begin
                Valid <= 1;
            end
        end
        endcase
    end
end

endmodule 
