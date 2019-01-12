;   *************************************************
;   *    Simple Bluetooth Monitor Program           *
;   *************************************************

stack   equ  2fh          ; bottom of stack
                          ; - stack starts at 30h -
errorf  equ  00h          ; bit 0 is error status

;=================================================================
; 2051 hardware vectors
;=================================================================
   org  0000h              ; power up and reset vector table jump
   ljmp start
   org  0003h              ; interrupt 0 vector table jump
   ljmp start
   org  000Bh              ; timer 0 interrupt vector table jump
   ljmp start
   org  0013h              ; interrupt 1 vector table jump
   ljmp start
   org  001Bh              ; timer 0 interrupt 1 vector table jump
   ljmp start
   org  0023h              ; serial port interrupt vector table jump
   ljmp start

;=================================================================
; jump table for general-purpose utility routines
;=================================================================

   org 0050h

;    routine        offset
;    -------        ------
   ljmp    ascbin       ; 0060h
   ljmp    binasc       ; 0063h
   ljmp    cret         ; 0066h
   ljmp    crlf         ; 0069h
   ljmp    delay        ; 006ch
   ljmp    getbyt       ; 006fh
   ljmp    getchr       ; 0072h
   ljmp    init         ; 0075h
   ljmp    mon_return   ; 0078h
   ljmp    print        ; 007bh
   ljmp    prtstr       ; 007eh
   ljmp    prthex       ; 0081h
   ljmp    sndchr       ; 0084h

;=================================================================
; begin main program
;=================================================================
   org     00A0h

start:
   clr     ea             ; disable interrupts
   lcall   init           ; initialize hardware

   ;clr     P3.7           ; LED On
   ;lcall   delay

   ;setb    P3.7           ; LED Off
   ;lcall   print          ; configure BT device
   ;db 'AT+NAMETest1', 0h
   ;db 'AT+NAMETest2', 0dh, 0ah, 0h
   ;clr     P3.7           ; LED On
   ;lcall   delay

   ;setb    P3.7           ; LED Off
   ;lcall   print          ; configure BT device
   db 'AT+PIN3333', 0h
   ;db 'AT+PIN7777', 0dh, 0ah, 0h
   ;clr     P3.7           ; LED On
   ;lcall   delay

   setb    P3.7           ; LED Off
   mov     sp, #stack     ; reinitialize stack pointer
   clr     errorf         ; clear the error flag
   setb    ea             ; enable all interrupts


monloop:

   lcall   print          ; print prompt
   db 0dh, 0ah,'CMD>', 0h
   clr     ri             ; flush the serial input buffer
   lcall   getcmd         ; read the single-letter command
   mov     r2, a          ; put the command number in R2
   ljmp    nway           ; branch to a monitor routine

endloop:                  ; come here after command has finished
   ljmp monloop           ; loop forever in monitor loop

;=================================================================
; subroutine init
; this routine initializes the hardware
;=================================================================
init:
; set up serial port with 11.0592 MHz crystal
; use timer 1 for 9600 baud serial communication
MOV TMOD, #20h	; set timer 1 for auto-reload - mode 2
MOV TCON, #40h	; enable timer 1
MOV TH1, #0FDh	; set 9600 baud rate using 11.0592MHz crystal
MOV SCON, #50h	; set serial control register for 8 bit data and mode 1

   ret

;=================================================================
; monitor jump table
;=================================================================
jumtab:
   dw badcmd              ; command '@' 00
   dw badcmd              ; command 'a' 01
   dw badcmd              ; command 'b' 02
   dw badcmd              ; command 'c' 03
   dw badcmd              ; command 'd' 04
   dw badcmd              ; command 'e' 05
   dw badcmd              ; command 'f' 06
   dw badcmd              ; command 'g' 07
   dw helplist            ; command 'h' 08 used to list commands
   dw badcmd              ; command 'i' 09
   dw badcmd              ; command 'j' 0a
   dw badcmd              ; command 'k' 0b
   dw badcmd              ; command 'l' 0c
   dw badcmd              ; command 'm' 0d
   dw badcmd              ; command 'n' 0e
   dw badcmd              ; command 'o' 0f
   dw poke                ; command 'p' 10 used to poke location
   dw badcmd              ; command 'q' 11
   dw readram             ; command 'r' 12 used for reading memory
   dw show                ; command 's' 13 used to show the PIN info
   dw toggle              ; command 't' 14 used to toggle pin 3.7
   dw badcmd              ; command 'u' 15
   dw version             ; command 'v' 16 used to report version ID
   dw badcmd              ; command 'w' 17
   dw badcmd              ; command 'x' 18
   dw badcmd              ; command 'y' 19
   dw badcmd              ; command 'z' 1a

