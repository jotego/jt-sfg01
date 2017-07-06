module jt2148(
	input	[2:0]		addr,
	input	[7:0]		din,
	output	[7:0]		dout,
	input				midi_rx,
	output				midi_tx,
	// bus control
	input				cs_n,
	output				irq_n,
	input				ic_n, // rst
	input				rd_n,
	input				wr_n,
	output				opm_n,
	// keyboard
	output	[7:0]		st,
	input	[7:0]		sd

);

wire irq_rx_n = 1'b1;
wire irq_tx_n = 1'b1;

assign opm_n = !(!cs_n && addr[2:1]==2'b00);
assign irq_n = irq_rx_n | irq_tx_n;

endmodule // jt2148