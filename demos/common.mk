################################################################################
#                    DE10_DEMO common build template                           #
################################################################################
build: $(TARGET)

$(TARGET): $(addsuffix .o,$(OBJS))
	$(CC) $(LDFLAGS) $^ -o $@ 

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ 
