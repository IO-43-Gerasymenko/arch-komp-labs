#include "byteorder.h"

#include <errno.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

static void print_bytes(const char *label, const uint8_t bytes[4])
{
    printf("%s: %02x %02x %02x %02x\n", label,
           (unsigned)bytes[0], (unsigned)bytes[1],
           (unsigned)bytes[2], (unsigned)bytes[3]);
}

int main(int argc, char **argv)
{
    uint32_t value = UINT32_C(0x12345678);
    uint8_t little[4];
    uint8_t big[4];

    if (argc > 2) {
        fprintf(stderr, "Usage: %s [uint32]\n", argv[0]);
        return 2;
    }
    if (argc == 2) {
        char *end;
        uintmax_t parsed;

        errno = 0;
        parsed = strtoumax(argv[1], &end, 0);
        if (argv[1][0] == '-' || end == argv[1] || *end != '\0' ||
            errno == ERANGE || parsed > UINT32_MAX) {
            fprintf(stderr, "Invalid unsigned 32-bit integer: %s\n", argv[1]);
            return 2;
        }
        value = (uint32_t)parsed;
    }

    encode_le32(value, little);
    encode_be32(value, big);
    printf("Value: 0x%08" PRIx32 "\n", value);
    print_bytes("Little-endian", little);
    print_bytes("Big-endian   ", big);
    printf("Decoded LE: 0x%08" PRIx32 "; BE: 0x%08" PRIx32 "\n",
           decode_le32(little), decode_be32(big));
    return decode_le32(little) != value || decode_be32(big) != value;
}
