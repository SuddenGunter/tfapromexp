# tfapromexp
TFA-Dostmann CO2 monitor metrics exporter 

Based on [co2-monitor](https://github.com/maddindeiss/co2-monitor).

# Usage

I use this container in my [rpi-hosted repo](https://github.com/SuddenGunter/rpi-hosted/tree/main/v3).

## Rootless

To run this app in rootless mode:

```bash
udevadm info -a -n /dev/bus/usb/001/003 | grep '{idVendor}\|{idProduct}'
sudo nano /etc/udev/rules.d/99-tfa-usb.rules

# put SUBSYSTEM=="usb", ATTR{idVendor}=="__VENDOR_ID__", ATTR{idProduct}=="__PRODUCT_ID__", MODE="0666"

sudo udevadm control --reload-rules
sudo udevadm trigger
```