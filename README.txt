.wav file player for DOS

Originally developed and shared by:

jeff leyda
jeff@silent.net
sep 02 2002

(With some small modifications/additions made by Volkert de Buisonjé)

Uses AC'97 audio on supported Intel chipsets
(ICH/ICH0/ICH2/ICH3/ICH4/ICH5/ESB/ICH6/ICH7 southbridge, or 440MX chipset)
No drivers required. (there aren't any for DOS anyway!)



Usage: player <wavfile.wav>

Or, to maximize the codec output volume before playing (be careful!):

       player /v <wavfile.wav>

To stop playback, press either SHIFT key.  

-----------------------------------------------------------------------------



Major issues:

1) Doesn't properly examine the .wav file header to find the start of the
data chunks, and it also assumes that there is only 1 data chunk in the file.

[The project I required this code for was for a very controlled situation
where I knew the format of the .wav file was never going to vary, so I didn't
implement proper .wav header parsing.  You get what you pay for.]

2) Only the ICH2 chip has been tested on real hardware at the moment. The older
(first generation) ICH has been successfully tested in both QEMU+KVM and
VirtualBox VMs, but has yet to be tested on actual hardware. Other ICHes (up to
ICH7) should be compatible with the the ICH2 but these haven't been tested yet.
If you have tested with any of these chipsets, please share your findings!

3) ONLY supports 16bit samples, stereo format .wav files.  Multiple sample
rates are supported.


Minor issues:

1) The last chunk of the .wav data is padded with 0's so that the .wav file is
broken down into multiples of 64k in size.  All this really means is that
the .wav file might play slightly more silence at the end of a song than the
true length of the file.  


2) If your BIOS hasn't allocated the resources for the AC97 device's Base
Address Registers or enabled I/O decoding, this program won't allocate or
enable them for you.   Try setting your BIOS up to a non plug-n-play O/S.
If you don't know what that means, you might be over your head with this code.


3) Doesn't seem to work under windows 98SE very well.  Windows might have a
lock on the bus master and mixer registers and won't allow a DOS window to
modify them.  Use this program in pure DOS only.  (memory managers are ok, in
fact I suggest using himem.sys and smartdrv.exe to speed up initial file load
time.)


4) No volume adjustments are made to the codec by default.  Your mixer and
codec might default to muted and/or off when you boot into DOS. Add "/v" as a
first parameter (before the WAV file path argument) to force the player to set
the volume to maximum before playing the file. Be careful about turning down
the volume knob of your speakers first, though! Also, this volume will then
remain at that level until you either reboot your system or use some other
utility to adjust the codec volume further.


5) The detection routine seems to be quite slow, at least in a QEMU VM or when
running in DOSBox. The detection speed might be better on actual hardware,
though. If anybody knows a way to speed up the detection process, please share
how.


-----------------------------------------------------------------------------


Good reading materials:

1) Intel 82801AA (ICH) and intel 8201AB (ICH0) I/O controller Hub.
order number 290655-001
(any of the ICH based datasheets should do)

2) Intel Audio Codec '97 specification version 2.3
(no document # that I can find)
(has lots of information that programmers don't really need.  Ignore everyhing
about codec "slots", it'll only confuse the issue)


3) Intel 8201BA I/O Controller Hub (ICH2) AC97 Programmers reference manual.
Order number 298238-001
This one was hard to find on intel's web site but it provided the bulk of the
information required to figure this thing out.


4) Intel 810 and friends ICH driver for linux source code.  Look for ICHWAV.C

5) various .wav file format specs available everywhere on the web.

6) an excellent PCI programming guide at
https://www.waste.org/~winkles/hardware/pci.htm (also by Jeff, coincidentally)

7) List of PCI BIOS function IDs in the FreeBSD source code:
https://github.com/freebsd/freebsd/blob/master/sys/i386/include/pc/bios.h


------------------------------------------------------------------------------



Playing a .wav file using the ICH AC'97 in a nutshell:

1) locate the AC'97 device in PCI space.

2) get Mixer base address register and Bus Master base address register.

3) open file, examine playback sample rate and program into codec/mixer.
   Set volumes, mutes, etc here if needed.

4) Allocate two buffers for file data.

5) open .wav file, skip past file header, load data into the 2 buffers.

6) create the array of Buffer Descriptor Lists (BDL's).

7) point the BDL base address register to the array

8) start the DMA engine playing the data.

9) now you have 2 options:

   A) poll the Current Index Register to see which buffer we're playing.
      Once the player switches to the 2nd buffer, refresh buffer 1 with new
      data.  Alternate filling buffers until the last data is loaded.
      (we use this option since we're single task in DOS and it's easier!)

   B) Have the DMA engine fire an interrupt at the completion of a buffer,
      alerting your ISR routine to refresh the buffers with new data.
      You'd want to do that if you have lots of other things happening like
      a multithreaded O/S would.  

10) repeat refreshing whichever buffer is not being played until the .wav
    file data is finished.

11) since there are only 32 BDL entries, and your .wav file may be longer
    than 32 entries, update the Last Valid Index to make the BDL "wrap"
    back to BDL #0 when it finishes with BDL #31.

12) repeat speps 9-11 until .wav file finished.

13) stop DMA engine, exit program.

More details provided in the heavily commented source code.


-----------------------------------------------------------------------------


About the source:

It's free, do with it what you will. I don't particularly care.
Feel free to contact me with questions and improvements.  I'm a nice guy and
I don't expect a flood of email about this to bog me down, so I'll give you
as much support as you need.
(NOTE: printhex.asm was added later and is licensed CC BY-SA 3.0)


It's compiled with microsoft assembler 6.11, linked with microsoft linker.
To compile it, just type "nmaker", provided MASM is in your path.
Alternatively, the source can be built with the Open Watcom toolchain as well.
To do so, make sure WASM and WLINK are in your path and then run
./make-with-open-watcom.sh or owmake.bat (depending on your OS).


file list:
ichwav.asm   - THE KEY FILE to figuring out how to program this audio device.
ich2ac97.inc - ich2 register information
codec.asm    - codec setup
codec.inc    - codec/mixer register information
player.asm   - main start point and control routines.
pci.asm      - pci reader/writer support routines
file.asm     - simple file open/close routines
cmdline.asm  - command line parser
utils.asm    - non platform specific support routines
memalloc.asm - memory allocation/deallocation
constant.inc - global equates
printhex.asm - routines for displaying hex values on the console

added later:
owmake.bat               - a batch file that can build the executable using the
                           Open Watcom assembler instead of MASM (DOS/win32)
make-with-open-watcom.sh - a shell script that can build the executable using
                           the Open Watcom assembler instead of MASM (posix)


Could this code be used to make a device driver to support DOS games?  Dunno.
You'd probably have to set up a protected mode environment to catch access
going to the sound blaster ports (220h) and convert them into ICH compatible
accesses.  That PM interface would probably mess with games that use PM or
other DOS extenders.  This is my first attempt at writing audio based
software.  I don't know how different this device is than a SB or ADlib or
whatever else might be out there.  All I know is that there was no DOS based
code that I could find on the net.

I have no idea how to support MIDI.  Please don't ask, but please do tell me!

