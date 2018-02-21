################################################################################
#                             MINER Makefile                                   #
################################################################################
IPATH += -I$(PRJ_ROOT)/src/COM
LPATH += -L$(PRJ_ROOT)/src/COM
OBJ =  main COM_mgr STRATUM JSON_ser SCHEDULER hex terasic_lib FPGA_Drv LCD_Driver LCD_Graphic

all : build_miner
build_miner : $(addsuffix .o,$(OBJ))
	$(CC) $(CFLAGS) $(LPATH) $(addsuffix .o,$(OBJ)) -o miner -lpthread -ljson-c
	
%.o : %.c
	$(CC) $(CFLAGS) $(IPATH) $(LPATH) -c $< -o $@

clean:
	rm -f *.a *.o *~ 
