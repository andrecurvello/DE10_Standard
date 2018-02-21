################################################################################
#                           DE10_STANDARD build file                           #
################################################################################
COMMON_DIRS := drv/FPGA drv/LCD
DRV_DIRS := common/terasic common/utils
COM_DIRS := COM
INCLUDE_DIRS := include/utils include/terasic include/json
PROD_TEST_DIRS := drv production_test
MINER_DIRS := drv COM common

export IPATH += -I$(PRJ_ROOT)/src/include $(addprefix -I$(PRJ_ROOT)/src/,$(INCLUDE_DIRS)) $(addprefix -I$(PRJ_ROOT)/src/,$(COMMON_DIRS)) $(addprefix -I$(PRJ_ROOT)/src/,$(DRV_DIRS)) $(addprefix -I$(PRJ_ROOT)/src/,$(COM_DIRS))
export LPATH += -L$(PRJ_ROOT)/src/lib $(addprefix -L$(PRJ_ROOT)/src/,$(COMMON_DIRS)) $(addprefix -L$(PRJ_ROOT)/src/,$(DRV_DIRS)) $(addprefix -L$(PRJ_ROOT)/src/,$(COM_DIRS))

ifeq ($(MAKECMDGOALS),all)
  export BUILD_DIR := $(PRJ_ROOT)/src/COM
endif

ifeq ($(MAKECMDGOALS),production_test)
  export BUILD_DIR := $(PRJ_ROOT)/src/production_test
endif

ifeq ($(MAKECMDGOALS),production_test_sim)
  export BUILD_DIR := $(PRJ_ROOT)/src/production_test
endif

all: build_miner
build_miner : build_common build_drivers
	$(MAKE) -C COM all

build_common :
	$(MAKE) -C common all

build_common_sim :
	$(MAKE) -C common sim

build_drivers :
	$(MAKE) -C drv all

# tests targets defn
production_test : build_drivers build_common
	$(MAKE) -C production_test test

production_test_sim : build_common_sim
	$(MAKE) -C production_test test_sim

clean:
	$(foreach DIR,$(MINER_DIRS),cd $(DIR) && make clean && cd .. &&) true
	$(foreach DIR,$(PROD_TEST_DIRS),cd $(DIR) && make clean && cd .. &&) true
