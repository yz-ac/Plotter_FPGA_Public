import Servo_P::ServoPos_t;
import Servo_P::ServoMov_t;

typedef enum {
	SERVO_CTRL_IDLE_UP,
	SERVO_CTRL_IDLE_DOWN,
	SERVO_CTRL_WORKING_UP,
	SERVO_CTRL_WORKING_DOWN
} ServoCtrl_state;

module ServoCtrl_FSM (
	input logic clk,
	input logic reset,
	input logic clk_en,
	input logic trigger,
	input Servo_P::ServoPos_t pos,
	input logic pulse_done,

	output Servo_P::ServoMov_t mov,
	output logic working
);

	ServoCtrl_state _cur_state;
	ServoCtrl_state _nxt_state;

	always_comb begin
		case (_cur_state)
		SERVO_CTRL_IDLE_UP: begin
			_nxt_state = SERVO_CTRL_IDLE_UP;
			mov = Servo_P::SERVO_MOV_CENTER;
			working = 0;
			if (trigger & (pos == Servo_P::SERVO_POS_DOWN)) begin
				// If up was requested there is nothing to be done.
				_nxt_state = SERVO_CTRL_WORKING_DOWN;
				working = 1;
			end
		end

		SERVO_CTRL_IDLE_DOWN: begin
			_nxt_state = SERVO_CTRL_IDLE_DOWN;
			mov = Servo_P::SERVO_MOV_CENTER;
			working = 0;
			if (trigger & (pos == Servo_P::SERVO_POS_UP)) begin
				// If down was requested there is nothing to be done.
				_nxt_state = SERVO_CTRL_WORKING_UP;
				working = 1;
			end
		end

		SERVO_CTRL_WORKING_UP: begin
			_nxt_state = SERVO_CTRL_WORKING_UP;
			mov = Servo_P::SERVO_MOV_UP;
			working = 1;
			if (pulse_done) begin
				_nxt_state = SERVO_CTRL_IDLE_UP;
			end
		end

		SERVO_CTRL_WORKING_DOWN: begin
			_nxt_state = SERVO_CTRL_WORKING_DOWN;
			mov = Servo_P::SERVO_MOV_DOWN;
			working = 1;
			if (pulse_done) begin
				_nxt_state = SERVO_CTRL_IDLE_DOWN;
			end
		end

		default: begin
			_nxt_state = SERVO_CTRL_IDLE_UP;
			mov = Servo_P::SERVO_MOV_CENTER;
			working = 0;
		end
		endcase
	end // always_comb

	always_ff @(posedge clk) begin
		if (reset) begin
			_cur_state <= SERVO_CTRL_IDLE_UP;
		end
		else if (clk_en) begin
			_cur_state <= _nxt_state;
		end
		else begin
			_cur_state <= _cur_state;
		end
	end // always_ff

endmodule : ServoCtrl_FSM
