module myrtl#(
  parameter integer T = 1000 * 1000
) (
  input wire clk,
  input wire resetn,
  output wire [2:0] led
);

  reg [31:0] counter;
  reg [2:0] out;
  wire [2:0] out_next_led;
  assign led = out;

  always @(posedge clk) begin
    if (!resetn)
      counter <= 0;
    else
      counter <= counter == T? 0 : counter + 1;
  end

  assign out_next_led = {out[1:0], out[2]};
  always @(posedge clk) begin
    if (!resetn)
      out <= 3'b001;
    else
      out <= counter == T? out_next_led: out;
  end

endmodule