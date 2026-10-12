CC ?= cc
AR ?= ar
CPPFLAGS += -I.
CFLAGS ?= -O2
CFLAGS += -std=c11 -Wall -Wextra -Wpedantic -Werror -MMD -MP
BUILD := build
LIB := $(BUILD)/libbyteorder.a
APP := $(BUILD)/byteorder-demo
OBJECTS := $(BUILD)/main.o $(BUILD)/byteorder.o

.PHONY: all clean
all: $(APP)

$(APP): $(BUILD)/main.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

$(LIB): $(BUILD)/byteorder.o
	$(AR) rcs $@ $^

$(BUILD)/%.o: %.c | $(BUILD)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD):
	mkdir -p $@

clean:
	rm -rf $(BUILD)

-include $(OBJECTS:.o=.d)
