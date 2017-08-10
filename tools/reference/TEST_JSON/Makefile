################################################################################
#                           TEST JSON Makefile                                 #
################################################################################
all: TEST_JSON_SERVER TEST_JSON_CLIENT

TEST_JSON_SERVER: server.o 
	$(CC) $(LDFLAGS) $^ -o $@  

TEST_JSON_CLIENT: client.o 
	$(CC) $(LDFLAGS) $^ -o $@
	
%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ 
