# Makefile

VLIB :=vlib
VDEL :=vdel
VCOM :=vlog
VSIM :=vsim

LIB_NAME =out
TESTS_PATH =tests/tests
IDIR =include
SDIR =src
TDIR =tb
ODIR =$(LIB_NAME)

COMMON_DIR =common
PARSER_DIR =parser
PROC_DIR =processor
MOTORS_DIR =motors
BRAM_DIR =bram
VGA_DIR =vga
UART_DIR =uart
PLOTTER_DIR =plotter
CLOCKING_DIR =clocking

VINCLUDE :=+incdir+$(IDIR) +incdir+.
VFLAGS :=-O0 +acc=npr -sv -sv12compat -s $(VINCLUDE)

TOP :=

SIM_FLAGS :=-nolog
SIM_CMD :=-do "add wave $(TOP).* -depth 1; run -all"

VFILES :=
VFILES += $(COMMON_DIR)/FreqDivider.sv
VFILES += $(COMMON_DIR)/Abs.sv
VFILES += $(COMMON_DIR)/PulseGen.sv
VFILES += $(COMMON_DIR)/PulseGen_FSM.sv
VFILES += $(COMMON_DIR)/Pwm.sv
VFILES += $(COMMON_DIR)/TriggeredTimer.sv
VFILES += $(COMMON_DIR)/TriggeredTimer_FSM.sv
VFILES += $(COMMON_DIR)/IntSqrt_FSM.sv
VFILES += $(COMMON_DIR)/IntSqrt.sv
VFILES += $(COMMON_DIR)/PositionUpdate_IF.sv
VFILES += $(COMMON_DIR)/PositionState_IF.sv
VFILES += $(COMMON_DIR)/PositionKeeper.sv
VFILES += $(COMMON_DIR)/QuadrantFinder.sv
VFILES += $(COMMON_DIR)/OpToBits.sv
VFILES += $(COMMON_DIR)/BitsToOp.sv
VFILES += $(COMMON_DIR)/Multiplier.sv
VFILES += $(BRAM_DIR)/Bram.sv
VFILES += $(BRAM_DIR)/BramFifoCtrl_FSM.sv
VFILES += $(BRAM_DIR)/BramFifoCtrl.sv
VFILES += $(BRAM_DIR)/BramReader_FSM.sv
VFILES += $(BRAM_DIR)/BramReader.sv
VFILES += $(BRAM_DIR)/FifoBuffer.sv
VFILES += $(MOTORS_DIR)/StepperCtrl.sv
VFILES += $(MOTORS_DIR)/StepperCtrl_IF.sv
VFILES += $(MOTORS_DIR)/StepperCtrlXY.sv
VFILES += $(MOTORS_DIR)/StepperCtrlXY_InnerConnect.sv
VFILES += $(MOTORS_DIR)/StepperCtrlXY_IF.sv
VFILES += $(MOTORS_DIR)/ServoCtrl_IF.sv
VFILES += $(MOTORS_DIR)/ServoCtrl_FSM.sv
VFILES += $(MOTORS_DIR)/ServoCtrl_DirToPwm.sv
VFILES += $(MOTORS_DIR)/ServoCtrl.sv
VFILES += $(MOTORS_DIR)/MotorsCtrl_IF.sv
VFILES += $(MOTORS_DIR)/MotorsCtrl.sv
VFILES += $(MOTORS_DIR)/MotorsCtrl_InnerConnect.sv
VFILES += $(MOTORS_DIR)/MotorsCtrl_FSM.sv
VFILES += $(PROC_DIR)/OpHandler_IF.sv
VFILES += $(PROC_DIR)/OpHandlerOutputChooser.sv
VFILES += $(PROC_DIR)/DummyOpHandler_FSM.sv
VFILES += $(PROC_DIR)/DummyOpHandler.sv
VFILES += $(PROC_DIR)/OpHandlerInputChooser.sv
VFILES += $(PROC_DIR)/LinearOpHandler_NumStepsCalculator.sv
VFILES += $(PROC_DIR)/LinearOpHandler_DirectionFinder.sv
VFILES += $(PROC_DIR)/LinearOpHandler_InnerLogic.sv
VFILES += $(PROC_DIR)/LinearOpHandler.sv
VFILES += $(PROC_DIR)/LinearOpHandler_FSM.sv
VFILES += $(PROC_DIR)/CircularOpHandler_DirectionFinder.sv
VFILES += $(PROC_DIR)/CircularOpHandler_NumStepsCalculator.sv
VFILES += $(PROC_DIR)/CircularOpHandler_InnerLogic.sv
VFILES += $(PROC_DIR)/CircularOpHandler_FSM.sv
VFILES += $(PROC_DIR)/CircularOpHandler.sv
VFILES += $(PROC_DIR)/ProcessorTopInnerConnector.sv
VFILES += $(PROC_DIR)/ProcessorTop.sv
VFILES += $(PARSER_DIR)/CharDecoder.sv
VFILES += $(PARSER_DIR)/AsciiToDigit.sv
VFILES += $(PARSER_DIR)/NumberBuilder.sv
VFILES += $(PARSER_DIR)/OpBuilder.sv
VFILES += $(PARSER_DIR)/ArgSizeCheck.sv
VFILES += $(PARSER_DIR)/CircularFlagsBuilder.sv
VFILES += $(PARSER_DIR)/GcodeToCmd.sv
VFILES += $(PARSER_DIR)/Subparser_IF.sv
VFILES += $(PARSER_DIR)/CmdSubparser_FSM.sv
VFILES += $(PARSER_DIR)/CmdSubparser.sv
VFILES += $(PARSER_DIR)/ArgSubparser_FSM.sv
VFILES += $(PARSER_DIR)/ArgSubparser.sv
VFILES += $(PARSER_DIR)/DummySubparser_FSM.sv
VFILES += $(PARSER_DIR)/DummySubparser.sv
VFILES += $(PARSER_DIR)/SubparserConnector.sv
VFILES += $(PARSER_DIR)/LinearSubparser_FSM.sv
VFILES += $(PARSER_DIR)/LinearSubparser.sv
VFILES += $(PARSER_DIR)/CircularSubparser_FSM.sv
VFILES += $(PARSER_DIR)/CircularSubparser.sv
VFILES += $(PARSER_DIR)/SubparserInputChooser.sv
VFILES += $(PARSER_DIR)/SubparserOutputChooser.sv
VFILES += $(PARSER_DIR)/ParserTop_Innerconnect.sv
VFILES += $(PARSER_DIR)/ParserTop_FSM.sv
VFILES += $(PARSER_DIR)/ParserTop.sv
VFILES += $(VGA_DIR)/VgaController.sv
VFILES += $(VGA_DIR)/ByteToRgb.sv
VFILES += $(VGA_DIR)/VgaBuffer.sv
VFILES += $(VGA_DIR)/MotorSignalsToVga_InnerLogic.sv
VFILES += $(VGA_DIR)/MotorSignalsToVga.sv
VFILES += $(UART_DIR)/UartRxController_FSM.sv
VFILES += $(UART_DIR)/UartRxController.sv
VFILES += $(UART_DIR)/UartToFifoBuf_FSM.sv
VFILES += $(UART_DIR)/UartToFifoBuf.sv
VFILES += $(PLOTTER_DIR)/PlotterTop_InnerConnect.sv
VFILES += $(PLOTTER_DIR)/PlotterTop.sv
VFILES += $(CLOCKING_DIR)/Mmcm.sv
VFILES += Top.sv

