module ProcessorTopInnerConnector (
	input logic trigger,

	OpHandler_IF handler_intf,

	output logic done,
	output logic rdy
);

	assign handler_intf.trigger = trigger;
	assign done = handler_intf.done;
	assign rdy = handler_intf.rdy;

endmodule : ProcessorTopInnerConnector
