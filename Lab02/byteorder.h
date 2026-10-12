#ifndef BYTEORDER_H
#define BYTEORDER_H

#include <stdint.h>

void encode_le32(uint32_t value, uint8_t bytes[4]);
void encode_be32(uint32_t value, uint8_t bytes[4]);
uint32_t decode_le32(const uint8_t bytes[4]);
uint32_t decode_be32(const uint8_t bytes[4]);

#endif
