# Minecraft Server Scripts

Helper scripts to do various things.

## Disclaimer

> You should **never** trust these scripts, as with all scripts on the Internet. Double-check them and use them at your own risk.

## Scripts

- [Minecraft server as systemd service](#minecraft-server-as-systemd-service)
- [Downloader](#downloader)
- [World in Ramdisk](#world-in-ramdisk)
- [Logfile analysis tools](#logfile-analysis-tools)

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

Download or compile the latest or a specific build of bukkit, spigot, paper or tuinity server.

### Note

`spigot-download` will create additional folders and files, you might want to execute it in its own folder.

### Files

Inside folder `downloader`:
- `spigot-download`
- `paper-download`
- `tuinity-download`

### Installation

- Put `spigot-download` into `/usr/local/bin/` and ensure it is executable by everyone
- Put `paper-download` into `/usr/local/bin/` and ensure it is executable by everyone
- Put `tuinity-download` into `/usr/local/bin/` and ensure it is executable by everyone
- You might want to create a symlink for `bukkit-download`: `ln -sf -T spigot-download bukkit-download`
- Install `jq` on your system (for paper and tuinity, optional for bukkit and spigot)
- Install `git` (for bukkit and spigot)

### Usage

- `spigot-download`: compile bukkit and spigot for the latest minecraft version available
- `spigot-download <minecraft-version>`: compile bukkit and spigot for the given minecraft version
- `paper-download`: download latest paper build of the latest minecraft version available
- `paper-download <minecraft-version>`: download latest paper build of the given minecraft version
- `paper-download <minecraft-version> <build>`: download the given paper build of the given minecraft version
- `tuinity-download`: download latest tuinity build available
- `tuinity-download <build>`: download the given tuinity build

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

## Logfile analysis tools

Analyse minecraft server logs to extract some information.

### Files

Inside folder `logfile-analysis`:
- `userjoins.sh`
- `process-userjoins.r`

### Installation

- Ensure you have `bash` installed
- Put `userjoins.sh` and `process-userjoins.r` somewhere you have easy access (e.g. `~/.bin/` or `/usr/local/bin/`) and ensure it is executable
  - I don't recommend installing it globally, but it is possible and won't break anything
- Install [R](https://www.r-project.org/) on your system
  - If you analyze files on a remote server you might want to install R locally instead
  - Required R libraries:
    - Either `readr` and `tibble`
    - Or [the complete `tidyverse` library](https://www.tidyverse.org/)

### Usage

1. Create a directory for analysis files (e.g. `mkdir -p ~/server/analytics`)
2. Change directory into your analysis folder (e.g. `cd ~/server/analytics`)
3. Execute `userjoins.sh <log dir>` (e.g. `~/.bin/userjoins.sh ../logs/`)
4. If you want to download all files, pack them: `tar -czf analysis.tar.gz *.csv`
5. Execute `process-userjoins.r` (e.g. `~/.bin/process-userjoins.r`)
6. The R script writes the output to `analysis.csv`

#### Additional information
- Note that consecutive executions of `process-userjoins.r` will fails, as the script can't differentiate between the old `analysis.csv` and the input data.
- If you don't specify the log directory to `userjoins.sh` it will assume `../logs` by default.
- You can adjust the logging level of `userjoins.sh` by setting the `LOG_LEVEL` environment variable:
  ```shell script
  LOG_LEVEL=2 userjoins.sh /path/to/logs
  ```
  Valid levels are:
  - `0` for `DEBUG`
  - `1` for `INFO`
  - `2` for `WARNING`
  - `3` for `SEVERE`
- To set a custom time zone set the `TIMEZONE` environment variable: 
  ```shell script
  TIMEZONE='+05:30' userjoins.sh /path/to/logs
  ```
  The default is the system's time zone.
