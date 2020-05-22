comment %


Codec registers.

Not all codecs are created equal. Refer to the spec for your specific codec.

All registers are 16bits wide.  Access to codec registers over the AC97 link
is defined by the OEM.  


Secondary codec's are accessed by ORing in BIT7 of all register accesses.

%

; each codec/mixer register is 16bits

CODEC_RESET_REG                 equ     00      ; reset codec
CODEC_MASTER_VOL_REG            equ     02      ; master volume
CODEC_HP_VOL_REG                equ     04      ; headphone volume
CODEC_MASTER_MONO_VOl_REG       equ     06      ; master mono volume
CODEC_MASTER_TONE_REG           equ     08      ; master tone (R+L)
CODEC_PCBEEP_VOL_REG            equ     0ah     ; PC beep volume
CODEC_PHONE_VOL_REG             equ     0bh     ; phone volume
CODEC_MIC_VOL_REG               equ     0eh     ; MIC volume
CODEC_LINE_IN_VOL_REG           equ     10h     ; line input volume
CODEC_CD_VOL_REG                equ     12h     ; CD volume
CODEC_VID_VOL_REG               equ     14h     ; video volume
CODEC_AUX_VOL_REG               equ     16h     ; aux volume
CODEC_PCM_OUT_REG               equ     18h     ; PCM output volume
CODEC_RECORD_SELECT_REG         equ     1ah     ; record select input
CODEC_RECORD_VOL_REG            equ     1ch     ; record volume
CODEC_RECORD_MIC_VOL_REG        equ     1eh     ; record mic volume
CODEC_GP_REG                    equ     20h     ; general purpose
CODEC_3D_CONTROL_REG            equ     22h     ; 3D control
; 24h is reserved
CODEC_POWER_CTRL_REG            equ     26h     ; powerdown control
CODEC_EXT_AUDIO_REG             equ     28h     ; extended audio
CODEC_EXT_AUDIO_CTRL_REG        equ     2ah     ; extended audio control
CODEC_PCM_FRONT_DACRATE_REG     equ     2ch     ; PCM out sample rate
CODEC_PCM_SURND_DACRATE_REG     equ     2eh     ; surround sound sample rate
CODEC_PCM_LFE_DACRATE_REG       equ     30h     ; LFE sample rate
CODEC_LR_ADCRATE_REG            equ     32h     ; PCM in sample rate
CODEC_MIC_ADCRATE_REG           equ     34h     ; mic in sample rate

; registers 36-7a are reserved on the ICH

CODEC_VENDORID1_REG             equ     7ch     ; codec vendor ID 1
CODEC_VENDORID2_REG             equ     7eh     ; codec vendor ID 2



; Mixer registers 0 through 51h reside in the ICH and are not forwarded over
; the AC97 link to the codec, which I think is a little weird.  Looks like
; the ICH makes it so you don't need a fully functional codec to play audio?
;
; whenever 2 codecs are present in the system, use BIT7 to access the 2nd
; set of registers, ie 80h-feh

PRIMARY_CODEC                   equ     0       ; 0-7F for primary codec
SECONDARY_CODEC                 equ     BIT7    ; 80-8f registers for 2ndary



SAMPLE_RATE_441khz              equ     44100   ; 44.1Khz (cd quality) rate


