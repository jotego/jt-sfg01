module jt_sfg01(
	input					rst,		// pin 25 		(MSX 15) RESET 

	//inout reg [ 7:0] 	dio, 		// pins 43-50 	IO(MSX 33-40) 	DATA BUS 	
	output [ 7:0]     sfg_dbi, 		// pins 43-50 	IO(MSX 33-40) 	DATA BUS 	
	input  [ 7:0]     sfg_dbo, 		// pins 43-50 	IO(MSX 33-40) 	DATA BUS 	

	input  [15:0] 		addr, 	// pins 27-42	O (MSX 17-32)	ADDRESS BUS
	input					clk,		// pin 52		O (MSX 42)		CLOCK 3.579545Mhz
	// bus control
	input					wr_n,		// pin 23		O (MSX 13) 		WRITE Request from CPU
	input					rd_n, 	// pin 24		O (MSX 14) 		READ Request from CPU
	input					slt3_n,	// pin 14		O (MSX 04) 		SLOT Select signal
	input					iorq_n,	// pin 21		O (MSX 11)		I/O Request from CPU
   input					mi,		// pin 19		O (MSX 09)		M1 Signal from CPU
	
	output				int_n,	// pin 18		I (MSX 08) 		Maskable INTERRUPT request, open collector signal
	output				wait_n,	// pin 17		I (MSX 07) 		WAIT request, open collector signal
	
	output 				oe_n,		// ROM OE_n 
	
	output  [15:0] 	left,
	output  [15:0] 	right
	
	// midi
	// input				midi_rx,
	// output			midi_tx,
	// keyboard control
);

//	ADDRESS TABLE (A2-A0)
// #3FF0 (R)	FM Status register
// #3FF0 (W)	FM Address register
// #3FF1 (R/W)	FM Data register
//
// #3FF2 (R/W)	Yamaha external keyboard (YK-01 or YK-10) I/O address.
// #3FF3 (W)	MIDI IRQ vector address
// #3FF4 (W)	External IRQ vector address
// #3FF5 (R/W)	MIDI UART Data read and write buffer
// #3FF6 (R)	MIDI UART Status Register
// #3FF6 (W)	MIDI UART Command Register

// glue logic
wire ce_n = &addr[13:7]; // IC105 and IC106  

wire ic106_4 = ~(addr[6] & ce_n);
wire ic106_2 = ~(addr[5] & addr[4]);

wire ic107_3 = ~(~ic106_4 & ~ic106_2); // this is just an OR but I want to follow the schematic

wire ic107_4 = ~(~ic107_3 & ~addr[3]);

wire cs_n    = ~(~ic107_4 & ~slt3_n);  // ic107_1

assign busdir_n = ~(~iorq_n & ~mi);    // ic107_2
assign wait_n	= 1'b1;                 // No usamos el wait

// OPM_n	         == 0        --> CS_n --> YM2151
wire opm_n = !(!cs_n && addr[2:1]==2'b00); // OPM active when CS (0x3FF0-0x3FF8) and addr[2:1] =00 

// wire [7:0] opm_dout;
// reg [7:0] rom_dout;

assign oe_n = !(!ce_n && !slt3_n);  

// Data bus is IO so this manages hight impedance for Output Enable
/*
always @(woe_n) begin
	oe_n <= woe_n;
	if( !woe_n )
		dio <= ( !opm_n ? opm_dout : 8'd0 ) | rom_dout;
	else
		dio <= 8'hzz;
end
*/

// assign midi_tx = 1'b0;

jt51(
	.clk		( clk			),	// main clock
	.rst		( rst			),	// reset
	.cs_n		( opm_n		),	// chip select
	.wr_n		( wr_n		),	// write
	.a0		( addr[0]	),

//	.d_in		( dio			), // data in
//	.d_out	( opm_dout	), // data out
	.d_in		( sfg_dbo	), // data in
	.d_out	( sfg_dbi	), // data out

	.irq_n	( int_n		),	// I do not synchronize this signal

	// Low resolution output (same as real chip)
	//output				sample,	// marks new output sample
	//output	signed	[15:0] left,
	//output	signed	[15:0] right,
	
	// Full resolution output
	//output	signed	[15:0] xleft,
	//output	signed	[15:0] xright,
	
	// unsigned outputs for sigma delta converters, full resolution
	//output	[15:0] dacleft,
	//output	[15:0] dacright

	//.xleft 	( left),
	//.xright	(right)
	.left 	( left),
	.right	(right)
);

/*
always @(*)
	casex( {addr[7:0], ce_n, slt3_n} )
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
*/

endmodule // jt_sfg01
