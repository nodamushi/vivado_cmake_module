`timescale 1 ps / 1 ps

module top (
  output wire [2:0] led0,
  output wire [2:0] led1,
  input wire reset,
  input wire sys_clock);

  wire aclk;
  wire aresetn;
  wire [2:0] hoge;

  myrtl myrtl(
    .clk(aclk),
    .resetn(aresetn),
    .led(led0),
    .hoge(hoge)
  );

  design_1_wrapper design_1(
    .aclk(aclk),
    .aresetn(aresetn),
    .led1(led1),
    .reset(reset),
    .sys_clock(sys_clock),
    .led0(led0),
    .hoge(hoge));
endmodule
