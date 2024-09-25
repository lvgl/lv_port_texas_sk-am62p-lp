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

The guide is based on TI [documentation](https://dev.ti.com/tirex/content/tirex-product-tree/am62px-devtools/docs/am62px_skevm_quick_start_guide.html)

- Connect to the board the following: 

  - UART
  - Power
  - Screen (HDMI)
  - Ethernet

- SD card is needed to flash the image. Follow the [guide](https://dev.ti.com/tirex/content/tirex-product-tree/am62px-devtools/docs/am62px_skevm_quick_start_guide.html) to download or build the `.wic` image

- If there are problems encountered flashing the SD card with BalenaEtcher as mentioned in the documentation, use this command instead: 

  ```bash
  # Mount the SD on your system and find where it was mounter (e.g.: sda, sdb)
  sudo dd if=path/to/am62p-image.wic of=/dev/sdX bs=4M status=progress conv=fsync
  ```

- Use the UART to ensure the system has started successfully.



## Run LVGL on the board

### Start default benchmark configuration 

Support to run docker systems on arm64: 

```bash
sudo apt-get install qemu-user-static
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

Build the docker image: 

```bash
./scripts/docker_setup.sh --build
```

Run the executable on the target: 

- Get the IP of the target board:

  - Option 1: from the UART, on the board: 

    ```bash
    sudo picocom -b 115200 /dev/ttyUSB0
    ## Then inside the console, log as "root", no password required 
    ## Then retrieve the ip of the board
    ip a
    ```

  - Option 2 : Get the IP from your host with nmap

    ```bash
    ## Install nmap if it is not yet on your system
    sudo apt install nmap
    ## Find the IP of the board. You need to know your ip (ifconfig or ip a)
    ## HOST_IP should be built like this :
    ## If the ip is 192.168.1.86, then HOST_IP = 192.168.1.0/24
    nmap -sn <HOST_IP>.0/24 | grep am62pxx   
    ```

- Then transfer the executable on the board: 

  ```bash
  ## Copy the executable on the host
  ./scripts/docker_setup.sh --run
  
  ## Transfer the executable on the board
  scp lvgl_port_linux/bin/lvgl-app root@<BOARD_IP>:/root
  ```

- Start the application

  ```bash
  ssh root@<BOARD_IP>
  
  ## stop default presentation screen if it is running
  systemctl stop ti-apps-launcher
  ######################################
  ## WARNING: Not to do if using wayland
  systemctl stop weston.socket 
  systemctl stop weston.service 
  ######################################
  
  ./lvgl-app
  ```



### Change configuration

Some configurations are provided in the folder `lvgl_conf_example` .

The default configuration used is lv_conf_fb_4_threads.h. To change the configuration, modify the `lvgl_port_linux/lv_conf.h` file with the desired configuration.

Also modify the `lv_port_linux/CMakelists.txt` file option: 

- LV_USE_WAYLAND
- LV_USE_SDL
- LV_USE_DRM

Default is for fbdev backend. Only set 1 of these options to "ON" and ensure it's coherent with `lv_conf.h`. This can also be changed from the script `scripts/build_app.sh`.



### Start with your own application

The folder `lvgl_port_linux` is an example of an application using LVGL. 

LVGL is integrated as a submodule in the folder. To change the version of LVGL, modify the submodule properties in the file `.gitmodules`.

The file `main.c` is the default application provided and is configured to run the benchmark demo provided by LVGL library. 

The main steps to create your own application are: 

- Modify `main.c`
- Add any folders and files to extend the functionalities
- Update `Dockerfile` to add any package
- Modify `CMakeLists.txt` provided file to ensure all the required files are compiled and linked
- Use the docker scripts provided to build the application for arm64 architecture.



## Benchmark results

**Frame buffer, 1 thread**

| Name                      | Avg. CPU | Avg. FPS | Avg. time | render time | flush time |
| ------------------------- | -------- | -------- | --------- | ----------- | ---------- |
| Empty screen              | 15.00%   | 24       | 5         | 1           | 4          |
| Moving wallpaper          | 29.00%   | 27       | 9         | 5           | 4          |
| Single rectangle          | 5.00%    | 27       | 0         | 0           | 0          |
| Multiple rectangles       | 14.00%   | 27       | 4         | 2           | 2          |
| Multiple RGB images       | 31.00%   | 27       | 9         | 5           | 4          |
| Multiple ARGB images      | 66.00%   | 28       | 21        | 17          | 4          |
| Rotated ARGB images       | 94.00%   | 5        | 167       | 163         | 4          |
| Multiple labels           | 59.00%   | 28       | 15        | 11          | 4          |
| Screen sized text         | 2.00%    | 27       | 0         | 0           | 0          |
| Multiple arcs             | 43.00%   | 28       | 14        | 10          | 4          |
| Containers                | 74.00%   | 28       | 24        | 20          | 4          |
| Containers with overlay   | 91.00%   | 16       | 51        | 47          | 4          |
| Containers with opa       | 90.00%   | 17       | 49        | 45          | 4          |
| Containers with opa_layer | 92.00%   | 13       | 67        | 63          | 4          |
| Containers with scrolling | 85.00%   | 27       | 28        | 24          | 4          |
| Widgets demo              | 28.00%   | 27       | 8         | 7           | 1          |
| All scenes avg.           | 51.00%   | 23       | 29        | 26          | 3          |

**Frame buffer, 4 threads**

| Name                      | Avg. CPU | Avg. FPS | Avg. time | render time | flush time |
| ------------------------- | -------- | -------- | --------- | ----------- | ---------- |
| Empty screen              | 15.00%   | 24       | 5         | 1           | 4          |
| Moving wallpaper          | 26.00%   | 27       | 8         | 4           | 4          |
| Single rectangle          | 5.00%    | 26       | 0         | 0           | 0          |
| Multiple rectangles       | 19.00%   | 28       | 6         | 4           | 2          |
| Multiple RGB images       | 28.00%   | 27       | 8         | 4           | 4          |
| Multiple ARGB images      | 40.00%   | 28       | 12        | 8           | 4          |
| Rotated ARGB images       | 87.00%   | 14       | 60        | 56          | 4          |
| Multiple labels           | 40.00%   | 27       | 9         | 5           | 4          |
| Screen sized text         | 2.00%    | 27       | 0         | 0           | 0          |
| Multiple arcs             | 27.00%   | 27       | 8         | 4           | 4          |
| Containers                | 45.00%   | 26       | 14        | 10          | 4          |
| Containers with overlay   | 78.00%   | 28       | 26        | 22          | 4          |
| Containers with opa       | 79.00%   | 28       | 23        | 19          | 4          |
| Containers with opa_layer | 85.00%   | 23       | 33        | 29          | 4          |
| Containers with scrolling | 51.00%   | 28       | 16        | 12          | 4          |
| Widgets demo              | 19.00%   | 27       | 6         | 5           | 1          |
| All scenes avg.           | 40.00%   | 25       | 14        | 11          | 3          |



## TroubleShooting

### Output folder permissions

If there is any problem with the output folder generated permissions, modify the permissions: 

```bash
sudo chown -R $(whoami):$(whoami) output/
```



### Wayland example runtime error

While running the application, if there is an error about `XDG_RUNTIME_DIR`, add the following environment variable on the board.

```bash
export XDG_RUNTIME_DIR=/run/user/1000
```
