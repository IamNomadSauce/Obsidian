---
title: "7900xtx debugging"
source: "https://x.com/i/grok?conversation=2097512234087862396"
author:
published:
created: 2026-09-11
description: "grok debugging amd 7900xtx chestnut bugs"
tags:
  - "clippings"
---
make -C handmade flash make: Entering directory '/home/master/chestnut/handmade' Resetting to bootloader... Device reset complete. Flashing firmware to device... Traceback (most recent call last): File "/home/master/chestnut/handmade/../flash.py", line 24, in \<module> raise RuntimeError('Could not open controller. You can set USBDEV environment variable to your device\\'s vendor and device ID (e.g., USBDEV="174C:2464")') RuntimeError: Could not open controller. You can set USBDEV environment variable to your device's vendor and device ID (e.g., USBDEV="174C:2464") make: \*\*\* \[Makefile:122: flash\] Error 1 make: Leaving directory '/home/master/chestnut/handmade'

The reset over FTDI worked. The failure is the next step: flash.py never found an ASM2464PD on USB.That script only opens these IDs: 174C:2464, 174C:2463, and 3801:0001. Anything else (or no device at all) raises exactly the error you saw.

[github.com](https://github.com/tinygrad/asm2464pd-firmware/blob/master/flash.py)

What to check

1\. See what the chip actually enumerates as after bootloader resetRight after make -C handmade flash fails, run:

```bash
lsusb | grep -iE '174c|3801|asmedia|asm'
```

or dump everything:

```bash
lsusb
```

- If nothing new appears, the controller did not come up on USB (cable/port/power/enumeration).
- If it appears with a different vid:pid, pass that to the flasher:

```bash
USBDEV="vvvv:pppp" make -C handmade flash
```

Example from the script itself: USBDEV="174C:2464".2. Permissions / kernel driverflash.py uses tinygrad’s USB3 backend (libusb). Typical Linux issues:

```bash
# see if the device is claimed
lsusb -t
dmesg | tail -40
```

Then try:

```bash
sudo USBDEV="174C:2464" make -C handmade flash
```

If it works only as root, add a udev rule for 174c/3801 and reload udev.If the kernel bound usb-storage/uas to it, unbind or unplug other mass-storage on that bus so libusb can claim it.3. Timing after -bnThe Makefile does ftdi\_debug.py -bn then immediately flash.py. Enumeration can lag. Test manually:

```bash
python3 ../ftdi_debug.py -bn
sleep 2
lsusb
python3 ../flash.py build/firmware_wrapped.bin
```

4\. Physical / host USB
- Use a data-capable cable, preferably USB3, not a hub.
- Try another port.
- Confirm the dock is powered (Chestnut needs its PSU / switch on).
- FTDI debug UART working does not prove the ASM USB port is up.
5\. tinygrad import pathflash.py imports tinygrad.runtime.support.usb.USB3. If that import failed you’d see a different traceback, but still run from the repo with tinygrad available:

```bash
PYTHONPATH=/path/to/tinygrad:$PYTHONPATH make -C handmade flash
```

Fastest isolation

```bash
python3 ../ftdi_debug.py -bn
sleep 2
lsusb
python3 -c "
from tinygrad.runtime.support.usb import USB3
for vid, pid in [(0x174C,0x2464),(0x174C,0x2463),(0x3801,0x0001)]:
    print(hex(vid), hex(pid), USB3.list_devices(vid, pid))
"
```

- Empty lists + no lsusb match → hardware/enumeration.
- Devices listed but open fails → permissions or claimed interface.
- Different VID:PID in lsusb → set USBDEV.
Paste lsusb from immediately after the reset and I can tell you which of those it is.

(.venv) master@lab:~/chestnut$ lsusb | grep -iE '174c|3801|asmedia|asm' Bus 002 Device 005: ID 174c:2463 ASMedia Technology Inc. AS2462 (.venv) master@lab:~/chestnut$ USBDEV="174c:2463" make -C handmade flash make: Entering directory '/home/master/chestnut/handmade' Resetting to bootloader... Device reset complete. Flashing firmware to device... Traceback (most recent call last): File "/home/master/chestnut/handmade/../flash.py", line 24, in \<module> raise RuntimeError('Could not open controller. You can set USBDEV environment variable to your device\\'s vendor and device ID (e.g., USBDEV="174C:2464")') RuntimeError: Could not open controller. You can set USBDEV environment variable to your device's vendor and device ID (e.g., USBDEV="174C:2464") make: \*\*\* \[Makefile:122: flash\] Error 1 make: Leaving directory '/home/master/chestnut/handmade'

174c:2463 is already in flash.py’s supported list (AS2462). USBDEV is not the problem, and that env var is being ignored in practice because the real failure is swallowed.flash.py does this:

```python
try:
    ...
    dev = USB3(...)
    break
except RuntimeError:
    pass
```

Any libusb open/claim failure becomes the generic “Could not open controller” message. Your lsusb was also taken before ftdi\_debug.py -bn. That reset re-enumerates the ASM chip; 2463 may drop off the bus or come back a second later.

What is actually failing

tinygrad’s USB3 open path does:
1. libusb\_open
2. read product string (must start with custom or AS2462)
3. detach kernel driver on interface 0
4. libusb\_reset\_device
5. set config 1, claim interface 0
On a Chestnut that is usually usb-storage/uas holding the device, or /dev/bus/usb/... not writable by your user. Either one raises RuntimeError and flash.py hides it.

[raw.githubusercontent.com](https://raw.githubusercontent.com/tinygrad/tinygrad/master/tinygrad/runtime/support/usb.py)

Do this in order

1\. See the device after bootloader reset, not before

```bash
python3 ftdi_debug.py -bn
sleep 2
lsusb | grep -iE '174c|3801|asmedia'
dmesg | tail -30
```

You want 174c:2463 or 174c:2464 to reappear. If it vanishes and stays gone, flashing cannot start.2. Print the real exception

```bash
python3 ftdi_debug.py -bn
sleep 2
python3 - <<'PY'
from tinygrad.runtime.support.usb import USB3
for vid, pid in [(0x174C,0x2463),(0x174C,0x2464),(0x3801,0x0001)]:
    devs = USB3.list_devices(vid, pid)
    print(hex(vid), hex(pid), devs)
    if devs:
        try:
            USB3(devs[0][0], 0x81, 0x83, 0x02, 0x04, use_bot=True)
            print("OPEN OK")
        except Exception as e:
            print(type(e).__name__, e)
PY
```

Typical results:

| Message | Meaning |
| --- | --- |
| empty lists after reset | chip did not re-enumerate yet / wrong port |
| LIBUSB\_ERROR\_ACCESS | permissions |
| LIBUSB\_ERROR\_BUSY / NOT\_FOUND | kernel driver or device reset mid-open |
| LIBUSB\_ERROR\_NO\_DEVICE | disappeared during -bn |

3\. If it is ACCESS / BUSY

```bash
# who owns it
lsusb -d 174c:2463 -v | head
readlink -f /sys/bus/usb/devices/*/idProduct | while read p; do
  grep -H . "$(dirname $p)/idVendor" "$(dirname $p)/idProduct"
done

sudo make -C handmade flash
```

If sudo works, add udev (then replug or udevadm trigger):

```
SUBSYSTEM=="usb", ATTR{idVendor}=="174c", ATTR{idProduct}=="2463", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="174c", ATTR{idProduct}=="2464", MODE="0666"
```

Unbind mass-storage if it grabbed the bridge:

```bash
# find the interface driver
find /sys/bus/usb/devices -name idProduct -exec grep -l 2463 {} \;
# then, example:
echo '2-1:1.0' | sudo tee /sys/bus/usb/drivers/uas/unbind
# or
echo '2-1:1.0' | sudo tee /sys/bus/usb/drivers/usb-storage/unbind
```

4\. If lsusb is empty after -bnReset raced ahead of enumeration. Patch the Makefile flash target with a sleep, or run the steps by hand:

```bash
python3 ftdi_debug.py -bn
sleep 3
python3 flash.py handmade/build/firmware_wrapped.bin
python3 ftdi_debug.py -rt 2
```

Use a USB3 port directly on the machine, dock power on.USBDEV="174c:2463" cannot help here: that PID is already searched, and the constructor error is discarded. The snippet in step 2 is the one that will tell you which of access, busy, or missing-after-reset it is.

(.venv) master@lab:~/chestnut$ python3 ftdi\_debug.py -bn sleep 2 lsusb | grep -iE '174c|3801|asmedia' dmesg | tail -30 Device reset complete. Bus 002 Device 007: ID 174c:2463 ASMedia Technology Inc. AS2462 dmesg: read kernel buffer failed: Operation not permitted

Good: after -bn the chip is still 174c:2463 / AS2462. Detection is fine. The failure is opening it with libusb.dmesg failed because your user cannot read the kernel log. That is a hint the same permission problem may block libusb\_open / detach.Run these next:

```bash
sudo dmesg | tail -40

python3 - <<'PY'
from tinygrad.runtime.support.usb import USB3
devs = USB3.list_devices(0x174C, 0x2463)
print("list:", devs)
if not devs:
    raise SystemExit("list_devices empty")
try:
    USB3(devs[0][0])
    print("OPEN OK")
except Exception as e:
    print(type(e).__name__ + ":", e)
PY
```

Then try the flash as root, without USBDEV:

```bash
sudo -E PYTHONPATH="$PYTHONPATH" make -C handmade flash
```

If the Python snippet prints LIBUSB\_ERROR\_ACCESS, sudo (or a udev rule) is required.  
If it prints LIBUSB\_ERROR\_BUSY or a detach/reset error, the kernel uas/usb-storage driver still owns interface 0 — unbind that interface, then flash.  
Paste the snippet output if it is anything else.

python3 ftdi\_debug.py -bn sleep 2 lsusb | grep -iE '174c|3801|asmedia' dmesg | tail -30 Device reset complete. Bus 002 Device 007: ID 174c:2463 ASMedia Technology Inc. AS2462 dmesg: read kernel buffer failed: Operation not permitted (.venv) master@lab:~/chestnut$ sudo dmesg | tail -40 python3 - <<'PY' from tinygrad.runtime.support.usb import USB3 devs = USB3.list\_devices(0x174C, 0x2463) print("list:", devs) if not devs: raise SystemExit("list\_devices empty") try: USB3(devs\[0\]\[0\]) print("OPEN OK") except Exception as e: print(type(e).\_\_name\_\_ + ":", e) PY \[sudo\] password for master: \[218594.906905\] sd 0:0:0:0: \[sda\] Media removed, stopped polling \[218594.907507\] sd 0:0:0:0: \[sda\] Attached SCSI removable disk \[218672.559422\] usb 5-1: usbfs: interface 0 claimed by ftdi\_sio while 'python3' sets config #1 \[218672.559920\] ftdi\_sio ttyUSB0: FTDI USB Serial Device converter now disconnected from ttyUSB0 \[218672.559950\] ftdi\_sio 5-1:1.0: device disconnected \[218674.142773\] usb 2-1: USB disconnect, device number 5 \[218676.092851\] usb 2-1: new SuperSpeed Plus Gen 2x1 USB device number 6 using xhci\_hcd \[218676.105355\] usb 2-1: New USB device found, idVendor=174c, idProduct=2463, bcdDevice= 0.01 \[218676.105358\] usb 2-1: New USB device strings: Mfr=2, Product=3, SerialNumber=1 \[218676.105359\] usb 2-1: Product: AS2462 \[218676.105361\] usb 2-1: Manufacturer: ASMedia \[218676.105362\] usb 2-1: SerialNumber: 00000000000000000000 \[218676.106620\] usb-storage 2-1:1.0: USB Mass Storage device detected \[218676.106950\] scsi host0: usb-storage 2-1:1.0 \[218676.148427\] ftdi\_sio 5-1:1.0: FTDI USB Serial Device converter detected \[218676.148483\] usb 5-1: Detected FT-X \[218676.160582\] usb 5-1: FTDI USB Serial Device converter now attached to ttyUSB0 \[218681.501189\] scsi 0:0:0:0: Direct-Access ASMT 2462 NVME 0 PQ: 0 ANSI: 6 \[218681.501799\] sd 0:0:0:0: Attached scsi generic sg0 type 0 \[218681.502297\] sd 0:0:0:0: \[sda\] Media removed, stopped polling \[218681.502862\] sd 0:0:0:0: \[sda\] Attached SCSI removable disk \[218747.206626\] usb 5-1: usbfs: interface 0 claimed by ftdi\_sio while 'python3' sets config #1 \[218747.206989\] ftdi\_sio ttyUSB0: FTDI USB Serial Device converter now disconnected from ttyUSB0 \[218747.207003\] ftdi\_sio 5-1:1.0: device disconnected \[218748.790388\] usb 2-1: USB disconnect, device number 6 \[218750.743484\] usb 2-1: new SuperSpeed Plus Gen 2x1 USB device number 7 using xhci\_hcd \[218750.757762\] usb 2-1: New USB device found, idVendor=174c, idProduct=2463, bcdDevice= 0.01 \[218750.757770\] usb 2-1: New USB device strings: Mfr=2, Product=3, SerialNumber=1 \[218750.757772\] usb 2-1: Product: AS2462 \[218750.757774\] usb 2-1: Manufacturer: ASMedia \[218750.757776\] usb 2-1: SerialNumber: 00000000000000000000 \[218750.759129\] usb-storage 2-1:1.0: USB Mass Storage device detected \[218750.759439\] scsi host0: usb-storage 2-1:1.0\[218750.803713\] ftdi\_sio 5-1:1.0: FTDI USB Serial Device converter detected \[218750.803815\] usb 5-1: Detected FT-X \[218750.815428\] usb 5-1: FTDI USB Serial Device converter now attached to ttyUSB0 \[218752.538568\] scsi 0:0:0:0: Direct-Access ASMT 2462 NVME 0 PQ: 0 ANSI: 6 \[218752.539154\] sd 0:0:0:0: Attached scsi generic sg0 type 0 \[218752.539448\] sd 0:0:0:0: \[sda\] Media removed, stopped polling \[218752.540111\] sd 0:0:0:0: \[sda\] Attached SCSI removable disk list: \[(<tinygrad.runtime.support.c.LP\_struct\_libusb\_device object at 0x749b2d5c4e50>, 'usb:2-7')\] RuntimeError: libusb\_open: Access denied (insufficient permissions)

That output is definitive: the chip is there, tinygrad finds it, and libusb\_open is denied.

```
list: [..., 'usb:2-7']
RuntimeError: libusb_open: Access denied (insufficient permissions)
```

usb-storage also binds as soon as it enumerates (usb-storage 2-1:1.0), which is why a later claim/detach would fight the kernel even after permissions are fixed.

Flash once

```bash
sudo -E PYTHONPATH="$PYTHONPATH" make -C handmade flash
```

Keep the venv’s tinygrad on PYTHONPATH so root still imports the same package.

Make it work without sudo

/etc/udev/rules.d/99-asm2464.rules:

```
SUBSYSTEM=="usb", ATTR{idVendor}=="174c", ATTR{idProduct}=="2463", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="174c", ATTR{idProduct}=="2464", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="3801", ATTR{idProduct}=="0001", MODE="0666"
```

Then:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Unplug/replug the dock (or run ftdi\_debug.py -bn again) so the node is created with the new mode.Optional: stop usb-storage from grabbing it before flash.py does:

```
SUBSYSTEM=="usb", ATTR{idVendor}=="174c", ATTR{idProduct}=="2463", MODE="0666", RUN+="/bin/sh -c 'echo %k:1.0 > /sys/bus/usb/drivers/usb-storage/unbind'"
```

USB3 already tries libusb\_detach\_kernel\_driver after a successful open; the udev MODE="0666" is the part you are missing.Re-run the same Python snippet without sudo after the rule + replug. You want OPEN OK, then make -C handmade flash as your user.

sudo -E PYTHONPATH="$PYTHONPATH" make -C handmade flash make: Entering directory '/home/master/chestnut/handmade' Resetting to bootloader... Traceback (most recent call last): File "/home/master/chestnut/handmade/../ftdi\_debug.py", line 7, in \<module> from pyftdi.ftdi import Ftdi ModuleNotFoundError: No module named 'pyftdi' make: \*\*\* \[Makefile:120: flash\] Error 1 make: Leaving directory '/home/master/chestnut/handmade'

Root is not using the venv. sudo ran system python3, which has no pyftdi.

```bash
which python3
# should be something like /home/master/chestnut/.venv/bin/python3
```

Flash with that interpreter:

```bash
sudo /home/master/chestnut/.venv/bin/python3 ftdi_debug.py -bn
sleep 2
sudo /home/master/chestnut/.venv/bin/python3 flash.py handmade/build/firmware_wrapped.bin
sudo /home/master/chestnut/.venv/bin/python3 ftdi_debug.py -rt 2
```

Or one shot through make, forcing the venv python:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" \
  PYTHONPATH="$PYTHONPATH" \
  make -C handmade flash
```

If firmware\_wrapped.bin is missing, build it first as your user:

```bash
make -C handmade
```

Longer-term, install the udev rule from the previous message so you can flash without sudo and stay inside the venv.

(.venv) master@lab:~/chestnut$ sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" \\ PYTHONPATH="$PYTHONPATH" \\ make -C handmade flash make: Entering directory '/home/master/chestnut/handmade' Resetting to bootloader... Device reset complete. Flashing firmware to device... done, you can disconnect the controller! Resetting device... Device reset complete. Starting debug output. Press Ctrl-C to exit. ------ % \[BOOT\] \[PCIe 00 down Gen01 x01\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] make: Leaving directory '/home/master/chestnut/handmade'

Flash succeeded. done, you can disconnect the controller! is flash.py finishing the write. The process then sat in ftdi\_debug.py -rt 2, which resets the chip and stays attached to the FTDI console. That is why make did not return until the serial session ended.Ctrl-C is the normal way out of that target.What the log means:
- \[BOOT\] — handmade firmware started.
- \[PCIe 78 UP Gen03 x02 CONNECTED\] — link trained to Gen3 x2.
- then \[PCIe 00 down Gen01 x01\] repeating — the link dropped and did not come back while the console was open.
That is separate from flashing. The image is on the controller. A downed PCIe link is power, GPU, cable, or firmware link-management after boot.Useful follow-ups:

```bash
# flash again without leaving a serial tail
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" \
  make -C handmade nflash
# nflash uses -rn (reset, no console)

# watch serial by itself
python3 ftdi_debug.py
```

Add the udev rule when you want this without sudo. For tinygrad after this image: DEV=USB+AMD (or whatever your GPU is) once the PCIe line stays UP.

\# flash again without leaving a serial tail sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" \\ make -C handmade nflash # nflash uses -rn (reset, no console) # watch serial by itself python3 ftdi\_debug.py make: Entering directory '/home/master/chestnut/handmade' Resetting to bootloader... Device reset complete. Flashing firmware to device... done, you can disconnect the controller! Device reset complete. make: Leaving directory '/home/master/chestnut/handmade' Starting debug output. Press Ctrl-C to exit. ------ \[PCIe 00 down Gen01 x01\] \[PCIe 58 UP Gen01 x02\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[C 00 05 0000\] \[A\] \[C 80 06 0008\] \[C 00 31 0000\] \[C 80 06 0012\] \[C 80 06 0005\] \[C 80 06 0016\] \[C 80 06 0009\] \[C 80 06 0079\] \[C 80 06 00FF\] \[C 80 06 00FF\] \[C 80 06 00FF\] \[C 80 06 00FF\] \[C 00 09 0000\] \[\*\*\* SET CONFIG \*\*\*\]

That is a clean flash and a healthy boot.nflash wrote the image and reset without hanging make. The second command attached the console, which is why you see the live stream.Sequence in the log:
1. Link starts down.
2. Trains Gen01 x02 (0x58).
3. Settles Gen03 x02 CONNECTED (0x78) and stays there.
4. \[LINK EVENT 08 link=02\] — firmware notices the x2 link.
5. \[C …\] lines — config-space / control traffic from the host.
6. \[\*\*\* SET CONFIG \*\*\*\] — USB enumeration finished; the host set configuration 1.
Compared with the earlier session (link up once, then stuck down), this one held Gen3 x2 and got a full USB config. That is the state you want before using the dock.Ctrl-C leaves the console. After that, try the GPU from the same machine, e.g. DEV=USB+AMD or DEV=USB+NV depending on the card. If the console later floods PCIe 00 down again, that is a link-drop after boot, not a failed flash.

ok, now i need a tinygrad test

Canonical smoke test for this firmware is a 1+1 on the USB GPU.From a tinygrad checkout (not only ~/chestnut):

```bash
cd /path/to/tinygrad   # or: PYTHONPATH=/path/to/tinygrad

# AMD RDNA3/4 on USB3 (what CI uses for UsbGPU)
sudo env PATH="$PATH" \
  DEBUG=2 GMMU=0 DEV=USB+AMD \
  python3 test/test_tiny.py TestTiny.test_plus
```

If the card is NVIDIA (Ampere+), usually over USB4:

```bash
sudo env PATH="$PATH" DEBUG=2 DEV=USB+NV \
  python3 test/test_tiny.py TestTiny.test_plus
```

test\_plus is “allocate two tensors, add, realize.” If that prints OK / exits 0, the dock + handmade FW + tinygrad stack is alive.Without pytest, same check:

```bash
sudo env PATH="$PATH" DEBUG=2 DEV=USB+AMD python3 - <<'PY'
from tinygrad import Tensor
print((Tensor([1.0]) + Tensor([2.0])).tolist())  # expect [3.0]
print("device:", Tensor([1.0]).device)
PY
```

Next rungs if test\_plus passes:

```bash
# full tiny suite
GMMU=0 DEV=USB+AMD python3 test/test_tiny.py

# USB copy bandwidth
PYTHONPATH=. GMMU=0 DEV=USB+AMD \
  python3 test/external/external_test_usb_asm24.py TestDevCopySpeeds
```

Notes:
- Use the venv python3 that has tinygrad (PATH=.../.venv/bin:$PATH), and sudo until the udev rule is in place. Same Access denied as flashing otherwise.
- DEV=USB+AMD vs USB+NV must match the GPU in the Chestnut. Wrong one fails at device init, not at +.
- Watch python3 ftdi\_debug.py in another terminal; you want PCIe 78 UP … CONNECTED while the test runs.
- GMMU=0 is what tinygrad’s USB AMD CI uses; drop it later if you want the default MMU path.

sudo env PATH="$PATH" \\ DEBUG=2 GMMU=0 DEV=USB+AMD \\ python3 test/test\_tiny.py TestTiny.test\_plus \[sudo\] password for master: opened device PYTHON from pid:90610 scheduled 3 kernels in 18.14 ms | CACHE MISS 0e870a0c | 49 uops in cache | /home/master/tinygrad/test/test\_tiny.py:24 am usb:2-11: product string: 'custom ed4e39b7-CLEAN' opened device CPU from pid:90610 F ====================================================================== FAIL: test\_plus (\_\_main\_\_.TestTiny.test\_plus) ---------------------------------------------------------------------- Traceback (most recent call last): File "/home/master/tinygrad/test/test\_tiny.py", line 24, in test\_plus self.assertListEqual(out.tolist(), \[5.0, 7.0, 9.0\]) ^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 769, in \_wrapper ret = fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 512, in tolist return self.data().tolist() ^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 766, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 485, in data buf = self.\_buffer() ^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 766, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 469, in \_buffer return cast(Buffer, x.realize().uop.buffer).ensure\_allocated() ^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 766, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/usr/lib/python3.12/contextlib.py", line 81, in inner return func(\*args, \*\*kwds) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 415, in realize run\_linear(\*Tensor.linear\_with\_vars(\*to\_realize), update\_stats=do\_update\_stats) File "/home/master/tinygrad/tinygrad/engine/realize.py", line 291, in run\_linear if not jit: linear = link\_linear(compile\_linear(linear, validate=VALIDATE\_WITH\_CPU, input\_uops=inputs), input\_uops=inputs) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/engine/realize.py", line 282, in compile\_linear linear = lower\_and\_compile(linear) ^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/engine/realize.py", line 243, in lower\_and\_compile if not len(ar:={c: a for c in linear.toposort() if c.op is Ops.CALL and (a:=\_get\_call\_to\_compile(c)) is not None}): return linear ^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/engine/realize.py", line 238, in \_get\_call\_to\_compile return ast, Device\[c.device if isinstance(c.device, str) else c.device\[0\]\].renderer ~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/device.py", line 26, in \_\_getitem\_\_ return self.\_\_get\_canonicalized\_item(ix) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/device.py", line 34, in \_\_get\_canonicalized\_item ret = self.get\_class(ix)(ix) ^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/ops\_amd.py", line 1020, in \_\_init\_\_ self.iface = self.\_select\_iface(device) ^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/device.py", line 382, in \_select\_iface return select\_first\_inited(\[functools.partial(iface, self, self.device\_id) for iface in filtered\], ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/helpers.py", line 146, in select\_first\_inited raise excs\[0\] if len(excs) == 1 else ExceptionGroup(err\_msg, excs) File "/home/master/tinygrad/tinygrad/helpers.py", line 142, in select\_first\_inited x = typ(\*args) ^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/ops\_amd.py", line 989, in \_\_init\_\_ self.dev\_impl = AMDev(self.pci\_dev) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/am/amdev.py", line 169, in \_\_init\_\_ self.\_run\_discovery() File "/home/master/tinygrad/tinygrad/runtime/support/am/amdev.py", line 363, in \_run\_discovery assert self.bhdr.binary\_signature == am.BINARY\_SIGNATURE and ihdr.signature == am.DISCOVERY\_TABLE\_SIGNATURE, "discovery signatures mismatch" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ AssertionError: discovery signatures mismatch---------------------------------------------------------------------- Ran 1 test in 0.112sFAILED (failures=1)

The USB path is working. Failure is AMD GPU bring-up behind the bridge.

```
am usb:2-11: product string: 'custom ed4e39b7-CLEAN'   # handmade FW, host can talk to the ASM
AssertionError: discovery signatures mismatch         # GPU IP discovery table unreadable
```

tinygrad opened the controller, then AMDev mapped the GPU and the discovery header was garbage or zeros. That is a PCIe/GPU-init problem, not libusb and not “wrong test.”CI boots UsbGPU with a device reset. Retry that first:

```bash
sudo env PATH="$PATH" \
  DEBUG=2 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 test/test_tiny.py TestTiny.test_plus
```

In another terminal:

```bash
python3 /home/master/chestnut/ftdi_debug.py
```

You want PCIe 78 UP Gen03 x02 CONNECTED during the test, not only at flash time. If it flaps to PCIe 00 down while AMDev runs, discovery will fail exactly like this.Also confirm:
- GPU is powered (Chestnut PSU / ATX adapter, card 8-pin/12VHPWR seated).
- Card is RDNA3 or RDNA4. Older GCN/RDNA1–2 will not pass this path.
- If this host also has an internal AMD GPU, force the USB one: DEV=USB+AMD:0 or check DEBUG=2 for which usb:2-11 it bound.
Scan what the bridge actually sees:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  python3 /home/master/chestnut/app/scan_pcie.py --deep --verbose
```

If that does not find a GPU at a downstream bus, tinygrad cannot discover it either. Then it is power, the GPU not coming out of reset, or the handmade FW dropping the link after \[\*\*\* SET CONFIG \*\*\*\].test\_plus only failed because.tolist() forced realize, which constructs AMDDevice and hits discovery. The add never ran on the GPU.

sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \\ python3 /home/master/chestnut/app/scan\_pcie.py --deep --verbose Error: Could not import ASM24Controller from tinygrad Make sure tinygrad is installed or available at ~/tinygrad

scan\_pcie.py is stale. Current tinygrad exports CustomASM24Controller, not ASM24Controller. The script never ran; that error is only an import name.One-shot scan with the new class:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.support.usb import USB3, CustomASM24Controller

dev = None
for vid, pid in [(0x174C,0x2463),(0x174C,0x2464),(0x3801,0x0001)]:
    found = USB3.list_devices(vid, pid)
    print(f"list {vid:04x}:{pid:04x} -> {found}")
    if found:
        dev = USB3(found[0][0])
        break
assert dev is not None, "no ASM USB device"

ctl = CustomASM24Controller(dev)
print("product:", getattr(dev, "product", "?"))

def cfg(bus, d, fn, off, size=4):
    return ctl.pcie_cfg_req(off, bus=bus, dev=d, fn=fn, size=size)

print("bus0 dev0 fn0 vendor:device =", hex(cfg(0,0,0,0,2)), hex(cfg(0,0,0,2,2)))

# walk a few buses/devs for a display-class device
for bus in range(0, 8):
    for d in range(0, 8):
        try:
            vid = cfg(bus, d, 0, 0, 2)
        except Exception as e:
            if bus == 0 and d == 0:
                print("cfg error", bus, d, e)
            continue
        if vid in (0, 0xFFFF, None):
            continue
        did = cfg(bus, d, 0, 2, 2)
        cls = cfg(bus, d, 0, 0x0A, 2)
        print(f"  {bus:02x}:{d:02x}.0  {vid:04x}:{did:04x} class={cls:04x}")
PY
```

Or patch the chestnut script:

```bash
sed -i 's/ASM24Controller/CustomASM24Controller/g' /home/master/chestnut/app/scan_pcie.py
```

CustomASM24Controller now requires an already-open USB3 instance; the old no-arg ASM24Controller() constructor is gone. After the sed, connect() will still be wrong unless you also pass USB3(...). Prefer the snippet above.While that runs, keep the FTDI console open. Then retry the actual tinygrad test with a GPU reset:

```bash
sudo env PATH="$PATH" \
  DEBUG=2 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 /home/master/tinygrad/test/test_tiny.py TestTiny.test_plus
```

What to look for in the scan:
- 1002:xxxx AMD GPU / upstream switch ports → bridge and card are visible; discovery-signature fail is then BAR/reset (AM\_RESET=1).
- only 1b21/174c ASMedia ports, no 1002/10de → GPU not on the link (power, PERST, or FW dropped PCIe).
- PCIe link not up from CustomASM24Controller → same as the serial PCIe 00 down lines.

sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.support.usb import USB3, CustomASM24Controllerdev = None for vid, pid in \[(0x174C,0x2463),(0x174C,0x2464),(0x3801,0x0001)\]: found = USB3.list\_devices(vid, pid) print(f"list {vid:04x}:{pid:04x} -> {found}") if found: dev = USB3(found\[0\]\[0\]) break assert dev is not None, "no ASM USB device"ctl = CustomASM24Controller(dev) print("product:", getattr(dev, "product", "?"))def cfg(bus, d, fn, off, size=4): return ctl.pcie\_cfg\_req(off, bus=bus, dev=d, fn=fn, size=size)print("bus0 dev0 fn0 vendor:device =", hex(cfg(0,0,0,0,2)), hex(cfg(0,0,0,2,2)))# walk a few buses/devs for a display-class device for bus in range(0, 8): for d in range(0, 8): try: vid = cfg(bus, d, 0, 0, 2) except Exception as e: if bus == 0 and d == 0: PY print(f" {bus:02x}:{d:02x}.0 {vid:04x}:{did:04x} class={cls:04x}") list 174c:2463 -> \[\] list 174c:2464 -> \[\] list 3801:0001 -> \[(<tinygrad.runtime.support.c.LP\_struct\_libusb\_device object at 0x7fd8ed31c0d0>, 'usb:2-11')\] product: custom ed4e39b7-CLEAN bus0 dev0 fn0 vendor:device = 0x1b21 0x2464 00:00.0 1b21:2464 class=0000 00:01.0 1b21:2464 class=0000 00:02.0 1b21:2464 class=0000 00:03.0 1b21:2464 class=0000 00:04.0 1b21:2464 class=0000 00:05.0 1b21:2464 class=0000 00:06.0 1b21:2464 class=0000 00:07.0 1b21:2464 class=0000 01:00.0 1b21:2464 class=0000 02:00.0 1002:1478 class=0604 03:00.0 1002:1479 class=0604 04:00.0 1002:744c class=0300

The GPU is on the bus. The earlier failure was not “no card.”

```
product: custom ed4e39b7-CLEAN
00:xx  1b21:2464     ASM2464 switch ports
02:00.0  1002:1478   Navi 31 upstream (bridge)
03:00.0  1002:1479   Navi 31 downstream (bridge)
04:00.0  1002:744c   RX 7900 XTX  class 0300  ← display function
```

Handmade firmware also re-enumerated as 3801:0001 (tiny custom ID). That is why lsusb no longer shows 174c:2463 after the flash. Fine.discovery signatures mismatch means tinygrad reached 04:00.0 and then read garbage from the GPU’s discovery table in BAR memory. Usual fix on this path is a controller-side GPU reset before AM init.

```bash
sudo env PATH="$PATH" \
  DEBUG=2 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 /home/master/tinygrad/test/test_tiny.py TestTiny.test_plus
```

If that still asserts, raise debug and keep serial up:

```bash
# terminal 1
python3 /home/master/chestnut/ftdi_debug.py

# terminal 2
sudo env PATH="$PATH" \
  DEBUG=3 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 /home/master/tinygrad/test/test_tiny.py TestTiny.test_plus
```

Link must stay PCIe 78 UP Gen03 x02 CONNECTED through AM discovery. A drop to 00 down while reading BAR reproduces the signature error even though the config-space scan looks perfect.744C is Navi 31 (7900 XTX class). That card is in-scope for DEV=USB+AMD. This is now GPU bring-up, not flashing.

Starting debug output. Press Ctrl-C to exit. ------ \[C 80 06 0004\] \[C 80 06 00FF\] \[C 00 09 0000\] \[\*\*\* SET CONFIG \*\*\*\] \[C 01 0B 0000\]sudo env PATH="$PATH" DEBUG=3 GMMU=0 AM\_RESET=1 DEV=USB+AMD python3 /home/master/tinygrad/test/test\_tiny.py TestTiny.test\_plus \[sudo\] password for master: opened device PYTHON from pid:109826 scheduled 3 kernels in 18.34 ms | CACHE MISS 162fdb63 | 49 uops in cache | /home/master/tinygrad/test/test\_tiny.py:24 loading libc from /lib/x86\_64-linux-gnu/libc.so.6 loading libusb from /lib/x86\_64-linux-gnu/libusb-1.0.so.0 am usb:2-11: product string: 'custom ed4e39b7-CLEAN' loading mesa failed: not found on system loading rt from /lib/x86\_64-linux-gnu/libgcc\_s.so.1 loading m from /lib/x86\_64-linux-gnu/libm.so.6 opened device CPU from pid:109826 F ====================================================================== FAIL: test\_plus (\_\_main\_\_.TestTiny.test\_plus) ---------------------------------------------------------------------- Traceback (most recent call last): File "/home/master/tinygrad/test/test\_tiny.py", line 24, in test\_plus self.assertListEqual(out.tolist(), \[5.0, 7.0, 9.0\]) ^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/tensor.py", line 767, in \_wrapper ret = fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/tensor.py", line 516, in tolist return self.data().tolist() ^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/tensor.py", line 764, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/tensor.py", line 489, in data buf = self.\_buffer() ^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/tensor.py", line 764, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/tensor.py", line 473, in \_buffer return cast(Buffer, x.realize().uop.buffer).ensure\_allocated() ^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/tensor.py", line 764, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/usr/lib/python3.12/contextlib.py", line 81, in inner return func(\*args, \*\*kwds) ^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/tensor.py", line 424, in realize run\_linear(\*Tensor.linear\_with\_vars(\*to\_realize), update\_stats=do\_update\_stats) File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/engine/realize.py", line 317, in run\_linear if not jit: linear = link\_linear(compile\_linear(linear, validate=VALIDATE\_WITH\_CPU, input\_uops=inputs)) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/engine/realize.py", line 308, in compile\_linear linear = lower\_and\_compile(linear) ^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/engine/realize.py", line 265, in lower\_and\_compile if not len(ar:={c: a for c in linear.toposort() if c.op is Ops.CALL and (a:=\_get\_call\_to\_compile(c)) is not None}): return linear ^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/engine/realize.py", line 260, in \_get\_call\_to\_compile return ast, Device\[c.device if isinstance(c.device, str) else c.device\[0\]\].renderer ~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/device.py", line 26, in \_\_getitem\_\_ return self.\_\_get\_canonicalized\_item(ix) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/device.py", line 34, in \_\_get\_canonicalized\_item ret = self.get\_class(ix)(ix) ^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/runtime/ops\_amd.py", line 999, in \_\_init\_\_ self.iface = self.\_select\_iface(device) ^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/device.py", line 385, in \_select\_iface return select\_first\_inited(\[functools.partial(iface, self, self.device\_id) for iface in filtered\], ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/helpers.py", line 146, in select\_first\_inited raise excs\[0\] if len(excs) == 1 else ExceptionGroup(err\_msg + " is available", excs) File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/helpers.py", line 142, in select\_first\_inited x = typ(\*args) ^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/runtime/ops\_amd.py", line 968, in \_\_init\_\_ self.dev\_impl = AMDev(self.pci\_dev) ^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/runtime/support/am/amdev.py", line 162, in \_\_init\_\_ self.\_run\_discovery() File "/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/runtime/support/am/amdev.py", line 313, in \_run\_discovery assert self.bhdr.binary\_signature == am.BINARY\_SIGNATURE and ihdr.signature == am.DISCOVERY\_TABLE\_SIGNATURE, "discovery signatures mismatch" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ AssertionError: discovery signatures mismatch---------------------------------------------------------------------- Ran 1 test in 0.395sFAILED (failures=1)

The GPU is visible; discovery is reading VRAM, not config space. That is why the scan looked fine and test\_plus still dies.AMDev.\_run\_discovery() does:
1. MMIO read mmRCC\_CONFIG\_MEMSIZE (BAR5, reg 0xde3) → VRAM size
2. Read 10KB at vram\_size - 64KiB from BAR0
3. Check magic binary\_signature / DISCOVERY\_TABLE\_SIGNATURE
Garbage or 0xffffffff there → exactly discovery signatures mismatch. AM\_RESET never runs; it is after discovery. The serial SET CONFIG lines are only USB enum, not a GPU init.You are also not running the git tree you think you are. The traceback is:/home/master/chestnut/.venv/lib/python3.12/site-packages/tinygrad/...Force the checkout:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  DEBUG=2 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 /home/master/tinygrad/test/test_tiny.py TestTiny.test_plus
```

Dump what discovery actually sees:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import AMDDevice
from tinygrad.runtime.support.am import am
print("BINARY", hex(am.BINARY_SIGNATURE), "DISC", hex(am.DISCOVERY_TABLE_SIGNATURE))

# construct only PCI + bars, not full AMDev
from tinygrad.runtime.support.hcq import PCIDevice
# open via USB AMD iface
from tinygrad.runtime.ops_amd import PCIInterface
iface = PCIInterface.__new__(PCIInterface)
# easier: use Device path until AMDev
import traceback
try:
    from tinygrad.device import Device
    d = Device["AMD"]
    print("opened", d)
except Exception as e:
    traceback.print_exc()
PY
```

More useful, dump memsize + first discovery dwords without going through the assert. Put this next to the USB controller you already have working:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.support.usb import USB3, CustomASM24Controller
from tinygrad.runtime.ops_amd import USBIface  # may be named USBInterface
print("imports ok", USB3, CustomASM24Controller)
import tinygrad.runtime.ops_amd as m
print([n for n in dir(m) if "USB" in n or "PCI" in n or "Iface" in n or "Interface" in n])
PY
```

Paste that name list if the next bit fails. Expected next step is print vram\_size and 16 bytes at the table.Meanwhile, two high-probability causes on Navi 31 over this bridge:
1. BAR5/BAR0 not mapped through the handmade FW (config scan works; memory TLPs do not). Stock image is the control:

```bash
cd /home/master/chestnut
sudo env PATH="$PATH" python3 ftdi_debug.py -bn
sleep 2
sudo env PATH="$PATH" python3 flash.py fw_tinygrad.bin
sudo env PATH="$PATH" python3 ftdi_debug.py -rn
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  DEBUG=2 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 /home/master/tinygrad/test/test_tiny.py TestTiny.test_plus
```

2. ASPM L1 — amdev.py comments that L1 across retimers makes reads 0xffffffff. Discovery then fails. The USB AMD path should clear ASPM on the endpoint; if handmade FW does not forward those config writes correctly, you get this.
744c + upstream/downstream ports are correct for a 7900 XTX. Do not chase flashing or USBDEV anymore. Next data that matters is vram\_size and the first 16 bytes of that discovery window (or stock-FW test\_plus).

Traceback (most recent call last): File "\<stdin>", line 2, in \<module> ImportError: cannot import name 'am' from 'tinygrad.runtime.support.am' (/home/master/tinygrad/tinygrad/runtime/support/am/\_\_init\_\_.py)

am is a submodule, not re-exported. Use the file directly, or skip it and dump raw MMIO.

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.support.am import amdev
import pkgutil, tinygrad.runtime.support.am as p
print("am package files:", [m.name for m in pkgutil.iter_modules(p.__path__)])
print("BINARY" in dir(amdev), [x for x in dir(amdev) if "SIGN" in x.upper() or "DISC" in x.upper()])
PY
```

That only names things. What you actually need is memsize + the 16-byte header. Do not import Device\["AMD"\] — that hits the same assert.More important than the import: run the test against the git tree, then try stock firmware as a control.

```bash
# 1) git tinygrad, not the venv copy
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  DEBUG=2 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 /home/master/tinygrad/test/test_tiny.py TestTiny.test_plus

# 2) stock FW control
cd /home/master/chestnut
sudo env PATH="$PATH" python3 ftdi_debug.py -bn && sleep 2
sudo env PATH="$PATH" python3 flash.py fw_tinygrad.bin
sudo env PATH="$PATH" python3 ftdi_debug.py -rn
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  DEBUG=2 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 /home/master/tinygrad/test/test_tiny.py TestTiny.test_plus
```

If stock fw\_tinygrad.bin passes test\_plus and handmade fails, the bug is BAR/memory TLP handling in handmade FW (config scan already proved the GPU is there). If stock also mismatches, it is ASPM/BAR mapping/host tinygrad, not your flash.Ignore the from tinygrad.runtime.support.am import am snippet; it cannot work on current tinygrad.

sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.support.usb import USB3, CustomASM24Controller from tinygrad.runtime.ops\_amd import USBIface # may be named USBInterface print("imports ok", USB3, CustomASM24Controller) import tinygrad.runtime.ops\_amd as m print(\[n for n in dir(m) if "USB" in n or "PCI" in n or "Iface" in n or "Interface" in n\]) PY imports ok \<class 'tinygrad.runtime.support.usb.USB3'> \<class 'tinygrad.runtime.support.usb.CustomASM24Controller'> \['AMD\_USB\_POLL\_US', 'FileIOInterface', 'KFDIface', 'MMIOInterface', 'PCIAllocationMeta', 'PCIIface', 'PCIIfaceBase', 'USB3', 'USBIface', 'USBPCIDevice'\] (.venv) master@lab:~/chestnut$ (.venv) master@lab:~/chestnut$ sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.support.am import amdev import pkgutil, tinygrad.runtime.support.am as p print("am package files:", \[m.name for m in pkgutil.iter\_modules(p.\_\_path\_\_)\]) print("BINARY" in dir(amdev), \[x for x in dir(amdev) if "SIGN" in x.upper() or "DISC" in x.upper()\]) PY am package files: \['amdev', 'ip'\] False \[\] (.venv) master@lab:~/chestnut$ sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \\ DEBUG=2 GMMU=0 AM\_RESET=1 DEV=USB+AMD \\ python3 /home/master/tinygrad/test/test\_tiny.py TestTiny.test\_plus opened device PYTHON from pid:109867 scheduled 3 kernels in 17.58 ms | CACHE MISS 0e870a0c | 49 uops in cache | /home/master/tinygrad/test/test\_tiny.py:24 am usb:2-11: product string: 'custom ed4e39b7-CLEAN' opened device CPU from pid:109867 F ====================================================================== FAIL: test\_plus (\_\_main\_\_.TestTiny.test\_plus) ---------------------------------------------------------------------- Traceback (most recent call last): File "/home/master/tinygrad/test/test\_tiny.py", line 24, in test\_plus self.assertListEqual(out.tolist(), \[5.0, 7.0, 9.0\]) ^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 769, in \_wrapper ret = fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 512, in tolist return self.data().tolist() ^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 766, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 485, in data buf = self.\_buffer() ^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 766, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 469, in \_buffer return cast(Buffer, x.realize().uop.buffer).ensure\_allocated() ^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 766, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/usr/lib/python3.12/contextlib.py", line 81, in inner return func(\*args, \*\*kwds) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 415, in realize run\_linear(\*Tensor.linear\_with\_vars(\*to\_realize), update\_stats=do\_update\_stats) File "/home/master/tinygrad/tinygrad/engine/realize.py", line 291, in run\_linear if not jit: linear = link\_linear(compile\_linear(linear, validate=VALIDATE\_WITH\_CPU, input\_uops=inputs), input\_uops=inputs) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/engine/realize.py", line 282, in compile\_linear linear = lower\_and\_compile(linear) ^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/engine/realize.py", line 243, in lower\_and\_compile if not len(ar:={c: a for c in linear.toposort() if c.op is Ops.CALL and (a:=\_get\_call\_to\_compile(c)) is not None}): return linear ^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/engine/realize.py", line 238, in \_get\_call\_to\_compile return ast, Device\[c.device if isinstance(c.device, str) else c.device\[0\]\].renderer ~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/device.py", line 26, in \_\_getitem\_\_ return self.\_\_get\_canonicalized\_item(ix) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/device.py", line 34, in \_\_get\_canonicalized\_item ret = self.get\_class(ix)(ix) ^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/ops\_amd.py", line 1020, in \_\_init\_\_ self.iface = self.\_select\_iface(device) ^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/device.py", line 382, in \_select\_iface return select\_first\_inited(\[functools.partial(iface, self, self.device\_id) for iface in filtered\], ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/helpers.py", line 146, in select\_first\_inited raise excs\[0\] if len(excs) == 1 else ExceptionGroup(err\_msg, excs) File "/home/master/tinygrad/tinygrad/helpers.py", line 142, in select\_first\_inited x = typ(\*args) ^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/ops\_amd.py", line 989, in \_\_init\_\_ self.dev\_impl = AMDev(self.pci\_dev) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/am/amdev.py", line 169, in \_\_init\_\_ self.\_run\_discovery() File "/home/master/tinygrad/tinygrad/runtime/support/am/amdev.py", line 363, in \_run\_discovery assert self.bhdr.binary\_signature == am.BINARY\_SIGNATURE and ihdr.signature == am.DISCOVERY\_TABLE\_SIGNATURE, "discovery signatures mismatch" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ AssertionError: discovery signatures mismatch---------------------------------------------------------------------- Ran 1 test in 0.112sFAILED (failures=1)

Git-tree tinygrad is in use now (/home/master/tinygrad/...). Same assert. USBIface exists and only looks for 3801:0001 / ADD1:0001 — you already have 3801:0001, so device selection is fine.Dump BAR5 memsize and the discovery header without constructing AMDev:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

devs = USB3.list_devices(0x3801, 0x0001) + USB3.list_devices(0xADD1, 0x0001)
print("devs", devs)
assert devs, "no USB AMD controller"

pci = USBPCIDevice("AM", *devs[0])
print("pci", pci)

mmio = pci.map_bar(5, fmt="I")
print("BAR5 bytes", mmio.nbytes)
memsize = mmio[0xDE3]
print("mmRCC_CONFIG_MEMSIZE raw", hex(memsize), "=> GiB", memsize)

vram = pci.map_bar(0)
print("BAR0 bytes", vram.nbytes)
off = (memsize << 20) - (64 << 10)
print("discovery off", hex(off))
if 0 <= off < vram.nbytes:
    hdr = bytes(vram.view(off, 16)[:])
    print("discovery[0:16]", hdr.hex())
else:
    print("offset not in BAR0 (small BAR or memsize garbage)")
    hdr = bytes(vram.view(0, 16)[:])
    print("BAR0[0:16]", hdr.hex())
PY
```

How to read it:

| memsize | discovery\[0:16\] | meaning |
| --- | --- | --- |
| 0 / 0xffffffff / huge | anything | BAR5 MMIO not working |
| sane (8–24 for a 7900 XTX) | ffffffff / zeros | BAR0 VRAM window wrong / ASPM junk |
| sane | starts with known AMD discovery magic | table is there; assert is offset/struct |

Known good first dword is AMD’s binary header magic (tinygrad’s BINARY\_SIGNATURE). You do not need that constant to compare: ffffffff vs a stable non-ff pattern is enough.Then A/B the firmware. If stock passes and handmade fails, handmade is dropping memory TLPs (config already works).

```bash
cd /home/master/chestnut
sudo env PATH="$PATH" python3 ftdi_debug.py -bn && sleep 2
sudo env PATH="$PATH" python3 flash.py fw_tinygrad.bin
sudo env PATH="$PATH" python3 ftdi_debug.py -rn
```

Paste the dump’s four printed lines (memsize, BAR sizes, hex header). That is the next useful signal.

devs \[(<tinygrad.runtime.support.c.LP\_struct\_libusb\_device object at 0x77876d08b5d0>, 'usb:2-11')\] pci <tinygrad.runtime.support.system.USBPCIDevice object at 0x77876eb02b70> BAR5 bytes 1048576 mmRCC\_CONFIG\_MEMSIZE raw 0x0 => GiB 0 BAR0 bytes 1073741824 discovery off -0x10000 offset not in BAR0 (small BAR or memsize garbage) BAR0\[0:16\] ffffffffffffffffffffffffffffffff

That dump is enough.

```
BAR5 = 1 MiB mapped          ← aperture exists
mmRCC_CONFIG_MEMSIZE = 0     ← GPU MMIO read is dead
BAR0 = 1 GiB                 ← small BAR (7900 XTX is 24 GiB, so this is the 1 GiB window)
BAR0[0:16] = ff ff ff ...    ← memory read not from real VRAM
discovery off = -0x10000     ← (0 << 20) - 64KiB, so the table address is nonsense
```

Config space still works (1002:744c). Memory-mapped BAR reads do not. Discovery therefore cannot work, AM\_RESET never runs, test\_plus cannot pass.Typical causes, in order:
1. Handmade firmware forwards CFG TLPs, not MEM TLPs (or MEM completions are wrong).
2. GPU PCI\_COMMAND Memory Space Enable never sticks.
3. BAR addresses programmed in config are not the addresses the bridge decodes.
4. Link in L1 / completions come back as 0xff.
A/B with stock firmware:

```bash
cd /home/master/chestnut
sudo env PATH="$PATH" python3 ftdi_debug.py -bn
sleep 2
sudo env PATH="$PATH" python3 flash.py fw_tinygrad.bin
sudo env PATH="$PATH" python3 ftdi_debug.py -rn
```

Re-run the same dump. If stock shows memsize around 0x18 (24 GiB) and a non-ff discovery header, handmade is the bug. If stock is also memsize=0 / ff, it is BAR setup or ASPM on the host path, not the image you just built.Do not spend more time on test\_plus until mmRCC\_CONFIG\_MEMSIZE is a plausible GiB count.

(.venv) master@lab:~/chestnut$ cd /home/master/chestnut sudo env PATH="$PATH" python3 ftdi\_debug.py -bn sleep 2 sudo env PATH="$PATH" python3 flash.py fw\_tinygrad.bin sudo env PATH="$PATH" python3 ftdi\_debug.py -rn Device reset complete. done, you can disconnect the controller! Device reset complete.t2:\[\*\*\* SET CONFIG \*\*\*\] \[C 01 0B 0000\] EFrdvreuvr|Hvreuvreuvreuvreuvreuvreuvreuvreuvreuvrgvrkuv|bT4|F+hreuvreuv+h+h+2+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+Q+QT4+ZxAY|bT4+ZxAY|bT2+ZAY|bT3+UxrbvAYFrdvreuvr|Hvreuvreuvreuvreuvreuvrgvrgvrmvvrbvrbv|bT'+ZwVAY|bT'+ZwVAY|bT(+ZwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVAY|bT(+ZwVwVwVwVwVwVwVwVwVwVwVwVwVwVwVwV%\[flp=00\]\[InternalPD\_StateInit\]\[CC\_state=00\]\[Drive\_HardRst\]\[InternalPD\_StateInit\]\[1 sec time out\] \[RstRxpll...\]\[Done\] \[CDRV ok\]

Stock image is on the chip. That console is the vendor firmware (PD / Drive\_HardRst / RstRxpll), not handmade \[PCIe 78 UP\].VID/PID may have switched back to 174c:2463. Re-run both probes:

```bash
lsusb | grep -iE '174c|3801|add1|asmedia'

sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
devs = (USB3.list_devices(0x3801, 0x0001)
      + USB3.list_devices(0xADD1, 0x0001)
      + USB3.list_devices(0x174C, 0x2463)
      + USB3.list_devices(0x174C, 0x2464))
print("devs", [(hex(0), d[1]) for d in []])  # placeholder
print("list", [x[1] for x in devs])
assert devs, "controller not visible"
pci = USBPCIDevice("AM", *devs[0])
mmio = pci.map_bar(5, fmt="I")
print("BAR5", mmio.nbytes, "memsize", hex(mmio[0xDE3]), "GiB", mmio[0xDE3])
vram = pci.map_bar(0)
print("BAR0", vram.nbytes, "head", bytes(vram.view(0, 16)[:]).hex())
PY
```

Then:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  DEBUG=2 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 /home/master/tinygrad/test/test_tiny.py TestTiny.test_plus
```

Compare to handmade:
- stock memsize non-zero and test\_plus OK → handmade MEM TLP path is broken.
- stock still memsize=0 / ff → not the image; BAR enable / ASPM / host USB path.
USBIface only auto-picks 3801:0001 and ADD1:0001. If stock stays 174c:2463, DEV=USB+AMD will not see it even if the dump does. In that case the dump is the result that matters, or set USBDEV=174C:2463 if your tinygrad build honors it.

lsusb | grep -iE '174c|3801|add1|asmedia'sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.ops\_amd import USB3, USBPCIDevice devs = (USB3.list\_devices(0x3801, 0x0001) + USB3.list\_devices(0xADD1, 0x0001) + USB3.list\_devices(0x174C, 0x2463) + USB3.list\_devices(0x174C, 0x2464)) print("devs", \[(hex(0), d\[1\]) for d in \[\]\]) # placeholder print("list", \[x\[1\] for x in devs\]) assert devs, "controller not visible" pci = USBPCIDevice("AM", \*devs\[0\]) mmio = pci.map\_bar(5, fmt="I") print("BAR5", mmio.nbytes, "memsize", hex(mmio\[0xDE3\]), "GiB", mmio\[0xDE3\]) vram = pci.map\_bar(0) print("BAR0", vram.nbytes, "head", bytes(vram.view(0, 16)\[:\]).hex()) PY Bus 002 Device 013: ID add1:0001 tiny USB 3.2 PCIe TinyEnclosure devs \[\] list \['usb:2-13'\] Traceback (most recent call last): File "\<stdin>", line 9, in \<module> File "/home/master/tinygrad/tinygrad/runtime/support/system.py", line 230, in \_\_init\_\_ usb = USB3(dev) ^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 57, in \_\_init\_\_ assert self.product.startswith("custom") or self.product.startswith("AS2462") ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ AssertionError sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \\ DEBUG=2 GMMU=0 AM\_RESET=1 DEV=USB+AMD \\ python3 /home/master/tinygrad/test/test\_tiny.py TestTiny.test\_plus opened device PYTHON from pid:109981 scheduled 3 kernels in 17.69 ms | CACHE MISS 0e870a0c | 49 uops in cache | /home/master/tinygrad/test/test\_tiny.py:24 F ====================================================================== FAIL: test\_plus (\_\_main\_\_.TestTiny.test\_plus) ---------------------------------------------------------------------- Traceback (most recent call last): File "/home/master/tinygrad/test/test\_tiny.py", line 24, in test\_plus self.assertListEqual(out.tolist(), \[5.0, 7.0, 9.0\]) ^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 769, in \_wrapper ret = fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 512, in tolist return self.data().tolist() ^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 766, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 485, in data buf = self.\_buffer() ^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 766, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 469, in \_buffer return cast(Buffer, x.realize().uop.buffer).ensure\_allocated() ^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 766, in \_wrapper if TRACEMETA < 1 or \_METADATA.get() is not None: return fn(\*args, \*\*kwargs) ^^^^^^^^^^^^^^^^^^^ File "/usr/lib/python3.12/contextlib.py", line 81, in inner return func(\*args, \*\*kwds) ^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/tensor.py", line 415, in realize run\_linear(\*Tensor.linear\_with\_vars(\*to\_realize), update\_stats=do\_update\_stats) File "/home/master/tinygrad/tinygrad/engine/realize.py", line 291, in run\_linear if not jit: linear = link\_linear(compile\_linear(linear, validate=VALIDATE\_WITH\_CPU, input\_uops=inputs), input\_uops=inputs) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/engine/realize.py", line 282, in compile\_linear linear = lower\_and\_compile(linear) ^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/engine/realize.py", line 243, in lower\_and\_compile if not len(ar:={c: a for c in linear.toposort() if c.op is Ops.CALL and (a:=\_get\_call\_to\_compile(c)) is not None}): return linear ^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/engine/realize.py", line 238, in \_get\_call\_to\_compile return ast, Device\[c.device if isinstance(c.device, str) else c.device\[0\]\].renderer ~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/device.py", line 26, in \_\_getitem\_\_ return self.\_\_get\_canonicalized\_item(ix) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/device.py", line 34, in \_\_get\_canonicalized\_item ret = self.get\_class(ix)(ix) ^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/ops\_amd.py", line 1020, in \_\_init\_\_ self.iface = self.\_select\_iface(device) ^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/device.py", line 382, in \_select\_iface return select\_first\_inited(\[functools.partial(iface, self, self.device\_id) for iface in filtered\], ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/helpers.py", line 146, in select\_first\_inited raise excs\[0\] if len(excs) == 1 else ExceptionGroup(err\_msg, excs) File "/home/master/tinygrad/tinygrad/helpers.py", line 142, in select\_first\_inited x = typ(\*args) ^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/ops\_amd.py", line 988, in \_\_init\_\_ self.dev, self.pci\_dev, self.vram\_bar, self.count = dev, USBPCIDevice("AM", \*visible\[dev\_id\]), 0, len(visible) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/system.py", line 230, in \_\_init\_\_ usb = USB3(dev) ^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 57, in \_\_init\_\_ assert self.product.startswith("custom") or self.product.startswith("AS2462") ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ AssertionError---------------------------------------------------------------------- Ran 1 test in 0.069sFAILED (failures=1)

Stock came up as add1:0001 / tiny USB 3.2 PCIe TinyEnclosure. tinygrad’s USB3 then refuses it:

```python
assert product.startswith("custom") or product.startswith("AS2462")
```

That is why both the dump and test\_plus died before any BAR read. It is not another discovery failure.Print the string, then open with the assert patched only in this process:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.support import usb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

# see what stock actually calls itself
for vid, pid in [(0xADD1,0x0001),(0x3801,0x0001),(0x174C,0x2463),(0x174C,0x2464)]:
    print(hex(vid), hex(pid), USB3.list_devices(vid, pid))

# bypass product-name gate for this dump only
usb.USB3.__init__.__globals__  # keep module loaded
_orig = usb.USB3.__init__
def _init(self, dev, *a, **k):
    import ctypes
    from tinygrad.runtime.autogen import libusb
    from tinygrad.runtime.support import c
    from tinygrad.runtime.support.usb import checked, alloc_cbuffer, itertools
    # fall through to original after relaxing assert
    import tinygrad.runtime.support.usb as u
    u.USB3.__init__ = _orig
    # monkeypatch assert by wrapping product
    real = _orig
    def wrapped(self, dev, *a, **k):
        try:
            return real(self, dev, *a, **k)
        except AssertionError:
            # reopen: patch startswith check
            raise
    raise SystemExit("use the second snippet")
PY
```

Simpler: edit the one line, dump, restore.

```bash
# show the string
python3 -c "import pathlib; p=pathlib.Path('/home/master/tinygrad/tinygrad/runtime/support/usb.py'); print(p)"

sudo sed -n '52,59p' /home/master/tinygrad/tinygrad/runtime/support/usb.py
```

Temporarily change line 57 to:

```python
assert True or self.product.startswith("custom") or self.product.startswith("AS2462")
print("product:", self.product)
```

Then:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
devs = USB3.list_devices(0xADD1, 0x0001) + USB3.list_devices(0x3801, 0x0001)
print("devs", [d[1] for d in devs])
pci = USBPCIDevice("AM", *devs[0])
mmio = pci.map_bar(5, fmt="I")
print("BAR5", mmio.nbytes, "memsize", hex(mmio[0xDE3]), "GiB", mmio[0xDE3])
vram = pci.map_bar(0)
print("BAR0", vram.nbytes, "head", bytes(vram.view(0, 16)[:]).hex())
PY
```

If stock memsize is still 0 / BAR0 still ff, the problem is not handmade vs stock. If stock memsize is ~\`0x18\`, handmade’s MEM path is the regression.Flash handmade again when you want the custom … product string back (make -C handmade nflash). That image is the one USB3 accepts without a patch.

0xadd1 0x1 \[(<tinygrad.runtime.support.c.LP\_struct\_libusb\_device object at 0x7cd39458c0d0>, 'usb:2-13')\] 0x3801 0x1 \[\] 0x174c 0x2463 \[\] 0x174c 0x2464 \[\] sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.ops\_amd import USB3, USBPCIDevice devs = USB3.list\_devices(0xADD1, 0x0001) + USB3.list\_devices(0x3801, 0x0001) print("devs", \[d\[1\] for d in devs\]) pci = USBPCIDevice("AM", \*devs\[0\]) mmio = pci.map\_bar(5, fmt="I") print("BAR5", mmio.nbytes, "memsize", hex(mmio\[0xDE3\]), "GiB", mmio\[0xDE3\]) vram = pci.map\_bar(0) print("BAR0", vram.nbytes, "head", bytes(vram.view(0, 16)\[:\]).hex()) PY devs \['usb:2-13'\] product: USB 3.2 PCIe TinyEnclosure Traceback (most recent call last): File "\<stdin>", line 4, in \<module> File "/home/master/tinygrad/tinygrad/runtime/support/system.py", line 232, in \_\_init\_\_ self.usb: CustomASM24Controller = CustomASM24Controller(usb) ^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 142, in \_\_init\_\_ ltssm = self.read(0xB450, 1)\[0\] ^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 204, in read result += self.usb.control\_read(0xE4, chunk, value=base\_addr + off) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 78, in control\_read assert checked(libusb.libusb\_control\_transfer)(self.handle, 0xC0, request, value, index, self.\_ctrl\_buf, length, timeout) == length ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 16, in wrapper if (rc:=fn(\*args)) < 0: raise RuntimeError(f"{msg or fn.\_\_name\_\_}: {ctypes.string\_at(libusb.libusb\_strerror(rc)).decode()}") ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuntimeError: libusb\_control\_transfer: Pipe error

That stock image is the wrong control for DEV=USB+AMD.fw\_tinygrad.bin enumerates as add1:0001 / USB 3.2 PCIe TinyEnclosure. tinygrad then uses custom vendor commands (0xE4 XDATA, 0xF0 TLP, 0xF2 SRAM). Stock does not implement those, so read(0xB450) dies with Pipe error. You never got a stock memsize reading.The path that actually speaks this protocol is handmade:
- USB ID 3801:0001
- product custom ed4e39b7-CLEAN
- config scan saw 1002:744c
- BAR5 memsize = 0, BAR0 head ff
Put that image back:

```bash
cd /home/master/chestnut
sudo env PATH="$PATH" make -C handmade nflash
```

Revert the assert True patch in usb.py if you still want the product-name check.test\_plus will keep failing until mmRCC\_CONFIG\_MEMSIZE is non-zero. That is a memory TLP / BAR decode bug in handmade (or BAR programming in USBPCIDevice), not flashing and not the stock ROM.Useful next checks on handmade only:
1. After USBPCIDevice maps bars, read GPU PCI\_COMMAND at 04:00.0 — bit 1 (memory space) and bit 2 (bus master) must be set.
2. Read BAR0/BAR5 from config (0x10 / 0x24) and confirm they match what the USB mapper programmed.
3. Read MMIO at a known-alive register besides 0xde3 (e.g. a vendor ID mirror in config is not enough). If every BAR5 dword is 0 or 0xffffffff, MEM completions are broken.
4. Watch FTDI during the dump: link must stay PCIe 78 UP.
Config works; MEM does not. That is the remaining problem.

ok, i have run the nflash

Handmade is back. Confirm it, then dump command/BARs/memsize in one shot.

```bash
lsusb | grep -iE '3801|174c|add1'

sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.support.usb import USB3, CustomASM24Controller
from tinygrad.runtime.ops_amd import USBPCIDevice

devs = USB3.list_devices(0x3801, 0x0001)
print("devs", [d[1] for d in devs])
assert devs, "handmade not enumerated as 3801:0001"

usb = USB3(devs[0][0])
print("product", usb.product)
ctl = CustomASM24Controller(usb)

def cfg(bus, d, fn, off, size=4, value=None):
    return ctl.pcie_cfg_req(off, bus=bus, dev=d, fn=fn, size=size, value=value)

print("04:00.0 id", hex(cfg(4,0,0,0,2)), hex(cfg(4,0,0,2,2)))
cmd = cfg(4,0,0,4,2)
print("04:00.0 COMMAND", hex(cmd),
      "mem" if cmd & 2 else "NOMEM",
      "master" if cmd & 4 else "NOMASTER")
print("BAR0 cfg", hex(cfg(4,0,0,0x10,4)))
print("BAR5 cfg", hex(cfg(4,0,0,0x24,4)))

pci = USBPCIDevice("AM", *devs[0])
mmio = pci.map_bar(5, fmt="I")
print("BAR5 map", mmio.nbytes, "memsize", hex(mmio[0xDE3]), "GiB", mmio[0xDE3])
print("BAR5[0:8]", [hex(mmio[i]) for i in range(8)])
vram = pci.map_bar(0)
print("BAR0 map", vram.nbytes, "head", bytes(vram.view(0, 16)[:]).hex())
PY
```

- product custom …
- 04:00.0 still 1002:744c
- COMMAND includes mem and preferably master
- memsize not 0 / 0xffffffff
If COMMAND lacks mem after map\_bar, the mapper’s config writes are not sticking. If mem is set and memsize is still 0, handmade is not completing MEM reads. Paste those lines.

lsusb | grep -iE '3801|174c|add1'sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.support.usb import USB3, CustomASM24Controller from tinygrad.runtime.ops\_amd import USBPCIDevicedevs = USB3.list\_devices(0x3801, 0x0001) print("devs", \[d\[1\] for d in devs\]) assert devs, "handmade not enumerated as 3801:0001"usb = USB3(devs\[0\]\[0\]) print("product", usb.product) ctl = CustomASM24Controller(usb)def cfg(bus, d, fn, off, size=4, value=None): return ctl.pcie\_cfg\_req(off, bus=bus, dev=d, fn=fn, size=size, value=value)print("04:00.0 id", hex(cfg(4,0,0,0,2)), hex(cfg(4,0,0,2,2))) cmd = cfg(4,0,0,4,2) print("04:00.0 COMMAND", hex(cmd), "mem" if cmd & 2 else "NOMEM", "master" if cmd & 4 else "NOMASTER") print("BAR0 cfg", hex(cfg(4,0,0,0x10,4))) print("BAR5 cfg", hex(cfg(4,0,0,0x24,4)))pci = USBPCIDevice("AM", \*devs\[0\]) mmio = pci.map\_bar(5, fmt="I") print("BAR5 map", mmio.nbytes, "memsize", hex(mmio\[0xDE3\]), "GiB", mmio\[0xDE3\]) print("BAR5\[0:8\]", \[hex(mmio\[i\]) for i in range(8)\]) vram = pci.map\_bar(0) print("BAR0 map", vram.nbytes, "head", bytes(vram.view(0, 16)\[:\]).hex()) PY Bus 002 Device 015: ID 3801:0001 tiny custom ed4e39b7-CLEAN devs \['usb:2-15'\] product: custom ed4e39b7-CLEAN product custom ed4e39b7-CLEAN Traceback (most recent call last): File "\<stdin>", line 15, in \<module> File "\<stdin>", line 13, in cfg File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 184, in pcie\_cfg\_req return self.pcie\_request(fmt\_type, address, value, size) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 176, in pcie\_request raise RuntimeError(f"TLP completion status: {status\_map.get(cpl\_status, f'Reserved (0b{cpl\_status:03b})')}") RuntimeError: TLP completion status: Unsupported Request: 0x4000000

Handmade is up (3801:0001, custom ed4e39b7-CLEAN). Bus 04 is not there yet. After a reset the ASM switch ports exist; secondary buses are not numbered until something enumerates them. 0x4000000 is config for bus 4, and the completer correctly returns Unsupported Request.Do not assume 04:00.0. Scan first, or let USBPCIDevice enumerate (it opens USB itself — do not hold a second USB3 on the same device).

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
from tinygrad.runtime.support.usb import CustomASM24Controller

devs = USB3.list_devices(0x3801, 0x0001)
print("devs", [d[1] for d in devs])
usb = USB3(devs[0][0])
print("product", usb.product)
ctl = CustomASM24Controller(usb)

def cfg(bus, d, fn, off, size=2):
    return ctl.pcie_cfg_req(off, bus=bus, dev=d, fn=fn, size=size)

print("scan:")
for bus in range(0, 8):
    for d in range(0, 8):
        try:
            vid = cfg(bus, d, 0, 0, 2)
        except Exception:
            continue
        if vid in (0, 0xFFFF, None):
            continue
        did = cfg(bus, d, 0, 2, 2)
        print(f"  {bus:02x}:{d:02x}.0 {vid:04x}:{did:04x}")
PY
```

Then a separate process for BARs (so the first handle is closed):

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
devs = USB3.list_devices(0x3801, 0x0001)
pci = USBPCIDevice("AM", *devs[0])
mmio = pci.map_bar(5, fmt="I")
print("BAR5", mmio.nbytes, "memsize", hex(mmio[0xDE3]), "GiB", mmio[0xDE3])
print("BAR5[0:8]", [hex(mmio[i]) for i in range(8)])
vram = pci.map_bar(0)
print("BAR0", vram.nbytes, "head", bytes(vram.view(0, 16)[:]).hex())
PY
```

If the scan only shows 1b21:2464 on bus 0 and no 1002, the GPU link is down after this boot. Check FTDI for PCIe 78 UP while the scan runs. If 1002:744c shows up on some bus N, use that bus in COMMAND/BAR reads, not hardcoded 4.

devs \['usb:2-15'\] product: custom ed4e39b7-CLEAN product custom ed4e39b7-CLEAN scan: 00:00.0 1b21:2464 00:01.0 1b21:2464 00:02.0 1b21:2464 00:03.0 1b21:2464 00:04.0 1b21:2464 00:05.0 1b21:2464 00:06.0 1b21:2464 00:07.0 1b21:2464product: custom ed4e39b7-CLEAN BAR5 1048576 memsize 0x0 GiB 0 BAR5\[0:8\] \['0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0xff00ff00'\] BAR0 1073741824 head ffffffffffffffffffffffffffffffff

The GPU is off the fabric this boot. That is why memsize is still 0.

```
scan: only 00:00–07  1b21:2464   (ASM switch ports)
no 1002:1478 / 1479 / 744c
BAR5 all 0, BAR0 all ff         ← no endpoint behind those windows
```

Earlier you had 02:00.0 1002:1478 … 04:00.0 1002:744c with the same handmade image. After this nflash the link did not come up, so USBPCIDevice mapped empty BARs.Check the link while the dock is powered and the GPU’s aux power is seated:

```bash
python3 /home/master/chestnut/ftdi_debug.py
```

You want PCIe 78 UP Gen03 x02 CONNECTED and for it to stay there. PCIe 00 down = no GPU on any bus.Then, with the console still up:

```bash
# hard reset the ASM + retrain
sudo env PATH="$PATH" python3 /home/master/chestnut/ftdi_debug.py -rn
sleep 3
# scan again (same scan script as before)
```

If serial stays down:
- Chestnut 12V / ATX adapter on, GPU 8-pin or 12VHPWR clicked
- reseat the GPU in the dock
- power-cycle the dock (switch), not only -rn
test\_plus cannot work until 1002:744c is back in the scan. BAR dumps in that state are meaningless.

% \[BOOT\] \[PCIe 00 down Gen01 x01\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[PCIe 58 UP Gen03 x02\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe 00 down Gen01 x01\] \[PCIe timeout\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[C 00 05 0000\] \[A\] \[C 80 06 0008\] \[C 00 31 0000\] \[C 80 06 0012\] \[C 80 06 0005\] \[C 80 06 0016\] \[C 80 06 0009\] \[C 80 06 0079\] \[C 80 06 00FF\] \[C 80 06 00FF\] \[C 80 06 00FF\] \[C 80 06 00FF\] \[C 00 09 0000\] \[\*\*\* SET CONFIG \*\*\*\]sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.ops\_amd import USB3, USBPCIDevice from tinygrad.runtime.support.usb import CustomASM24Controllerdevs = USB3.list\_devices(0x3801, 0x0001) print("devs", \[d\[1\] for d in devs\]) usb = USB3(devs\[0\]\[0\]) print("product", usb.product) ctl = CustomASM24Controller(usb)def cfg(bus, d, fn, off, size=2): return ctl.pcie\_cfg\_req(off, bus=bus, dev=d, fn=fn, size=size)print("scan:") for bus in range(0, 8): for d in range(0, 8): try: vid = cfg(bus, d, 0, 0, 2) except Exception: continue if vid in (0, 0xFFFF, None): continue did = cfg(bus, d, 0, 2, 2) print(f" {bus:02x}:{d:02x}.0 {vid:04x}:{did:04x}") PY devs \['usb:2-22'\] product: custom ed4e39b7-CLEAN product custom ed4e39b7-CLEAN scan: 00:00.0 1b21:2464 00:01.0 1b21:2464 00:02.0 1b21:2464 00:03.0 1b21:2464 00:04.0 1b21:2464 00:05.0 1b21:2464 00:06.0 1b21:2464 00:07.0 1b21:2464 (.venv) master@lab:~/chestnut$ (.venv) master@lab:~/chestnut$ (.venv) master@lab:~/chestnut$ sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.ops\_amd import USB3, USBPCIDevice devs = USB3.list\_devices(0x3801, 0x0001) pci = USBPCIDevice("AM", \*devs\[0\]) mmio = pci.map\_bar(5, fmt="I") print("BAR5", mmio.nbytes, "memsize", hex(mmio\[0xDE3\]), "GiB", mmio\[0xDE3\]) print("BAR5\[0:8\]", \[hex(mmio\[i\]) for i in range(8)\]) vram = pci.map\_bar(0) print("BAR0", vram.nbytes, "head", bytes(vram.view(0, 16)\[:\]).hex()) PY product: custom ed4e39b7-CLEAN BAR5 1048576 memsize 0x0 GiB 0 BAR5\[0:8\] \['0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0xff00ff00'\] BAR0 1073741824 head ffffffffffffffffffffffffffffffff

The link is dying before the GPU can be enumerated.

```
[PCIe 78 UP Gen03 x02 CONNECTED]
[PCIe 58 UP Gen03 x02]
[PCIe 00 down ...]     × many
[PCIe timeout]
[LINK EVENT 08 link=02]
[*** SET CONFIG ***]   ← USB host only; PCIe already dead
```

Scan then only sees ASM ports. BAR reads of 0 / ff are the empty switch, not the 7900 XTX.You already had one good window: same firmware, link held, 04:00.0 1002:744c. This boot does not hold.Do this while watching serial:
1. Power-cycle the dock (switch), GPU cables seated, wait until you see CONNECTED and it stops printing down.
2. The moment it stays 78 UP for a few seconds, run only the bus scan (not USBPCIDevice yet).
3. If it drops again within a second of SET CONFIG, host USB config is interacting with a flaky link — still a link problem.
CustomASM24Controller refuses to start if LTSSM ≠ 0x78. Your scan ran, so at open the FW thought the link was up (0x78), then it fell over, or the downstream Navi ports never got bus numbers.Practical splits:
- Link never stays 78 → power / slot / handmade LTSSM. Not tinygrad.
- Link stays 78, scan still only 1b21 → bridges not opening downstream (need USBPCIDevice enumeration while link is up).
- Link stays 78 and 1002:744c returns → rerun the BAR dump immediately; that is the only time memsize means anything.
test\_plus is blocked on a stable PCIe 78 UP, not on USB permissions or flashing.

i restarted and got this in the debug: \[C 80 06 0004\] \[C 80 06 00FF\] \[C 00 09 0000\] \[\*\*\* SET CONFIG \*\*\*\] \[C 01 0B 0000\] \[C 80 06 0004\] \[C 80 06 00FF\] \[C 00 09 0000\] \[\*\*\* SET CONFIG \*\*\*\] \[C 01 0B 0000\]the results from the two scripts you gave me are the same

That serial snippet is only USB enumeration. There is no \[BOOT\] and no \[PCIe …\] in what you pasted, so either the console was attached after boot, or this boot never printed link state.\[\*\*\* SET CONFIG \*\*\*\] twice is the host opening the ASM USB device (your scripts). It says nothing about the GPU.Do it in this order, one terminal each:Terminal 1 — console first

```bash
python3 /home/master/chestnut/ftdi_debug.py
```

Leave it running. You should see a live stream; if it is idle, that is fine.Terminal 2 — then reset

```bash
sudo env PATH="$PATH" python3 /home/master/chestnut/ftdi_debug.py -rn
```

Terminal 1 must then show something like:

```
[BOOT]
[PCIe …]
```

If you still only get \[C …\] / SET CONFIG, this -rn did not reboot the 8051 or you are on the wrong tty.When you see PCIe 78 UP … CONNECTED and it is not immediately followed by down, run the scan in terminal 2 within a couple of seconds.If CONNECTED never appears, or it appears then a burst of down / timeout before you can scan, the 7900 XTX link is not staying up. Same scan results (1b21 only, memsize=0) are expected in that state.Power: dock switch on, GPU aux power seated, then the two-terminal sequence above. Do not run USBPCIDevice / test\_plus until the scan prints a 1002: line again.

% \[BOOT\] \[PCIe 00 down Gen01 x01\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[PCIe 00 down Gen01 x01\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[PCIe 78 UP Gen03 x02 CONNECTED\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[LINK EVENT 08 link=02\] \[C 00 05 0000\] \[A\] \[C 80 06 0008\] \[C 00 31 0000\] \[C 80 06 0012\] \[C 80 06 0005\] \[C 80 06 0016\] \[C 80 06 0009\] \[C 80 06 0079\] \[C 80 06 00FF\] \[C 80 06 00FF\] \[C 80 06 00FF\] \[C 80 06 00FF\] \[C 00 09 0000\] \[\*\*\* SET CONFIG \*\*\*\](.venv) master@lab:~/chestnut$ sudo env PATH="$PATH" python3 /home/master/chestnut/ftdi\_debug.py -rn Device reset complete. (.venv) master@lab:~/chestnut$ sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.ops\_amd import USB3, USBPCIDevice from tinygrad.runtime.support.usb import CustomASM24Controllerdevs = USB3.list\_devices(0x3801, 0x0001) print("devs", \[d\[1\] for d in devs\]) usb = USB3(devs\[0\]\[0\]) print("product", usb.product) ctl = CustomASM24Controller(usb)def cfg(bus, d, fn, off, size=2): return ctl.pcie\_cfg\_req(off, bus=bus, dev=d, fn=fn, size=size)print("scan:") for bus in range(0, 8): for d in range(0, 8): try: vid = cfg(bus, d, 0, 0, 2) except Exception: continue if vid in (0, 0xFFFF, None): continue did = cfg(bus, d, 0, 2, 2) print(f" {bus:02x}:{d:02x}.0 {vid:04x}:{did:04x}") PY devs \['usb:2-23'\] product: custom ed4e39b7-CLEAN product custom ed4e39b7-CLEAN scan: 00:00.0 1b21:2464 00:01.0 1b21:2464 00:02.0 1b21:2464 00:03.0 1b21:2464 00:04.0 1b21:2464 00:05.0 1b21:2464 00:06.0 1b21:2464 00:07.0 1b21:2464 (.venv) master@lab:~/chestnut$ sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.ops\_amd import USB3, USBPCIDevice devs = USB3.list\_devices(0x3801, 0x0001) pci = USBPCIDevice("AM", \*devs\[0\]) mmio = pci.map\_bar(5, fmt="I") print("BAR5", mmio.nbytes, "memsize", hex(mmio\[0xDE3\]), "GiB", mmio\[0xDE3\]) print("BAR5\[0:8\]", \[hex(mmio\[i\]) for i in range(8)\]) vram = pci.map\_bar(0) print("BAR0", vram.nbytes, "head", bytes(vram.view(0, 16)\[:\]).hex()) PY product: custom ed4e39b7-CLEAN BAR5 1048576 memsize 0x0 GiB 0 BAR5\[0:8\] \['0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0xff00ff00'\] BAR0 1073741824 head ffffffffffffffffffffffffffffffff

This boot the link held (78 UP through SET CONFIG). The scan is still blind because it never programs the ASM switch.USBPCIDevice hardcodes the GPU at bus 4 and is supposed to run pci\_setup\_usb\_bars(...) so that 02/03/04 exist. A raw walk of buses 0–7 before that only sees the eight 1b21:2464 ports on bus 0. That matches what you have.After USBPCIDevice exists, ask bus 4 through that object (same handle that just set up the bridges):

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
devs = USB3.list_devices(0x3801, 0x0001)
pci = USBPCIDevice("AM", *devs[0])
print("product setup done")
for off, sz, name in [(0,2,"vid"),(2,2,"did"),(4,2,"cmd"),(0x10,4,"bar0"),(0x24,4,"bar5")]:
    v = pci.read_config(off, sz)
    print(name, hex(v))
mmio = pci.map_bar(5, fmt="I")
print("memsize", hex(mmio[0xDE3]), "GiB", mmio[0xDE3])
print("BAR5[0:8]", [hex(mmio[i]) for i in range(8)])
PY
```

Interpret:
- vid/did 0x1002 / 0x744c and cmd has bit 1 → setup found the 7900 XTX; then look at memsize.
- vid 0xffff / exception Unsupported Request: 0x4000000 → pci\_setup\_usb\_bars did not put a device on bus 4 even though LTSSM is 78.
- vid good, memsize still 0 → MEM TLPs still broken.
Do this while serial still shows 78 UP, not after a later down. The earlier 1002:744c scan happened after something (likely a previous USBPCIDevice / test\_plus) had already numbered the buses.

product: custom ed4e39b7-CLEAN product setup done vid 0x1002 did 0x744c cmd 0x7 bar0 0xc bar5 0x10000000 memsize 0x0 GiB 0 BAR5\[0:8\] \['0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0xff00ff00'\]

Setup is doing its job. The GPU is on bus 4 and command/BARs are programmed.

```
vid/did   1002:744c     RX 7900 XTX
cmd       0x7           IO + MEM + bus master
BAR5      0x10000000    1 MiB window tinygrad uses for MMIO
memsize   0             that window does not contain GPU MMIO
BAR5[0:6] 0
BAR5[7]   0xff00ff00    not a live Navi MMIO image
```

BAR0 = 0xc is the low dword of a 64-bit prefetchable BAR (type bits only). The address is in the next dword (0x14). That is normal.So: config TLPs to 04:00.0 work; memory TLPs to the address you wrote into BAR5 do not return RCC/VRAM. Discovery cannot work until those reads are real.That is handmade (or the USB MEM path), not permissions and not “GPU missing.”Next useful prints, same USBPCIDevice session:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
print("bar0 lo/hi", hex(pci.read_config(0x10,4)), hex(pci.read_config(0x14,4)))
print("bar2 lo/hi", hex(pci.read_config(0x18,4)), hex(pci.read_config(0x1c,4)))
print("bar5", hex(pci.read_config(0x24,4)))
mmio = pci.map_bar(5, fmt="I")
for off in (0x0, 0x1, 0x7, 0x10, 0xDE3, 0xDE4, 0x1500):
    print(hex(off), hex(mmio[off]))
PY
```

And watch serial: it must stay 78 UP for the whole script. A drop to down mid-read also yields zeros.If those MMIO dwords stay 0 / ff00ff00 with the link up, you are looking at 0xF0 MEM TLP issue in handmade/src/main.c (completions, address, byte enables), not at another host test.

product: custom ed4e39b7-CLEAN bar0 lo/hi 0xc 0x8 bar2 lo/hi 0x4000000c 0x8 bar5 0x10000000 0x0 0x0 0x1 0x0 0x7 0xff00ff00 0x10 0x0 0xde3 0x0 0xde4 0x0 0x1500 0x0

That confirms the split.

| Path | Result |
| --- | --- |
| USB + custom FW | works (3801:0001, custom ed4e39b7-CLEAN) |
| CFG to 04:00.0 | works (1002:744c, COMMAND=0x7) |
| BAR programming | works (BAR0 0x8\_00000000, BAR2 0x8\_40000000, BAR5 0x10000000) |
| MEM to BAR5 | dead (0 / 0xff00ff00, memsize=0) |

test\_plus fails at discovery because it reads VRAM/MMIO through BAR0/BAR5. Those completions are not GPU register data.Handmade is enumerating and forwarding config TLPs. It is not returning usable memory TLP completions for the windows pci\_setup\_usb\_bars assigned (mem\_base=0x10000000, prefetch at 32 GiB).What to change is handmade/src/main.c (and the 0xF0 path in CustomASM24Controller.pcie\_request): address decode, fmt/type, byte enables, completion data. Host-side flashing, USBDEV, udev, and AM\_RESET are done.Until BAR5\[0xde3\] is a real size (this card should look like ~24 GiB → 0x18), DEV=USB+AMD will keep asserting discovery signatures mismatch.

ok, whats the code i need to integrate and where?

There is nothing new to splice into tinygrad. DEV=USB+AMD already talks to handmade through 0xF0 / 0xE4 / 0xF2. The hole is on the device side: config TLPs work, memory TLPs to BAR5 0x10000000 do not.

Where the code already is

| Piece | File | Role |
| --- | --- | --- |
| Host MEM/CFG | tinygrad/runtime/support/usb.py → CustomASM24Controller.pcie\_request / \_f0\_out | already used |
| BAR + bus 4 | tinygrad/runtime/support/system.py → USBPCIDevice / pci\_setup\_usb\_bars(..., gpu\_bus=4, mem\_base=0x10000000) | already used |
| Firmware TLP | chestnut/handmade/src/main.c handle\_usb\_control() 0xF0 SETUP / DATA\_OUT / IN | this is what to change |
| Chunk DMA | chestnut/handmade/src/pcie\_pio.h pcie\_read\_chunk / pcie\_write\_chunk | streaming path |
| FW self-test | chestnut/handmade/test\_pcie.py | use this, not test\_plus |

What to change

All of it goes in handmade/src/main.c (and pcie\_pio.h if the bug is the engine, not the USB wrapper).The MEM path you care about for memsize is mode 0 (single TLP), not bulk:

```c
/* ~line 281 SETUP 0xF0 OUT — only latches, real work is DATA_OUT */
/* ~line 289 SETUP 0xF0 IN  — waits COMPLETE, copies DATA_* + status */
/* ~line 329 DATA_OUT       — loads ADDR/DATA, KICK + TRIGGER */
```

Host MMIO read of BAR5+0xde3\*4 becomes:
- fmt\_type = 0x20 (MRd64)
- byte\_en = 0x0F
- addr = 0x10000000 + 0x378C
If REG\_PCIE\_STATUS times out you already print \[PCIE TIMEOUT\]. If it “completes” with zeros, the engine fired at the wrong address or the switch window does not cover 0x10000000.

Minimal debug to add (same file)

In the DATA\_OUT mode == 0 block, after loading address regs, log fmt / mode / addr bytes / kick result. In the F0 IN path, log REG\_PCIE\_STATUS, ret\_status, and the four DATA\_\* bytes. Flash with nflash and rerun the BAR5 dump; the console will show whether MEM reads complete and with what payload.Also check at boot:

```c
REG_PCIE_TLP_LENGTH = 0x20;  /* main(), ~line 506 */
```

A 1-dword MMIO read should be length 1 DW, not 0x20 bytes/dwords if that register is TLP length. Wrong length is a common way to get a “completion” of zeros.Address load (already in DATA\_OUT) must stay consistent with CFG, which works:

```c
REG_PCIE_ADDR_0 = DESC_BUF[3]; /* ... */
REG_PCIE_ADDR_3 = DESC_BUF[0];
```

Do not “fix” that byte order unless you also keep CFG working.

How to test after a change

Do not start with test\_plus. Use the firmware test that only hits F0 MEM:

```bash
cd /home/master/chestnut
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  python3 handmade/test_pcie.py -v -s
```

That assigns BAR0 VRAM and write/read-verifies. If test\_f0\_write\_read\_small passes, rerun the BAR5 memsize dump, then TestTiny.test\_plus.Host tinygrad does not need a patch unless you change the 0xF0 contract (wValue/wIndex/12-byte payload). Keep that layout as documented in main.c and test\_pcie.py.

yes, give me the specific code i need to put in main.c and elsewhere. i need to know what to change specifically

There is no host-side patch. Change handmade/src/main.c only. Streaming MMIO (pcie\_mem\_read / mmio\[0xde3\]) uses 0xF0 mode 2, which never sets TLP length; boot leaves REG\_PCIE\_TLP\_LENGTH = 0x20. Each PIO kick is one dword. A length of 0x20 on a 1-DW engine is the first thing that will return zeros on BAR5 while CFG still works.

1\. handmade/src/main.c — set length on every 0xF0 DATA\_OUT

In the 0xF0 DATA\_OUT block, after REG\_PCIE\_BYTE\_EN = byte\_en; and before if (mode == 0), add:

```c
/* PIO engine fires one dword per TRIGGER. Length must be 1 DW.
 * Boot sets REG_PCIE_TLP_LENGTH = 0x20; that breaks MEM reads to BAR5. */
REG_PCIE_TLP_LENGTH = 0x01;
```

So that section looks like:

```c
REG_PCIE_FMT_TYPE   = fmt_type;
REG_PCIE_BYTE_EN    = byte_en;
REG_PCIE_TLP_LENGTH = 0x01;
REG_PCIE_ADDR_0     = DESC_BUF[3];
REG_PCIE_ADDR_1     = DESC_BUF[2];
REG_PCIE_ADDR_2     = DESC_BUF[1];
REG_PCIE_ADDR_3     = DESC_BUF[0];
REG_PCIE_ADDR_HIGH   = DESC_BUF[7];
REG_PCIE_ADDR_HIGH_1 = DESC_BUF[6];
REG_PCIE_ADDR_HIGH_2 = DESC_BUF[5];
REG_PCIE_ADDR_HIGH_3 = DESC_BUF[4];
```

Do not change the ADDR byte order. CFG uses the same mapping and VID 1002 is correct.

2\. Same file — log MEM completions

Right after the length/addr setup (still in DATA\_OUT), add:

```c
uart_puts("[F0 m=");
uart_puthex(mode);
uart_puts(" fmt=");
uart_puthex(fmt_type);
uart_puts(" a=");
uart_puthex(DESC_BUF[7]); uart_puthex(DESC_BUF[6]);
uart_puthex(DESC_BUF[5]); uart_puthex(DESC_BUF[4]);
uart_puthex(DESC_BUF[3]); uart_puthex(DESC_BUF[2]);
uart_puthex(DESC_BUF[1]); uart_puthex(DESC_BUF[0]);
uart_puts("]\n");
```

In the 0xF0 IN path, after you fill DESC\_BUF\[0..7\]:

```c
uart_puts("[F0IN st=");
uart_puthex(ret_status);
uart_puts(" d=");
uart_puthex(DESC_BUF[3]); uart_puthex(DESC_BUF[2]);
uart_puthex(DESC_BUF[1]); uart_puthex(DESC_BUF[0]);
uart_puts(" cpl=");
uart_puthex(REG_PCIE_CPL_HDR_HI);
uart_puthex(REG_PCIE_CPL_HDR_LO);
uart_puts("]\n");
```

registers.h already says COMPLETE can fire on an Unsupported Request. If cpl is UR, the switch window does not cover 0x10000000 and the fix is bridge MEM base/limit in host pci\_setup\_usb\_bars, not more firmware.

3\. Optional consistency in pcie\_pio.h

pcie\_read\_chunk / pcie\_write\_chunk kick 0xB296=0x07 and 0xB254=0x0F and never touch length. After change (1), mode 2 inherits LENGTH=1. Leave the asm alone unless logs show length still 0x20.

4\. Build / flash / test

```bash
cd /home/master/chestnut
sudo env PATH="$PATH" make -C handmade nflash
```

Console on, then:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  python3 handmade/test_pcie.py -v -s -k test_f0_write_read_small
```

Then the BAR5 dump again. Success is memsize ≈ 0x18 and \[F0IN st=00 d=........\] not all zero.Do not edit tinygrad/runtime/support/usb.py or ops\_amd.py. The contract (0xF0 / 12-byte LE addr+value / modes 0–2) stays as-is.

dude, your instructions are so vague. where is desc\_buf\[1..7\]? i told you to be specific where things go, dont be vague

Search for these exact strings in /home/master/chestnut/handmade/src/main.c. Replace the whole block, do not hunt for DESC\_BUF\[7\] by itself.

---

Change 1 — 0xF0 DATA\_OUTFind this exact block (it is the only place that assigns REG\_PCIE\_FMT\_TYPE through REG\_PCIE\_ADDR\_HIGH\_3):

```c
/* Configure PCIe TLP engine */
REG_PCIE_FMT_TYPE   = fmt_type;
REG_PCIE_BYTE_EN    = byte_en;
REG_PCIE_ADDR_0     = DESC_BUF[3];
REG_PCIE_ADDR_1     = DESC_BUF[2];
REG_PCIE_ADDR_2     = DESC_BUF[1];
REG_PCIE_ADDR_3     = DESC_BUF[0];
REG_PCIE_ADDR_HIGH   = DESC_BUF[7];
REG_PCIE_ADDR_HIGH_1 = DESC_BUF[6];
REG_PCIE_ADDR_HIGH_2 = DESC_BUF[5];
REG_PCIE_ADDR_HIGH_3 = DESC_BUF[4];
```

Replace it with:

```c
/* Configure PCIe TLP engine */
REG_PCIE_FMT_TYPE   = fmt_type;
REG_PCIE_BYTE_EN    = byte_en;
REG_PCIE_TLP_LENGTH = 0x01;
REG_PCIE_ADDR_0     = DESC_BUF[3];
REG_PCIE_ADDR_1     = DESC_BUF[2];
REG_PCIE_ADDR_2     = DESC_BUF[1];
REG_PCIE_ADDR_3     = DESC_BUF[0];
REG_PCIE_ADDR_HIGH   = DESC_BUF[7];
REG_PCIE_ADDR_HIGH_1 = DESC_BUF[6];
REG_PCIE_ADDR_HIGH_2 = DESC_BUF[5];
REG_PCIE_ADDR_HIGH_3 = DESC_BUF[4];

uart_puts("[F0 m=");
uart_puthex(mode);
uart_puts(" fmt=");
uart_puthex(fmt_type);
uart_puts(" a=");
uart_puthex(DESC_BUF[7]); uart_puthex(DESC_BUF[6]);
uart_puthex(DESC_BUF[5]); uart_puthex(DESC_BUF[4]);
uart_puthex(DESC_BUF[3]); uart_puthex(DESC_BUF[2]);
uart_puthex(DESC_BUF[1]); uart_puthex(DESC_BUF[0]);
uart_puts("]\n");
```

That is immediately after dma\_dwords = 0; and immediately before if (mode == 0) {.

---

Change 2 — 0xF0 INFind this exact block (the only usb\_send\_data(8) in the file):

```c
if (ret_status == 0) {
  DESC_BUF[0] = REG_PCIE_DATA_3;
  DESC_BUF[1] = REG_PCIE_DATA_2;
  DESC_BUF[2] = REG_PCIE_DATA_1;
  DESC_BUF[3] = REG_PCIE_DATA_0;
  DESC_BUF[4] = REG_PCIE_CPL_HDR_HI;
  DESC_BUF[5] = REG_PCIE_CPL_HDR_LO;
  DESC_BUF[6] = REG_PCIE_COMPL_STATUS;
} else {
  if (ret_status == 0xFF) uart_puts("[PCIE TIMEOUT]\n");
  int i;
  for (i = 0; i < 7; i++) DESC_BUF[i] = 0;
}
DESC_BUF[7] = ret_status;
usb_send_data(8);
```

Replace it with:

```c
if (ret_status == 0) {
  DESC_BUF[0] = REG_PCIE_DATA_3;
  DESC_BUF[1] = REG_PCIE_DATA_2;
  DESC_BUF[2] = REG_PCIE_DATA_1;
  DESC_BUF[3] = REG_PCIE_DATA_0;
  DESC_BUF[4] = REG_PCIE_CPL_HDR_HI;
  DESC_BUF[5] = REG_PCIE_CPL_HDR_LO;
  DESC_BUF[6] = REG_PCIE_COMPL_STATUS;
} else {
  if (ret_status == 0xFF) uart_puts("[PCIE TIMEOUT]\n");
  int i;
  for (i = 0; i < 7; i++) DESC_BUF[i] = 0;
}
DESC_BUF[7] = ret_status;
uart_puts("[F0IN st=");
uart_puthex(ret_status);
uart_puts(" d=");
uart_puthex(DESC_BUF[3]); uart_puthex(DESC_BUF[2]);
uart_puthex(DESC_BUF[1]); uart_puthex(DESC_BUF[0]);
uart_puts(" cpl=");
uart_puthex(REG_PCIE_CPL_HDR_HI);
uart_puthex(REG_PCIE_CPL_HDR_LO);
uart_puts("]\n");
usb_send_data(8);
```

---

Do not edit pcie\_pio.h, usb.py, or ops\_amd.py.

```bash
sudo env PATH="$PATH" make -C /home/master/chestnut/handmade nflash
```

ok, i made the changes and saved. what are my next steps?

1. Flash the image you just built:

```bash
sudo env PATH="$PATH" make -C /home/master/chestnut/handmade nflash
```

2. Attach the console before anything else, leave it running:

```bash
python3 /home/master/chestnut/ftdi_debug.py
```

Wait until you see \[BOOT\] and PCIe 78 UP … CONNECTED and it is not immediately followed by a stream of down.
3. In a second terminal, run the firmware MEM test (not test\_plus):

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  python3 /home/master/chestnut/handmade/test_pcie.py -v -s -k test_f0_write_read_small
```

4. If that errors or you want the same signal as before, run the BAR5 dump:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)), "cmd", hex(pci.read_config(4,2)))
mmio = pci.map_bar(5, fmt="I")
print("memsize", hex(mmio[0xDE3]), "GiB", mmio[0xDE3])
print("BAR5[0:8]", [hex(mmio[i]) for i in range(8)])
PY
```

What to look at

| Console | Meaning |
| --- | --- |
| \[F0 m=02 fmt=20 a=000000001000378C\] (example) | mode-2 MEM read of BAR5+0xde3 |
| \[F0IN st=00 d=........\] with non-zero d | length change is doing something |
| \[PCIE TIMEOUT\] | kick still not completing |
| st=00 but d=00000000 and memsize still 0 | TLP length was not the bug |
| test\_f0\_write\_read\_small PASS | MEM path works; then run test\_plus |

Only if step 3 passes:

```bash
sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \
  DEBUG=2 GMMU=0 AM_RESET=1 DEV=USB+AMD \
  python3 /home/master/tinygrad/test/test_tiny.py TestTiny.test_plus
```

Paste the serial \[F0 / \[F0IN lines plus memsize / pytest result.

stuck on step 3: sudo env PATH="$PATH" PYTHONPATH=/home/master/tinygrad \\ python3 /home/master/chestnut/handmade/test\_pcie.py -v -s -k test\_f0\_write\_read\_small Traceback (most recent call last): File "/home/master/chestnut/handmade/test\_pcie.py", line 10, in \<module> import ctypes, struct, unittest, time, sys, os, array, pytest ModuleNotFoundError: No module named 'pytest'

pytest is not in the Python that sudo is running. Install it in the venv, then rerun the same command:

```bash
/home/master/chestnut/.venv/bin/pip install pytest
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad \
  python3 /home/master/chestnut/handmade/test_pcie.py -v -s -k test_f0_write_read_small
```

If you do not want pytest, use unittest (same file, no extra package):

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad \
  python3 -m unittest handmade.test_pcie.TestF0.test_f0_write_read_small
```

That second form must be run from /home/master/chestnut so handmade.test\_pcie imports.

(.venv) master@lab:~/chestnut$ sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad \\ python3 -m unittest handmade.test\_pcie.TestF0.test\_f0\_write\_read\_small Setting up bridges (target gpu\_bus=4)... E ====================================================================== ERROR: setUpClass (handmade.test\_pcie.TestF0) ---------------------------------------------------------------------- Traceback (most recent call last): File "/home/master/chestnut/handmade/test\_pcie.py", line 106, in setUpClass gpu\_bus = setup\_bridges(cls.handle, GPU\_BUS) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/handmade/../pcie/pcie\_probe.py", line 237, in setup\_bridges pcie\_cfg\_write(handle, PCI\_PRIMARY\_BUS, buses, bus=bus, size=4, verbose=verbose) File "/home/master/chestnut/handmade/../pcie/pcie\_probe.py", line 169, in pcie\_cfg\_write return pcie\_request(handle, fmt, address, value=value, size=size, verbose=verbose) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/chestnut/handmade/../pcie/pcie\_probe.py", line 114, in pcie\_request raise TimeoutError(f"PCIe completion timeout at 0x{address:08X} (fmt=0x{fmt\_type:02X})") TimeoutError: PCIe completion timeout at 0x00000018 (fmt=0x44)---------------------------------------------------------------------- Ran 0 tests in 0.178sFAILED (errors=1)\[F0 m=00 fmt=44 a=0000000000000018\] \[PCIE TIMEOUT\] \[F0IN st=FF d=00000000 cpl=0000\] \[F0 m=00 fmt=44 a=0000000000000018\] \[PCIE TIMEOUT\] \[F0IN st=FF d=00000000 cpl=0000\] \[F0 m=00 fmt=44 a=0000000000000018\] \[PCIE TIMEOUT\] \[F0IN st=FF d=00000000 cpl=0000\]

REG\_PCIE\_TLP\_LENGTH = 0x01 on every 0xF0 broke config writes. The failing TLP is fmt=0x44 (CfgWr0) to offset 0x18 (bridge bus numbers). That used to complete when length stayed 0x20.Set length only for memory TLPs (fmt & 0x1F == 0). Leave CFG at 0x20.In the same DATA\_OUT block, replace:

```c
REG_PCIE_TLP_LENGTH = 0x01;
```

with:

```c
if ((fmt_type & 0x1F) == 0)
  REG_PCIE_TLP_LENGTH = 0x01;   /* MRd / MWr: 1 DW */
else
  REG_PCIE_TLP_LENGTH = 0x20;   /* CFG: stock length */
```

Keep the \[F0 uart lines.

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" make -C /home/master/chestnut/handmade nflash
```

Console up, then the same unittest. You want \[F0 m=00 fmt=44 …\] without \[PCIE TIMEOUT\], then later \[F0 m=02 fmt=20 …\] for the VRAM test.

(.venv) master@lab:~/chestnut$ /home/master/chestnut/.venv/bin/pip install pytest sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad \\ python3 /home/master/chestnut/handmade/test\_pcie.py -v -s -k test\_f0\_write\_read\_small Requirement already satisfied: pytest in./.venv/lib/python3.12/site-packages (9.1.1) Requirement already satisfied: iniconfig>=1.0.1 in./.venv/lib/python3.12/site-packages (from pytest) (2.3.0) Requirement already satisfied: packaging>=22 in./.venv/lib/python3.12/site-packages (from pytest) (26.3) Requirement already satisfied: pluggy<2,>=1.5 in./.venv/lib/python3.12/site-packages (from pytest) (1.6.0) Requirement already satisfied: pygments>=2.7.2 in./.venv/lib/python3.12/site-packages (from pytest) (2.21.0) ============================================= test session starts ============================================= platform linux -- Python 3.12.3, pytest-9.1.1, pluggy-1.6.0 -- /home/master/chestnut/.venv/bin/python3 cachedir:.pytest\_cache rootdir: /home/master/chestnut configfile: pytest.ini collected 9 items / 8 deselected / 1 selectedhandmade/test\_pcie.py::TestF0::test\_f0\_write\_read\_small Setting up bridges (target gpu\_bus=4)... Bus 0 -> 1: \[1B21:2464\] ASMedia class=0x00 htype=1 Bus 1 -> 2: \[1002:1478\] AMD/ATI class=0x06 htype=1 Bus 2 -> 3: \[1002:1479\] AMD/ATI class=0x06 htype=1 Bus 3 -> 4: \[1002:744C\] AMD/ATI class=0x03 htype=0 Found endpoint on bus 4 VRAM BAR0: 0x800000000 FAILED================================================== FAILURES =================================================== \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ TestF0.test\_f0\_write\_read\_small \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ handmade/test\_pcie.py:123: in test\_f0\_write\_read\_small got = stream\_read(self.handle, self.vram, len(data)) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ handmade/test\_pcie.py:57: in stream\_read assert ret == 0, f"bulk read failed: {ret}" E AssertionError: bulk read failed: -7 E assert -7 == 0 =========================================== short test summary info =========================================== FAILED handmade/test\_pcie.py::TestF0::test\_f0\_write\_read\_small - AssertionError: bulk read failed: -7 assert -7 == 0 ======================================= 1 failed, 8 deselected in 5.10s ======================================= (.venv) master@lab:~/chestnut$(.venv) master@lab:~/chestnut$ sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad \\ python3 -m unittest handmade.test\_pcie.TestF0.test\_f0\_write\_read\_small Setting up bridges (target gpu\_bus=4)... Bus 0 -> 1: \[1B21:2464\] ASMedia class=0x00 htype=1 Bus 1 -> 2: \[1002:1478\] AMD/ATI class=0x06 htype=1 Bus 2 -> 3: \[1002:1479\] AMD/ATI class=0x06 htype=1 Bus 3 -> 4: \[1002:744C\] AMD/ATI class=0x03 htype=0 Found endpoint on bus 4 VRAM BAR0: 0x800000000 F ====================================================================== FAIL: test\_f0\_write\_read\_small (handmade.test\_pcie.TestF0.test\_f0\_write\_read\_small) Write 512 bytes (1 bulk packet), read back, verify. ---------------------------------------------------------------------- Traceback (most recent call last): File "/home/master/chestnut/handmade/test\_pcie.py", line 124, in test\_f0\_write\_read\_small self.assertEqual(parse\_le\_data(got), list(range(n))) AssertionError: Lists differ: \[2130706432, 2130706432, 2130706432, 21307\[1489 chars\]6432\]!= \[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,\[483 chars\] 127\]First differing element 0: 2130706432 0Diff is 2834 characters long. Set self.maxDiff to None to see it.---------------------------------------------------------------------- Ran 1 test in 0.069sFAILED (failures=1)...\[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000018\] \[F0IN st=00 d=4000000C cpl=0004\] \[F0 m=00 fm

CFG is healthy again. That log is all fmt=05/45 (config). Bridges came up, GPU is 04:00.0 744C, BAR0 is 0x800000000.MEM streaming is still broken:
- pytest: libusb -7 = bulk IN timeout
- unittest: 128 dwords of 2130706432 = 0x7F000000 (not 0..127)
\[F0 m=01\] / \[F0 m=02\] should appear on the console during the write/read. If they do not, the stream never kicked. If they do and d= is 7F000000 / timeout, length=1 did not fix MEM.Next, same console still attached:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))
mmio = pci.map_bar(5, fmt="I")
print("memsize", hex(mmio[0xDE3]))
print("BAR5[0:4]", [hex(mmio[i]) for i in range(4)])
PY
```

Copy every new \[F0 m=02 / \[F0IN / \[PCIE TIMEOUT\] line from that run.test\_plus is still blocked. Do not revert the CFG vs MEM length split — that is what made setup\_bridges work again.

(.venv) master@lab:~/chestnut$ sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY' from tinygrad.runtime.ops\_amd import USB3, USBPCIDevice pci = USBPCIDevice("AM", \*USB3.list\_devices(0x3801, 0x0001)\[0\]) print("id", hex(pci.read\_config(0,2)), hex(pci.read\_config(2,2))) mmio = pci.map\_bar(5, fmt="I") print("memsize", hex(mmio\[0xDE3\])) print("BAR5\[0:4\]", \[hex(mmio\[i\]) for i in range(4)\]) PY product: custom ed4e39b7-DIRTY Traceback (most recent call last): File "\<stdin>", line 2, in \<module> File "/home/master/tinygrad/tinygrad/runtime/support/system.py", line 233, in \_\_init\_\_ self.\_bar\_info = System.pci\_setup\_usb\_bars(self.usb, gpu\_bus=4, mem\_base=0x10000000, pref\_mem\_base=(32 << 30)) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/system.py", line 94, in pci\_setup\_usb\_bars usb.pcie\_cfg\_req(pci.PCI\_PRIMARY\_BUS, bus=bus, dev=0, fn=0, value=buses, size=4) File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 184, in pcie\_cfg\_req return self.pcie\_request(fmt\_type, address, value, size) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 171, in pcie\_request if cnt > 0: return self.pcie\_request(fmt\_type, address, value, size, cnt=cnt-1) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 171, in pcie\_request if cnt > 0: return self.pcie\_request(fmt\_type, address, value, size, cnt=cnt-1) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 171, in pcie\_request if cnt > 0: return self.pcie\_request(fmt\_type, address, value, size, cnt=cnt-1) ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ \[Previous line repeated 7 more times\] File "/home/master/tinygrad/tinygrad/runtime/support/usb.py", line 172, in pcie\_request raise RuntimeError(f"TLP error after retries: ret\_status={ret\_status}, address={address:#x}") RuntimeError: TLP error after retries: ret\_status=255, address=0x18

The TLP engine is wedged from the failed bulk test. ret\_status=255 is the same \[PCIE TIMEOUT\] / st=FF you already saw. USBPCIDevice dies on the first CFG write (0x18) because of that, not because the GPU vanished.Reset the 8051, then dump only after serial is 78 UP:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" \
  python3 /home/master/chestnut/ftdi_debug.py -rn
```

On the console you should get a fresh \[BOOT\] and PCIe 78 UP … CONNECTED. Then immediately:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))
mmio = pci.map_bar(5, fmt="I")
print("memsize", hex(mmio[0xDE3]))
print("BAR5[0:4]", [hex(mmio[i]) for i in range(4)])
PY
```

Do not run test\_pcie.py again until this dump either prints memsize or fails with a new \[F0 line. If -rn still times out on 0x18, power-cycle the dock switch, then the same two commands.

great, now we are at this output: product: custom ed4e39b7-DIRTY id 0x1002 0x744c memsize 0x744c0000 BAR5\[0:4\] \['0x744c0000', '0x744c0000', '0x744c0000', '0x744c0000'\]

That is not VRAM size. 0x744c0000 is the GPU device ID (744c) sitting in the high half of every BAR5 dword. Real mmRCC\_CONFIG\_MEMSIZE for a 24 GiB 7900 XTX is 0x18.So:
- CFG still good (1002:744c)
- MEM TLPs now “complete” instead of timeout
- the payload is stuck / aliased, not MMIO
The length split moved you from zeros/ff to a frozen 744c pattern. Do not run test\_plus yet.On the console for this dump, find \[F0 m=02 and \[F0IN. You want:

```
[F0 m=02 fmt=20 a=........1000378C]   # BAR5 + 0xde3*4
[F0IN st=00 d=........]
```

If d= is 744c0000 / 0000744c for every address, the engine is not loading CplD data for MRd. That is still 0xF0 mode 2 + pcie\_read\_chunk in pcie\_pio.h, not tinygrad.Paste those \[F0 / \[F0IN lines from this run. That is the next useful signal.

from the console...\[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 cpl=0004\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D cpl=0004\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000018\] \[F0IN st=00 d=0000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000018\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000018\] \[F0IN st=00 d=FFE0000C cpl=0004\] \[F0 m=00 fmt=45 a=000000000400001C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=000000000400001C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000018\] \[F0IN st=00 d=00000040 cpl=0004\] \[F0 m=00 fmt=45 a=000000000400001C\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000020\] \[F0IN st=00 d=00000001 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 cpl=0004\] \[F0 m=02 fmt=20 a=000000001000378C\] \[F0 m=02 fmt=20 a=0000000010000000\] \[F0 m=02 fmt=20 a=0000000010000004\] \[F0 m=02 fmt=20 a=0000000010000008\] \[F0 m=02 fmt=20 a=000000001000000C\]

Those last five lines are the MEM reads. They are issued correctly:

```
[F0 m=02 fmt=20 a=000000001000378C]   # BAR5 + 0xde3*4  ← memsize
[F0 m=02 fmt=20 a=0000000010000000]   # BAR5+0
...
```

There is no \[F0IN\] after them. That is expected: mode 2 returns data on bulk IN, not on 0xF0 IN. The 0x744c0000 you printed is that bulk payload (stale 744c, not MMIO).CFG before that is fine (fmt=05/45, st=00).Isolate mode 0 vs mode 2. After -rn and 78 UP:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
import ctypes, struct
from tinygrad.runtime.autogen import libusb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

devs = USB3.list_devices(0x3801, 0x0001)
pci = USBPCIDevice("AM", *devs[0])  # programs BAR5 to 0x10000000
h = pci.usb.usb.handle

def tlp_rd(addr):
    wval = 0x20 | (0x0F << 8)
    buf = (ctypes.c_ubyte * 12)(*struct.pack('<III', addr & 0xFFFFFFFF, addr >> 32, 0))
    libusb.libusb_control_transfer(h, 0x40, 0xF0, wval, 0, buf, 12, 5000)
    resp = (ctypes.c_ubyte * 8)()
    n = libusb.libusb_control_transfer(h, 0xC0, 0xF0, 0, 0, resp, 8, 5000)
    print(hex(addr), "n", n, "st", resp[7], "d", bytes(resp[0:4]).hex(), "cpl", bytes(resp[4:6]).hex())

tlp_rd(0x10000000)
tlp_rd(0x1000378C)
PY
```

Console should show \[F0 m=00 fmt=20 a=...10000000\] and \[F0IN...\].

| \[F0IN\] d= | meaning |
| --- | --- |
| non-zero, not 744c0000, and the two addresses differ | mode 0 MEM works; bug is pcie\_read\_chunk / mode 2 |
| both 744c0000 / 00000000 / st=FF | mode 0 MEM also dead; length=1 is not enough |

Paste those two Python lines and the matching \[F0IN\] pair.

product: custom ed4e39b7-DIRTY 0x10000000 n 8 st 255 d 00000000 cpl 0000 0x1000378c n 8 st 1 d 00000000 cpl 0000\[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=000000000400001C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000018\] \[F0IN st=00 d=00000040 cpl=0004\] \[F0 m=00 fmt=45 a=000000000400001C\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000020\] \[F0IN st=00 d=00000001 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=10000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 cpl=0004\] \[PCIE TIMEOUT\] \[F0IN st=FF d=00000000 cpl=0004\] \[F0 m=00 fmt=20 a=000000001000378C\] \[F0IN st=01 d=00000000 cpl=0004\]

Mode 0 MEM to BAR5 is failing. CFG is not.

```
Python  0x10000000  st=255  d=0     ← timeout
Python  0x1000378c  st=1    d=0     ← PCIE_STATUS_ERROR
Serial  [PCIE TIMEOUT]
Serial  [F0 m=00 fmt=20 a=...1000378C]
        [F0IN st=01 d=00000000 cpl=0004]
```

fmt=20 is MRd64. The engine either never gets a completion (st=FF) or sets ERROR (st=01). That is why memsize is junk.LENGTH=1 on MEM is not a win. Put MEM back to the same length CFG uses.In the DATA\_OUT block, replace the if ((fmt\_type & 0x1F) == 0) / else length split with this single line:

```c
REG_PCIE_TLP_LENGTH = 0x20;
```

Leave the \[F0 prints.

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" make -C /home/master/chestnut/handmade nflash
```

\-rn (or the flash reset), wait for 78 UP, rerun the same two-address Python snippet.You want \[F0 m=00 fmt=20 a=...10000000\] then \[F0IN st=00 d=........\] with d different at 0x10000000 vs 0x1000378C. If both still st=FF/01/d=0, the problem is not length; MRd64 to 0x10000000 is not being completed on the link (window / fmt / engine), and that is the firmware bug to fix next.

ok and what script am i running to test this?

After nflash (or -rn) and the console shows PCIe 78 UP … CONNECTED, run this and nothing else:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
import ctypes, struct
from tinygrad.runtime.autogen import libusb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

devs = USB3.list_devices(0x3801, 0x0001)
pci = USBPCIDevice("AM", *devs[0])
h = pci.usb.usb.handle
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))

def tlp_rd(addr):
    wval = 0x20 | (0x0F << 8)
    buf = (ctypes.c_ubyte * 12)(*struct.pack('<III', addr & 0xFFFFFFFF, addr >> 32, 0))
    libusb.libusb_control_transfer(h, 0x40, 0xF0, wval, 0, buf, 12, 5000)
    resp = (ctypes.c_ubyte * 8)()
    n = libusb.libusb_control_transfer(h, 0xC0, 0xF0, 0, 0, resp, 8, 5000)
    print(hex(addr), "n", n, "st", resp[7], "d", bytes(resp[0:4]).hex(), "cpl", bytes(resp[4:6]).hex())

tlp_rd(0x10000000)
tlp_rd(0x1000378C)
PY
```

Leave ftdi\_debug.py running. Paste the two 0x1000… Python lines and the matching \[F0 m=00 fmt=20 / \[F0IN console lines.

product: custom ed4e39b7-DIRTY id 0x1002 0x744c 0x10000000 n 8 st 0 d 00000000 cpl 0004 0x1000378c n 8 st 0 d 00000000 cpl 0004\[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 cpl=0004\]

MEM is “succeeding” and returning zero. That is the original bug with LENGTH=0x20.

```
0x10000000  st=0  d=00000000
0x1000378c  st=0  d=00000000
```

The console clip you pasted is only BAR5 config (fmt=05/45 to …0024). The MRd lines are \[F0 m=00 fmt=20 a=0000000010000000\] — scroll for those. If they are missing, UART dropped them; the Python st=0 still means the IN completed.BAR5 is a 32-bit BAR at 0x10000000. The host is issuing MRd64 (fmt=20). Try MRd32 on the same script; firmware unchanged.Change only this line in the script:

```python
wval = 0x20 | (0x0F << 8)
```

to:

```python
wval = 0x00 | (0x0F << 8)   # MRd32
```

Run the same command after 78 UP (no nflash). You want:

```
[F0 m=00 fmt=00 a=0000000010000000]
[F0IN st=00 d=........]    # not 00000000, and different at 378C
```

If MRd32 is still d=00000000, length and 32-vs-64 are both ruled out; the engine is completing MRd without CplD data.

ok ran it again, this is hte terminal output:\[C 80 06 0004\] \[C 80 06 00FF\] \[C 00 09 0000\] \[\*\*\* SET CONFIG \*\*\*\] \[C 01 0B 0000\] \[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 cpl=0004\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D cpl=0004\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000018\] \[F0IN st=00 d=4000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000018\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000018\] \[F0IN st=00 d=FFE0000C cpl=0004\] \[F0 m=00 fmt=45 a=000000000400001C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=000000000400001C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000018\] \[F0IN st=00 d=00000040 cpl=0004\] \[F0 m=00 fmt=45 a=000000000400001C\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000020\] \[F0IN st=00 d=00000001 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=10000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 cpl=0004\]

That log is only USBPCIDevice programming bridges and BAR5. It stops at writing BAR5 = 0x10000000. There is no fmt=00 / fmt=20 yet, so the two tlp\_rd calls are either not in what you pasted or the script exited before them.This chunk is healthy CFG:
- buses 0→1→2→3→4 numbered
- 04:00.0 BAR5 set to 0x10000000 (fmt=45 a=…0024 then readback 00000010)
Send:
1. The Python stdout (id …, 0x10000000 n …, 0x1000378c n …).
2. Console lines after that last fmt=45 a=…0024 — they must look like \[F0 m=00 fmt=00 a=0000000010000000\].
If Python printed st=0 d=00000000 for both addresses and those fmt=00 lines exist, MRd32 is the same dead-zero result as MRd64. If Python never printed the two 0x1000 lines, the script died at setup and you have not tested MRd32 yet.

i dont understand what you want me to do next

Do these three things, in order. Nothing else.1. Confirm the console is still running and the last line is that fmt=45 …0024 block (link still 78 UP). If the console is dead or you see PCIe down, run:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" python3 /home/master/chestnut/ftdi_debug.py -rn
```

Wait for CONNECTED, keep that console open.2. Run this exact script:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
import ctypes, struct
from tinygrad.runtime.autogen import libusb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
h = pci.usb.usb.handle
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))

def tlp_rd(addr):
    wval = 0x00 | (0x0F << 8)
    buf = (ctypes.c_ubyte * 12)(*struct.pack('<III', addr & 0xFFFFFFFF, addr >> 32, 0))
    libusb.libusb_control_transfer(h, 0x40, 0xF0, wval, 0, buf, 12, 5000)
    resp = (ctypes.c_ubyte * 8)()
    n = libusb.libusb_control_transfer(h, 0xC0, 0xF0, 0, 0, resp, 8, 5000)
    print(hex(addr), "n", n, "st", resp[7], "d", bytes(resp[0:4]).hex(), "cpl", bytes(resp[4:6]).hex())

tlp_rd(0x10000000)
tlp_rd(0x1000378C)
PY
```

3\. Reply with two pieces of text only:
- The three print lines from Python (id, 0x10000000 …, 0x1000378c …).
- From the console, only lines that contain fmt=00 or that come right after them (\[F0IN …\]).
That is the whole next step. Do not flash, do not run test\_plus or test\_pcie.py.

product: custom ed4e39b7-DIRTY id 0x1002 0x744c 0x10000000 n 8 st 0 d 00000000 cpl 0004 0x1000378c n 8 st 0 d 00000000 cpl 0004complete terminal output:\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000840 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 cpl=0004\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D cpl=0004\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000018\] \[F0IN st=00 d=0000000C cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000018\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000018\] \[F0IN st=00 d=FFE0000C cpl=0004\] \[F0 m=00 fmt=45 a=000000000400001C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=000000000400001C\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000018\] \[F0IN st=00 d=00000040 cpl=0004\] \[F0 m=00 fmt=45 a=000000000400001C\] \[F0IN st=00 d=08000000 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000020\] \[F0IN st=00 d=00000001 cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=00000000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF cpl=0004\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 cpl=0004\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 cpl=0004\]

This run is enough. Stop changing length/fmt and stop rerunning the same script.What you proved
- GPU is 1002:744c, BAR5 is 0x10000000, CFG works.
- MRd32 to 0x10000000 and 0x1000378C completes (st=0, cpl=0004) with d=00000000.
- MRd64 did the same. So this is not 32-vs-64 and not TLP length.
test\_plus will keep failing. Discovery needs a real memsize (~\`0x18\`), not zero.The console dump still has no \[F0 m=00 fmt=00 …\] lines. UART is dropping them under the CFG burst. The Python st=0 d=00000000 is the result.What to do next (firmware, not more host tests)In handmade/src/main.c, 0xF0 IN already copies REG\_PCIE\_DATA\_\*. Those regs are zero on MRd. Check the completer status the comments in registers.h point at: B22A / REG\_PCIE\_CPL\_HDR\_\* for UR vs CplD.You already print cpl=. On the zero MRds it is 0004, same as working CFG. So the engine thinks the TLP finished; it is not latching MEM payload into DATA\_\*.That lives in the TLP engine setup around:
- REG\_PCIE\_TLP\_CTRL (0xB213, boot sets 0x01)
- REG\_PCIE\_TLP\_LENGTH (0xB216)
- PHY\_TLP\_ROUTING in pcie\_power\_on()
- pcie\_read\_chunk in pcie\_pio.h (mode 2 only; your last test was mode 0, so this file is not why d=0)
No more nflash until you change one of those with a reason. No test\_plus until a mode-0 MRd to 0x1000378C prints a non-zero d.

ok give me the exact code to change/remove and where

There is no engine “fix” line to paste that is known-good. The next change is only the 0xF0 IN block so you can see whether MEM data is in B220–B223 or in the completion-header data regs B22C/B22D.cpl=0004 already means B22A=0x00, B22B=0x04 → Successful Completion, 4 bytes. The payload is just not in DATA\_\*.

---

File: /home/master/chestnut/handmade/src/main.c  
Find this exact block (the one that ends with usb\_send\_data(8);):

```c
uart_puts("[F0IN st=");
uart_puthex(ret_status);
uart_puts(" d=");
uart_puthex(DESC_BUF[3]); uart_puthex(DESC_BUF[2]);
uart_puthex(DESC_BUF[1]); uart_puthex(DESC_BUF[0]);
uart_puts(" cpl=");
uart_puthex(REG_PCIE_CPL_HDR_HI);
uart_puthex(REG_PCIE_CPL_HDR_LO);
uart_puts("]\n");
usb_send_data(8);
```

Replace with:

```c
uart_puts("[F0IN st=");
uart_puthex(ret_status);
uart_puts(" d=");
uart_puthex(DESC_BUF[3]); uart_puthex(DESC_BUF[2]);
uart_puthex(DESC_BUF[1]); uart_puthex(DESC_BUF[0]);
uart_puts(" b22a=");
uart_puthex(REG_PCIE_CPL_HDR_HI);
uart_puthex(REG_PCIE_CPL_HDR_LO);
uart_puts(" b284=");
uart_puthex(REG_PCIE_COMPL_STATUS);
uart_puts(" b22c=");
uart_puthex(REG_PCIE_CPL_DATA);
uart_puthex(REG_PCIE_CPL_DATA_ALT);
uart_puts("]\n");
usb_send_data(8);
```

Do not change pcie\_pio.h, length, or fmt.

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" make -C /home/master/chestnut/handmade nflash
```

Wait for 78 UP, run the same MRd32 script as last time.Reply with only the two Python 0x1000… lines and console lines that contain fmt=00 or \[F0IN after them.Read b22a:
- 00xx = success (you already have this)
- 20xx = UR (address not claimed)
b284 bit 0 set = CplD. If b22c is non-zero and d= is still 00000000, MEM data is in B22C and the next edit is to copy those regs into DESC\_BUF\[0..3\] instead of DATA\_3..0.

ok whats the script to run to test this

After nflash and the console shows PCIe 78 UP … CONNECTED:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
import ctypes, struct
from tinygrad.runtime.autogen import libusb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
h = pci.usb.usb.handle
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))

def tlp_rd(addr):
    wval = 0x00 | (0x0F << 8)
    buf = (ctypes.c_ubyte * 12)(*struct.pack('<III', addr & 0xFFFFFFFF, addr >> 32, 0))
    libusb.libusb_control_transfer(h, 0x40, 0xF0, wval, 0, buf, 12, 5000)
    resp = (ctypes.c_ubyte * 8)()
    n = libusb.libusb_control_transfer(h, 0xC0, 0xF0, 0, 0, resp, 8, 5000)
    print(hex(addr), "n", n, "st", resp[7], "d", bytes(resp[0:4]).hex(), "cpl", bytes(resp[4:6]).hex())

tlp_rd(0x10000000)
tlp_rd(0x1000378C)
PY
```

Leave ftdi\_debug.py running. Paste the two 0x1000… Python lines and any console line with fmt=00 or b22a= / b22c=.

product: custom ed4e39b7-DIRTY id 0x1002 0x744c 0x10000000 n 8 st 0 d 00000000 cpl 0004 0x1000378c n 8 st 0 d 00000000 cpl 0004\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=450 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=00001002 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=744C0000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=00 a=0000000010000000\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=00 a=000000001000378C\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\]

This answers the B22C question. Stop editing that print.

```
CfgRd  b284=01  d=nonzero     ← CplD + payload in DATA_*  (working)
CfgWr  b284=00  d=…           ← no data, correct
MRd32  0x10000000   b22a=0004 b284=01 d=00000000 b22c=0000
MRd32  0x1000378C   b22a=0004 b284=01 d=00000000 b22c=0000
```

b22a=0004 = Successful Completion, 4 bytes.  
b284=01 = hardware says CplD.  
b22c is always 0000, including on working CFG reads, so MEM data is not hiding in B22C.The engine is completing an MRd to BAR5 with a 4-byte zero payload. CFG to the same device returns real values (1002 / 744C). So this is not “wrong DATA register” and not a host test bug.test\_plus cannot pass until an MRd to 0x1000378C returns a non-zero d.Do not change main.c again for logging. Next useful experiment is a write then read of BAR5 (proves whether MEM writes land). Say if you want that script; otherwise the work is in how the ASM forwards MWr/MRd to 0x10000000 through the switch windows, not in more F0IN prints.

ok, lets get that script, we should be close to nailing this down

After 78 UP (no nflash needed unless you rebuilt):

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
import ctypes, struct
from tinygrad.runtime.autogen import libusb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
h = pci.usb.usb.handle
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)), "cmd", hex(pci.read_config(4,2)))
print("bar5 cfg", hex(pci.read_config(0x24,4)))
print("bar0", hex(pci.read_config(0x10,4)), hex(pci.read_config(0x14,4)))

def f0(fmt, addr, value=0):
    wval = fmt | (0x0F << 8)
    buf = (ctypes.c_ubyte * 12)(*struct.pack('<III', addr & 0xFFFFFFFF, addr >> 32, value))
    libusb.libusb_control_transfer(h, 0x40, 0xF0, wval, 0, buf, 12, 5000)
    resp = (ctypes.c_ubyte * 8)()
    n = libusb.libusb_control_transfer(h, 0xC0, 0xF0, 0, 0, resp, 8, 5000)
    d = int.from_bytes(bytes(resp[0:4]), "little")
    print(f"  fmt={fmt:02x} addr={addr:#x} wr={value:#010x} n={n} st={resp[7]} d={d:#010x}")
    return d

BAR5 = 0x10000000
BAR0 = 0x800000000
MAGIC = 0xA5A55A5A

print("BAR5 write+read")
f0(0x40, BAR5, MAGIC)          # MWr32
f0(0x00, BAR5)                 # MRd32
f0(0x40, BAR5 + 0x378C, MAGIC)
f0(0x00, BAR5 + 0x378C)

print("BAR0 VRAM write+read")
f0(0x60, BAR0, MAGIC)          # MWr64
f0(0x20, BAR0)                 # MRd64
PY
```

| Python | meaning |
| --- | --- |
| BAR5 readback 0xa5a55a5a | MEM hits BAR5; memsize==0 was the GPU, not the bridge |
| BAR5 still 0, BAR0 readback 0xa5a55a5a | MEM works on prefetch VRAM; BAR5 window/decode is wrong |
| both stay 0 | MWr/MRd to mapped BARs are not reaching the GPU |

Paste the Python block from id through the last fmt= line, plus any new \[F0 m=00 fmt=40 / fmt=60 console lines.

product: custom ed4e39b7-DIRTY id 0x1002 0x744c cmd 0x7 bar5 cfg 0x10000000 bar0 0xc 0x8 BAR5 write+read fmt=40 addr=0x10000000 wr=0xa5a55a5a n=8 st=255 d=0x00000000 fmt=00 addr=0x10000000 wr=0x00000000 n=8 st=0 d=0xa5a55a58 fmt=40 addr=0x1000378c wr=0xa5a55a5a n=8 st=255 d=0x00000000 fmt=00 addr=0x1000378c wr=0x00000000 n=8 st=0 d=0xa5a55a5a BAR0 VRAM write+read fmt=60 addr=0x800000000 wr=0xa5a55a5a n=8 st=255 d=0x00000000 fmt=20 addr=0x800000000 wr=0x00000000 n=8 st=0 d=0xffffffff\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=450004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=00001002 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=744C0000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000004\] \[F0IN st=00 d=00000007 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=10000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=00000008 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=40 a=0000000010000000\] \[PCIE TIMEOUT\] \[F0IN st=FF d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=00 a=0000000010000000\] \[F0IN st=00 d=A5A55A58 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=40 a=000000001000378C\] \[PCIE TIMEOUT\] \[F0IN st=FF d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=00 a=000000001000378C\] \[F0IN st=00 d=A5A55A5A b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=60 a=0000000800000000\] \[PCIE TIMEOUT\] \[F0IN st=FF d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=20 a=0000000800000000\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\]

MEM32 to BAR5 works. The write “timeout” is a false alarm.MWr is posted (no completion). Your 0xF0 IN still waits, so writes show st=255. The TLP still went out:

```
MWr32 0x10000000  magic     st=255   (ignore)
MRd32 0x10000000            d=0xa5a55a58   ← came back
MWr32 0x1000378C  magic     st=255   (ignore)
MRd32 0x1000378C            d=0xa5a55a5a   ← exact
```

So 0x10000000 is a real 32-bit MEM window. Earlier memsize=0 was the reset value of that dword, not a dead BAR. You then overwrote 0xde3 with 0xa5a55a5a, so do not trust memsize until you reset.BAR0 VRAM (0x800000000, 64-bit) is still dead: MRd64 → 0xffffffff.Do this
1. Reset so 0xde3 is not your magic:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" python3 /home/master/chestnut/ftdi_debug.py -rn
```

2. When console is 78 UP, read only (no writes):

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))
mmio = pci.map_bar(5, fmt="I")
print("memsize", hex(mmio[0xDE3]))
print("BAR5[0], [1], [0xde3]", hex(mmio[0]), hex(mmio[1]), hex(mmio[0xDE3]))
vram = pci.map_bar(0)
print("BAR0 head", bytes(vram.view(0, 16)[:]).hex())
PY
```

mmio\[0xDE3\] uses the same mode-2 path as tinygrad. If that is a plausible size (0x18 = 24 GiB) and not 0 / a5a55a5a, run test\_plus next.If memsize is still 0 after -rn, the GPU is returning 0 for RCC memsize (not a bridge bug). Then test\_plus still cannot discover; that is GPU/init, and BAR0 ffffffff is the other half.

product: custom ed4e39b7-DIRTY id 0x1002 0x744c memsize 0x0 BAR5\[0\], \[1\], \[0xde3\] 0x0 0x0 0x0 BAR0 head ffffffffffffffffffffffffffffffffterminal:\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000840 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45000000004000024\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=00001002 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=744C0000 b22a=0004 b284=01 b22c=0000\] \[F0 m=02 fmt=20 a=000000001000378C\] \[F0 m=02 fmt=20 a=0000000010000000\] \[F0 m=02 fmt=20 a=0000000010000004\] \[F0 m=02 fmt=20 a=000000001000378C\] \[F0 m=02 fmt=20 a=0000000800000000\]

Two different paths:
- Mode 0 MRd32: write/read of BAR5 worked (0xa5a55a5a).
- This dump used mode 2 MRd64 (\[F0 m=02 fmt=20 a=…1000378C\]). That still returns 0.
tinygrad’s mmio\[0xDE3\] is mode 2. So memsize=0 here does not prove the GPU register is 0.Reset if needed (78 UP), then mode 0 MRd32 only — no map\_bar, no writes:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
import ctypes, struct
from tinygrad.runtime.autogen import libusb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
h = pci.usb.usb.handle

def rd32(addr):
    buf = (ctypes.c_ubyte * 12)(*struct.pack('<III', addr & 0xFFFFFFFF, 0, 0))
    libusb.libusb_control_transfer(h, 0x40, 0xF0, 0x00 | 0x0F00, 0, buf, 12, 5000)
    resp = (ctypes.c_ubyte * 8)()
    libusb.libusb_control_transfer(h, 0xC0, 0xF0, 0, 0, resp, 8, 5000)
    d = int.from_bytes(bytes(resp[0:4]), "little")
    print(hex(addr), "st", resp[7], "d", hex(d))
    return d

print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))
rd32(0x10000000)
rd32(0x10000004)
rd32(0x1000378C)
PY
```

| 0x1000378C | meaning |
| --- | --- |
| 0x18 (or other small GiB count) | GPU MMIO is fine; mode 2 / MRd64 stream is what test\_plus hits |
| 0 | GPU really reports 0 memsize; discovery cannot work yet |
| 0xa5a55a5a | last magic write is still in the part; -rn again |

Paste the three rd32 lines. That decides whether the next fix is pcie\_read\_chunk / mode 2, or GPU bring-up.

product: custom ed4e39b7-DIRTY id 0x1002 0x744c 0x10000000 st 0 d 0x0 0x10000004 st 0 d 0x0 0x1000378c st 0 d 0x0\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=4524\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=00001002 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=744C0000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=00 a=0000000010000000\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=00 a=0000000010000004\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=00 a=000000001000378C\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\]

That is the real reset state. Mode 0 MRd32, CplD, success, payload is 0:

```
0x10000000  d=0
0x10000004  d=0
0x1000378C  d=0   ← mmRCC_CONFIG_MEMSIZE
```

So:
- Handmade MEM32 to BAR5 works (magic write/read already proved that).
- After -rn, the GPU returns 0 for those MMIO addresses.
- BAR0 VRAM is still ffffffff.
test\_plus will keep hitting discovery signatures mismatch. Discovery needs memsize << 20 and a table at the end of VRAM. Both are empty here.This is no longer a “change main.c TLP length” problem. The bridge is forwarding 32-bit MEM. The 7900 XTX has not published a memory size or a discovery blob over this link yet (clocks / PSP / BAR0 64-bit window).Do not flash more logging. Do not expect TestTiny.test\_plus to pass on this boot.What is actually left:
1. BAR0 64-bit (0x800000000) still ffffffff — that is the VRAM path AM uses when memsize is known.
2. GPU init so 0xde3 is ~\`0x18without you writing it. That is AM / SMU / BAR clocks, not another0xF0\` print.
Handmade + host USB CFG/MEM32 are doing their job.

ok, whats the next step, what code am i changind, what script am i testing?

No more logging. The only firmware mismatch left that can break BAR0 (above 4 GiB) is the high-address bytes. BAR5 is below 4 GiB (high=0), so it cannot show this bug. pcie\_pio.h says B21C = addr\[39:32\]; main.c currently writes that byte to B21F.File: /home/master/chestnut/handmade/src/main.c  
Find:

```c
REG_PCIE_ADDR_HIGH   = DESC_BUF[7];
REG_PCIE_ADDR_HIGH_1 = DESC_BUF[6];
REG_PCIE_ADDR_HIGH_2 = DESC_BUF[5];
REG_PCIE_ADDR_HIGH_3 = DESC_BUF[4];
```

Replace with:

```c
REG_PCIE_ADDR_HIGH   = DESC_BUF[4];
REG_PCIE_ADDR_HIGH_1 = DESC_BUF[5];
REG_PCIE_ADDR_HIGH_2 = DESC_BUF[6];
REG_PCIE_ADDR_HIGH_3 = DESC_BUF[7];
```

Do not touch the low ADDR\_0..3 lines. Do not touch pcie\_pio.h yet.

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" make -C /home/master/chestnut/handmade nflash
```

Wait for 78 UP, then:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
import ctypes, struct
from tinygrad.runtime.autogen import libusb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
h = pci.usb.usb.handle
print("bar0", hex(pci.read_config(0x10,4)), hex(pci.read_config(0x14,4)))

def rd(fmt, addr):
    buf = (ctypes.c_ubyte * 12)(*struct.pack('<III', addr & 0xFFFFFFFF, addr >> 32, 0))
    libusb.libusb_control_transfer(h, 0x40, 0xF0, fmt | 0x0F00, 0, buf, 12, 5000)
    resp = (ctypes.c_ubyte * 8)()
    libusb.libusb_control_transfer(h, 0xC0, 0xF0, 0, 0, resp, 8, 5000)
    print(f"fmt={fmt:02x} {addr:#x} st={resp[7]} d={bytes(resp[0:4]).hex()}")

rd(0x00, 0x1000378C)     # BAR5 memsize, must still work
rd(0x20, 0x800000000)    # BAR0 VRAM
PY
```

| BAR5 0xde3 | BAR0 | action |
| --- | --- | --- |
| st=0 (any d) | d not ffffffff | high-addr fix is right; leave it |
| st=FF / CFG breaks | anything | revert the 4 lines |
| BAR5 same as now, BAR0 still ffffffff | revert is optional; BAR0 is then GPU/window, not this swap |  |

Paste the two rd( print lines. If CFG setup itself dies after this flash, revert immediately.

(0x20, 0x800000000) # BAR0 VRAMize, must still works(resp\[0:4\]).hex()}") product: custom ed4e39b7-DIRTY bar0 0xc 0x8 fmt=00 0x1000378c st=0 d=00000000 fmt=20 0x800000000 st=0 d=00000000\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000840 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45fmt=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=00000008 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=00 a=000000001000378C\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=20 a=0000000800000000\] \[F0IN st=00 d=00000000 b22a=2004 b284=00 b22c=0000\]

Revert the high-address swap. It made BAR0 worse.

```
BAR5  fmt=00  0x1000378C  b22a=0004  SC, still fine
BAR0  fmt=20  0x800000000 b22a=2004  UR — nothing claimed that address
```

0x20 in b22a is Unsupported Request. Before the swap, BAR0 was ffffffff with successful CplD. After the swap it is UR. pcie\_pio.h increment and the old DESC\_BUF\[7\]→B21C mapping were the consistent pair.File: /home/master/chestnut/handmade/src/main.c  
Find:

```c
REG_PCIE_ADDR_HIGH   = DESC_BUF[4];
REG_PCIE_ADDR_HIGH_1 = DESC_BUF[5];
REG_PCIE_ADDR_HIGH_2 = DESC_BUF[6];
REG_PCIE_ADDR_HIGH_3 = DESC_BUF[7];
```

Put back:

```c
REG_PCIE_ADDR_HIGH   = DESC_BUF[7];
REG_PCIE_ADDR_HIGH_1 = DESC_BUF[6];
REG_PCIE_ADDR_HIGH_2 = DESC_BUF[5];
REG_PCIE_ADDR_HIGH_3 = DESC_BUF[4];
```

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" make -C /home/master/chestnut/handmade nflash
```

No test script until that is flashed. After 78 UP, CFG must still work (1002:744c). Then we are back to: MEM32 BAR5 works and reads 0 at reset; BAR0 is a 64-bit window the GPU answers with ff, not UR.

ok flash is done

Confirm the revert. Console up, 78 UP, then:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
import ctypes, struct
from tinygrad.runtime.autogen import libusb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
h = pci.usb.usb.handle
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))

def rd(fmt, addr):
    buf = (ctypes.c_ubyte * 12)(*struct.pack('<III', addr & 0xFFFFFFFF, addr >> 32, 0))
    libusb.libusb_control_transfer(h, 0x40, 0xF0, fmt | 0x0F00, 0, buf, 12, 5000)
    resp = (ctypes.c_ubyte * 8)()
    libusb.libusb_control_transfer(h, 0xC0, 0xF0, 0, 0, resp, 8, 5000)
    print(f"fmt={fmt:02x} {addr:#x} st={resp[7]} d={bytes(resp[0:4]).hex()}")

rd(0x00, 0x1000378C)
rd(0x20, 0x800000000)
PY
```

- id 0x1002 0x744c
- BAR5 st=0 ( d can be 0 )
- BAR0 not console b22a=2004
If BAR0 is d=ffffffff and b22a=0004, the revert is good. Paste those two rd lines.

product: custom ed4e39b7-DIRTY id 0x1002 0x744c fmt=00 0x1000378c st=0 d=00000000 fmt=20 0x800000000 st=0 d=ffffffff\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000840 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45fmt=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=00001002 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=744C0000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=00 a=000000001000378C\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=20 a=0000000800000000\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\]

Revert is good.

```
BAR5  0x1000378C  b22a=0004 b284=01  d=0           SC + CplD
BAR0  0x800000000 b22a=0004 b284=01  d=ffffffff    SC + CplD, not UR
```

Leave ADDR\_HIGH as it is now (DESC\_BUF\[7\] → B21C).That is the working handmade picture:
- USB + CFG + bus 4 + 1002:744c — OK
- MEM32 BAR5 — OK, GPU returns 0 for memsize at reset
- MEM64 BAR0 — OK as a TLP, GPU/window returns ffffffff (no VRAM contents)
test\_plus will still fail discovery. There is no further main.c tweak that will invent a non-zero memsize or a discovery table. Next work is GPU/BAR0 bring-up in tinygrad AM (clocks / PSP / how pci\_setup\_usb\_bars sizes BAR0), not another 0xF0 log line.

ok lets get to that then

Next is BAR0 size, not more 0xF0 logging. pci\_setup\_usb\_bars tries ReBAR, then maps BAR0 at 0x800000000. If that size is 256 MiB instead of ~24 GiB, VRAM reads at the base are ffffffff even though the TLP is SC.Console 78 UP, no firmware change:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))
print("bars", {k: (hex(v[0]), hex(v[1])) for k,v in pci._bar_info.items()})

# ReBAR ext cap walk
cap = 0x100
while cap:
    hdr = pci.read_config(cap, 4)
    cid = hdr & 0xffff
    nxt = (hdr >> 20) & 0xfff
    if cid == 0x0015:  # PCI_EXT_CAP_ID_REBAR
        capab = pci.read_config(cap + 4, 4)
        ctrl  = pci.read_config(cap + 8, 4)
        print("rebar cap", hex(cap), "capab", hex(capab), "ctrl", hex(ctrl),
              "bar_size_sel", (ctrl >> 8) & 0x1f)
    cap = nxt
PY
```

| bars\[0\] size | meaning |
| --- | --- |
| 0x4000000 (64 MiB) / 0x10000000 (256 MiB) | ReBAR did not grow; VRAM window is tiny; ffffffff is expected |
| 0x600000000 (24 GiB) | window is full; ffffffff is GPU FB not enabled |
| bars\[5\] ≈ 0x100000 | BAR5 1 MiB, matches what you have |

Paste the bars line and any rebar line. That decides whether the next edit is ReBAR in system.py pci\_setup\_usb\_bars or AM GPU init after a real memsize.

product: custom ed4e39b7-DIRTY id 0x1002 0x744c bars {0: ('0x800000000', '0x40000000'), 2: ('0x840000000', '0x200000'), 5: ('0x10000000', '0x100000')} rebar cap 0x200 capab 0x7000 ctrl 0xa40 bar\_size\_sel 10\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45000004000024\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=00001002 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=744C0000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\]

BAR0 is 1 GiB, not 24 GiB. That is the largest ReBAR the GPU is advertising:

```
bars[0] = 0x800000000 size 0x40000000   # 1 GiB
rebar capab 0x7000  sel 10              # 256M / 512M / 1G only
bars[5] = 0x10000000 size 0x100000      # 1 MiB MMIO
```

A 7900 XTX that has not brought FB up will not advertise 24 GiB and will return ffffffff on BAR0. memsize=0 matches that.Discovery lives at vram\_size - 64KiB. With a 1 GiB window, that address is 0x800000000 + 0x3FFF0000. Read it (no firmware change):

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
import ctypes, struct
from tinygrad.runtime.autogen import libusb
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
h = pci.usb.usb.handle
addr = 0x800000000 + 0x3FFF0000
buf = (ctypes.c_ubyte * 12)(*struct.pack('<III', addr & 0xFFFFFFFF, addr >> 32, 0))
libusb.libusb_control_transfer(h, 0x40, 0xF0, 0x20 | 0x0F00, 0, buf, 12, 5000)
resp = (ctypes.c_ubyte * 8)()
libusb.libusb_control_transfer(h, 0xC0, 0xF0, 0, 0, resp, 8, 5000)
print("end-of-1G", hex(addr), "st", resp[7], "d", bytes(resp[0:4]).hex())
PY
```

| d | next |
| --- | --- |
| not 00/ff | possible discovery header; we can point AM at 1 GiB |
| ffffffff / 00000000 | no table in the 1 GiB BAR; need GPU FB/PSP init, not another BAR tweak |

Paste that one print line.

product: custom ed4e39b7-DIRTY end-of-1G 0x83fff0000 st 0 d ffffffff\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45fmt=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=20 a=000000083FFF0000\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\]

There is no discovery table in the 1 GiB BAR.

```
end-of-1G  0x83fff0000  st=0  d=ffffffff  b22a=0004 b284=01
```

SC + CplD, payload all ff. Same as BAR0+0. That window is mapped; framebuffer contents are not there.Where you are

| Layer | Status |
| --- | --- |
| Handmade USB + 0xF0 CFG/MEM | Working |
| Switch + 04:00.0 744c | Working |
| BAR5 1 MiB @ 0x10000000 | Working; memsize reads 0 |
| BAR0 1 GiB @ 0x800000000 | Working as TLPs; data is ff |
| ReBAR | Max advertised 1 GiB (capab=0x7000), not 24 GiB |
| test\_plus / AM discovery | Cannot run: no memsize, no table |

Do not change main.c for this. Further 0xF0 prints will not create VRAM.What is left is Navi 31 FB/PSP bring-up inside tinygrad AM (amdev.py after \_run\_discovery, SMU/PSP, possible AM\_RESET), which today never starts because discovery asserts first. That is a different codebase than handmade.Practical next edit if you want to keep going in AM: in /home/master/tinygrad/tinygrad/runtime/support/am/amdev.py \_run\_discovery, print vram\_size and the first 16 bytes before the assert (do not force a fake size). You already know those bytes will be ff / memsize=0. The real work is why this card’s RCC still reports 0 GiB and ReBAR only 1 GiB over the dock — GPU power/PSP/VBIOS, not the ASM TLP engine.

ok give me that script to do that test

No need to edit amdev.py. This is the same two reads discovery does, without the assert:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
mmio = pci.map_bar(5, fmt="I")
vram = pci.map_bar(0)

memsize = mmio[0xDE3]
vram_size = memsize << 20
print("mmRCC_CONFIG_MEMSIZE", hex(memsize), "vram_size", hex(vram_size))
print("BAR0 bytes", hex(vram.nbytes), "BAR5 bytes", hex(mmio.nbytes))

off = vram_size - (64 << 10)
print("discovery off", hex(off))
if 0 <= off <= vram.nbytes - 16:
    print("discovery[0:16]", bytes(vram.view(off, 16)[:]).hex())
else:
    print("offset not in BAR0")
    print("BAR0[0:16]", bytes(vram.view(0, 16)[:]).hex())
    end = vram.nbytes - 16
    print("BAR0[end-16:]", bytes(vram.view(end, 16)[:]).hex())
PY
```

Wait for 78 UP first. Expected on this card: memsize 0x0, offset not in BAR0, both BAR0 slices ff. That is the discovery failure with the assert removed.

product: custom ed4e39b7-DIRTY mmRCC\_CONFIG\_MEMSIZE 0x0 vram\_size 0x0 BAR0 bytes 0x40000000 BAR5 bytes 0x100000 discovery off -0x10000 offset not in BAR0 BAR0\[0:16\] ffffffffffffffffffffffffffffffff BAR0\[end-16:\] ffffffffffffffffffffffffffffffff\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=02 fmt=20 a=000000001000378C\] \[F0 m=02 fmt=20 a=0000000800000000\] \[F0 m=02 fmt=20 a=000000083FFFFFF0\]

That is discovery, with the assert stripped:

```
memsize     0
vram_size   0
BAR0 1 GiB  ff…ff at start and end
```

AMDev would compute off = -0x10000, then read garbage/ff and fail discovery signatures mismatch. Same result as test\_plus.Stop rerunning this script. Handmade and USB MEM/CFG are not the blocker anymore. The 7900 XTX is not exposing FB (memsize=0, ReBAR max 1 GiB, BAR0 all ff). Next work is Navi init in tinygrad AM, not another host dump.

ok great, progress, lets move forward with that next step

AM cannot start: \_run\_discovery() is the first thing after mapping BARs. PSP/SMU init never runs.There is a comment in amdev.py that matches your BAR0 data:

```
# L1 across retimers makes reads oscillate to 0xffffffff; power on defaults it enabled.
```

AM only clears ASPM on the GPU. Your path is GPU + three AMD switches + ASM. Next step: clear L1 on every bus, then reread memsize and BAR0.

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice
from tinygrad.runtime.support.usb import CustomASM24Controller

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
usb: CustomASM24Controller = pci.usb

def cfg_rd(bus, off, size=2):
    return usb.pcie_cfg_req(off, bus=bus, dev=0, fn=0, size=size)
def cfg_wr(bus, off, val, size=2):
    usb.pcie_cfg_req(off, bus=bus, dev=0, fn=0, value=val, size=size)

def find_pcie_cap(bus):
    cap = cfg_rd(bus, 0x34, 1) & 0xFC
    seen = set()
    while cap and cap not in seen:
        seen.add(cap)
        if cfg_rd(bus, cap, 1) == 0x10:
            return cap
        cap = cfg_rd(bus, cap + 1, 1) & 0xFC
    return None

print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))
for bus in range(0, 5):
    cap = find_pcie_cap(bus)
    if cap is None:
        print(f"bus {bus}: no PCIe cap")
        continue
    lnkctl = cfg_rd(bus, cap + 0x10, 2)
    cfg_wr(bus, cap + 0x10, lnkctl & ~3, 2)
    print(f"bus {bus}: cap {cap:#x} lnkctl {lnkctl:#x} -> {cfg_rd(bus, cap+0x10,2):#x}")

