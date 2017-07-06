module jt_sfg01(
	input			rst,
	inout  [ 7:0] 	dio,
	input  [13:0] 	addr,
	input			clk,	// pin 52
	// bus control
	input			wr_n,
	input			rd_n,
	input			slt3_n,
	// input			iorq_n,
	// input			mi,
	output			int_n,
	output			wait_n,
	// midi
	// input			midi_rx,
	// output			midi_tx,
	// keyboard control

);

// glue logic
wire ce_n = &addr[13:7]; // IC105 and IC106
wire ic106_4 = ~(addr[6] & ce_n);
wire ic106_2 = ~(addr[5] & addr[4]);
wire ic107_3 = ~(~ic106_4 & ~ic106_2); // this is just an OR but I want to follow the schematic
wire ic107_4 = ~(~ic107_3 & addr[4]);
wire cs_n    = ~(~ic107_4 & ~slt3_n); // ic107_1

assign busdir_n = ~(~iorq_n & ~mi);
assign wait_n	= 1'b1;

wire opm_n = !(!cs_n && addr[2:1]==2'b00);

wire [7:0] opm_dout;
reg [7:0] rom_dout;
wire oe_n = !( (!ce_n && !slt3_n) || !opm_n );

always @(oe_n)
	if( !oe_n )
		dio <= ( !opm_n ? opm_dout : 8'd0 ) | rom_dout;
	else
		dio <= 8'hzz;

//assign dout = ( !opm_n ? opm_dout : 8'd0 ) | rom_dout;

// assign midi_tx = 1'b0;

jt51(
	.clk	( clk		),	// main clock
	.rst	( rst		),	// reset
	.cs_n	( opm_n		),	// chip select
	.wr_n	( wr_n		),	// write
	.a0		( addr[0]	),
	.d_in	( dio		), // data in
	.d_out	( opm_dout	), // data out
	.irq_n	( int_n		),	// I do not synchronize this signal
	// Full resolution output
	output	signed	[15:0] xleft,
	output	signed	[15:0] xright,
	// unsigned outputs for sigma delta converters, full resolution
	// output	[15:0] dacleft,
	// output	[15:0] dacright
);


always @(*)
	casex( addr[7:0], ce_n, slt3_n )
		{ 8'hxx, 1'b1, 1'bx } : rom_dout = 8'd0;
		{ 8'hxx, 1'bx, 1'b1 } : rom_dout = 8'd0;
		{ 8'h80, 1'b0, 1'b0 } : rom_dout = 8'h4d;
		{ 8'h81, 1'b0, 1'b0 } : rom_dout = 8'h43;
		{ 8'h82, 1'b0, 1'b0 } : rom_dout = 8'h48;
		{ 8'h83, 1'b0, 1'b0 } : rom_dout = 8'h46;
		{ 8'h84, 1'b0, 1'b0 } : rom_dout = 8'h4d;
		{ 8'h85, 1'b0, 1'b0 } : rom_dout = 8'h30;
		default: rom_dout = 8'd0;
	endcase

endmodule // jt_sfg01