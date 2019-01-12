;=================================================================
;Flash User Configuration Byte (UCFG1)
;Must be set to 2B hex (reset disabled - clock double enabled)
;=================================================================

;=================================================================
; lpc9107 SFR equates
;=================================================================
P0            equ 80h;
P0M1x         equ 84h;
P0M2x         equ 85h;

P1            equ 90h;
P1M1x         equ 91h;
P1M2x         equ 92h;

;------------------
PSW           equ 0D0h;
ACC           equ 0E0h;
B             equ 0F0h;
SP            equ 81h;
DPL           equ 82h;
DPH           equ 83h;
;------------------

AUXR1         equ 0A2h;
CMP1          equ 0ACh;
DIVM          equ 95h;

FMADRH        equ 0E7h;
FMADRL        equ 0E6h;

FMCON         equ 0E4h;
FMDATA        equ 0E5h;

IEN0          equ 0A8h;
IEN1          equ 0E8h;

IP0           equ 0B8h;
IP0H          equ 0B7h;
IP1           equ 0F8h;
IP1H          equ 0F7h;

KBCON         equ 94h;
KBMASK        equ 86h;
KBPATN        equ 93h;

PCON          equ 87h;
PCONA         equ 0B5h;
PCONB         equ 0B6h;

PT0AD         equ 0F6h;
RSTSRC        equ 0DFh;

RTCCON        equ 0D1h;
RTCH          equ 0D2h;
RTCL          equ 0D3h;

SADDR         equ 0A9h
SADEN         equ 0B9h
SBUF          equ 99h
SCON          equ 98h
SSTAT         equ 0BAh

TCON          equ 88h;
TH0           equ 8Ch;
TH1           equ 8Dh;
TL0           equ 8Ah;
TL1           equ 8Bh;
TMOD          equ 89h;
TRIM          equ 96h;

WDCON         equ 0A7h;
WDL           equ 0C1h;
WFEED1        equ 0C2h;
WFEED2        equ 0C3h;

ADCON1        equ 97h
ADINS         equ 0A3h
ADMODA        equ 0C0h
ADMODB        equ 0A1h
AD1BH         equ 0C4h
AD1BL         equ 0BCh
AD1DAT0       equ 0D5h
AD1DAT1       equ 0D6h
AD1DAT2       equ 0D7h
AD1DAT3       equ 0F5h

EA            equ 0AFh
RI            equ 98h

;=================================================================
; Other equates
;=================================================================
stack    equ  2Fh   ;begin stack after last bit memory location in internal RAM
command  equ  P0.1
LED      equ  P0.7

;=================================================================
; lpc9107 hardware vectors
;=================================================================
org 0000h                ; power up and reset vector
   ajmp start

org 0003h                ; interrupt 0 vector
   ajmp start

org 000Bh                ; timer 0 interrupt vector
   ajmp start

org 0013h                ; interrupt 1 vector
   ajmp start

org 001Bh                ; timer 1 interrupt vector
   ajmp start

org 0023h                ; serial port interrupt vector
   ajmp start

org 002Bh                ; brown out interrupt vector
   ajmp start

org 003Bh                ; KB interrupt vector
   ajmp start

org 0043h                ; comparator interrupt vector
   ajmp start

org 0053h                ; watchdog/rtc interrupt vector
   ajmp start

org 006Bh                ; TI interrupt vector
   ajmp start

org 0073h                ; ADC interrupt vector
   ajmp start


;=================================================================
; begin main program
;=================================================================
   org     0078h

start:
   mov     a, TRIM
   setb    acc.7
   setb    acc.1
   mov     TRIM, a

   mov     P0M1x, #00111100b
   mov     P0M2x, #10000010b
   ;Port0...
   ;  Pin 0.1 = output
   ;  Pin 0.2 = input
   ;  Pin 0.3 = input
   ;  Pin 0.4 = input
   ;  Pin 0.5 = input
   ;  Pin 0.7 = output

   mov     P1M1x, #00000100b
   mov     P1M2x, #00000000b
   ;Port1...
   ;  Pin 1.0 = bidirectional
   ;  Pin 1.1 = bidirectional
   ;  Pin 1.2 = input

   mov     DIVM,  #00h

   clr     ea             ; disable interrupts

   ;select register bank 0 and push the registers that will be used
   clr     psw.3
   clr     psw.4

   ;initalise baud rate generator
   mov     a, pcon
   setb    acc.7
   mov     pcon, a
   mov     tmod, #20h        ; set timer 1 for auto reload - mode 2
   mov     th1,  #0D0h       ; set 9600 baud with 14.7456MHz RC Oscillator (2 clk / cycle)
   mov     tcon, #40h        ; run timer 1
   mov     scon, #50h        ; set serial control reg for 8 bit data and mode 1

   clr     LED           ; LED On
   clr     command
   lcall   delay

   setb    LED           ; LED Off
   setb    command
   lcall   delay

   lcall   print          ; configure BT device
   db 'AT+UART=9600,0,0', 0dh, 0ah, 0h
   lcall   delay

   lcall   print          ; configure BT device
   db 'AT+PSWD=6666', 0dh, 0ah, 0h
   lcall   delay

   clr     LED           ; LED On
   clr     command
   lcall   delay

   setb    LED           ; LED Off
   mov     sp, #stack     ; reinitialize stack pointer
   setb    ea             ; enable all interrupts


