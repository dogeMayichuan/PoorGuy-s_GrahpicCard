`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/06 23:37:14
// Design Name: 
// Module Name: arst_syn_release
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


module arst_syn_release(
input arstn, 
input clk,
output syn_rst
    );
    
reg reset1;
reg reset2;
assign syn_rst = reset2;

always@(posedge clk or negedge arstn)begin
        if(!arstn) begin
                reset1 <= 1'b1;
                reset2 <= 1'b1;
        end
        else begin
               reset1 <= 1'b0;
               reset2 <= reset1;
        end
end
endmodule
