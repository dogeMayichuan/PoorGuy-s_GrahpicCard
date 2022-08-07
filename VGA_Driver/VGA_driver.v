`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:    Yichuan Ma
// 
// Create Date: 2022/08/06 14:46:26
// Design Name: 
// Module Name: LCD_driver
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


module VGA_driver
#(

//Standard timming constraints for 1280*720

parameter H_SYNC             = 16'd40,
parameter H_BP                   = 16'd220,
parameter H_DISP               = 16'd1280,
parameter H_FP                    = 16'd40,
parameter H_TOTAL           = 16'd1650,


parameter V_SYNC              = 16'd5,
parameter V_BP                    = 16'd20,
parameter V_DISP                = 16'd720,
parameter V_FP                     = 16'd5,
parameter V_TOTAL            = 16'd750

)
(

input                            pclk,
input                            arstn,

// connection to image source
output  [15:0]    p_xpos,
output  [15:0]    p_ypos,
input   [23:0]              pdata_rgb,

//VGA output 
output                         video_hs,    
output                         video_vs,    
output                         video_clk, 
output                         video_de,  
output   [23:0]          video_rgb  //RGB-888 format
    );
    
    //counters for pix  indexing
    reg [15:0] v_cnt;
    reg [15:0] h_cnt;
    
    always@(posedge pclk or negedge arstn) begin
        if(!arstn)begin
                    h_cnt <=    0;
                    v_cnt  <=   0;
        end
        else begin
                    if (h_cnt == H_TOTAL - 1 )begin
                         h_cnt  <= 0; 
                         if(v_cnt == V_TOTAL - 1) begin
                                v_cnt <= 0;
                         end
                         else begin
                                v_cnt <= v_cnt + 1;
                         end
                    end
                    else begin
                        h_cnt <= h_cnt + 1;
                    end                 
        end
    end
    
    //data enable logic and rgb channel
    assign video_de    = (h_cnt >= H_SYNC + H_BP ) &&(h_cnt < H_SYNC + H_BP + H_DISP ) &&(v_cnt >= V_SYNC + V_BP) &&(v_cnt < V_SYNC + V_BP + V_DISP) ?  1'b1:1'b0;
    assign video_rgb  = (video_de)?                                  pdata_rgb:24'd0;
    assign video_hs     = (h_cnt <  H_SYNC )?               1'b0:1'b1;
    assign video_vs     = (v_cnt  <  V_SYNC )?               1'b0:1'b1;
    
   //pix Request  
    wire data_req = (h_cnt >= H_SYNC + H_BP  - 1'b1) &&(h_cnt < H_SYNC + H_BP + H_DISP - 1'b1) &&(v_cnt >= V_SYNC + V_BP) &&(v_cnt < V_SYNC + V_BP + V_DISP) ?  1'b1:1'b0;
    assign p_xpos =   data_req?           (h_cnt - H_SYNC - H_BP+ 1'b1) : 16'd0;
     assign p_ypos =   data_req?          (v_cnt - V_SYNC - V_BP+ 1'b1) :  16'd0;
    
    
endmodule
