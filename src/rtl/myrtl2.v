module myrtl2 (
  input wire clk,
  input wire resetn,
  output wire [2:0] led,
  output wire [2:0] hoge
);
  assign hoge = 2;

  _myrtl2 #(
    .T(50 * 1000 * 1000)) i (
    .clk(clk),
    .resetn(resetn),
    .led(led)
  );

endmodule