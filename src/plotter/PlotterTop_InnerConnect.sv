import Servo_PKG::SERVO_POS_UP;
import Servo_PKG::SERVO_POS_DOWN;

/**
* Inner connections of PlotterTop module - connects motor interfaces and prepares
* VGA signals.
*
* :iface proc_motors_intf: Motors interface from the processor side.
* :iface motors_intf: Motors interface from the motors side.
* :outptut should_draw: Is currently drawing (is servo up or down).
*/
module PlotterTop_InnerConnect (
	MotorsCtrl_IF proc_motors_intf,
	MotorsCtrl_IF motors_intf,
	output logic should_draw
);

	assign motors_intf.pulse_num_x = proc_motors_intf.pulse_num_x;
	assign motors_intf.pulse_num_y = proc_motors_intf.pulse_num_y;
	assign motors_intf.servo_pos = proc_motors_intf.servo_pos;
	assign motors_intf.trigger = proc_motors_intf.trigger;
	assign proc_motors_intf.done = motors_intf.done;
	assign proc_motors_intf.rdy = motors_intf.rdy;

	assign should_draw = (proc_motors_intf.servo_pos == SERVO_POS_DOWN) ? 1 : 0;

endmodule : PlotterTop_InnerConnect
