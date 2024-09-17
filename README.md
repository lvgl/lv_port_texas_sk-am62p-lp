# LVGL ported to AM62P-LP (TI)

## Overview

This guide provides steps to setup the AM62P-LP board and to cross cross-compile an LVGL project on the target.



## Board setup

The guide is based on TI [documentation](https://dev.ti.com/tirex/explore/node?node=A__AaM8dWF78x986JGiasfPsA__am62px-devtools__FUz-xrs__LATEST)

- Connect to the board the following: 

  - UART
  - Power
  - Screen (HDMI)
  - Ethernet

- An SD card is needed to flash the image. Follow the guide to download or build the `.wic` image
  
- If there are problems encountered flashing the SD card with BalenaEtcher as mentioned in the documentation, use this command instead: 

  ```bash
  # Mount the SD on your system and find where it was mounter (e.g.: sda, sdb)
  sudo dd if=path/to/am62p-image.wic of=/dev/sdX bs=4M status=progress conv=fsync
  ```

- Use the UART to ensure the system has started successfully.



## Port LVGL on the board

Support to run docker systems on arm64: 
```bash
sudo apt-get install qemu-user-static
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

Build the docker image: 
```bash
docker build --platform linux/arm64/v8 -t lvgl-build-arm64-image . 
```

Run the executable on the target: 
```bash
```

