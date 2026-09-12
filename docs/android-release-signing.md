# Android Release Signing and Verification Runbook

## Overview

Tarwi2a enforces strict compile-time release signing validation. The build configuration (`android/app/build.gradle.kts`) rejects any attempt to produce release artifacts using debug keystores or placeholder credentials.

## Configuration Requirements

1. Copy `android/key.properties.example` to `android/key.properties`:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
2. Populate `android/key.properties` with valid owner credentials:
   ```properties
   keyAlias=<release_key_alias>
   keyPassword=<release_key_password>
   storeFile=<path_to_keystore_file>
   storePassword=<keystore_password>
   ```
   Note: `key.properties` and keystore files (`*.jks`, `*.keystore`, `*.p12`) are strictly ignored in `.gitignore` and must NEVER be committed to version control.

## Release Build Execution

Once valid signing credentials are provided, generate the production Android App Bundle (AAB):

```bash
flutter build appbundle --release --no-pub --obfuscate --split-debug-info=./symbols
```

## Post-Build Verification Gate

1. **Verify Certificate Fingerprint**:
   Inspect the produced AAB or extracted APK to confirm it was signed with the production release certificate, never the Android debug certificate:
   ```bash
   keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
   ```
   Verify the SHA-256 fingerprint matches the Play Console App Integrity certificate.

2. **16 KB Page-Size Compatibility Inspection**:
   Google Play requires 64-bit native libraries to support 16 KB page alignment:
   Extract native shared libraries (`.so`) from the bundle and inspect ELF alignment using `readelf` or the Android 16 KB check tool:
   ```bash
   # Unpack AAB using bundletool or unzip
   unzip -q build/app/outputs/bundle/release/app-release.aab -d build/aab-extracted
   # Inspect each .so in base/lib/arm64-v8a/
   find build/aab-extracted/base/lib -name "*.so" -exec objdump -p {} + | grep LOAD
   ```
   Confirm all `LOAD` program headers have `align 2**14 (0x4000)` or `align 2**16 (0x10000)`.

## Build Behavior Matrix

| Build Type | Command | Behavior | Signing Result |
|---|---|---|---|
| Debug | `flutter build apk --debug` | Builds successfully | Android debug certificate |
| Release (Missing `key.properties`) | `flutter build appbundle --release` | Fails fast with descriptive error | No artifact generated |
| Release (Configured `key.properties`) | `flutter build appbundle --release` | Produces production AAB | Production release certificate |
