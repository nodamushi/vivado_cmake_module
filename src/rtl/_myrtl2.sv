module _myrtl2#(
  parameter integer T = 1000 * 1000
) (
  input clk,
  input resetn,
  output [2:0] led
);

  logic [31:0] counter;
  logic [2:0] out;
  logic [2:0] out_next_led;
  assign led = out;

  always_ff @(posedge clk) begin
    if (!resetn)
      counter <= 0;
    else
      counter <= counter == T? 0 : counter + 1;
  end

  assign out_next_led = {out[1:0], out[2]};
  always_ff @(posedge clk) begin
    if (!resetn)
      out <= 3'b001;
    else
      out <= counter == T? out_next_led: out;
  end

endmodule