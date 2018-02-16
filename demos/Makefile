################################################################################
#                               DE10_DEMO build                                #
################################################################################
DEMOS = DEMO_LCD DEMO_HPS_GHRD DEMO_GPIO

all :
	$(foreach DEMO,$(DEMOS),cd $(DEMO) && make && cd .. &&) true

clean:
	$(foreach DEMO,$(DEMOS),cd $(DEMO) && make clean && cd .. &&) true
