PORT = /dev/tty.usbmodem141103
OUT = buildroot/output/images

build: reconf
	cd buildroot && make

clean:
	cd buildroot && make clean

menuconfig:
	cd buildroot && make menuconfig

flash-full:
	# pip3 install bflb-iot-tool
	bflb-iot-tool --chipname bl808 --interface uart --port /dev/tty.usbmodem141203 --baudrate 2000000 --firmware $(OUT)/bl808_16M_whole_bin.bin --addr 0 --single

flash-rootfs:
	bflb-iot-tool --chipname bl808 --interface uart --port /dev/tty.usbmodem141203 --baudrate 2000000 --firmware $(OUT)/rootfs.squashfs --addr 0x500000 --single

reconf:
	./reconf.sh
