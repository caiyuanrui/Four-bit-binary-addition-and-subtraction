`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/01 11:30:02
// Design Name: 
// Module Name: Adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Dispaly(
input [1:0]num,
input [7:0]led_bits,
output reg [6:0]a_to_g_left,
output reg [6:0]a_to_g_right,
output [7:0]D0_led_bits
);

assign D0_led_bits=led_bits;

always@(*)
begin
case(num)
    0:begin a_to_g_left=7'b1111110;a_to_g_right=7'b1111110;end
    1:begin a_to_g_left=7'b0110000;a_to_g_right=7'b0110000;end
    default:begin a_to_g_left=7'b1001111;a_to_g_right=7'b1001111;end
endcase
end
endmodule

module Adder(
input [7:0]num,//数码开关
input [2:0]operator,//运算符
input clk,
input clr,
output [7:0]t_led_bits,
output [6:0]a_to_g_left,
output [6:0]a_to_g_right
);
reg [7:0]led_bits;
reg [3:0]l_num;
reg [3:0]r_num;
reg [4:0]sum;
reg [15:0]clk_cnt;
reg sign;//符号判断
reg flag;//溢出判断
reg isresult;//显示判断
reg [1:0]n;//显示数字
wire [3:0]div1;
wire [2:0]div2;
wire order;
assign div1=clk_cnt[15:12];
assign div2=clk_cnt[15:13];
assign order=sum[4];//和的最高位
always@(posedge clk or posedge clr)
begin
    l_num={num[7],num[6],num[5],num[4]};
    r_num={num[3],num[2],num[1],num[0]};
    clk_cnt=clk_cnt+1;
    if(clr) begin clk_cnt=0;end                     //不显示结果
end

always@(posedge operator[2] or posedge operator[1] or posedge clr)
begin
    if(operator[2]||clr)
        sign=1;                             //+
    else if(operator[1])
        sign=0;                             //-
end

always@(posedge operator[0] or posedge clr)
begin
    if(clr)
        begin flag=0;sum=0;isresult=0;end
    else begin
    if(sign)
    begin
        sum=l_num+r_num;
        flag=0;
        if(order==1)
            flag=1;                         //溢出啦
    end
    else 
        if(l_num<r_num)
            flag=1;                         //成负数啦
        else begin sum=l_num-r_num;flag=0;end
    isresult=1;                             //显示结果
    end
end

//num赋值
always@(*)
begin
if(flag)
begin n=2;led_bits=8'b11111111;end
else
begin
    if(isresult)
    begin
        case(div2)
        0: begin n=sum[0];led_bits=8'b00000001;end
        1: begin n=sum[1];led_bits=8'b00000010;end
        2: begin n=sum[2];led_bits=8'b00000100;end 
        default: begin n=sum[3];led_bits=8'b00001000;end 
        endcase
    end
    else
    begin
        case(div1)
        0:begin n=l_num[3];led_bits=8'b10000000;end
        1:begin n=l_num[2];led_bits=8'b01000000;end
        2:begin n=l_num[1];led_bits=8'b00100000;end
        3:begin n=l_num[0];led_bits=8'b00010000;end
        4:begin n=r_num[3];led_bits=8'b00001000;end
        5:begin n=r_num[2];led_bits=8'b00000100;end
        6:begin n=r_num[1];led_bits=8'b00000010;end
        7:begin n=r_num[0];led_bits=8'b00000001;end
        default: begin n=r_num[0];led_bits=8'b00000001;end
        endcase
     end
  end
end
Dispaly D0_display(
    .num(n),
    .led_bits(led_bits),
    .a_to_g_left(a_to_g_left),
    .a_to_g_right(a_to_g_right),
    .D0_led_bits(t_led_bits)
);
endmodule