mmio = pci.map_bar(5, fmt="I")
vram = pci.map_bar(0)
print("memsize", hex(mmio[0xDE3]))
print("BAR0[0:16]", bytes(vram.view(0, 16)[:]).hex())
PY
```

| After ASPM clear | meaning |
| --- | --- |
| memsize becomes 0x18 (or similar) and/or BAR0 not all ff | L1 was eating MEM; then test\_plus |
| still memsize=0 and BAR0 ff | ASPM is not the issue; FB still off |

Paste the five bus N: lines plus memsize / BAR0\[0:16\].

int("BAR0\[0:16\]", bytes(vram.view(0, 16)\[:\]).hex()) product: custom ed4e39b7-DIRTY id 0x1002 0x744c bus 0: cap 0x80 lnkctl 0x0 -> 0x0 bus 1: cap 0x80 lnkctl 0x0 -> 0x0 bus 2: cap 0x58 lnkctl 0x0 -> 0x0 bus 3: cap 0x58 lnkctl 0x0 -> 0x0 bus 4: cap 0x64 lnkctl 0x0 -> 0x0 memsize 0x0 BAR0\[0:16\] ffffffffffffffffffffffffffffffff\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 fmt=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=00001002 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=744C0000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=04 a=0000000000000034\] \[F0IN st=00 d=00000050 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=04 a=0000000000000050\] \[F0IN st=00 d=00807005 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=04 a=0000000000000050\] \[F0IN st=00 d=00807005 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=04 a=0000000000000070\] \[F0IN st=00 d=C8238001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=04 a=0000000000000070\] \[F0IN st=00 d=C8238001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=04 a=0000000000000080\] \[F0IN st=00 d=0052C010 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=04 a=0000000000000090\] \[F0IN st=00 d=10110000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000090\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=04 a=0000000000000090\] \[F0IN st=00 d=10110000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000001000034\] \[F0IN st=00 d=00000050 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000001000050\] \[F0IN st=00 d=00807005 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000001000050\] \[F0IN st=00 d=00807005 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000001000070\] \[F0IN st=00 d=C8238001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000001000070\] \[F0IN st=00 d=C8238001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000001000080\] \[F0IN st=00 d=0162C010 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000001000090\] \[F0IN st=00 d=70230000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000090\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000001000090\] \[F0IN st=00 d=70230000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000002000034\] \[F0IN st=00 d=00000048 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000002000048\] \[F0IN st=00 d=00000009 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000002000048\] \[F0IN st=00 d=00005000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000002000050\] \[F0IN st=00 d=00000001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000002000050\] \[F0IN st=00 d=00005800 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000002000058\] \[F0IN st=00 d=00000010 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000002000068\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000068\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000002000068\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000003000034\] \[F0IN st=00 d=00000050 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000003000050\] \[F0IN st=00 d=00000001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000003000050\] \[F0IN st=00 d=00005800 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000003000058\] \[F0IN st=00 d=00000010 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000003000068\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000068\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000003000068\] \[F0IN st=00 d=00000000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000034\] \[F0IN st=00 d=00000048 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000048\] \[F0IN st=00 d=00000009 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000048\] \[F0IN st=00 d=00005000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000050\] \[F0IN st=00 d=00000001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000050\] \[F0IN st=00 d=00006400 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 \[F0 m=02 fmt=20 a=000000001000378C\] \[F0 m=02 fmt=20 a=0000000800000000\]

ASPM was already off (lnkctl 0x0 on buses 0–4). That is not why BAR0 is ff.AM’s other VRAM path is not BAR0. When large\_bar is false it uses MMIO:

```
wreg(0x06, addr>>31)
wreg(0x00, (addr & 0x7fffffff) | 0x80000000)
rreg(0x01)
```

memsize=0 never takes that path. Probe it directly:

```bash
sudo env PATH="/home/master/chestnut/.venv/bin:$PATH" PYTHONPATH=/home/master/tinygrad python3 - <<'PY'
from tinygrad.runtime.ops_amd import USB3, USBPCIDevice

