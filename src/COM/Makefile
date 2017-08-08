################################################################################
#                           TEST LCD Makefile                                  #
################################################################################
TARGET = TEST_LCD

LCD-LOC = $(PRJ_ROOT)\src\UI\drv\LCD
LDPATH += -L$(LCD-LOC)

TERA-LOC = $(PRJ_ROOT)\src\common\terasic
LDPATH += -L$(TERA-LOC)

OBJ-LST = LCD_Driver LCD_Graphic terasic_lib main 

build: $(TARGET)
$(TARGET): $(addsuffix .o,$(OBJ-LST)) 
	$(CC) $(LDFLAGS) $^ -o $@  

terasic_lib.o : 
	$(CC) $(CFLAGS) -c $(TERA-LOC)\terasic_lib.c -o $@
	
LCD_Driver.o : 
	$(CC) $(CFLAGS) -c $(LCD-LOC)\LCD_Driver.c -o $@

LCD_Graphic.o: 
	$(CC) $(CFLAGS) -c $(LCD-LOC)\LCD_Graphic.c -o $@
	
%.o : %.c
	$(CC) $(CFLAGS) -I$(LCD-LOC) -I$(TERA-LOC) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ 
