
;=================================================================
; IIC Definitions
;=================================================================
SCL           equ P1.7  ;I2C serial clock line.
SDA           equ P1.6  ;I2C serial data line.

;=================================================================
; Temporary Information
;=================================================================
dc_flag       equ 40h  ;Data/Command flag
data_val      equ 41h  ;Data value

page          equ 42h
maxpage       equ 08h

fontwidth     equ 05h  ;width of the font
string        equ 50h  ;start of string table

;=================================================================
; 2051 hardware vectors
;=================================================================
org 0000h                ; power up and reset vector
   ajmp init
org 0003h                ; external interrupt 0 vector
   ajmp init
org 000Bh                ; timer 0 interrupt vector
   ajmp init
org 0013h                ; external interrupt 1 vector
   ajmp init
org 001Bh                ; timer 1 interrupt vector
   ajmp init
org 0023h                ; serial port interrupt vector
   ajmp init

;strings to be written to the ss1306 display (8 lines)
;with upto 20 characters per line
org 0050h
DB   '0123456789abcdefghij',0h
org 0070h
DB   'klmnopqrstuvwxyz',0h
org 0090h
DB   'ABCDEFGHIJKLMNOPQRST',0h
org 00B0h
DB   'UVWXYZ',0h
org 00D0h
DB   'This is a test',0h
org 00F0h
DB   'Is this readable?',0h
org 0110h
DB   'If so - then yippee!',0h
org 0130h
DB   'Blah blah blah',0h

org 0150h
init:   mov     ie,   #00h     ;turn off all interrupts
        mov     ip,   #0       ;set interrupt priorities (all low)

        ;wait for power-on reset sequence
        lcall   delay

        mov     A, #0AEh     ;switch the display off
        lcall   iic_command

        mov     A, #8Dh      ;set Charge Pump to internal circuit
        lcall   iic_command
        mov     A, #14h
        lcall   iic_command

        mov     A, #81h      ;set for maximum contrast
        lcall   iic_command
        mov     A, #0FFh
        lcall   iic_command

        mov     A, #0D9h     ;set precharge period for internal circuit
        lcall   iic_command
        mov     A, #0F7h
        lcall   iic_command

        mov     A, #0A1h     ;remap segment/column addresses (flip)
        lcall   iic_command

        mov     A, #0C8h     ;remap row addresses (flip)
        lcall   iic_command

        mov     A, #20h      ;set for horizontal addressing
        lcall   iic_command
        mov     A, #00h
        lcall   iic_command

        mov     A, #0AFh     ;switch the display on
        lcall   iic_command

        lcall   clear

        mov     page, #00h

main:   ;lsb is top of column

        ;set page address (0..7)
        mov     A, #22h
        lcall   iic_command
        mov     A, page
        lcall   iic_command
        mov     A, page
        lcall   iic_command

        ;(re)set column address (0..127)
        mov     A, #21h
        lcall   iic_command
        mov     A, #0d
        lcall   iic_command
        mov     A, #127d
        lcall   iic_command

        mov     a, page
        mov     b, #20h
        mul     ab
        clr     c
        addc    a, #50h
        jnc     skip2
        mov     dph, #01h
        ljmp    skip3

skip2:  mov     dph, #00h

skip3:  mov     dpl, a

loop1:  clr     a                 ;clear Accumulator for any previous data
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        inc     dptr              ;increment data pointer
        jz      skip1             ;go to next line if zero

        clr     C
        subb    a, #32d
        mov     b, #05d
        mul     ab                ;calc the table offset for the first character segment

        push    dph               ;swap dptr
        push    dpl
        mov     dptr, #font       ;set second dptr to point to font table base address

        ; add character offset to table base address (16 bit addition is required)
        add     a, dpl
        mov     dpl, a
        mov     a, dph
        addc    a, b
        mov     dph, a

        mov     a, #00h
        lcall   iic_data

        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        inc     dptr              ;increment data pointer
        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        inc     dptr
        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        inc     dptr
        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        inc     dptr
        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        pop     dpl               ;swap dptr
        pop     dph

        sjmp    loop1

skip1:
        inc     page
        mov     a, page
        cjne    a, #maxpage, goback

        mov     r4, #00h

