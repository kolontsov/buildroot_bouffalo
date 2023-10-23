#!/bin/bash

BOARD_DIR=$BR2_EXTERNAL_BOUFFALO_BR_PATH/board/pine64/ox64

echo "Compressing UBoot Image"
lz4 -9 -f $BINARIES_DIR/u-boot.bin $BINARIES_DIR/u-boot.bin.lz4
cd $BINARIES_DIR
echo "Creating OpenSBI/DTB/Uboot Image"
$BOARD_DIR/mergebin.py -o bl808-firmware.bin -k u-boot.bin.lz4 -d u-boot.dtb -s fw_jump.bin
echo "Copying Boot Script"
$BINARIES_DIR/../host/bin/mkimage -C none -A riscv -T script -d $BOARD_DIR/boot-m1s.cmd $BINARIES_DIR/boot-m1s.scr
$BINARIES_DIR/../host/bin/mkimage -C none -A riscv -T script -d $BOARD_DIR/boot-pine64.cmd $BINARIES_DIR/boot-pine64.scr
cp $BINARIES_DIR/boot-pine64.scr $BINARIES_DIR/boot.scr
cp $BINARIES_DIR/*.scr $TARGET_DIR/boot/
cp $BOARD_DIR/*.cmd $TARGET_DIR/boot/
mkdir -p $BINARIES_DIR/extlinux/
cp $TARGET_DIR/boot/extlinux/* $BINARIES_DIR/extlinux/
echo "Creating Filesystem Image"
$BASE_DIR/../support/scripts/genimage.sh -c $BOARD_DIR/genimage.cfg

pushd $BINARIES_DIR
# Build FIT image
cp $BOARD_DIR/bl808.its .
$BINARIES_DIR/../host/bin/mkimage -f bl808.its bl808.itb
# Build whole image
$BOARD_DIR/nor_flash_whole_bin.py $BOARD_DIR/bl808_16M_partition.yaml bl808_16M_whole_bin.bin || exit 1
popd

echo "Completed - Images are at $BINARIES_DIR"
