################################################################################
#                           GENERAL TEST Makefile                              #
################################################################################
DIRS = 7SEG LCD
TARGETS = $(addprefix TEST_,$(DIRS))

################################################################################
#                              EXPORTS TO SUBMK                                #
################################################################################
export PRJ_ROOT = C:\Users\BDJ2Bp\workspace\BASE_DE10_STANDARD
export ALT_DEVICE_FAMILY ?= soc_cv_av
export SOCEDS_DEST_ROOT = C:\intelFPGA_pro\17.0\embedded
export SOCEDS_ROOT ?= $(SOCEDS_DEST_ROOT)
export HWLIBS_ROOT = $(SOCEDS_ROOT)/ip/altera/hps/altera_hps/hwlib
export CROSS_COMPILE = arm-linux-gnueabihf-
export IPATH = $(HWLIBS_ROOT)/include/$(ALT_DEVICE_FAMILY) $(HWLIBS_ROOT)/include/ $(PRJ_ROOT)/src/include/utils $(PRJ_ROOT)/src/include/terasic
export DFLAGS = $(ALT_DEVICE_FAMILY)
export CFLAGS = -static -g -Wall $(addprefix -D,$(IPATH))$(DFLAGS) $(addprefix -I,$(IPATH)) 

################################################################################
#                           ARCH AND CROSS-COMPILATION                         #
################################################################################
export CC = $(CROSS_COMPILE)gcc
export ARCH= arm

################################################################################
#                           TARGET DEFINITIONS                                 #
################################################################################
all : $(TARGETS)
	$(foreach DIR,$(TARGETS),cd $(DIR) && make all && cd .. &&) true

TEST_7SEG :
	@echo "test"
	
TEST_LCD :
	cd $@ && make all && cd ..

clean:
	$(foreach DIR,$(TARGETS),cd $(DIR) && make clean && cd .. &&) true
