# Makefile

VLIB :=vlib
VDEL :=vdel
VCOM :=vlog
VSIM :=vsim

LIB_NAME =out
IDIR =include
SDIR =src
TDIR =tb
ODIR =$(LIB_NAME)

COMMON_DIR =common
PARSER_DIR =parser
PROC_DIR =processor

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
VFILES += $(PROC_DIR)/StepperCtrl.sv
VFILES += $(PROC_DIR)/StepperCtrl_IF.sv
VFILES += $(PROC_DIR)/StepperCtrlXY.sv
VFILES += $(PROC_DIR)/StepperCtrlXY_InnerConnect.sv
VFILES += $(PROC_DIR)/StepperCtrlXY_IF.sv
VFILES += $(PROC_DIR)/ServoCtrl_IF.sv
VFILES += $(PROC_DIR)/ServoCtrl_FSM.sv
VFILES += $(PROC_DIR)/ServoCtrl_DirToPwm.sv
VFILES += $(PROC_DIR)/ServoCtrl.sv

PKG_FILES := 
PKG_FILES += $(PROC_DIR)/Servo_PKG.sv

TB_FILES :=
TB_FILES += SimClock.sv
TB_FILES += $(COMMON_DIR)/FreqDivider_tb.sv
TB_FILES += $(COMMON_DIR)/Abs_tb.sv
TB_FILES += $(COMMON_DIR)/PulseGen_tb.sv
TB_FILES += $(COMMON_DIR)/Pwm_tb.sv
TB_FILES += $(COMMON_DIR)/TriggeredTimer_tb.sv
TB_FILES += $(PROC_DIR)/StepperCtrl_tb.sv
TB_FILES += $(PROC_DIR)/StepperCtrlXY_tb.sv
TB_FILES += $(PROC_DIR)/ServoCtrl_tb.sv

_VFILES = $(patsubst %.sv,$(SDIR)/%.sv,$(VFILES))
_PKG_FILES = $(patsubst %.sv,$(SDIR)/%.sv,$(PKG_FILES))
_TB_FILES = $(patsubst %.sv,$(TDIR)/%.sv,$(TB_FILES))

FILES = $(_PKG_FILES) $(_VFILES) $(_TB_FILES)

.PHONY: all
all: debug

.PHONY: setup
setup:
	$(VLIB) $(LIB_NAME)

.PHONY: debug
debug: VFLAGS += +define+SIM_DEBUG
debug: setup
	$(VCOM) $(VFLAGS) -work $(LIB_NAME) $(FILES)

.PHONY: release
release: setup
	$(VCOM) $(VFLAGS) -work $(LIB_NAME) $(FILES)

.PHONY: clean
clean:
	$(VDEL) -all -lib $(LIB_NAME)
	rm -rf vsim.wlf

.PHONY: sim
sim:
	$(VSIM) $(SIM_FLAGS) $(LIB_NAME).$(TOP) $(SIM_CMD)

.PHONY: sim_manual
sim_manual:
	$(VSIM) $(SIM_FLAGS) $(LIB_NAME).$(TOP)
