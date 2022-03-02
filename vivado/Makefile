PROJECT_NAME := vivado_study
PROJECT_DIR := $(PROJECT_NAME).prj
TOP_MODULE := design_1_wrapper
BIT_STREAM := $(PROJECT_DIR)/$(PROJECT_NAME).runs/impl_1/$(TOP_MODULE).bit

all: implement

$(PROJECT_DIR):
	@vivado -mode batch -source create_project.tcl -tclargs $(PROJECT_NAME) $(PROJECT_DIR)

implement: $(PROJECT_DIR)
	@vivado -mode batch -source implement.tcl -tclargs $(PROJECT_NAME) $(PROJECT_DIR)

$(BIT_STREAM): $(PROJECT_DIR)
	@vivado -mode batch -source implement.tcl -tclargs $(PROJECT_NAME) $(PROJECT_DIR)

create_project: $(PROJECT_DIR)

clean:
	@rm -rf $(PROJECT_DIR) .Xil vivado_* *.log *.jou bin

bin:
	mkdir bin

bin/bitstream.bits: $(BIT_STREAM) bin
	cp $(BIT_STREAM) bin/bitstream.bits

copy: bin/bitstream.bits

.PHONY: all create_project clean copy implement
