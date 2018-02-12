################################################################################
#                             MINER Makefile                                   #
################################################################################
TARGET = TEST

TERA-LOC = $(PRJ_ROOT)\src\common\terasic
LDPATH += -L$(TERA-LOC)

FPGA-LOC = $(PRJ_ROOT)\src\drv\FPGA
LDPATH += -L$(FPGA-LOC)

#OBJ-LST = FPGA_Drv terasic_lib main test_vectors
OBJ-LST = main test_vectors

build: $(TARGET)
$(TARGET): $(addsuffix .o,$(OBJ-LST)) 
	$(CC) $(LDPATH) $^ -o $@ -lpthread

terasic_lib.o : 
	$(CC) $(CFLAGS) -c $(TERA-LOC)\terasic_lib.c -o $@
	
FPGA_Drv.o: 
	$(CC) $(CFLAGS) -c $(FPGA-LOC)\FPGA_Drv.c -o $@

%.o : %.c
	$(CC) $(CFLAGS) -I$(TERA-LOC) -I$(FPGA-LOC) -c $< -o  $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ 
