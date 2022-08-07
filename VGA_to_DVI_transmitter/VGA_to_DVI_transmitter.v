`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/07 01:20:34
// Design Name: 
// Module Name: VGA_to_DVI_transmitter
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/07 00:34:05
// Design Name: 
// Module Name: top1
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

module VGA_to_DVI_transmitter(


input                                           p_clk,
input                                      p_clk_x5,
input                                          arstn,

//VGA input
input [7:0]                                    VGA_r,
input [7:0]                                    VGA_g,
input [7:0]                                     VGA_b,
input                                               VGA_hs,
input                                                VGA_vs,
input                                                VGA_de,

//DVI output 

output                                            tmds_clk_p,
output                                          tmds_clk_n,
output  [2:0]                            tmds_data_p, //r g b
output  [2:0]                                       tmds_data_n
    );
    
    wire                       arstn_release;
    wire       [9:0]      red_10b;
    wire       [9:0]      green_10b;
    wire       [9:0]      blue_10b;
    

   arst_syn_release 
   arst_syn_release_ins(
   .arstn(arstn),
   .clk(p_clk),
   .syn_rst( arstn_release)
   );



   //8B to 10B DVI encoder
   DVI_encoder
    DVI_encoder_R(
   .clkin(p_clk),
   .rstin(arstn_release),
   .din( VGA_r),
   .c0(1'b0),
   .c1(1'b0),
   .de(VGA_de),
   .dout(red_10b)
   );
   
   DVI_encoder 
   DVI_encoder_G(
    .clkin(p_clk),
   .rstin(arstn_release),
   .din( VGA_g),
   .c0(1'b0),
   .c1(1'b0),
   .de(VGA_de),
   .dout(green_10b)
   );
   
   DVI_encoder 
   DVI_encoder_B(
   .clkin(p_clk),
  .rstin(arstn_release),
  .din( VGA_b),
  .c0(VGA_hs),
  .c1(VGA_vs),
  .de(VGA_de),
  .dout(blue_10b)
   );
                    
    ///Serdes
    wire SO_r;
    wire SO_g;
    wire SO_b;
    wire SO_clk;
    
    ///RED channel
    PISO_10to1 
    PISO_10to1_R(
    .reset(arstn_release),
    .PI_clk(p_clk),
    .SO_clk(p_clk_x5),
    .PI_data(red_10b),
    .SO_data(SO_r)
    );
    
       OBUFDS #(
       .IOSTANDARD("TMDS_33"), // Specify the output I/O standard
       .SLEW("SLOW")           // Specify the output slew rate
    ) OBUFDS_R (
       .O(tmds_data_p[2]),     // Diff_p output (connect directly to top-level port)
       .OB(tmds_data_n[2]),   // Diff_n output (connect directly to top-level port)
       .I(SO_r)      // Buffer input
    );

    /// Green channel
    PISO_10to1 
    PISO_10to1_G(
    .reset(arstn_release),
    .PI_clk(p_clk),
    .SO_clk(p_clk_x5),
    .PI_data(green_10b),
    .SO_data(SO_g)
    );
    
           OBUFDS #(
    .IOSTANDARD("TMDS_33"), // Specify the output I/O standard
    .SLEW("SLOW")           // Specify the output slew rate
 ) OBUFDS_G (
    .O(tmds_data_p[1]),     // Diff_p output (connect directly to top-level port)
    .OB(tmds_data_n[1]),   // Diff_n output (connect directly to top-level port)
    .I(SO_g)      // Buffer input
 );
    ///BLUE channel
   PISO_10to1 
   PISO_10to1_B(
    .reset(arstn_release),
    .PI_clk(p_clk),
    .SO_clk(p_clk_x5),
    .PI_data(blue_10b),
    .SO_data(SO_b)
    );
    
     OBUFDS #(
.IOSTANDARD("TMDS_33"), // Specify the output I/O standard
.SLEW("SLOW")           // Specify the output slew rate
) OBUFDS_B (
.O(tmds_data_p[0]),     // Diff_p output (connect directly to top-level port)
.OB(tmds_data_n[0]),   // Diff_n output (connect directly to top-level port)
.I(SO_b)      // Buffer input
);
    ///clk channel
        PISO_10to1 
    PISO_10to1_CLK(
     .reset(arstn_release),
     .PI_clk(p_clk),
     .SO_clk(p_clk_x5),
     .PI_data(10'b1111100000),
     .SO_data(SO_clk)
     );
         OBUFDS #(
.IOSTANDARD("TMDS_33"), // Specify the output I/O standard
.SLEW("SLOW")           // Specify the output slew rate
) OBUFDS_CLK (
.O(tmds_clk_p),     // Diff_p output (connect directly to top-level port)
.OB(tmds_clk_n),   // Diff_n output (connect directly to top-level port)
.I(SO_clk)      // Buffer input
);
    
    
endmodule

