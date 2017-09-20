################################################################################
#                           DE10_STANDARD build file                           #
#                                                                              #
# ---------------------------------------------------------------------------  #
#                                                                              #
#                                                                              #
################################################################################
DIRS = COM

################################################################################
#                              EXPORTS TO SUBMK                                #
################################################################################
export PRJ_ROOT = C:\Projects\DE10_Standard
export ALT_DEVICE_FAMILY = soc_cv_av
export SOCEDS_DEST_ROOT = C:\intelFPGA_pro\17.0\embedded
export SOCEDS_ROOT = $(SOCEDS_DEST_ROOT)
export HWLIBS_ROOT = $(SOCEDS_ROOT)/ip/altera/hps/altera_hps/hwlib
export CROSS_COMPILE = arm-linux-gnueabihf-
export IPATH = $(HWLIBS_ROOT)/include/$(ALT_DEVICE_FAMILY) $(HWLIBS_ROOT)/include/ $(PRJ_ROOT)/src/include/utils $(PRJ_ROOT)/src/include/terasic $(PRJ_ROOT)/src/include/json $(PRJ_ROOT)/src/COM $(PRJ_ROOT)/src/include
export DFLAGS = $(ALT_DEVICE_FAMILY)
export CFLAGS = -static -g -Wall $(addprefix -D,$(DFLAGS)) $(addprefix -I,$(IPATH)) 

################################################################################
#                           ARCH AND CROSS-COMPILATION                         #
################################################################################
export CC = $(CROSS_COMPILE)gcc
export ARCH= arm

################################################################################
#                           TARGET DEFINITIONS                                 #
################################################################################
default : usage

all : $(TARGETS)
	@echo -e "\033[1;32m[Compiling $@]\033[0m"
	$(foreach DIR,$(DIRS),cd $(DIR) && make all && cd .. &&) true
	@echo -e  "\033[1;32m[Finished $@]\033[0m"

miner : 	
	@echo -e "\033[1;32m[Compiling $@]\033[0m"
	$(MAKE) -C COM MINER
	@echo -e  "\033[1;32m[Finished $@]\033[0m"

usage list help:
	@echo -e "\033[1;36m[Listing available target for build : \033[0m"
	@echo -e "\033[1;36m[	all     - builds all available targets\033[0m"
	@echo -e "\033[1;36m[	miner   - builds the miner app\033[0m"
	@echo -e "\033[1;36m[	clean   - cleans the build directories\033[0m"

.PHONY: clean
clean:
	$(foreach DIR,$(DIRS),cd $(DIR) && make clean && cd .. &&) true
	
#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37