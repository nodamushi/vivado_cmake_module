module myrtl2#(
  parameter integer T = 1000 * 1000
) (
  input wire clk,
  input wire resetn,
  output wire [2:0] led
);

  _myrtl2 #(.T(T)) i (
    .clk(clk),
    .resetn(resetn),
    .led(led)
  );

endmodule