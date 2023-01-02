import Op_PKG::Op_st;
import Servo_PKG::SERVO_POS_UP;

/**
* Dummy opcode handler - used for meta gcodes (that don't control motors).
*
* :input clk: System clock.
* :input reset: Resets the module.
* :input clk_en: Module enabling clock.
* :iface handler_intf: Opcode handler interface (from parser side).
* :iface motors_intf: Motors controlling interface (to motors side).
*/
module DummyOpHandler (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input Op_st op,
	OpHandler_IF handler_intf,
	MotorsCtrl_IF motors_intf
);

	DummyOpHandler_FSM _fsm (
		.clk(clk),
		.reset(reset),
		.clk_en(clk_en),
		.trigger(handler_intf.trigger),
		.done(handler_intf.done),
		.rdy(handler_intf.rdy)
	);

	assign motors_intf.pulse_num_x = 0;
	assign motors_intf.pulse_num_y = 0;
	assign motors_intf.servo_pos = SERVO_POS_UP;
	assign motors_intf.trigger = 0;
	// motors done and rdy are disconnected

endmodule : DummyOpHandler
