################################################################################
#                           TEST LCD Makefile                                  #
################################################################################
OBJ-LST = main terasic_lib

build: $(TARGET)

$(TARGET): terasic_lib lcd_drv $(addsuffix .o,$(OBJ-LST))
	$(CC) $(LDFLAGS)   $^ -o $@ -lrt -lm
	
%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ *.bmp