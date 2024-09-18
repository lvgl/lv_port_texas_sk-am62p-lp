# LVGL ported to AM62P-LP (TI)

## Overview

This guide provides steps to setup the AM62P-LP board and to cross cross-compile an LVGL project on the target.



## Buy

You can purchase the AM62P-LP board directly from TI website.



## Specification

### CPU and memory

- Module: AM62P
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
| Empty screen              | 43.00%   | 25       | 15        | 7           | 8          |
| Moving wallpaper          | 87.00%   | 13       | 68        | 59          | 9          |
| Single rectangle          | 16.00%   | 29       | 2         | 1           | 1          |
| Multiple rectangles       | 51.00%   | 29       | 17        | 6           | 11         |
| Multiple RGB images       | 87.00%   | 18       | 45        | 37          | 8          |
| Multiple ARGB images      | 88.00%   | 20       | 39        | 30          | 9          |
| Rotated ARGB images       | 96.00%   | 5        | 162       | 153         | 9          |
| Multiple labels           | 86.00%   | 27       | 27        | 19          | 8          |
| Screen sized text         | 5.00%    | 5        | 2         | 2           | 0          |
| Multiple arcs             | 80.00%   | 20       | 39        | 31          | 8          |
| Containers                | 82.00%   | 25       | 29        | 21          | 8          |
| Containers with overlay   | 94.00%   | 8        | 107       | 96          | 11         |
| Containers with opa       | 94.00%   | 9        | 91        | 78          | 13         |
| Containers with opa_layer | 95.00%   | 8        | 106       | 92          | 14         |
| Containers with scrolling | 92.00%   | 15       | 57        | 49          | 8          |
| Widgets demo              | 50.00%   | 20       | 33        | 29          | 4          |
| All scenes avg.           | 71.00%   | 17       | 52        | 44          | 8          |

**Frame buffer, 4 threads**

| Name                      | Avg. CPU | Avg. FPS | Avg. time | render time | flush time |
| ------------------------- | -------- | -------- | --------- | ----------- | ---------- |
| Empty screen              | 44.00%   | 25       | 15        | 7           | 8          |
| Moving wallpaper          | 86.00%   | 12       | 68        | 59          | 9          |
| Single rectangle          | 21.00%   | 29       | 2         | 1           | 1          |
| Multiple rectangles       | 50.00%   | 28       | 18        | 7           | 11         |
| Multiple RGB images       | 81.00%   | 28       | 27        | 18          | 9          |
| Multiple ARGB images      | 76.00%   | 27       | 24        | 15          | 9          |
| Rotated ARGB images       | 95.00%   | 6        | 132       | 123         | 9          |
| Multiple labels           | 70.00%   | 29       | 20        | 12          | 8          |
| Screen sized text         | 4.00%    | 5        | 1         | 1           | 0          |
| Multiple arcs             | 74.00%   | 28       | 25        | 16          | 9          |
| Containers                | 69.00%   | 27       | 22        | 14          | 8          |
| Containers with overlay   | 93.00%   | 9        | 93        | 82          | 11         |
| Containers with opa       | 93.00%   | 12       | 70        | 58          | 12         |
| Containers with opa_layer | 87.00%   | 22       | 35        | 26          | 9          |
| Containers with scrolling | 87.00%   | 23       | 34        | 25          | 9          |
| Widgets demo              | 50.00%   | 22       | 25        | 21          | 4          |
| All scenes avg.           | 67.00%   | 20       | 37        | 30          | 7          |



## TroubleShooting

### Output folder permissions

If there is any problem with the output folder generated permissions, modify the permissions: 
```bash
sudo chown -R $(whoami):$(whoami) output/
```



