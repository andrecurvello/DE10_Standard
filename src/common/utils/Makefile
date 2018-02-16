IPATH += -I$(PRJ_ROOT)/src/common/utils
LPATH += -L$(PRJ_ROOT)/src/common/utils
OBJS = hex

include ../common.mk

common_sim : $(addsuffix .sim.o,$(OBJS))
%.sim.o : %.c
	$(HOSTCC)gcc $(CFLAGS) $(IPATH) $(LPATH) -c $< -o $@
	cp $@ $(BUILD_DIR)