PKG_FILES := 
PKG_FILES += $(COMMON_DIR)/Op_PKG.sv
PKG_FILES += $(COMMON_DIR)/Position_PKG.sv
PKG_FILES += $(MOTORS_DIR)/Servo_PKG.sv
PKG_FILES += $(PARSER_DIR)/Char_PKG.sv

TB_FILES :=
TB_FILES += SimClock.sv
TB_FILES += $(COMMON_DIR)/FreqDivider_tb.sv
TB_FILES += $(COMMON_DIR)/Abs_tb.sv
TB_FILES += $(COMMON_DIR)/PulseGen_tb.sv
TB_FILES += $(COMMON_DIR)/Pwm_tb.sv
TB_FILES += $(COMMON_DIR)/TriggeredTimer_tb.sv
TB_FILES += $(COMMON_DIR)/IntSqrt_tb.sv
TB_FILES += $(COMMON_DIR)/PositionKeeper_tb.sv
TB_FILES += $(COMMON_DIR)/QuadrantFinder_tb.sv
TB_FILES += $(COMMON_DIR)/OpToBits_tb.sv
TB_FILES += $(COMMON_DIR)/BitsToOp_tb.sv
TB_FILES += $(COMMON_DIR)/Multiplier_tb.sv
TB_FILES += $(BRAM_DIR)/Bram_tb.sv
TB_FILES += $(BRAM_DIR)/BramFifoCtrl_tb.sv
TB_FILES += $(BRAM_DIR)/BramReader_tb.sv
TB_FILES += $(BRAM_DIR)/FifoBuffer_tb.sv
TB_FILES += $(MOTORS_DIR)/StepperCtrl_tb.sv
TB_FILES += $(MOTORS_DIR)/StepperCtrlXY_tb.sv
TB_FILES += $(MOTORS_DIR)/ServoCtrl_tb.sv
TB_FILES += $(MOTORS_DIR)/MotorsCtrl_tb.sv
TB_FILES += $(PROC_DIR)/DummyOpHandler_tb.sv
TB_FILES += $(PROC_DIR)/OpHandlerOutputChooser_tb.sv
TB_FILES += $(PROC_DIR)/OpHandlerInputChooser_tb.sv
TB_FILES += $(PROC_DIR)/LinearOpHandler_NumStepsCalculator_tb.sv
TB_FILES += $(PROC_DIR)/LinearOpHandler_DirectionFinder_tb.sv
TB_FILES += $(PROC_DIR)/LinearOpHandler_tb.sv
TB_FILES += $(PROC_DIR)/CircularOpHandler_DirectionFinder_tb.sv
TB_FILES += $(PROC_DIR)/CircularOpHandler_NumStepsCalculator_tb.sv
TB_FILES += $(PROC_DIR)/CircularOpHandler_tb.sv
TB_FILES += $(PROC_DIR)/ProcessorTop_tb.sv
TB_FILES += $(PARSER_DIR)/CharDecoder_tb.sv
TB_FILES += $(PARSER_DIR)/AsciiToDigit_tb.sv
TB_FILES += $(PARSER_DIR)/NumberBuilder_tb.sv
TB_FILES += $(PARSER_DIR)/OpBuilder_tb.sv
TB_FILES += $(PARSER_DIR)/ArgSizeCheck_tb.sv
TB_FILES += $(PARSER_DIR)/CircularFlagsBuilder_tb.sv
TB_FILES += $(PARSER_DIR)/GcodeToCmd_tb.sv
TB_FILES += $(PARSER_DIR)/CmdSubparser_tb.sv
TB_FILES += $(PARSER_DIR)/ArgSubparser_tb.sv
TB_FILES += $(PARSER_DIR)/DummySubparser_tb.sv
TB_FILES += $(PARSER_DIR)/LinearSubparser_tb.sv
TB_FILES += $(PARSER_DIR)/CircularSubparser_tb.sv
TB_FILES += $(PARSER_DIR)/SubparserInputChooser_tb.sv
TB_FILES += $(PARSER_DIR)/SubparserOutputChooser_tb.sv
TB_FILES += $(PARSER_DIR)/ParserTop_tb.sv
TB_FILES += $(VGA_DIR)/VgaController_tb.sv
TB_FILES += $(VGA_DIR)/ByteToRgb_tb.sv
TB_FILES += $(VGA_DIR)/VgaBuffer_tb.sv
TB_FILES += $(VGA_DIR)/MotorSignalsToVga_tb.sv
TB_FILES += $(UART_DIR)/UartRxController_tb.sv
TB_FILES += $(UART_DIR)/UartToFifoBuf_tb.sv
TB_FILES += $(PLOTTER_DIR)/PlotterTop_tb.sv

