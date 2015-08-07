
FILENAME=firmware

.PHONY: clean all

all: firmware

firmware:	compiler
	pasm -bdz firmware.p

compiler:
	if [ ! -f pasm ]; then make -C pasm_source; fi

clean: 
	rm -f $(FILENAME).bin

