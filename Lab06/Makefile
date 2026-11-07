ifneq ($(KERNELRELEASE),)
obj-m := hello.o
ccflags-y += -g
else
KDIR ?= /lib/modules/$(shell uname -r)/build

.PHONY: all clean
all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules
	cp hello.ko hello.ko.unstripped
	$(CROSS_COMPILE)strip -g hello.ko

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean
	$(RM) hello.ko.unstripped

%.s %.i: %.c
	$(MAKE) -C $(KDIR) M=$(CURDIR) $@
endif