locked:
        ;set page address (0..7)
        mov     A, #22h
        lcall   iic_command
        mov     A, #01h
        lcall   iic_command
        mov     A, #01h
        lcall   iic_command

        ;(re)set column address (0..127)
        mov     A, #21h
        lcall   iic_command
        mov     A, #100d
        lcall   iic_command
        mov     A, #127d
        lcall   iic_command

        mov     a, #00h
        lcall   iic_data

        mov     dptr, #font
        mov     a, #16d
        add     a, r4
        mov     b, #05d
        mul     ab

        add     a, dpl         ; add Y low byte
        mov     dpl, a         ; put result in dpl low byte
        mov     a, b           ; load X high byte into accumulator
        addc    a, dph         ; add Y high byte with the carry from low ...
        mov     dph, a         ; save result in dph high byte

        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        inc     dptr              ;increment data pointer
        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        inc     dptr
        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        inc     dptr
        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        inc     dptr
        mov     a, #00h
        movc    a,@a+dptr         ;load the ASCII character in accumulator
        lcall   iic_data

        lcall   bigdelay

        inc     r4
        mov     a, r4
        cjne    a, #10d, locked
        mov     r4,#00h
        ljmp    locked

goback: ljmp    main


;===============================================================
; subroutine display clear
;===============================================================
clear:
         mov    r2, #04h
wait_0:
         mov    r3, #00h   ;reg2 and reg3
wait_1:
         mov    a, #00000000b
         lcall  iic_data
         djnz   r3, wait_1
         djnz   r2, wait_0
         ret

;===============================================================
; subroutine IIC write data / command
;===============================================================
iic_command:
         mov   dc_flag, #00h
         ljmp  iic_write

iic_data:
         mov   dc_flag, #40h

iic_write:
         ;Initial IIC bus state
         setb  SDA    ;If no one else is driving the bus,
         setb  SCL    ;it is now idle.

         jnb   SDA, $ ;wait until bus is idle.
         jnb   SCL, $

         ;Generate start signal
         clr   SDA
         ACALL wait_halfbit
         clr   SCL

         push  acc        ;store original acc - we need it later - after sending the iic address
         mov   A, #78h    ;address of IIC OLED
         acall write_byte ;send IIC address

         ;receiver should respond with ACK.
         ;this code does not verify that the ACK has been received
         acall wait_halfbit ; skip ACK
         setb  SCL ; idle the clock line (pretend to read ack)
         acall wait_halfbit

         clr   SCL ;start D/C command flag & Co(ntinuation)

         ;this is one for CGRAM data, i.e. D/C = 1 and Co = 0
         mov   A, dc_flag ;data code
         acall write_byte ;send IIC databyte

         ;receiver should respond with ACK.
         ;this code does not verify that the ACK has been received
         acall wait_halfbit ;skip ACK
         setb  SCL
         acall wait_halfbit

         clr   SCL ;start databyte

         ;this is the actual command byte to be sent (stored on the stack)
         pop   acc        ;restore the contents of the acc

         acall write_byte ;send IIC databyte

         ;receiver should respond with ACK.
         ;this code does not verify that the ACK has been received
         acall wait_halfbit ;skip ACK
         setb  SCL
         acall wait_halfbit

         ;send stop bit to end transaction
         clr   SCL            ;start sending stop bit
         clr   SDA            ;stop bit
         acall wait_halfbit
         setb  SCL            ;drop clock. signals receiver to sample data
         acall wait_halfbit
         setb  SDA            ;drop data. bus is now idle.

         acall wait_halfbit
         acall wait_halfbit

         ret

;===============================================================
; subroutine write byte to IIC
;===============================================================
write_byte: ;send an 8 bit word to IIC bus
         mov   r6, #08h     ;setup count

next_bit:
         ACALL wait_halfbit
         rlc   A            ;rotate next bit into carry
         mov   SDA, C       ;set IIC data to carry value
         setb  SCL          ;set IIC clock
         acall wait_halfbit ;wait
         clr   SCL          ;drop clock. signals receiver to sample data
         djnz  r6, next_bit ;do next bit

         setb  SDA          ;idle the data line
         ret

wait_halfbit:  ;wait for one half IIC bit period
         mov    r7, #02d
         djnz   r7, $
         ret                 ;return from routine

;===============================================================
; subroutine short delay
;===============================================================
delay:
         mov  r2, #01Fh
wait_2:
         mov  r3, #0FFh   ;reg2 and reg3
wait_3:
         djnz r3, wait_3
         djnz r2, wait_2
         ret
;===============================================================

;===============================================================
; subroutine long delay
;===============================================================
bigdelay:
         push 2
         push 3
         push 4
         mov  r2, #0Fh   ;initialise counters
wait_4:
         mov  r3, #0FFh   ;reg2 and reg3
wait_5:
         mov  r4, #0FFh   ;reg2 and reg3
wait_6:
         djnz r4, wait_6
         djnz r3, wait_5
         djnz r2, wait_4
         pop  4
         pop  3
         pop  2
         ret
;===============================================================

