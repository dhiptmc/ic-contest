module DT(
	input 			clk, 
	input			reset,
	output	reg		done ,
	output	reg		sti_rd ,
	output	reg 	[9:0]	sti_addr ,
	input		[15:0]	sti_di,
	output	reg		res_wr ,
	output	reg		res_rd ,
	output	reg 	[13:0]	res_addr ,
	output	reg 	[7:0]	res_do,
	input		[7:0]	res_di
	);

reg [2:0] cur_state, nxt_state;
parameter 	IDLE		= 3'd0,
			SELF1		= 3'd1,
			READ1 		= 3'd2,
			FORWARD 	= 3'd3,
			SELF2		= 3'd4,
			READ2 		= 3'd5,
			BACKWARD 	= 3'd6,
			FINAL 		= 3'd7;

reg judge;

reg [2:0] counter1; //for READ1
reg [2:0] counter2; //for READ2

reg [14:0] index;

reg [7:0] a,b,c,d,e;

reg flag;

wire [7:0] compare1, compare2, forwardresult, backwardresult;
assign compare1 = (a < b) ? a : b;
assign compare2 = (c < d) ? c : d;
assign forwardresult = (compare1 < compare2) ? (compare1 + 1) : (compare2 + 1);
assign backwardresult= (e < forwardresult) ? e : forwardresult;

always@(posedge clk or negedge reset)
begin
	if(!reset)
	begin
		cur_state <= IDLE;
	end
	else
	begin
		cur_state <= nxt_state;
	end
end

always@(*)
begin
	case(cur_state)
	IDLE:
		nxt_state = (reset) ? SELF1 : IDLE;

	SELF1:
		nxt_state = (flag) ? READ1 : SELF1;
	READ1:
		nxt_state = ( (index <= 127) || (index >= 16256) || (index % 128 == 0) || ((index % 128 == 127)) || (!judge) ) ? FORWARD : ( (counter1 != 4) ? READ1 : FORWARD );
	FORWARD:
		nxt_state = (flag) ? ( (index == 16383) ? SELF2 : SELF1 ) : FORWARD;

	SELF2:
		nxt_state = (flag) ? READ2 : SELF2;
	READ2:
		nxt_state = ( (index <= 127) || (index >= 16256) || (index % 128 == 0) || ((index % 128 == 127)) || (e == 0) ) ? BACKWARD : ( (counter2 != 4) ? READ2 : BACKWARD );
	BACKWARD:
		nxt_state = (flag) ? ( (index == 0) ? FINAL : SELF2 ) : BACKWARD;

	FINAL:
		nxt_state = IDLE;

	default:
		nxt_state = IDLE;			

	endcase
end

always@(posedge clk or negedge reset)
begin
	if(!reset)
	begin
		done 	<= 1'd0;
		sti_rd 	<= 1'd0;
		sti_addr<= 10'd0;
		res_wr 	<= 1'd0;
		res_rd 	<= 1'd0;
		res_addr<= 14'd0;
		res_do 	<= 8'd0;

		judge <= 1'd0;

		counter1 <= 3'd0;
		counter2 <= 3'd0;

		index <= 15'd0;

		a <= 8'd0;
		b <= 8'd0;
		c <= 8'd0;
		d <= 8'd0;	
		e <= 8'd0;

		flag <= 1'd0;		
	end
	else
	begin
		case(cur_state)
		SELF1:
		begin
			res_wr <= 0;	
			if(!flag)
			begin
				sti_rd <= 1;
				sti_addr <= index / 16;

				flag <= 1;
			end
			else
			begin
				sti_rd <= 0;				
				judge <= sti_di[15- index % 16];

				flag <= 0;
			end
		end

		READ1:
		begin
			if( (index <= 127) || (index >= 16256) || (index % 128 == 0) || ((index % 128 == 127)) || (!judge) );
			else
			begin
				counter1 <= counter1 + 1;
				res_rd <= 1;

				case(counter1)
				3'd0:
				begin
					res_addr <= (index - 129);
					// a <= res_di;
				end			
				3'd1:
				begin
					a <= res_di;
					res_addr <= (index - 128);
					// b <= res_di;
				end				
				3'd2:
				begin
					b <= res_di;
					res_addr <= (index - 127);
					// c <= res_di;
				end
				3'd3:
				begin
					c <= res_di;
					res_addr <= (index - 1);
					// d <= res_di;
				end
				3'd4:
				begin
					d <= res_di;
				end
				default:
				begin
					a <= 0;
					b <= 0;
					c <= 0;
					d <= 0;
				end
				endcase
			end
		end

		FORWARD:
		begin
			if(!flag)
			begin
				counter1 <= 0;
				res_rd <= 0;
				res_wr <= 1;
				res_addr <= index;

				flag <= 1;
			end
			else
			begin
				if(index < 16383)
					index <= index + 1;

				if( (index <= 127) || (index >= 16256) || (index % 128 == 0) || ((index % 128 == 127)) || (!judge) )
					res_do <= 8'd0;
				else
					res_do <= forwardresult;

				flag <= 0;
			end
		end

		SELF2:
		begin
			if(!flag)
			begin
				res_wr <= 0;
				res_rd <= 1;
				res_addr <= index;
				flag <= 1;
			end
			else
			begin
				res_rd <= 0;
				e <= res_di;
				flag <= 0;
			end
		end

		READ2:
		begin
			if( (index <= 127) || (index >= 16256) || (index % 128 == 0) || ((index % 128 == 127)) || (e == 0) );
			else
			begin
				counter2 <= counter2 + 1;

				res_rd <= 1;

				case(counter2)
				3'd0:
				begin
					res_addr <= (index + 129);
					// a <= res_di;
				end			
				3'd1:
				begin
					a <= res_di;
					res_addr <= (index + 128);
					// b <= res_di;
				end				
				3'd2:
				begin
					b <= res_di;
					res_addr <= (index + 127);
					// c <= res_di;
				end
				3'd3:
				begin
					c <= res_di;
					res_addr <= (index + 1);
					// d <= res_di;
				end
				3'd4:
				begin
					d <= res_di;
				end
				default:
				begin
					a <= 0;
					b <= 0;
					c <= 0;
					d <= 0;
					e <= 0;
				end
				endcase
			end
		end

		BACKWARD:
		begin
			if(!flag)
			begin
				counter2 <= 0;
				res_rd <= 0;
				res_wr <= 1;
				res_addr <= index;

				flag <= 1;
			end
			else
			begin
				if(index > 0)
					index <= index - 1;

				if( (index <= 127) || (index >= 16256) || (index % 128 == 0) || ((index % 128 == 127)) || (e == 0)  )
					res_do <= 8'd0;
				else
					res_do <= backwardresult;

				flag <= 0;
			end
		end

		FINAL:
		begin
			done <= 1'd1;
		end

		default:
		begin
			done 	<= 1'd0;
			sti_rd 	<= 1'd0;
			sti_addr<= 10'd0;
			res_wr 	<= 1'd0;
			res_rd 	<= 1'd0;
			res_addr<= 14'd0;
			res_do 	<= 8'd0;

			judge <= 1'd0;

			counter1 <= 3'd0;
			counter2 <= 3'd0;

			index <= 15'd0;

			a <= 8'd0;
			b <= 8'd0;
			c <= 8'd0;
			d <= 8'd0;	
			e <= 8'd0;

			flag <= 1'd0;		
		end

		endcase
	end
end


endmodule
