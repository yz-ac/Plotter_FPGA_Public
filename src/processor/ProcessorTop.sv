`include "common/common.svh"

import Op_PKG::Op_st;

/**
* Processor TOP module.
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :input op: Opcode to process.
* :input trigger: Triggers processing logic.
* :iface motors_intf: Interface to peripherals (originally motors).
* :output done: Processing is done.
* :output rdy: Ready to accept triggers.
*/
module ProcessorTop (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input Op_st op,
	input logic trigger,

	MotorsCtrl_IF motors_intf,
	output logic done,
	output logic rdy
);

	OpHandler_IF _handler_intf ();
	OpHandler_IF _lin_handler_intf ();
	OpHandler_IF _circ_handler_intf ();
	OpHandler_IF _dummy_handler_intf ();

	PositionState_IF #(
		.POS_X_BITS(`POS_X_BITS),
		.POS_Y_BITS(`POS_Y_BITS)
	) _state_intf ();

	PositionUpdate_IF #(
		.POS_X_BITS(`POS_X_BITS),
		.POS_Y_BITS(`POS_Y_BITS)
	) _lin_update_intf ();
	PositionUpdate_IF #(
		.POS_X_BITS(`POS_X_BITS),
		.POS_Y_BITS(`POS_Y_BITS)
	) _circ_update_intf ();
	PositionUpdate_IF #(
		.POS_X_BITS(`POS_X_BITS),
		.POS_Y_BITS(`POS_Y_BITS)
	) _dummy_update_intf ();
	PositionUpdate_IF #(
		.POS_X_BITS(`POS_X_BITS),
		.POS_Y_BITS(`POS_Y_BITS)
	) _update_intf ();

	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`POS_X_BITS),
		.PULSE_NUM_Y_BITS(`POS_Y_BITS)
	) _lin_motors_intf ();
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`POS_X_BITS),
		.PULSE_NUM_Y_BITS(`POS_Y_BITS)
	) _circ_motors_intf ();
	MotorsCtrl_IF #(
		.PULSE_NUM_X_BITS(`POS_X_BITS),
		.PULSE_NUM_Y_BITS(`POS_Y_BITS)
	) _dummy_motors_intf ();

	ProcessorTopInnerConnector _inner_connect (
		.trigger(trigger),
		.handler_intf(_handler_intf.master),
		.done(done),
		.rdy(rdy)
	);

	PositionKeeper _pos_keeper (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.op(op),
		.update_intf(_update_intf.slave),
		.state_intf(_state_intf.master)
	);

	OpHandlerInputChooser _input_chooser (
		.op(op),
		.handler_intf_in(_handler_intf.slave),
		.lin_handler_intf_out(_lin_handler_intf.master),
		.circ_handler_intf_out(_circ_handler_intf.master),
		.dummy_handler_intf_out(_dummy_handler_intf.master)
	);

	LinearOpHandler _lin_handler (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.op(op),
		.handler_intf(_lin_handler_intf.slave),
		.state_intf(_state_intf.slave),
		.update_intf(_lin_update_intf.master),
		.motors_intf(_lin_motors_intf.master)
	);

	CircularOpHandler _circ_handler (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.op(op),
		.handler_intf(_circ_handler_intf.slave),
		.state_intf(_state_intf.slave),
		.update_intf(_circ_update_intf.master),
		.motors_intf(_circ_motors_intf.master)
	);

	DummyOpHandler _dummy_handler (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.handler_intf(_dummy_handler_intf.slave),
		.motors_intf(_dummy_motors_intf.master),
		.pos_update_intf(_dummy_update_intf.master)
	);

	OpHandlerOutputChooser _output_chooser (
		.op(op),
		.lin_motors_intf_in(_lin_motors_intf.slave),
		.circ_motors_intf_in(_circ_motors_intf.slave),
		.dummy_motors_intf_in(_dummy_motors_intf.slave),
		.lin_pos_update_intf_in(_lin_update_intf.slave),
		.circ_pos_update_intf_in(_circ_update_intf.slave),
		.dummy_pos_update_intf_in(_dummy_update_intf.slave),
		.motors_intf_out(motors_intf),
		.pos_update_intf_out(_update_intf.master)
	);

endmodule : ProcessorTop
