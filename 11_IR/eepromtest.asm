COUNT 			equ 30h			; counter variable, to keep track of number of programmed moves
IN_LOOP_COUNT 	equ 34h			; delay loop variable
OUT_LOOP_COUNT 	equ 35h			; delay loop variable

var1 equ 36h
var2 equ 37h
var3 equ 38h
var4 equ 39h

org 00h

MOV EECON, #00011011b		; enable write to EEPROM
mov var1, #'A'
mov var2, #'S'
mov var3, #'G'
mov var4, #'M'

mov count, #00h
mov dptr, #00h
mov a, var1
;LCALL EEPROM_WRITE
inc count
mov a, var2
;LCALL EEPROM_WRITE
inc count
mov a, var3
;LCALL EEPROM_WRITE
inc count
mov a, var4
;LCALL EEPROM_WRITE
inc count
inc count


MOVE_LIST:						; display programmed path
	LCALL LOAD_DATA				; retrieve movement command from memory
	LCALL BT_send_char			; send the data via bluetooth
	INC DPTR					; get ready to retrieve next value
	DJNZ COUNT, MOVE_LIST		; decrement counter, if COUNT==0 then movement complete and exit MOVE_LIST

EEPROM_WRITE:					;--- Internal EEPROM data write
	MOVX @DPTR, A				; write data to EEPROM
	LCALL DELAY4MS
	LCALL DELAY4MS
	LCALL DELAY4MS				; wait for 12ms to programming EEPROM
	INC DPTR					; get ready for next EEPROM write
	RET							; return from subroutine call

LOAD_DATA:						;--- Load data from internal EEPROM
	MOVX A, @DPTR				; get byte from EEPROM
	RET

BT_Send_char:					;--- Serial data transfer.
	MOV SBUF, A					; put char in sbuf (scon.1 = TI)

TXLOOP:							; wait for transmission to finish
	JNB TI, TXLOOP				; wait till char is sent
	CLR TI						; get ready for next char
	RET							; leave subroutine

;--- 4 millisecond delay (exact)
DELAY4ms:
	MOV OUT_LOOP_COUNT, #4
AGAIN:
	MOV IN_LOOP_COUNT, #199
HERE:
	NOP
	NOP
	NOP
	DJNZ IN_LOOP_COUNT, HERE
	DJNZ OUT_LOOP_COUNT, AGAIN
	RET

END