_VFILES = $(patsubst %.sv,$(SDIR)/%.sv,$(VFILES))
_PKG_FILES = $(patsubst %.sv,$(SDIR)/%.sv,$(PKG_FILES))
_TB_FILES = $(patsubst %.sv,$(TDIR)/%.sv,$(TB_FILES))

FILES = $(_PKG_FILES) $(_VFILES) $(_TB_FILES)

.PHONY: all
all: debug

.PHONY: setup
setup:
	$(VLIB) $(LIB_NAME)
	mkdir -p $(TESTS_PATH)

.PHONY: debug
debug: VFLAGS += +define+SIM_DEBUG
debug: setup
	$(VCOM) $(VFLAGS) -work $(LIB_NAME) $(FILES)

.PHONY: release
release: setup
	$(VCOM) $(VFLAGS) -work $(LIB_NAME) $(FILES)

.PHONY: tests
tests: VFLAGS += +define+SIM_DEBUG +define+SIM_TESTS
tests: setup
	$(VCOM) $(VFLAGS) -work $(LIB_NAME) $(FILES)

.PHONY: clean
clean:
	rm -rf $(LIB_NAME)
	rm -rf $(TESTS_PATH)
	rm -rf vsim.wlf

.PHONY: sim
sim:
	$(VSIM) $(SIM_FLAGS) $(LIB_NAME).$(TOP) $(SIM_CMD)

.PHONY: sim_manual
sim_manual:
	$(VSIM) $(SIM_FLAGS) $(LIB_NAME).$(TOP)

.PHONY: sim_silent
sim_silent:
	$(VSIM) -c $(SIM_FLAGS) $(LIB_NAME).$(TOP) $(SIM_CMD)

.PHONY: run_tests
run_tests:
	python scripts/run_tests.py
