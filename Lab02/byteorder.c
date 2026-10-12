#include "byteorder.h"

void encode_le32(uint32_t value, uint8_t bytes[4])
{
    for (unsigned i = 0; i < 4; ++i)
        bytes[i] = (uint8_t)(value >> (8 * i));
}

void encode_be32(uint32_t value, uint8_t bytes[4])
{
    for (unsigned i = 0; i < 4; ++i)
        bytes[3 - i] = (uint8_t)(value >> (8 * i));
}

uint32_t decode_le32(const uint8_t bytes[4])
{
    uint32_t value = 0;

    for (unsigned i = 0; i < 4; ++i)
        value |= (uint32_t)bytes[i] << (8 * i);
    return value;
}

uint32_t decode_be32(const uint8_t bytes[4])
{
    uint32_t value = 0;

    for (unsigned i = 0; i < 4; ++i)
        value = (value << 8) | bytes[i];
    return value;
}
