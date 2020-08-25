# Minecraft Server Scripts

Helper scripts to do various things.

Disclaimer: You should **never** trust these scripts, as with all scripts on the Internet. Double-check them and use them on your own risk.

## Minecraft server as systemd service

Run your Minecraft server as non-privileged user inside a screen managed by systemd, so it starts on server-startup and stopps on server shutdown. Allows as many servers as you like to run in parallel. `minecraftctl` offers starting and stopping servers, creating new instances and opening the terminal by multiple users in parallel.

### Files

Inside folder `minecraft-server-systemd`:
- `minecraftctl`
- `minecraft@.service`

### Installation

- Create a unix user and group `minecraft`
  - You can use other user and group names, adjust `minecraft@.service`'s `User=` and `Group=` settings and `minecraftctl`'s `SCREEN_OWNER` constant accordingly
- Put `minecraft@.service` into `/etc/systemd/system/`
- Put `minecraftctl` into `/usr/local/bin/` and ensure it is executable by everyone and owned by root
  - You can put `minecraftctl` somewhere else, but you then need to adjust the `SAFE_SELF` constant inside the script
- Create a sudoers entry to allow users or a group of your choice to execute `minecraftctl` with elevated permissions

### Usage

- `minecraftctl`: show help
- `minecraftctl start <server-id>`: start the server with given id
- `minecraftctl stop <server-id>`: stop the server with given id
- `minecraftctl restart <server-id>`: restart the server with given id
- `minecraftctl status <server-id>`: show the status of the server with given id
- `minecraftctl enable <server-id>`: enable the server with given id to be started automatically on system boot
- `minecraftctl disable <server-id>`: disable the server with given id to be no longer started automatically on system boot
- `minecraftctl create <server-id> <executable>`: create a new server instance with given id and executable

## Downloader

Download the latest or any other paper executable.

### Files

Inside folder `downloader`:
- `paper-download`

### Installation

- Put `paper-download` into `/usr/local/bin/` and ensure it is executable by everyone

### Usage

- `paper-download`: download latest paper build of the latest minecraft version available
- `paper-download <minecraft-version>`: download latest paper build of the given minecraft version
- `paper-download <minecraft-version> <build>`: download the given paper build of the given minecraft version

## World in Ramdisk

Put your worlds into a ramdisk for faster load and save times.

### Files

Inside folder `world-ramdisk`:
- `minecraft-ramdisk-prepare.service`
- `minecraft-ramdisk.timer`
- `minecraft-ramdisk.service`

### Installation

- Put `minecraft-ramdisk-prepare.service`, `minecraft-ramdisk.timer` and `minecraft-ramdisk.service` into `/etc/systemd/system/`
- Adjust paths inside both service units to match your world storage
- Tell your server to use the worlds inside your ramdisk
  - Either use `--world-dir /dev/shm/minecraft/` if your server supports it
  - Or create symlinks to your worlds from the server directory to the shared memory worlds