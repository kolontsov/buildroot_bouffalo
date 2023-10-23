#!/usr/bin/env python3

# SPDX-License-Identifier: GPL-2.0-only
#
# Create whole flash image.
#
# Author: Chien Wong <qwang@bouffalolab.com>
#
# Copyright (C) Bouffalo Lab 2016-2023
#

import sys
import yaml

def merge_bins(config):
    flash_size = config['flash']['size']
    # Fill the merged bin with 0xff
    merged_bin = bytearray([0xff] * flash_size)

    # Read and merge the bin files
    for bin_file in config['partitions']:
        file_name = bin_file.get('file_name')
        if file_name is None:
            continue
        offset = bin_file['offset']
        size = bin_file['size']

        try:
            with open(file_name, 'rb') as file:
                file_data = file.read()
        except IOError:
            print(f"Error: Failed to open or read file '{file_name}'.")
            return None

        # Check if the file length exceeds the partition size
        if len(file_data) > size:
            print(f"Error: File '{file_name}' is too large for the specified partition size.")
            return None

        # fill the bin file
        merged_bin[offset:offset + len(file_data)] = file_data

    return merged_bin

# Check if the correct number of command-line arguments is provided
if len(sys.argv) != 3:
    print(f"Usage: python {sys.argv[0]} <config_file> <output_file>")
    sys.exit(1)

config_file = sys.argv[1]
output_file = sys.argv[2]

with open(config_file, 'r') as file:
    config = yaml.safe_load(file)

merged_bin = merge_bins(config)
if merged_bin is None:
    exit(1)

with open(output_file, 'wb') as file:
    file.write(merged_bin)
