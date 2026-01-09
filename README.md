# trdp-cmake

This repository provides clean, source-only snapshots of TRDP releases, with a minimal CMake build for each available version.

## Available versions

- 1.3.3.0
- 2.0.3.0
- 2.1.0.0
- 3.0.0.0

## CI

CI builds all supported TRDP versions in a matrix and validates that PRs keep `versions/` source-only (only `.c`, `.h`, and `.md` files are allowed).

## Build

`libtrdp` is always built. `libtrdpap` is built when helper sources (TAU/XML/marshalling, etc.) exist for the selected TRDP version.

```sh
cmake -S . -B build -DTRDP_VERSION=1.3.3.0 -DTRDP_MD_SUPPORT=ON
cmake --build build -j
```

```sh
cmake -S . -B build -DTRDP_VERSION=2.0.3.0 -DTRDP_MD_SUPPORT=ON
cmake --build build -j
```

```sh
cmake -S . -B build -DTRDP_VERSION=2.1.0.0 -DTRDP_MD_SUPPORT=ON
cmake --build build -j
```

```sh
cmake -S . -B build -DTRDP_VERSION=3.0.0.0 -DTRDP_MD_SUPPORT=ON
cmake --build build -j
```

To build example/tool executables when sources exist:

```sh
cmake -S . -B build -DTRDP_VERSION=3.0.0.0 -DTRDP_BUILD_EXAMPLES=ON
cmake --build build -j
```

To disable MD support:

```sh
cmake -S . -B build -DTRDP_VERSION=3.0.0.0 -DTRDP_MD_SUPPORT=OFF
```

## Install

Local prefix install:

```sh
cmake -S . -B build -DTRDP_VERSION=3.0.0.0 -DTRDP_BUILD_TRDPAP=ON
cmake --build build -j
cmake --install build --prefix "$PWD/install"
```

System install (default prefix):

```sh
sudo cmake --install build
```

Headers are installed under `<prefix>/include/trdp/<TRDP_VERSION>/`.

## Use from another project

Configure your app with a prefix that contains the TRDP package files:

```sh
cmake -S path/to/app -B app_build -DCMAKE_PREFIX_PATH=/path/to/install
```

In your app CMakeLists:

```cmake
find_package(TRDP CONFIG REQUIRED)
target_link_libraries(app PRIVATE trdp::trdp)
```

Consumers should rely on the imported target include dirs (from `trdp::trdp`) rather than hardcoding header paths.

Note: the `versions/` tree keeps only `.c`, `.h`, and `.md` files after cleanup.
