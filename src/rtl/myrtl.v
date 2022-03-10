module myrtl(
  input wire clk,
  input wire resetn,
  output wire [2:0] led,
  output wire [2:0] hoge
);
  assign hoge = 1;
  localparam integer T = 200 * 1000 * 1000;
  reg [31:0] counter;
  reg [2:0] out;
  wire [2:0] out_next_led;
  assign led = out;
  assign hoge = 1;

  always @(posedge clk) begin
    if (!resetn)
      counter <= 0;
    else
      counter <= counter >= T? 0 : counter + 1;
  end

  assign out_next_led = {out[1:0], out[2]};
  always @(posedge clk) begin
    if (!resetn)
      out <= 3'b001;
    else
      out <= counter >= T? out_next_led: out;
  end

  initial begin
    counter = 0;
    out = 0;
  end

endmodule