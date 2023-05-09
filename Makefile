CONTIKI_PROJECT = sender coordinator
all: $(CONTIKI_PROJECT)

PLATFORMS_EXCLUDE = sky nrf52dk native simplelink

CONTIKI = /senslab/users/wifi2023stras10/iot-lab/parts/iot-lab-contiki-ng/contiki-ng

TARGET = iotlab
BOARD = m3
ARCH_PATH = /senslab/users/wifi2023stras10/iot-lab/parts/iot-lab-contiki-ng/arch/

ORCHESTRA ?= 0

ifeq ($(ORCHESTRA),1)
	MODULES += $(CONTIKI_NG_SERVICES_DIR)/orchestra
endif

MODULES += $(CONTIKI_NG_SERVICES_DIR)/shell

tsch:
	OCHESTRA=1
	$(MAKE) MAKE_MAC=MAKE_MAC_TSCH -f Makefile

orchestra:
	ORCHESTRA=1
	$(MAKE) MAKE_MAC=MAKE_MAC_TSCH -f Makefile

csma:
	$(MAKE) MAKE_MAC=MAKE_MAC_CSMA -f Makefile

include $(CONTIKI)/Makefile.dir-variables
include $(CONTIKI)/Makefile.include

