################################################################################
#                               DE10_DEMO build                                #
################################################################################
COMMON = terasic utils

all :
	$(foreach DIR,$(COMMON),cd $(DIR) && make all&& cd .. &&) true

sim :
	$(MAKE) -C utils common_sim

clean:
	$(foreach DIR,$(COMMON),cd $(DIR) && make clean && cd .. &&) true
