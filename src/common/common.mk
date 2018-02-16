################################################################################
#                       MINER common build template                            #
################################################################################
all : $(addsuffix .o,$(OBJS))# Specify gnu make that we ned the objects
%.o : %.c
	$(CC) $(CFLAGS) $(IPATH) $(LPATH) -c $< -o $@
	cp $@ $(BUILD_DIR)

clean:
	rm -f *.a *.o *~ 
