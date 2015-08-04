
FILENAME=firmware

.PHONY: clean all

all: bugs

bugs:	compiler
	pasm -bdz firmware.p

compiler:
	if [ ! -f pasm ]; then make -C pasm_source; fi

clean: 
	rm -f $(FILENAME).bin