;*****************************************************************
; monitor command routines
;*****************************************************************

;===============================================================
; command toggle  't'
; this command writes a byte to memory.
;===============================================================
toggle:
   cpl   P3.7

   lcall print          ; print version code
   db 0ah, 0dh,'Toggled Light', 0h

   ljmp  endloop          ; return

;===============================================================
; command toggle  's'
; this command writes a byte to memory.
;===============================================================
show:
   lcall print          ; print version code
   db 'AT+PIN3333', 0h
   lcall   crlf

   ljmp  endloop          ; return

;===============================================================
; command poke  'p'
; this command writes a byte to memory.
;===============================================================
poke:
   mov   a, #'?'
   lcall sndchr
   lcall crlf

   lcall getbyt         ; load R0 with memory address 
   mov   R0, a          ; taken from the accumulator
   lcall prthex

   mov   a, #'?'
   lcall sndchr
   lcall crlf

   lcall getbyt         ; using R0 as an index to the memory location 
   mov   @R0, a         ; save data byte held in the accumulator
   lcall prthex

   ljmp  endloop        ; return

;===============================================================
; command readram  'r'
; this command reads a small portion of the external data memory
;===============================================================
readram:
   mov   a, #'?'
   lcall sndchr
   lcall crlf

   lcall getbyt           ; load R0 with memory address
   mov   R0, a
   lcall prthex

   mov   r4, #10h         ; initialise RAM reading range

ramloop:
   mov   a, R0
   lcall prthex

   mov   a, #' '
   lcall sndchr

   mov   a, @R0           ; load from mem
   lcall prthex

   lcall crlf
   inc   R0               ; bump mem pointer
   djnz  r4, ramloop      ; test to see if RAM reading range has
                          ; been reached
   ljmp  endloop          ; return

;===============================================================
; command version report  'v'
; this command reports the EEPROM version ID of the bootstrap 
; program
;===============================================================
version:
   lcall   crlf
   lcall   print          ; print version code
   db 0ah, 0dh,'Bluetooth Monitor Program', 0h
   lcall   print          ; print version code
   db 0ah, 0dh,'08/03/2012 Version 1a', 0h
   lcall   print          ; print version code
   db 0ah, 0dh,'by Chris', 0h
   ljmp    endloop        ; return


;===============================================================
; command list 'h'
; this command reports the available commands 
; 
;===============================================================
helplist:
   lcall   crlf

   lcall   print
   db 0ah, 0dh,'Available commands are as follows:', 0h
   lcall   print
   db 0ah, 0dh,'Poke     - 'P' followed by one-byte address ADDR + byte', 0h
   lcall   print
   db 0ah, 0dh,'Read     - 'R' followed by one-byte address ADDR', 0h
   lcall   print
   db 0ah, 0dh,'Toggle   - 'T' to flip pin 3.7', 0h
   lcall   print
   db 0ah, 0dh,'Version  - 'V' provides version message', 0h
   lcall   print
   db 0ah, 0dh,'Help     - 'H' invoke this list', 0h

   ljmp    endloop        ; return

   
;*****************************************************************
; monitor support routines
;*****************************************************************
badcmd:
   lcall print
   db 0dh, 0ah,' bad command ', 0h
   ljmp endloop

badpar:
   lcall print
   db 0dh, 0ah,' bad parameter ', 0h
   ljmp endloop

;===============================================================
; subroutine getbyt
; this routine reads in an 2 digit ascii hex number from the
; serial port. the result is returned in the acc.
;===============================================================
getbyt:
   lcall getchr           ; get msb ascii chr
   lcall ascbin           ; conv it to binary
   swap  a                ; move to most sig half of acc
   mov   b,  a            ; save in b
   lcall getchr           ; get lsb ascii chr
   lcall ascbin           ; conv it to binary
   orl   a,  b            ; combine two halves
   ret

