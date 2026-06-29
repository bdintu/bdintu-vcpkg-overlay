# bdintu vcpkg overlay Agent Guide

Read `README.md` first for every task in this repo. It defines the supported
overlay layout, triplets, usage commands, and maintained ports.

## Scope

This repo owns shared vcpkg overlay ports and triplets used by bdintu C++
projects.

- `ports/` owns custom vcpkg ports that are not maintained in the upstream vcpkg
  registry for these projects.
- `triplets/` owns supported debug and release triplets.
- `README.md` owns user-facing usage commands and supported triplet/port lists.

## Rules

- Keep ports pinned to explicit upstream tags or commits.
- Prefer overlay ports over manual `/usr/local` dependency installs.
- Document every supported triplet in `README.md`.
- When adding or changing a port, update `README.md` if usage, supported ports,
  or supported triplets change.
- Keep triplet names explicit about architecture, platform, and build mode, such
  as `arm64-osx-debug` or `x64-linux-release`.
- Do not edit the upstream vcpkg checkout under `$VCPKG_ROOT` for project
  behavior. Put reusable changes in this overlay repo instead.
- Do not add one-off local machine paths to ports, triplets, or README examples
  unless they are clearly marked as examples.

## Validation

For port or triplet changes, validate with a fresh build directory in a consumer
project when practical. At minimum, run CMake configure with the changed overlay
paths and target triplet.
