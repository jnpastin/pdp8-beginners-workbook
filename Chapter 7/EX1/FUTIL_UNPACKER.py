#!/usr/bin/env python3

import re
import sys


def word_binary(word):
    """Format a 12-bit PDP-8 word as xxxx xxxx xxxx grouped in 3-bit chunks."""
    b = format(word, "012b")
    return f"{b[0:3]} {b[3:6]} {b[6:9]} {b[9:12]}"


def byte_binary(byte):
    """Format an 8-bit byte as xx xxx xxx."""
    b = format(byte, "08b")
    return f"{b[0:2]} {b[2:5]} {b[5:8]}"


def unpack_word_pair(word1, word2):
    """
    PDP-8 3-for-2 unpacking

    byte1 = word1[7:0]
    byte2 = word2[7:0]
    byte3[7:4] = word1[11:8]
    byte3[3:0] = word2[11:8]
    """

    byte1 = word1 & 0xFF
    byte2 = word2 & 0xFF
    byte3 = (((word1 >> 8) & 0x0F) << 4) | ((word2 >> 8) & 0x0F)

    return [byte1, byte2, byte3]


def decode_pdp8_ascii(byte):
    """
    Convert PDP-8 ASCII to standard ASCII.

    PDP-8 ASCII stores printable characters with bit 7 set.
    """
    if byte >= 0o200:
        ascii_code = byte - 0o200
    else:
        ascii_code = byte

    return ascii_code


def printable_char(ascii_code):

    special = {
        0o00: "<nul>",
        0o07: "<bel>",
        0o10: "<bs>",
        0o11: "<tab>",
        0o12: "<lf>",
        0o13: "<vt>",
        0o14: "<ff>",
        0o15: "<cr>",
        0o33: "<esc>",
        0o40: "<sp>",
        0o177: "<del>",
    }

    if ascii_code in special:
        return special[ascii_code]

    if 32 <= ascii_code <= 126:
        return chr(ascii_code)

    return f"<{ascii_code:03o}>"


def read_words(filename):
    """
    Read FUTIL dump.

    Everything before ':' is discarded.
    """
    words = []

    with open(filename, "r") as f:
        for line in f:

            if ":" not in line:
                continue

            data = line.split(":", 1)[1]

            for word in re.findall(r"\b[0-7]{4}\b", data):
                words.append(int(word, 8))

    return words


def print_header():

    print(
        "WORD\tBINARY WORD\t\tBINARY BYTE\tPDP-8\tOCTAL\tCHAR"
    )
    print(
        "PAIR\tPAIR\t\t\tTRIAD\t\tASCII\tASCII"
    )
    print(
        "----\t----------------\t----------\t-----\t-----\t----"
    )


def print_pair(word1, word2):

    bytes_out = unpack_word_pair(word1, word2)

    decoded = []

    for byte in bytes_out:

        ascii_code = decode_pdp8_ascii(byte)

        decoded.append(
            (
                byte_binary(byte),
                f"{byte:03o}",
                f"{ascii_code:03o}",
                printable_char(ascii_code),
            )
        )

    print(
        f"{word1:04o}\t"
        f"{word_binary(word1):<15}\t\t"
        f"{decoded[0][0]:<10}\t"
        f"{decoded[0][1]}\t"
        f"{decoded[0][2]}\t"
        f"{decoded[0][3]}"
    )

    print(
        f"{word2:04o}\t"
        f"{word_binary(word2):<15}\t\t"
        f"{decoded[1][0]:<10}\t"
        f"{decoded[1][1]}\t"
        f"{decoded[1][2]}\t"
        f"{decoded[1][3]}"
    )

    print(
        f"\t\t\t\t"
        f"{decoded[2][0]:<10}\t"
        f"{decoded[2][1]}\t"
        f"{decoded[2][2]}\t"
        f"{decoded[2][3]}"
    )

    print()


def main():

    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <futil_dump.txt>")
        sys.exit(1)

    filename = sys.argv[1]

    words = read_words(filename)

    print_header()

    for i in range(0, len(words) - 1, 2):
        print_pair(words[i], words[i + 1])


if __name__ == "__main__":
    main()