;===============================================================
; subroutine getcmd
; this routine gets the command line.  currently only a
; single-letter command is read - all command line parameters
; must be parsed by the individual routines.
;
;===============================================================
getcmd:
   lcall getchr           ; get the single-letter command
   clr   acc.5            ; make lower case
   lcall sndchr           ; echo command
   clr   C                ; clear the carry flag
   subb  a, #'@'          ; convert to command number
   jnc   cmdok1           ; letter command must be above '@'
   lcall badpar

cmdok1:
   push  acc              ; save command number
   subb  a, #1Bh          ; command number must be 1Ah or less
   jc    cmdok2
   lcall badpar           ; no need to pop acc since badpar
                          ; initializes the system
cmdok2:
   pop   acc              ; recall command number
   ret

;===============================================================
; subroutine nway
; this routine branches (jumps) to the appropriate monitor
; routine. the routine number is in r2
;================================================================
nway:
   mov   dptr, #jumtab    ;point dptr at beginning of jump table
   mov   a, r2            ;load acc with monitor routine number
   rl    a                ;multiply by two.
   inc   a                ;load first vector onto stack
   movc  a, @a+dptr       ;         "          "
   push  acc              ;         "          "
   mov   a, r2            ;load acc with monitor routine number
   rl    a                ;multiply by two
   movc  a, @a+dptr       ;load second vector onto stack
   push  acc              ;         "          "
   ret                    ;jump to start of monitor routine


;*****************************************************************
; general purpose routines
;*****************************************************************

;===============================================================
; subroutine delay
;===============================================================
delay:
   mov  r2, #50h   ;initialise counters

wait_0:
   mov  r3, #0ffh   ;reg2 and reg3

wait_1:
   mov  r4, #0ffh   ;reg2 and reg3

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
; subroutine crlf
; crlf sends a carriage return line feed out the serial port
;===============================================================
crlf:
   mov   a,  #0ah         ; print lf
   lcall sndchr

cret:
   mov   a,  #0dh         ; print cr
   lcall sndchr
   ret

;===============================================================
; subroutine prthex
; this routine takes the contents of the acc and prints it out
; as a 2 digit ascii hex number.
;===============================================================
prthex:
   lcall binasc           ; convert acc to ascii
   lcall sndchr           ; print first ascii hex digit
   mov   a,  r2           ; get second ascii hex digit
   lcall sndchr           ; print it
   ret

;===============================================================
; subroutine binasc
; binasc takes the contents of the accumulator and converts it
; into two ascii hex numbers.  the result is returned in the
; accumulator and r2.
;===============================================================
binasc:
   mov   r2, a            ; save in r2
   anl   a,  #0fh         ; convert least sig digit.
   add   a,  #0f6h        ; adjust it
   jnc   noadj1           ; if a-f then readjust
   add   a,  #07h

noadj1:
   add   a,  #3ah         ; make ascii
   xch   a,  r2           ; put result in reg 2
   swap  a                ; convert most sig digit
   anl   a,  #0fh         ; look at least sig half of acc
   add   a,  #0f6h        ; adjust it
   jnc   noadj2           ; if a-f then re-adjust
   add   a,  #07h

noadj2:
   add   a,  #3ah         ; make ascii
   ret

;===============================================================
; subroutine ascbin
; this routine takes the ascii character passed to it in the
; acc and converts it to a 4 bit binary number which is returned
; in the acc.
;===============================================================
ascbin:
   clr   errorf
   add   a,  #0d0h        ; if chr < 30 then error
   jnc   notnum
   clr   c                ; check if chr is 0-9
   add   a,  #0f6h        ; adjust it
   jc    hextry           ; jmp if chr not 0-9
   add   a,  #0ah         ; if it is then adjust it
   ret

hextry:
   clr   acc.5            ; convert to upper
   clr   c                ; check if chr is a-f
   add   a,  #0f9h        ; adjust it
   jnc   notnum           ; if not a-f then error
   clr   c                ; see if char is 46 or less.
   add   a,  #0fah        ; adjust acc
   jc    notnum           ; if carry then not hex
   anl   a,  #0fh         ; clear unused bits
   ret

notnum:
   setb  errorf           ; if not a valid digit
   ljmp  endloop

;===============================================================
; mon_return is not a subroutine.  
; it simply jumps to address 0 which resets the system and 
; invokes the monitor program.
; A jump or a call to mon_return has the same effect since 
; the monitor initializes the stack.
;===============================================================
mon_return:
   ljmp  0

; ====================================================
; end of Bluetooth

end

