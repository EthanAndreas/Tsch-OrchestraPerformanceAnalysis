# to set TSCH value run $make TSCH=1

CONTIKI_PROJECT = sender coordinator
all: $(CONTIKI_PROJECT)

PLATFORMS_EXCLUDE = sky nrf52dk native simplelink

CONTIKI=/senslab/users/wifi2023stras10/iot-lab/parts/iot-lab-contiki-ng/contiki-ng

TARGET = iotlab
BOARD = m3
ARCH_PATH=/senslab/users/wifi2023stras10/iot-lab/parts/iot-lab-contiki-ng/arch/

include $(CONTIKI)/Makefile.dir-variables


ifeq ($(TSCH),1)
    MAKE_MAC = MAKE_MAC_TSCH
    MODULES += $(CONTIKI_NG_SERVICES_DIR)/orchestra
else
    MAKE_MAC = MAKE_MAC_CSMA
endif

MODULES += $(CONTIKI_NG_SERVICES_DIR)/shell

include $(CONTIKI)/Makefile.include
