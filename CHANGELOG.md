# Changelog

## M7 — Scythe Kernel: Reborn (development)

- Adopted the Scythe Kernel: Reborn identity, inspired by the original 2023 project.
- Changed the kernel local version suffix to `-Scythe-Reborn`.
- Added an ASCII recovery banner and graphical README branding.
- Replaced inherited Bifrost artwork while retaining its attribution.
- Renamed build artifacts and enabled CI on `16.0-mem-opt-m7`.
- Added package verification of the included ASCII banner.
- Preserved RMX1911 device checks and functional kernel settings.

Build and on-device validation of the rebranded kernel are pending.

## v1.0-r5x — Stormbreaker stable baseline (M6)

- Validated the M5 kernel through boot, daily usage, camera and suspend/resume testing on RMX1911.
- Enabled strict RMX1911 device checking and verified RC1 installation.
- Published the original tested kernel payload with the updated installer.
- Kernel build commit: `22749f8ce774aec14417dd20faf2b1496423fa52`.
- Installer/source tag commit: `b5e775e65ad838f3fcea74adb925291b2e2e4059`.

## Earlier milestones

- M5: camera registration fix, zRAM metadata allocation fallback, installer validation and conditional recovery backups, automated build and packaging, CI integration.
- M4.1: native 4 GiB zRAM initialization.
- M4: Deadline scheduler and power-efficient workqueues.
- M3: memory reclaim tuning and persistent configuration.
- M1–M2: MGLRU integration and activation, PSI and zstd support.

The stable baseline is not evidence of measured performance gains over stock; controlled benchmarking remains planned.
