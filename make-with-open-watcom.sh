#!/bin/sh

# Important: make sure to source owsetenv.sh in your Open Watcom installation directory first, so that wasm and wlink
# are available in the path. Otherwise this make script will fail.

set -e

if [ -f player.exe ]; then
  rm player.exe
fi

wasm player.asm
wasm cmdline.asm
wasm codec.asm
wasm file.asm
wasm ichwav.asm
wasm memalloc.asm
wasm pci.asm
wasm utils.asm

# Add the parameter `com` between `dos` and `file` to build a COM file instead of an EXE file (requires tiny mem model)
wlink sys dos file player.o file cmdline.o file codec.o file file.o file ichwav.o file memalloc.o file pci.o file utils.o

rm *.o
