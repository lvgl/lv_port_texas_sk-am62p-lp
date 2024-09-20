# LVGL ported to AM62P-LP (TI)

## Overview

This guide provides steps to setup the AM62P-LP board and to cross cross-compile an LVGL project on the target.



## Buy

You can purchase the AM62P-LP board directly from TI website.



## Specification

### CPU and memory

- Module: AM62P Q
- RAM: 8GB internal
- Flash: Can boot from SD
- GPU: 3D GPU and 4K acceleration

### Hardware

- Screen: HDMI 1920x1080 touchscreen



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

- Get the IP of the target board:

  - Option 1: from the UART, on the board: 
    ```bash
    ip a
    ```

  - Option 2 : Get the IP from your host with nmap
    ```bash
    ## Install nmap if it is not yet on your system
    sudo apt install nmap
    ## Find the IP of the board. You need to know your ip (ifconfig or ip a)
    ## YOUR_IP should be built like this :
    ## If the ip is 192.168.1.86, then you should have 192.168.1.0/24
    nmap -sn <YOUR_IP>.0/24 | grep am62pxx   
    ```

- Then transfer the executable on the board: 
  ```bash
  ## Copy the executable on the host
  docker run --rm --platform linux/arm64 -v $(pwd)/output:/output lvgl-build-arm64-image
  
  ## Transfer the executable on the board
  scp output/lvgl-demo root@192.168.1.123:/root
  ```

- Start the application
  ```bash
  ssh root@<board_ip>
  systemctl stop weston.service ## stop default presentation screen if it is running
  ./lvgl-demo
  ```



## Change configuration

There are 2 configuration examples that can be used in lvgl_docker: 

- lv_conf_fb_1_thread.h
- lv_conf_fb_4_threads.h

The default configuration used is lv_conf_fb_4_threads.h. To change the configuration, modify the lv_conf.h file with the desired configuration.



## Change Application

In the folder lvgl_docker, modify the "main.c" file.

This docker is only for tests purpose, for more complex modifications, modify the docker accordingly to clone another repository or add the files to the cloned repository.



## Benchmark results

**Frame buffer, 1 thread**

| Name                      | Avg. CPU | Avg. FPS | Avg. time | render time | flush time |
| ------------------------- | -------- | -------- | --------- | ----------- | ---------- |
| Empty screen              | 78.00%   | 17       | 41        | 18          | 23         |
| Moving wallpaper          | 96.00%   | 5        | 178       | 154         | 24         |
| Single rectangle          | 23.00%   | 28       | 5         | 3           | 2          |
| Multiple rectangles       | 86.00%   | 17       | 49        | 18          | 31         |
| Multiple RGB images       | 95.00%   | 6        | 136       | 113         | 23         |
| Multiple ARGB images      | 95.00%   | 7        | 119       | 95          | 24         |
| Rotated ARGB images       | 98.00%   | 1        | 506       | 483         | 23         |
| Multiple labels           | 94.00%   | 10       | 79        | 55          | 24         |
| Screen sized text         | 6.00%    | 5        | 2         | 2           | 0          |
| Multiple arcs             | 84.00%   | 10       | 79        | 56          | 23         |
| Containers                | 96.00%   | 6        | 140       | 117         | 23         |
| Containers with overlay   | 98.00%   | 3        | 315       | 290         | 25         |
| Containers with opa       | 98.00%   | 3        | 262       | 238         | 24         |
| Containers with opa_layer | 98.00%   | 2        | 301       | 277         | 24         |
| Containers with scrolling | 96.00%   | 6        | 154       | 130         | 24         |
| Widgets demo              | 35.00%   | 20       | 57        | 50          | 7          |
| All scenes avg.           | 79.00%   | 9        | 151       | 131         | 20         |

**Frame buffer, 4 threads**

| Name                      | Avg. CPU | Avg. FPS | Avg. time | render time | flush time |
| ------------------------- | -------- | -------- | --------- | ----------- | ---------- |
| Empty screen              | 77.00%   | 17       | 42        | 18          | 24         |
| Moving wallpaper          | 96.00%   | 5        | 179       | 155         | 24         |
| Single rectangle          | 26.00%   | 27       | 5         | 3           | 2          |
| Multiple rectangles       | 81.00%   | 17       | 49        | 19          | 30         |
| Multiple RGB images       | 93.00%   | 11       | 74        | 50          | 24         |
| Multiple ARGB images      | 93.00%   | 12       | 70        | 46          | 24         |
| Rotated ARGB images       | 97.00%   | 2        | 353       | 328         | 25         |
| Multiple labels           | 92.00%   | 14       | 56        | 32          | 24         |
| Screen sized text         | 6.00%    | 5        | 2         | 2           | 0          |
| Multiple arcs             | 85.00%   | 15       | 55        | 31          | 24         |
| Containers                | 93.00%   | 10       | 80        | 57          | 23         |
| Containers with overlay   | 97.00%   | 3        | 254       | 232         | 22         |
| Containers with opa       | 96.00%   | 7        | 121       | 97          | 24         |
| Containers with opa_layer | 96.00%   | 6        | 141       | 117         | 24         |
| Containers with scrolling | 94.00%   | 10       | 86        | 62          | 24         |
| Widgets demo              | 34.00%   | 21       | 39        | 32          | 7          |
| All scenes avg.           | 78.00%   | 11       | 100       | 80          | 20         |



## TroubleShooting

### Output folder permissions

If there is any problem with the output folder generated permissions, modify the permissions: 
```bash
sudo chown -R $(whoami):$(whoami) output/
```



