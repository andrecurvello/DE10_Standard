################################################################################
#                             drivers build file                               #
################################################################################
DRV_DIRS = FPGA LCD #7SEG BUTTON 

all : 
	$(foreach DIR,$(DRV_DIRS),cd $(DIR) && make all && cd .. &&) true

clean:
	$(foreach DIR,$(DRV_DIRS),cd $(DIR) && make clean && cd .. &&) true
