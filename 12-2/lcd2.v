////////////////////////////////////////////////////////////////////////
// Department of Computer Science
// National Tsing Hua University
// Project   : Design Gadgets for Hardware Lab
// Module    : lcd2 (top module)
// Author    : Chih-Tsun Huang
// E-mail    : cthuang@cs.nthu.edu.tw
// Revision  : 2
// Date      : 2011/04/13
`include "global.v"
module lcd2 (
clk,
rst_n,sec,AMPM,hour,year99,
col,
row,
LCD_rst,
LCD_cs,
LCD_rw,
LCD_di,
LCD_data,
LCD_en,
key,
mode,
set,
set_hour,set_minute,
start,pause
  
);
  input              clk;
  input              rst_n,sec,AMPM,hour,year99;
  input set;
  input set_hour,set_minute;
  input start,pause;
  input mode;
  input  wire [3:0]  col;
  output wire [3:0]  row;
  output             LCD_rst;
  output wire [1:0]  LCD_cs;
  output             LCD_rw;
  output             LCD_di;
  output wire [7:0]  LCD_data;
  output             LCD_en;
  output wire [15:0] key;

  wire change,en,out_valid;
  wire [7:0] data_out;
  wire clk_div;
  wire [`BCD_BIT_WIDTH-1:0] dig0,dig1,dig2,dig3;
  wire [`BCD_BIT_WIDTH-1:0] out0,out1,out2,out3;
  wire [15:0] ee_clock;
  wire [15:0] stopwatch;
  reg [16:0] op;
  
  assign ee_clock = {dig0,dig1,dig2,dig3};
  assign stopwatch = {out0,out1,out2,out3};
  
  always@*
  begin
	if(~mode)
		op = ee_clock;
	else
		op =stopwatch;
  end

  keypad_scan K1 (
    .rst_n(rst_n),
    .clk(clk_div),
    .col(col),
    .row(row),
    .change(change),          // push and release
    .key(key)                 // mask {F,E,D,C,B,3,6,9,A,2,5,8,0,1,4,7}
  );
	
  lab7 electronic_clock(
  .display(), // 14 segment display control
  .ftsd_ctl(), // scan control for 14-segment display
  .clk(clk), // clock
  .rst_n(rst_n), // low active reset
  .in(), // input control for FSM
  .sec(sec),
  .AMPM(AMPM),
  .varyfast(),
  .fast(),
  .slow(),
  .hour(hour),
  .year99(year99),
  .dig0(dig0),
  .dig1(dig1),
  .dig2(dig2),
  .dig3(dig3));
  
  stopwatch s1(
  .display(), // 14 segment display control
  .ftsd_ctl(), // scan control for 14-segment display
  .clk(clk), // clock
  .rst_n(rst_n), // low active reset
  .in(), // input control for FSM
  .set(set),
  .set_hour(set_hour),
  .set_minute(set_minute),
  .start(start),
  .pause(pause),
  .state_start(),
  .state_pause(),
  .led(),
  .out0(out0),
  .out1(out1),
  .out2(out2),
  .out3(out3)
);

  RAM_ctrl R2 (
    .clk(clk_div),
    .rst_n(rst_n),
    .change(1'b1),
    .key(op),
    .en(en),
    .data_out(data_out),
    .data_valid(out_valid));

  lcd_ctrl d1 (
    .clk(clk_div),
    .rst_n(rst_n),
    .data(data_out),           // memory value  
    .data_valid(out_valid),    // if data_valid = 1 the data is valid
    .LCD_di(LCD_di),
    .LCD_rw(LCD_rw),
    .LCD_en(LCD_en),
    .LCD_rst(LCD_rst),
    .LCD_cs(LCD_cs),
    .LCD_data(LCD_data),
    .en_tran(en)
  );

  clock_divider #(
    .half_cycle(200),         // half cycle = 200 (divided by 400)
    .counter_width(8)         // counter width = 8 bits
  ) clk100K (
    .rst_n(rst_n),
    .clk(clk),
    .clk_div(clk_div)
  );

endmodule
