# LVGL ported to AM62P-LP (TI)

## Overview

This guide provides steps to setup the SK-AM62P-LP starter kit and to cross-compile an LVGL application to run it the target.



## Buy

You can purchase the AM62P-LP board from TI website.



## Benchmark

The default buffering is fbdev.

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

The other configurations are: 

- DRM
- Wayland

Any of these buffering strategies can be used with multiple threads to render the frames.



## Specification

### CPU and memory

- **MCU**: AM625P with Quad 64-bit Arm Cortex-A53 up to 1.4GHz, two ARM Cortex R5F single core up to 800MHz
- **RAM**: 8GB LPDDR4 
  - 32-bits data bus with inline EEC
  - Supports speeds up to 3200 MT/s

- **Flash**: 32GB SD
- **GPU**: PowerVR  

### Display

- Screen: HDMI 1920x1080 touchscreen

### Connectivity

- 1 Type-A USB 2.0
- 1 Type-C dual-role device (DRD) USB 2.0 supports USB booting
- UART
- USB
- Onboard XDS110 Joint Test Action Group (JTAG) emulator
- 4 universal asynchronous receiver-transmitters (UARTs) via USB 2.0-B
- Ethernet



## Getting started

### Hardware setup

This [document](https://dev.ti.com/tirex/content/tirex-product-tree/am62px-devtools/docs/am62px_skevm_quick_start_guide.html) from TI provides detailed information for the hardware setup

- Connect to the board the following: 

  - UART
  - Power
  - Screen (HDMI)
  - Ethernet (Connect the board to the same LAN the host is, the board obtains an IP address from the network manager)

- SD card is needed to flash the image. 

  - Follow the [guide](https://dev.ti.com/tirex/content/tirex-product-tree/am62px-devtools/docs/am62px_skevm_quick_start_guide.html) to download a pre-built `.wic` image

  - Follow this [guide](https://software-dl.ti.com/processor-sdk-linux-rt/esd/AM62PX/09_01_00_08/exports/docs/linux/Overview_Building_the_SDK.html) to build the image with Yocto

- If there are problems encountered flashing the SD card with BalenaEtcher as mentioned in the documentation, use this command instead: 

  ```bash
  # Mount the SD on your system and find where it was mounter (e.g.: sda, sdb)
  sudo dd if=path/to/am62p-image.wic of=/dev/sdX bs=4M status=progress conv=fsync
  ```

- Use the UART to ensure the system has started successfully.



### Software setup

This guide was tested on Ubuntu 22.04 host.

#### Install docker

- Follow this [tutorial](/https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04) to install and setup docker on your system.

- Support to run arm64 docker containers on the host: 
  ```bash
  sudo apt-get install qemu-user-static
  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
  ```

#### Install utilities 

```bash
sudo apt install picocom nmap
```



### Run the default project

Clone the repository: 
```bash
git clone --recurse-submodules https://github.com/lvgl/lv_port_texas_sk-am62p-lp.git
```

Build the docker image and the lvgl benchmark application: 

```bash
cd lv_port_texas_sk-am62p-lp
./scripts/docker_setup.sh --build
./scripts/docker_setup.sh --run
```

Run the executable on the target: 

- Get the IP of the target board:

  - <u>Option 1</u>: from the UART, on the board: 

    ```bash
    sudo picocom -b 115200 /dev/ttyUSB0
    ## Then inside the console, log as "root", no password required 
    ## Then retrieve the ip of the board
    ip a
    ```

  - <u>Option 2</u>: Get the IP from your host with nmap

    ```bash
    ## Find the IP of the board. You need to know your ip (ifconfig or ip a)
    ## HOST_IP should be built like this :
    ## If the ip is 192.168.1.86, in the following command HOST_IP = 192.168.1.0/24
    nmap -sn <HOST_IP>/24 | grep am62pxx   
    ```
  
- Then transfer the executable on the board: 

  ```bash
  scp lvgl_port_linux/bin/lvgl-app root@<BOARD_IP>:/root
  ```
  
- Start the application

  ```bash
  ssh root@<BOARD_IP>
  
  ## stop default presentation screen if it is running
  systemctl stop ti-apps-launcher
  ######################################
  ## WARNING: do not stop these services if using wayland demo
  systemctl stop weston.socket 
  systemctl stop weston.service 
  ######################################
  
  ./lvgl-app
  ```



### Change configuration

Some configurations are provided in the folder `lvgl_conf_example` .

The default configuration used is lv_conf_fb_4_threads.h. To change the configuration, modify the `lvgl_port_linux/lv_conf.h` file with the desired configuration.

Also modify the `lvgl_port_linux/CMakelists.txt` file option: 

- LV_USE_WAYLAND
- LV_USE_SDL
- LV_USE_DRM

Default is for fbdev backend. Only set 1 of these options to "ON" and ensure it's coherent with `lv_conf.h`. This can also be changed from the script `scripts/build_app.sh`.



### Start with your own application

The folder `lvgl_port_linux` is an example of an application using LVGL. 

LVGL is integrated as a submodule in the folder. To change the version of the library: 

```bash
cd lvgl_port_linux
git checkout <branch_name_or_commit_hash>
```

The file `main.c` is the default application provided and is configured to run the benchmark demo provided by LVGL library. 

The main steps to create your own application are: 

- Modify `main.c`
- Add any folders and files to extend the functionalities
- Update `Dockerfile` to add any package
- Modify `CMakeLists.txt` provided file to ensure all the required files are compiled and linked
- Use the docker scripts provided to build the application for ARM64 architecture.



## TroubleShooting

### Output folder permissions

If there is any problem with the output folder generated permissions, modify the permissions: 

```bash
sudo chown -R $(whoami):$(whoami) lvgl_port_linux/bin
```



### Wayland example runtime error

While running the application, if there is an error about `XDG_RUNTIME_DIR`, add the following environment variable on the board.

```bash
export XDG_RUNTIME_DIR=/run/user/1000
```



## Contribution and Support

If you find any issues with the development board feel free to open an Issue in this repository. For LVGL related issues (features, bugs, etc) please use the main [lvgl repository](https://github.com/lvgl/lvgl).

If you found a bug and found a solution too please send a Pull request. If you are new to Pull requests refer to [Our Guide](https://docs.lvgl.io/master/CONTRIBUTING.html#pull-request) to learn the basics.
