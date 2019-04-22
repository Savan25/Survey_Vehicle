ORG 0000H

SETUP:
	MOV P2, #00H				; Configure Port 1 as output ... motors
	;Bluetooth setup
	MOV TMOD, #20H				; Timer 1, Mode 2 - 8 bit mode
	MOV TCON, #40h				; enable timer 1
	MOV TH1, #0FDH				; Baud rate = 9600
	MOV SCON, #50H				; Serial Mode 1 - 10 bit total: 1sn, 8db, 1sb
	CLR TI						; Clear TI register
	SETB TR1					; Start Timer 1

;	MOV EECON, #00011011b		; enable write to EEPROM
;	MOV DPTR, #00H				; set data pointer position to 100H

BT_ready:
	CLR RI						; RI = 0

BT_recv:
	JNB RI, BT_recv				; wait for data to be received
	MOV A, SBUF					; Copy SBUF contents to ACC
	CJNE A, #'F', BT_ready 	; if 'H' not received goto CMD_check2, else continue
	SJMP FW
	;LCALL EEPROM_WRITE				; if 'H' received goto HELP_LIST
	;SJMP BT_ready

;CMD_check2:
;	CJNE A, #'S', BT_ready 	; if 'S' not received goto CMD_check2, else continue
;	MOV DPTR, #00H				; set data pointer position to 100H
;	SJMP LOAD_DATA

;LOAD_DATA:
;	MOVX A, @DPTR				; get byte from EEPROM
;	ACALL DELAY4MS
;	INC DPTR

FW:  							; Counter-Clockwise Rotation
	MOV A, #00010001B
	MOV R5, #01H				; step multiplier = 16
FWRepeatSteps:
	MOV R4, #08H ;080h				; steps = 128, total steps = 4*4*128=2048
FW1:
	MOV P2, A    				; Step
	RR A    					; Next step
	ACALL DELAY5ms
	DJNZ R4, FW1

FWStepCheck:
	DJNZ R5, FWRepeatSteps
	MOV P2, #00H
	;RET
	SJMP BT_ready

;--- Internal EEPROM data write
;EEPROM_WRITE:
;	MOVX @DPTR, A				; write data to EEPROM
;	LCALL DELAY4MS
;	LCALL DELAY4MS
;	LCALL DELAY4MS				; wait about ~12ms for programming EEPROM
;	INC DPTR
;	RET

;--- 5.035 millisecond delay
DELAY5MS:
	MOV R4, #1	;11
DELAY_AGAIN:
	MOV R5, #1	;96
DELAY_HERE:
	NOP
	NOP
	DJNZ R5, DELAY_HERE
	DJNZ R4, DELAY_AGAIN
	RET

;--- ~4 millisecond delay
DELAY4ms:
	MOV R4, #4
AGAIN:
	MOV R5, #194
HERE:
	NOP
	NOP
	DJNZ R5, HERE
	DJNZ R4, AGAIN
	RET

END