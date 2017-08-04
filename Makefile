################################################################################
#                           DE10_STANDARD build file                           #
#                                                                              #
# ---------------------------------------------------------------------------  #
#                                                                              #
#                                                                              #
################################################################################
COM = linux
UI = lib
FPGA = design

#export INSTALL_DIR := /usr/targets/current/root/usr/include/
#export LIB_DIR     := /usr/targets/current/root/usr/lib/
#export KERNEL_IPATH:= /usr/targets/current/root/usr/src/modules/wycec/linux/include
export PWD         := $(shell pwd)
export IPATH       :=
export DFLAGS      :=

ifeq ($(SPY),y)
	DFLAGS += -DSPY
endif

ifeq ($(DEBUG),y)
	DFLAGS += -DDEBUG
endif

ifeq ($(VERBOSE),y)
	DFLAGS += -DVERBOSE
endif

all :  com ui fpga

com :
	$(foreach COM,$(COM_DIR),cd $(COM) && make com && cd .. &&) true
ui :
	$(foreach UI,$(UI_DIR),cd $(UI) && make ui && cd .. &&) true

fpga :
	echo "Nothing to do for the time being"
	# $(foreach FPGA,$(FPDA_DIR),cd $(FPGA) && make fpga && cd .. &&) true

clean:
	$(foreach COM,$(COM_DIR),cd $(COM) && make  clean && cd .. &&) true
	$(foreach UI,$(UI_DIR),cd $(UI) && make  clean && cd .. &&) true
	$(foreach FPGA,$(FPDA_DIR),cd $(FPGA) && make  clean && cd .. &&) true
