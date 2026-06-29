# bdintu vcpkg overlay

Shared vcpkg overlay ports and triplets for bdintu C++ projects. Debug triplets use static libraries for easier debugging; release triplets use dynamic libraries so multiple services can share dependency text pages in memory.

## Layout

- `ports/` contains custom vcpkg ports that are not managed in the upstream vcpkg registry for these projects.
- `triplets/` contains supported debug and release triplets used by local and container builds.

## Supported Triplets

- `arm64-osx-debug`
- `arm64-osx-release`
- `arm64-linux-debug`
- `arm64-linux-release`
- `x64-linux-debug`
- `x64-linux-release`

## Usage

These commands assume this overlay repo is checked out next to the project repo:

```text
/Users/j/src/bdintu/
  bdintu-vcpkg-overlay/
  drogon-scylladb-crud-basic/
```

Use a fresh build directory when changing triplets or build types. Release triplets are dynamic-linkage triplets; package/runtime setup must make the resulting shared libraries available to the service binaries.

macOS ARM64 release build with tests and install:

```sh
cmake -S . -B build -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DCMAKE_BUILD_TYPE=Release \
  -DVCPKG_OVERLAY_PORTS="$PWD/../bdintu-vcpkg-overlay/ports" \
  -DVCPKG_OVERLAY_TRIPLETS="$PWD/../bdintu-vcpkg-overlay/triplets" \
  -DVCPKG_TARGET_TRIPLET=arm64-osx-release \
  && cmake --build build --parallel \
  && ctest --test-dir build -L unit --output-on-failure \
  && ctest --test-dir build -L integration --output-on-failure \
  && cmake --install build
```

macOS ARM64 debug build:

```sh
cmake -S . -B build-debug -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DVCPKG_OVERLAY_PORTS="$PWD/../bdintu-vcpkg-overlay/ports" \
  -DVCPKG_OVERLAY_TRIPLETS="$PWD/../bdintu-vcpkg-overlay/triplets" \
  -DVCPKG_TARGET_TRIPLET=arm64-osx-debug \
  && cmake --build build-debug --parallel
```

Linux ARM64 release build:

```sh
cmake -S . -B build-linux-arm64-release -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DCMAKE_BUILD_TYPE=Release \
  -DVCPKG_OVERLAY_PORTS="$PWD/../bdintu-vcpkg-overlay/ports" \
  -DVCPKG_OVERLAY_TRIPLETS="$PWD/../bdintu-vcpkg-overlay/triplets" \
  -DVCPKG_TARGET_TRIPLET=arm64-linux-release \
  && cmake --build build-linux-arm64-release --parallel
```

Linux x64 release build:

```sh
cmake -S . -B build-linux-x64-release -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DCMAKE_BUILD_TYPE=Release \
  -DVCPKG_OVERLAY_PORTS="$PWD/../bdintu-vcpkg-overlay/ports" \
  -DVCPKG_OVERLAY_TRIPLETS="$PWD/../bdintu-vcpkg-overlay/triplets" \
  -DVCPKG_TARGET_TRIPLET=x64-linux-release \
  && cmake --build build-linux-x64-release --parallel
```

## Ports

### scylla-cpp-driver

Builds ScyllaDB's C/C++ driver from `https://github.com/scylladb/cpp-driver.git`, pinned to tag `2.16.2-1` commit `4bf44c772d6f5b9ddace963acc292981c35a3a8d`.
