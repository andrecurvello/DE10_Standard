################################################################################
#                             MINER Makefile                                   #
################################################################################
TARGET = MINER

LCD-LOC = $(PRJ_ROOT)\src\drv\LCD
LDPATH += -L$(LCD-LOC)

TERA-LOC = $(PRJ_ROOT)\src\common\terasic
LDPATH += -L$(TERA-LOC)

FPGA-LOC = $(PRJ_ROOT)\src\drv\FPGA
LDPATH += -L$(FPGA-LOC)

#7SEG-LOC = $(PRJ_ROOT)\src\drv\7SEG
#LDPATH += -L$(7SEGLOC)

#BUTTON-LOC = $(PRJ_ROOT)\src\drv\BUTTON
#LDPATH += -L$(BUTTON-LOC)

OBJ-LST = FPGA_Drv LCD_Driver LCD_Graphic terasic_lib main COM_mgr

build: $(TARGET)
$(TARGET): $(addsuffix .o,$(OBJ-LST)) 
	$(CC) $(LDFLAGS) -lpthread $^ -o $@  

terasic_lib.o : 
	$(CC) $(CFLAGS) -c $(TERA-LOC)\terasic_lib.c -o $@
	
LCD_Driver.o : 
	$(CC) $(CFLAGS) -c $(LCD-LOC)\LCD_Driver.c -o $@

LCD_Graphic.o: 
	$(CC) $(CFLAGS) -c $(LCD-LOC)\LCD_Graphic.c -o $@

FPGA_Drv.o: 
	$(CC) $(CFLAGS) -c $(FPGA-LOC)\FPGA_Drv.c -o $@
	
%.o : %.c
	$(CC) $(CFLAGS) -I$(LCD-LOC) -I$(TERA-LOC) -I$(FPGA-LOC) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ 
