################################################################################
#                           DE10_STANDARD build file                           #
################################################################################
TARGET = TEST_7SEG
OBJ-LST = main

build: $(TARGET)
$(TARGET): $(addsuffix .o,$(OBJ-LST)) 
	$(CC) $(LDFLAGS) $^ -o $@  
	
%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ 
