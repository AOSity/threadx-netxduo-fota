TARGET ?= NUCLEO-F767ZI
PROJECT ?= app
TARGET_DIR := target/$(TARGET)
BUILD_DIR := build/$(TARGET)/$(PROJECT)
ELF := $(BUILD_DIR)/bin/$(TARGET).elf

# Dictionary of OpenOCD target config files per board
# Add more entries as needed
define TARGET_CFG_MAP
NUCLEO-F767ZI=target/stm32f7x.cfg
B-L475E-IOT01A2=target/stm32l4x.cfg
endef
$(eval $(TARGET_CFG_MAP))

OPENOCD_TARGET := $(strip $(value $(TARGET)))
OPENOCD_INTERFACE := interface/stlink.cfg

.PHONY: all build flash clean

all: build

build:
	cd $(TARGET_DIR) && python ../../scripts/prepare_target.py
	@mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && cmake -G "Unix Makefiles" \
		-DCMAKE_TOOLCHAIN_FILE=../../../cmake/arm-none-eabi-toolchain.cmake \
		-DTARGET_BOARD=$(TARGET) -DPROJECT=$(PROJECT) ../../..
	cd $(BUILD_DIR) && make -j

flash: build
	openocd -f $(OPENOCD_INTERFACE) -f $(OPENOCD_TARGET) \
		-c "program $(ELF) verify reset exit"

clean:
	rm -rf build