;Terminal5x8 Font
font:
DB 00h
DB 00h
DB 00h
DB 00h
DB 00h    ; Code for char "space"
DB 00h
DB 06h
DB 5Fh
DB 06h
DB 00h    ; Code for char !
DB 07h
DB 03h
DB 00h
DB 07h
DB 03h    ; Code for char "
DB 24h
DB 7Eh
DB 24h
DB 7Eh
DB 24h    ; Code for char #
DB 24h
DB 2Bh
DB 6Ah
DB 12h
DB 00h    ; Code for char $
DB 63h
DB 13h
DB 08h
DB 64h
DB 63h    ; Code for char %
DB 36h
DB 49h
DB 56h
DB 20h
DB 50h    ; Code for char &
DB 00h
DB 07h
DB 03h
DB 00h
DB 00h    ; Code for char '
DB 00h
DB 3Eh
DB 41h
DB 00h
DB 00h    ; Code for char (
DB 00h
DB 41h
DB 3Eh
DB 00h
DB 00h    ; Code for char )
DB 08h
DB 3Eh
DB 1Ch
DB 3Eh
DB 08h    ; Code for char *
DB 08h
DB 08h
DB 3Eh
DB 08h
DB 08h    ; Code for char +
DB 00h
DB 0E0h
DB 60h
DB 00h
DB 00h    ; Code for char ,
DB 08h
DB 08h
DB 08h
DB 08h
DB 08h    ; Code for char -
DB 00h
DB 60h
DB 60h
DB 00h
DB 00h    ; Code for char .
DB 20h
DB 10h
DB 08h
DB 04h
DB 02h    ; Code for char /
DB 3Eh
DB 51h
DB 49h
DB 45h
DB 3Eh    ; Code for char 0
DB 00h
DB 42h
DB 7Fh
DB 40h
DB 00h    ; Code for char 1
DB 62h
DB 51h
DB 49h
DB 49h
DB 46h    ; Code for char 2
DB 22h
DB 49h
DB 49h
DB 49h
DB 36h    ; Code for char 3
DB 18h
DB 14h
DB 12h
DB 7Fh
DB 10h    ; Code for char 4
DB 2Fh
DB 49h
DB 49h
DB 49h
DB 31h    ; Code for char 5
DB 3Ch
DB 4Ah
DB 49h
DB 49h
DB 30h    ; Code for char 6
DB 01h
DB 71h
DB 09h
DB 05h
DB 03h    ; Code for char 7
DB 36h
DB 49h
DB 49h
DB 49h
DB 36h    ; Code for char 8
DB 06h
DB 49h
DB 49h
DB 29h
DB 1Eh    ; Code for char 9
DB 00h
DB 6Ch
DB 6Ch
DB 00h
DB 00h    ; Code for char :
DB 00h
DB 0ECh
DB 6Ch
DB 00h
DB 00h    ; Code for char ;
DB 08h
DB 14h
DB 22h
DB 41h
DB 00h    ; Code for char <
DB 24h
DB 24h
DB 24h
DB 24h
DB 24h    ; Code for char =
DB 00h
DB 41h
DB 22h
DB 14h
DB 08h    ; Code for char >
DB 02h
DB 01h
DB 59h
DB 09h
DB 06h    ; Code for char ?
DB 3Eh
DB 41h
DB 5Dh
DB 55h
DB 1Eh    ; Code for char @
DB 7Eh
DB 11h
DB 11h
DB 11h
DB 7Eh    ; Code for char A
DB 7Fh
DB 49h
DB 49h
DB 49h
DB 36h    ; Code for char B
DB 3Eh
DB 41h
DB 41h
DB 41h
DB 22h    ; Code for char C
DB 7Fh
DB 41h
DB 41h
DB 41h
DB 3Eh    ; Code for char D
DB 7Fh
DB 49h
DB 49h
DB 49h
DB 41h    ; Code for char E
DB 7Fh
DB 09h
DB 09h
DB 09h
DB 01h    ; Code for char F
DB 3Eh
DB 41h
DB 49h
DB 49h
DB 7Ah    ; Code for char G
DB 7Fh
DB 08h
DB 08h
DB 08h
DB 7Fh    ; Code for char H
DB 00h
DB 41h
DB 7Fh
DB 41h
DB 00h    ; Code for char I
DB 30h
DB 40h
DB 40h
DB 40h
DB 3Fh    ; Code for char J
DB 7Fh
DB 08h
DB 14h
DB 22h
DB 41h    ; Code for char K
DB 7Fh
DB 40h
DB 40h
DB 40h
DB 40h    ; Code for char L
DB 7Fh
DB 02h
DB 04h
DB 02h
DB 7Fh    ; Code for char M
DB 7Fh
DB 02h
DB 04h
DB 08h
DB 7Fh    ; Code for char N
DB 3Eh
DB 41h
DB 41h
DB 41h
DB 3Eh    ; Code for char O
DB 7Fh
DB 09h
DB 09h
DB 09h
DB 06h    ; Code for char P
DB 3Eh
DB 41h
DB 51h
DB 21h
DB 5Eh    ; Code for char Q
DB 7Fh
DB 09h
DB 09h
DB 19h
DB 66h    ; Code for char R
DB 26h
DB 49h
DB 49h
DB 49h
DB 32h    ; Code for char S
DB 01h
DB 01h
DB 7Fh
DB 01h
DB 01h    ; Code for char T
DB 3Fh
DB 40h
DB 40h
DB 40h
DB 3Fh    ; Code for char U
DB 1Fh
DB 20h
DB 40h
DB 20h
DB 1Fh    ; Code for char V
DB 3Fh
DB 40h
DB 3Ch
DB 40h
DB 3Fh    ; Code for char W
DB 63h
DB 14h
DB 08h
DB 14h
DB 63h    ; Code for char X
DB 07h
DB 08h
DB 70h
DB 08h
DB 07h    ; Code for char Y
DB 71h
DB 49h
DB 45h
DB 43h
DB 00h    ; Code for char Z
DB 00h
DB 7Fh
DB 41h
DB 41h
DB 00h    ; Code for char [
DB 02h
DB 04h
DB 08h
DB 10h
DB 20h    ; Code for char BackSlash
DB 00h
DB 41h
DB 41h
DB 7Fh
DB 00h    ; Code for char ]
DB 04h
DB 02h
DB 01h
DB 02h
DB 04h    ; Code for char ^
DB 80h
DB 80h
DB 80h
DB 80h
DB 80h    ; Code for char _
DB 00h
DB 03h
DB 07h
DB 00h
DB 00h    ; Code for char `
DB 20h
DB 54h
DB 54h
DB 54h
DB 78h    ; Code for char a
DB 7Fh
DB 44h
DB 44h
DB 44h
DB 38h    ; Code for char b
DB 38h
DB 44h
DB 44h
DB 44h
DB 28h    ; Code for char c
DB 38h
DB 44h
DB 44h
DB 44h
DB 7Fh    ; Code for char d
DB 38h
DB 54h
DB 54h
DB 54h
DB 08h    ; Code for char e
DB 08h
DB 7Eh
DB 09h
DB 09h
DB 00h    ; Code for char f
DB 18h
DB 0A4h
DB 0A4h
DB 0A4h
DB 7Ch    ; Code for char g
DB 7Fh
DB 04h
DB 04h
DB 78h
DB 00h    ; Code for char h
DB 00h
DB 00h
DB 7Dh
DB 40h
DB 00h    ; Code for char i
DB 40h
DB 80h
DB 84h
DB 7Dh
DB 00h    ; Code for char j
DB 7Fh
DB 10h
DB 28h
DB 44h
DB 00h    ; Code for char k
DB 00h
DB 00h
DB 7Fh
DB 40h
DB 00h    ; Code for char l
DB 7Ch
DB 04h
DB 18h
DB 04h
DB 78h    ; Code for char m
DB 7Ch
DB 04h
DB 04h
DB 78h
DB 00h    ; Code for char n
DB 38h
DB 44h
DB 44h
DB 44h
DB 38h    ; Code for char o
DB 0FCh
DB 44h
DB 44h
DB 44h
DB 38h    ; Code for char p
DB 38h
DB 44h
DB 44h
DB 44h
DB 0FCh    ; Code for char q
DB 44h
DB 78h
DB 44h
DB 04h
DB 08h    ; Code for char r
DB 08h
DB 54h
DB 54h
DB 54h
DB 20h    ; Code for char s
DB 04h
DB 3Eh
DB 44h
DB 24h
DB 00h    ; Code for char t
DB 3Ch
DB 40h
DB 20h
DB 7Ch
DB 00h    ; Code for char u
DB 1Ch
DB 20h
DB 40h
DB 20h
DB 1Ch    ; Code for char v
DB 3Ch
DB 60h
DB 30h
DB 60h
DB 3Ch    ; Code for char w
DB 6Ch
DB 10h
DB 10h
DB 6Ch
DB 00h    ; Code for char x
DB 9Ch
DB 0A0h
DB 60h
DB 3Ch
DB 00h    ; Code for char y
DB 64h
DB 54h
DB 54h
DB 4Ch
DB 00h    ; Code for char z
DB 08h
DB 3Eh
DB 41h
DB 41h
DB 00h    ; Code for char {
DB 00h
DB 00h
DB 77h
DB 00h
DB 00h    ; Code for char |
DB 00h
DB 41h
DB 41h
DB 3Eh
DB 08h    ; Code for char }
DB 02h
DB 01h
DB 02h
DB 01h
DB 00h    ; Code for char ~

end

