#!/bin/sh

# Reduce NOR flash image size
rm -rf $TARGET_DIR/boot
rm -rf $TARGET_DIR/lib/libgfortran.so*
