#! Makefile

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
VFLAGS :=-O0 -sv -sv12compat -s $(VINCLUDE)

TOP :=

SIM_FLAGS :=-nolog
SIM_CMD :=-do "add wave $(TOP).* -depth 1; run -all"

VFILES :=
VFILES += $(COMMON_DIR)/FreqDivider.sv
VFILES += $(COMMON_DIR)/Abs.sv

TB_FILES :=
TB_FILES += SimClock.sv
TB_FILES += $(COMMON_DIR)/FreqDivider_tb.sv
TB_FILES += $(COMMON_DIR)/Abs_tb.sv

_VFILES = $(patsubst %.sv,$(SDIR)/%.sv,$(VFILES))
_TB_FILES = $(patsubst %.sv,$(TDIR)/%.sv,$(TB_FILES))

FILES = $(_VFILES) $(_TB_FILES)

.PHONY: all
all: debug

.PHONY: setup
setup:
	$(VLIB) $(LIB_NAME)

.PHONY: debug
debug: setup
	$(VCOM) $(VFLAGS) -work $(LIB_NAME) $(FILES)

.PHONY: clean
clean:
	$(VDEL) -all -lib $(LIB_NAME)
	rm -rf vsim.wlf

.PHONY: sim
sim:
	$(VSIM) $(SIM_FLAGS) $(LIB_NAME).$(TOP) $(SIM_CMD)
