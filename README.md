# ZygiskEnv Alpha Bridge - compatibility patch

**Status:** source patch; not validated on a physical Magisk Alpha device.
This is a continuation of [TheSillyOk/ZygiskEnv](https://github.com/TheSillyOk/ZygiskEnv), which is released under the Unlicense.

## What changed

1. Fix installer CPU-family check: `!= arm || != arm64` was true for all values.
2. Use ReZygisk's `PROCESS_IS_MANAGER` as the primary manager signal, with exact-prefix matching for the historical Magisk Alpha and official app package names.
3. Set the process-local `ZYGISK_ENABLED=1` **after `postAppSpecialize`** so the value survives Android's app specialization. Magisk official sets its own marker at this stage.
4. Do not mark unrelated apps as Zygisk-enabled simply because they were granted root. Preserve KernelSU Next manager compatibility while avoiding unrelated root-granted apps.
5. Installer now selects only the ABIs the device supports. Read-only `action.sh` reports diagnostic state.
6. Unit tests, installer simulations and GitHub Actions build provided.

## Important limitation

ReZygisk's current implementation already sets `ZYGISK_ENABLED` for recognized manager processes. This patch provides a targeted fallback for certain package names and re-applies the marker at post-specialize. **It cannot change Magisk Alpha's internal daemon status or guarantee that Magisk Alpha 31.1+ shows the Zygisk UI toggle as enabled.** ReZygisk upstream explicitly removed Magisk Alpha support. Its maintainers advise using official Magisk as a supported configuration. A disabled Magisk Zygisk toggle can be intentional with standalone ReZygisk.

Do **not** enable Magisk's built-in Zygisk simultaneously with ReZygisk. This ZIP is *not* ReZygisk and does not install it.

## Build

- Upload all source files to a GitHub repository. Go to Actions > `ZygiskEnv Alpha Bridge - build/test` > Run workflow.
- Download the **`ZygiskEnv-Alpha-Bridge-release`** artifact (directly a ZIP; no inner ZIP). Install that ZIP from the Magisk Alpha app after disabling built-in Zygisk, uninstalling any competing standalone Zygisk implementation, and installing ReZygisk.
- Or build locally with `NDK_PATH=/path/to/android-ndk make release`. An Android NDK with API 25 support (r29/r30) is expected. `make test` requires a JDK for JNI headers.
- To uninstall safely, remove `ZygiskEnv Alpha Bridge` from Magisk modules and reboot. Successful marker writes are logged with the tag `ZygiskEnvBridge` (view with `su -c "logcat -d -s ZygiskEnvBridge:I"`). Nothing is written to /system or the boot image.

## Source versions verified (8 November 2026)

- ZygiskEnv upstream `main` commit `7437e6d9c10aa0b079b7da69e94b37c6264bd5bc`.
- ReZygisk `main` revision `4aff785a1b82250ab0be7b5e4cae5cdb2f4d988b` (tree identifier).
- Magisk official sources: Zygisk manager process marker in `native/src/core/zygisk/module.cpp` after specialization.
- ReZygisk issue [#406](https://github.com/PerformanC/ReZygisk/issues/406) documents Magisk 31.1 showing Zygisk as disabled while ReZygisk is active.

## Security / test limitations

This is a compatibility experiment, not an upstream-approved fix. Production builds and hardware testing require a working Android NDK and an actual Android device. Root injection has boot stability risks: keep your known-good configuration and a boot recovery method. The local `make test` suite tests only our code and mocked installer, not a real Magisk Alpha installation.
