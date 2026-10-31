Step 1: Flash Handmade Firmware via FTDI (5 min)
cd ~/asm2464pd-firmware
source .venv/bin/activate

1. Build handmade firmware
make -C handmade clean
make -C handmade wrapped

 2. Put in bootloader mode via FTDI
python3 ftdi_debug.py -d 'ftdi://ftdi:ft-x:DK0KITDD/1' -b -n
sleep 2

3. Verify bootloader (should show 174C:2463)
lsusb | grep -iE '174c|3801|add1'

4. Flash handmade firmware
sudo PYTHONPATH=/home/master/tinygrad USBDEV="174C:2463" \
  /home/master/asm2464pd-firmware/.venv/bin/python3 \
  flash.py handmade/build/firmware_wrapped.bin

5. Reset from bootloader
python3 ftdi_debug.py -d 'ftdi://ftdi:ft-x:DK0KITDD/1' -r -n
sleep 2

6. Verify handmade firmware (should show 3801:0001)
lsusb | grep -iE '174c|3801|add1'