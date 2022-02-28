PROJECT_NAME := vivado_study
PROJECT_DIR := $(PROJECT_NAME).prj

all: implement

$(PROJECT_DIR):
	@vivado -mode batch -source create_project.tcl -tclargs $(PROJECT_NAME) $(PROJECT_DIR)

implement: $(PROJECT_DIR)
	@vivado -mode batch -source implement.tcl -tclargs $(PROJECT_NAME) $(PROJECT_DIR)

create_project: $(PROJECT_DIR)

clean:
	@rm -rf $(PROJECT_DIR) .Xil vivado_* *.log *.jou

.PHONY: all create_project clean
