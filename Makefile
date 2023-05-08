CONTIKI_PROJECT = sender coordinator
all: $(CONTIKI_PROJECT)

PLATFORMS_EXCLUDE = sky nrf52dk native simplelink

CONTIKI=/senslab/users/wifi2023stras10/iot-lab/parts/iot-lab-contiki-ng/contiki-ng

TARGET = iotlab
BOARD = m3
ARCH_PATH=/senslab/users/wifi2023stras10/iot-lab/parts/iot-lab-contiki-ng/arch/

MAKE_MAC = MAKE_MAC_TSCH

include $(CONTIKI)/Makefile.dir-variables
MODULES += $(CONTIKI_NG_SERVICES_DIR)/shell
MODULES += $(CONTIKI_NG_SERVICES_DIR)/orchestra

include $(CONTIKI)/Makefile.include