monloop:
   lcall   print          ; print prompt
   db 0dh, 0ah,'CMD>', 0h
   clr     ri             ; flush the serial input buffer
   lcall   getcmd         ; read the single-letter command

   cjne    a, #'t', next1
   ljmp    toggle
next1:
   cjne    a, #'v', next2
   ljmp    version
next2:
   cjne    a, #'h', endloop
   ljmp    helplist

endloop:                  ; come here after command has finished
   ljmp monloop           ; loop forever in monitor loop


;*****************************************************************
; monitor command routines
;*****************************************************************

;===============================================================
; command toggle  't'
; this command writes a byte to memory.
;===============================================================
toggle:
   cpl   LED
   lcall print          ; print version code
   db 0ah, 0dh,'Toggled Light', 0h
   ljmp  endloop          ; return


;===============================================================
; command version report  'v'
; this command reports the EEPROM version ID of the bootstrap 
; program
;===============================================================
version:
   lcall   print          ; print version code
   db 0ah, 0dh,'BT Monitor', 0h
   lcall   print          ; print version code
   db 0ah, 0dh,'16/01/2016 Ver-1a', 0h
   ljmp    endloop        ; return


;===============================================================
; command list 'h'
; this command reports the available commands
;===============================================================
helplist:
   lcall   print
   db 0ah, 0dh,'Available commands:', 0h
   lcall   print
   db 0ah, 0dh,'Toggle   - 'T' to flip LED', 0h
   lcall   print
   db 0ah, 0dh,'Version  - 'V' provides version', 0h
   lcall   print
   db 0ah, 0dh,'Help     - 'H' invoke this list', 0h
   ljmp    endloop        ; return


;===============================================================
; subroutine getcmd
; this routine gets the command line.  currently only a
; single-letter command is read - all command line parameters
; must be parsed by the individual routines.
;
;===============================================================
getcmd:
   lcall getchr           ; get the single-letter command
   push  acc

   clr   C                ; clear the carry flag
   subb  a, #'a'          ; convert to upper case
   jnc   cmdok1
   pop   acc
   setb  acc.5            ; make lower case
   ljmp  finishcmd

cmdok1:
   pop   acc              ; save command number

finishcmd:
   lcall sndchr           ; echo command
   ret                    ; return


;*****************************************************************
; general purpose routines
;*****************************************************************

;===============================================================
; subroutine delay
;===============================================================
delay:
   mov  r2, #5Fh   ;initialise counters

wait_0:
   mov  r3, #0FFh   ;reg2 and reg3

wait_1:
   mov  r4, #0FFh   ;reg2 and reg3

wait_2:
   djnz r4, wait_2
   djnz r3, wait_1
   djnz r2, wait_0

   ret

;===============================================================
; subroutine sndchr
; this routine takes the chr in the acc and sends it out the
; serial port.
;===============================================================
sndchr:
   clr  scon.1            ; clear the tx  buffer full flag.
   mov  sbuf,a            ; put chr in sbuf

txloop:
   jnb  scon.1, txloop    ; wait till chr is sent
   ret

;===============================================================
; subroutine getchr
; this routine reads in a chr from the serial port and saves it
; in the accumulator.
;===============================================================
getchr:
   jnb  ri, getchr        ; wait till character received
   mov  a,  sbuf          ; get character
   anl  a,  #7fh          ; mask off 8th bit
   clr  ri                ; clear serial status bit
   ret

;===============================================================
; subroutine print
; print takes the string immediately following the call and
; sends it out the serial port.  the string must be terminated
; with a null. this routine will ret to the instruction
; immediately following the string.
;===============================================================
print:
   pop   dph              ; put return address in dptr
   pop   dpl

prtstr:
   clr  a                 ; set offset = 0
   movc a,  @a+dptr       ; get chr from code memory
   cjne a,  #0h, mchrok   ; if chr = ff then return
   sjmp prtdone

mchrok:
   lcall sndchr           ; send character
   inc   dptr             ; point at next character
   sjmp  prtstr           ; loop till end of string

prtdone:
   mov   a,  #1h          ; point to instruction after string
   jmp   @a+dptr          ; return

;===============================================================
; end of Bluetooth
;===============================================================
end

