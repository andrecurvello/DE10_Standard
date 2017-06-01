################################################################################
#                           DE10_STANDARD build file                           #
#                                                                              #
# ---------------------------------------------------------------------------  #
#                                                                              #
#                                                                              #
################################################################################

################################################################################
#                              EXPORTS TO SUBMK                                #
################################################################################
#export PWD := $(shell C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe pwd)
export PWD := $(shell pwd)
export ALT_DEVICE_FAMILY = soc_cv_av
export PRJ_ROOT = C:/Projects/DE10_Standard
export SOCEDS_DEST_ROOT = C:/intelFPGA_pro/17.0/embedded
export SOCEDS_ROOT = $(SOCEDS_DEST_ROOT)
export HWLIBS_ROOT = $(SOCEDS_ROOT)/ip/altera/hps/altera_hps/hwlib

export HOSTCC = mingw32-
export CROSS_COMPILE = arm-linux-gnueabihf-
export IPATH := -I$(HWLIBS_ROOT)/include/$(ALT_DEVICE_FAMILY) -I$(HWLIBS_ROOT)/include/ -I$(PRJ_ROOT)/src/include/altera/
export DFLAGS := $(ALT_DEVICE_FAMILY)
export CFLAGS = -static -g -Wall -Werror $(addprefix -D,$(DFLAGS))

################################################################################
#                           ARCH AND CROSS-COMPILATION                         #
################################################################################
export CC = $(CROSS_COMPILE)gcc
export ARCH= arm

################################################################################
#                               directories layout                             #
################################################################################
CLEAN_DIRS = demos src

################################################################################
#                           TARGET DEFINITIONS                                 #
################################################################################
default : usage

all : miner

miner :
	@echo -e "\033[1;32m[Compiling $@]\033[0m"
	$(MAKE) -C src all
	@echo -e  "\033[1;32m[Finished $@]\033[0m"

demonstrations :
	@echo -e "\033[1;32m[Compiling $@]\033[0m"
	$(MAKE) -C demos all
	@echo -e  "\033[1;32m[Finished $@]\033[0m"

test :
	@echo -e "\033[1;32m[Compiling $@]\033[0m"
	$(MAKE) -C src production_test
	@echo -e  "\033[1;32m[Finished $@]\033[0m"

test_sim :
	@echo -e "\033[1;32m[Compiling $@]\033[0m"
	$(MAKE) -C src production_test_sim
	@echo -e  "\033[1;32m[Finished $@]\033[0m"

usage list help:
	@echo -e "\033[1;36m[Listing available target for build : ]\033[0m"
	@echo -e "\033[1;36m[	all             - builds the miner by default]\033[0m"
	@echo -e "\033[1;36m[	miner           - builds the miner app]\033[0m"
	@echo -e "\033[1;36m[	demonstrations  - builds the demos]\033[0m"
	@echo -e "\033[1;36m[	test            - builds the production test]\033[0m"
	@echo -e "\033[1;36m[	test_sim        - builds the test simulation]\033[0m"
	@echo -e "\033[1;36m[	clean           - cleans the build directories]\033[0m"

PHONY := clean
clean:
	$(foreach DIR,$(CLEAN_DIRS),cd $(DIR) && make clean && cd .. &&) true
	
#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37
