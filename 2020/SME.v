module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg valid;

reg [7:0] string [33:0];
reg [5:0] stringcounter; 
reg [5:0] stringcounterini;

reg [7:0] pattern [7:0];
reg [5:0] patterncounter;
reg [5:0] patterncounterini;

reg [4:0] testcounter;
reg [3:0] testpatternindex;     

integer i;

always@(posedge clk or posedge reset)
begin
  if(reset)
  begin
    match <= 1'b0;
    match_index <= 5'b0;
    valid <= 1'b0;

    stringcounter <= 6'd1; // start reading from string[1]
    stringcounterini <= 6'd1;
    patterncounter <= 6'b0;
    patterncounterini <= 6'b0;
    testcounter <= 5'b0;
    testpatternindex <= 4'b0;

    for( i = 0; i <= 33; i = i + 1)
    begin
      string[i] <= 8'h20; // initial spaces
    end
    for( i = 0; i <= 7; i = i + 1)
    begin
      pattern[i] <= 8'b0;
    end      
  end
  else
  begin
    if(isstring)
    begin
      match <= 1'b0;
      match_index <= 5'b0;
      valid <= 1'b0;
      string[stringcounterini] <= chardata;
      stringcounter <= stringcounterini + 1;
      stringcounterini <= stringcounterini + 1;
    end

    else if(ispattern)
    begin 
      match <= 1'b0;
      match_index <= 5'b0;
      valid <= 1'b0;
      pattern[patterncounterini] <= chardata;
      patterncounter <= patterncounterini + 1;
      patterncounterini <= patterncounterini + 1;
    end

    else // main
    begin
      stringcounterini <= 6'd1;
      patterncounterini <= 6'b0;
      string[stringcounter] <= 8'h20;
      pattern[patterncounter] <= 8'b0;

      //for( i = stringcounter; i <= 33; i = i + 1)
      //begin
        //string[i] <= 8'h20;
      //end
      //for( i = patterncounter; i <= 7; i = i + 1)
      //begin
        //pattern[i] <= 8'b0;
      //end

      if( pattern[0] == 8'h5e && pattern[patterncounter - 1] == 8'h24 ) // ^  $
      begin
        if( testcounter <= stringcounter - ( patterncounter - 1 ) ) // check boundary
        begin
          if( string[testcounter] == 8'h20 && string[testcounter + patterncounter - 1] == 8'h20 ) //  20 (something) 20
          begin
            if( string[testcounter + 1 + testpatternindex] == pattern[testpatternindex + 1] || pattern[testpatternindex + 1] == 8'h2e ) //fit
            begin
              if( testpatternindex == patterncounter - 3 )
              begin
                valid <= 1'b1;
                match <= 1'b1;
                match_index <= testcounter;
                testcounter <= 5'b0;
                testpatternindex <= 4'b0;
              end
              else // keep checking fit or not
              begin
                testpatternindex <= testpatternindex + 1;
              end
            end

            else // not fit
            begin
              testcounter <= testcounter + 1;
              testpatternindex <= 4'b0;
            end
          end

          else // search again
          begin
            testcounter <= testcounter + 1;
            testpatternindex <= 4'b0;
          end
        end

        else // not found
        begin
          valid <= 1'b1;
          match <= 1'b0;
          match_index <= 5'b0;
          testcounter <= 5'b0;
          testpatternindex <= 4'b0;
        end
      end

      else if( pattern[0] == 8'h5e ) // ^
      begin
        if( testcounter <= stringcounter - patterncounter ) // check boundary
        begin
          if( string[testcounter] == 8'h20 ) //  20 (something)
          begin
            if( string[testcounter + 1 + testpatternindex] == pattern[testpatternindex + 1] || pattern[testpatternindex + 1] == 8'h2e ) //fit
            begin
              if( testpatternindex == patterncounter - 2 )
              begin
                valid <= 1'b1;
                match <= 1'b1;
                match_index <= testcounter;
                testcounter <= 5'b0;
                testpatternindex <= 4'b0;
              end
              else // keep checking fit or not
              begin
                testpatternindex <= testpatternindex + 1;
              end
            end

            else // not fit
            begin
              testcounter <= testcounter + 1;
              testpatternindex <= 4'b0;
            end
          end

          else // search again
          begin
            testcounter <= testcounter + 1;
            testpatternindex <= 4'b0;
          end
        end

        else // not found
        begin
          valid <= 1'b1;
          match <= 1'b0;
          match_index <= 5'b0;
          testcounter <= 5'b0;
          testpatternindex <= 4'b0;
        end
      end

      else if( pattern[patterncounter - 1] == 8'h24 ) // $
      begin
        if( testcounter <= stringcounter - ( patterncounter - 1 ) ) // check boundary
        begin
          if( string[testcounter + patterncounter ] == 8'h20 ) //  (something) 20
          begin
            if( string[testcounter + 1 + testpatternindex] == pattern[testpatternindex] || pattern[testpatternindex] == 8'h2e ) //fit
            begin
              if( testpatternindex == patterncounter - 2 )
              begin
                valid <= 1'b1;
                match <= 1'b1;
                match_index <= testcounter;
                testcounter <= 5'b0;
                testpatternindex <= 4'b0;
              end
              else // keep checking fit or not
              begin
                testpatternindex <= testpatternindex + 1;
              end
            end

            else // not fit
            begin
              testcounter <= testcounter + 1;
              testpatternindex <= 4'b0;
            end
          end

          else // search again
          begin
            testcounter <= testcounter + 1;
            testpatternindex <= 4'b0;
          end
        end

        else // not found
        begin
          valid <= 1'b1;
          match <= 1'b0;
          match_index <= 5'b0;
          testcounter <= 5'b0;
          testpatternindex <= 4'b0;
        end
      end

      else // no pre and post symbol
      begin
        if( testcounter <= stringcounter - patterncounter ) // check boundary
        begin
          if( string[testcounter + 1 + testpatternindex] == pattern[testpatternindex] || pattern[testpatternindex] == 8'h2e ) //fit
          begin
            if( testpatternindex == patterncounter - 1 )
            begin
              valid <= 1'b1;
              match <= 1'b1;
              match_index <= testcounter;
              testcounter <= 5'b0;
              testpatternindex <= 4'b0;
            end
            else // keep checking fit or not
            begin
              testpatternindex <= testpatternindex + 1;
            end
          end
          else // not fit
          begin
            testcounter <= testcounter + 1;
            testpatternindex <= 4'b0;
          end
        end

        else // not found
        begin
          valid <= 1'b1;
          match <= 1'b0;
          match_index <= 5'b0;
          testcounter <= 5'b0;
          testpatternindex <= 4'b0;
        end
      end

      
    end
  end
end

endmodule