pci = USBPCIDevice("AM", *USB3.list_devices(0x3801, 0x0001)[0])
mmio = pci.map_bar(5, fmt="I")

def read_vram_dw(addr):
    mmio[0x06] = addr >> 31
    mmio[0x00] = (addr & 0x7FFFFFFF) | 0x80000000
    return mmio[0x01]

print("id", hex(pci.read_config(0,2)), hex(pci.read_config(2,2)))
print("memsize", hex(mmio[0xDE3]))
for a in (0, 4, 0x1000, 0x3FFF0000):
    print(hex(a), hex(read_vram_dw(a)))
print("idx 0,1,6 after", hex(mmio[0]), hex(mmio[1]), hex(mmio[6]))
PY
```

| read\_vram\_dw | meaning |
| --- | --- |
| not 0 / ffffffff | FB exists behind the BIF window; discovery can use \_read\_vram if we supply a size |
| all 0 / ff | BIF VRAM window is empty too; PSP/GMC has not brought FB up |

Paste the memsize line and the four 0x… lines.

product: custom ed4e39b7-DIRTY id 0x1002 0x744c memsize 0x0 0x0 0xffffffff 0x4 0xffffffff 0x1000 0xffffffff 0x3fff0000 0xffffffff idx 0,1,6 after 0xbfff0000 0xffffffff 0x0\[F0 m=00 fmt=44 a=0000000000000018\] \[F0IN st=00 d=00010400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=000000000000002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=44 a=0000000000000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000018\] \[F0IN st=00 d=00020400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000100002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000001000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000018\] \[F0IN st=00 d=00030400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000200002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000002000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000018\] \[F0IN st=00 d=00040400 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=00100000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000020\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=00000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000024\] \[F0IN st=00 d=0000FFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000028\] \[F0IN st=00 d=08000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=000000000300002C\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000003000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000100\] \[F0IN st=00 d=1501000B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000150\] \[F0IN st=00 d=20020001 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000200\] \[F0IN st=00 d=24010015 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000204\] \[F0IN st=00 d=00007000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000208\] \[F0IN st=00 d=00000A40 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000208\] \[F0IN st=00 d=400A0000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000240\] \[F0IN st=00 d=27010004 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000270\] \[F0IN st=00 d=2A010019 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002A0\] \[F0IN st=00 d=2D01000D b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=00000000040002D0\] \[F0IN st=00 d=3201001B b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000320\] \[F0IN st=00 d=41010018 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000410\] \[F0IN st=00 d=45010026 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000450\] \[F0IN st=00 d=00010027 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=0000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000010\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000010\] \[F0IN st=00 d=C000000C b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000014\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45=45 a=0000000004000024\] \[F0IN st=00 d=FFFFFFFF b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000024\] \[F0IN st=00 d=FFF00000 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000024\] \[F0IN st=00 d=00000010 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=45 a=0000000004000004\] \[F0IN st=00 d=07000000 b22a=0004 b284=00 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=00001002 b22a=0004 b284=01 b22c=0000\] \[F0 m=00 fmt=05 a=0000000004000000\] \[F0IN st=00 d=744C0000 b22a=0004 b284=01 b22c=0000\] \[F0 m=02 fmt=20 a=000000001000378C\] \[F0 m=01 fmt=60 a=0000000010000018\] \[F0 m=01 fmt=60 a=0000000010000000\] \[F0 m=02 fmt=20 a=0000000010000004\] \[F0 m=01 fmt=60 a=0000000010000018\] \[F0 m=01 fmt=60 a=0000000010000000\] \[F0 m=02 fmt=20 a=0000000010000004\] \[F0 m=01 fmt=60 a=0000000010000018\] \[F0 m=01 fmt=60 a=0000000010000000\] \[F0 m=02 fmt=20 a=0000000010000004\] \[F0 m=01 fmt=60 a=0000000010000018\] \[F0 m=01 fmt=60 a=0000000010000000\] \[F0 m=02 fmt=20 a=0000000010000004\] \[F0 m=02 fmt=20 a=0000000010000000\] \[F0 m=02 fmt=20 a=0000000010000004\] \[F0 m=02 fmt=20 a=0000000010000018\]

BIF VRAM is empty too. Same ffffffff as BAR0.

```
mmio[0x06]/[0x00]/[0x01]  →  0xffffffff  at 0, 4, 0x1000, 0x3fff0000
mmio[0] after             →  0xbfff0000   (write stuck; the window is live)
```

So both AM VRAM paths work as transactions and both return “no FB”.AM boot order is:
1. map BARs
2. \_run\_discovery() ← you die here
3. init\_sw / PSP / SMU / GMC
You cannot load PSP until discovery gives IP bases. There is no next 0xF0 or BAR script that skips that.What is actually left is hardware/firmware on the GPU, not handmade:
- 7900 XTX 8-pin / dock 12V actually on
- same card in a PC with amdgpu unloaded: does memsize become 0x18?
- if yes, the dock power/PERST sequence is incomplete
- if no, the card is not coming out of reset
Do not run test\_plus until mmio\[0xDE3\] is a real GiB count. Do not patch amdev.py to fake vram\_size; \_read\_vram is already ff.

Think Harder