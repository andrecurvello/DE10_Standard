################################################################################
#                             Test Makefile                                    #
################################################################################
#OBJ-LST = FPGA_Drv terasic_lib main test_vectors
OBJ-LST := main test_vectors hex terasic_lib FPGA_Drv
OBJ-LST-SIM := main test_vectors hex

all: test test_sim

test : $(addsuffix .o,$(OBJ-LST))
	$(CC) $(CFLAGS) $(LPATH) $(IPATH) $^ -o $@ -lpthread
	
test_sim : $(addsuffix .sim.o,$(OBJ-LST-SIM))
	$(CC) $(CFLAGS) $(LPATH) $(IPATH) $^ -o $@ -lpthread

%.o : %.c
	$(CC) $(CFLAGS) $(LPATH) $(IPATH) -c $< -o  $@

%.sim.o : %.c
	$(CC) $(CFLAGS_SIM) $(LPATH) $(IPATH) -c $< -o $@

clean:
	rm -f *.a *.o *~ 
