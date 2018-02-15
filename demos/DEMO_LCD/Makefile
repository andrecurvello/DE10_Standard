################################################################################
#                           DE10_STANDARD build file                           #
#                                                                              #
# ---------------------------------------------------------------------------  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
################################################################################
TARGET = DEMO_LCD
ALT_DEVICE_FAMILY ?= soc_cv_av
SOCEDS_DEST_ROOT = C:\intelFPGA_pro\17.0\embedded

SOCEDS_ROOT ?= $(SOCEDS_DEST_ROOT)
HWLIBS_ROOT = $(SOCEDS_ROOT)/ip/altera/hps/altera_hps/hwlib
CROSS_COMPILE = arm-linux-gnueabihf-
CFLAGS = -static -g -Wall -D$(ALT_DEVICE_FAMILY) -I$(HWLIBS_ROOT)/include/$(ALT_DEVICE_FAMILY) -I$(HWLIBS_ROOT)/include/ 
LDFLAGS =  -g -Wall  
CC = $(CROSS_COMPILE)gcc
ARCH= arm

build: $(TARGET)

$(TARGET): main.o terasic_lib.o  \
LCD_Driver.o LCD_Graphic.o
	$(CC) $(LDFLAGS)   $^ -o $@ -lrt -lm
%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ *.bmp