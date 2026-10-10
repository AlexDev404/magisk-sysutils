# SysUtils

A [Magisk](https://github.com/topjohnwu/Magisk) module that installs a collection of prebuilt Android arm64 command-line utilities into `/system/xbin`, turning a rooted device into a much more capable Unix-like environment without needing a chroot, Termux, or a separate userspace.

## What it does

On install, the module's `customize.sh`:

1. Reads the device's Android SDK/API level via `getprop ro.build.version.sdk`.
2. Selects and installs the matching prebuilt `dmctl` binary for that API level (Android 13/34/35, from `META-INF/dmctl/`), since `dmctl` must be built against the specific platform version.
3. Copies all binaries from `system/xbin` into place and sets ownership/permissions (`root:root`, `0755`) recursively.

The rest of the module is a static payload — a directory of statically/arm64-linked binaries staged at `system/xbin` that Magisk's `system-as-root` overlay merges into `/system/xbin` on boot.

## Included utilities

`system/xbin` bundles utilities across several categories:

- **Shells & terminal**: `bash`, `mksh`, `tmux`, `script`
- **Editors**: `vim`, `nano`, `bvi`
- **Networking**: `curl`, `wget2`, `dig`, `dnsmasq`, `ncat`, `socat`, `stunnel`, `rsync`, `unfsd`, `ifconfig`, `route`, `netstat`, `arp`, `iptunnel`, `ipmaddr`, `mii-tool`, `nameif`, `rarp`, `ngrep`, `hostname`, `darkhttpd`
- **Process/system monitoring**: `htop`, `btop`, `nmon`, `pstree`, `strace`, `gdb`, `gdbserver`, `fuser`, `killall`, `pagemon`, `top`
- **Archives & compression**: `tar`, `zip`/`unzip`/`unzipsfx`/`funzip`/`zipcloak`/`zipnote`/`zipsplit`, `gzip`/`gunzip`, `pigz`, `zstd`, `xz`, `7zz`, `cpio`
- **Text processing**: `grep`, `awk`, `gawk`, `bc`, `xxd`, `less`/`lessecho`/`lesskey`, `bmore`, `bvmore`
- **Filesystem**: `find`, `mount`, `umount`, `losetup`, `mkfs.ext3`, `mkfs.ext4`
- **Databases**: `sqlite3` (plus pinned `3.50.1` / `3.50.4` builds, static and dynamic)
- **Security/crypto**: `openssl`, `sepolicy-inject`
- **Misc**: `run`, `protoc`, `toybox-debug`

See `module.prop` for the exact utility count shipped in the current release.

## Requirements

- A rooted Android device running **Magisk** (or a compatible root solution, e.g. KernelSU/APatch, that supports Magisk modules).
- **Android 13 (API 33) or newer.** Devices below API 33 will still install the module but `dmctl` will be skipped as unsupported.
- `arm64` device architecture (binaries are prebuilt for arm64 only).

## Installation

1. Download or build the module zip (it should contain `module.prop`, `customize.sh`, `META-INF/`, and `system/xbin/` at the root).
2. Flash it via **Magisk Manager → Modules → Install from storage**.
3. Reboot.
4. Once rebooted, the utilities are available directly from `/system/xbin`, which should already be on `PATH` for a root shell.

## Verifying the install

```sh
su -c 'ls /system/xbin'
su -c '/system/xbin/bash --version'
su -c '/system/xbin/dmctl --help'
```

If `dmctl` is missing, check the install log for the detected API level — it is intentionally omitted on API < 33.

## Repository layout

```
.
├── module.prop              # Magisk module metadata (id, name, version, description)
├── customize.sh              # Install-time script: picks dmctl variant, sets permissions
├── META-INF/
│   ├── com/google/android/   # Standard Magisk update-binary/updater-script
│   └── dmctl/                 # Per-API dmctl binaries (android33/34/35)
└── system/xbin/               # All installed utility binaries
```

## Updating utilities

To bump a binary or add a new one, drop it into `system/xbin/`, update the count/description in `module.prop`, bump `version`/`versionCode`, and re-zip the module root (not the parent folder) for distribution.

## License

Bundled binaries retain the licenses of their respective upstream projects (bash, vim, GNU coreutils/awk/grep, tmux, OpenSSL, 7-Zip, zstd, etc.). No license is asserted over third-party binaries by this module.
