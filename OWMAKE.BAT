@ECHO OFF

REM Make sure WASM and WLINK are in your path before you run this batch file.

del *.com
del *.exe

wasm player.asm
wasm cmdline.asm
wasm codec.asm
wasm file.asm
wasm ichwav.asm
wasm memalloc.asm
wasm pci.asm
wasm utils.asm

REM Add the parameter `com` between `dos` and `file` to build a COM file instead of an EXE file (requires tiny mem model)
wlink sys dos file player.o file cmdline.o file codec.o file file.o file ichwav.o file memalloc.o file pci.o file utils.o

del *.o
