ORG 0000H

;START BT Setup
	MOV TMOD, #20H	; Timer 1, Mode 2 - 8 bit mode
	MOV TCON, #40h	; enable timer 1
	MOV TH1, #0FDH	; Baud rate = 9600
	MOV SCON, #50H	; Serial Mode 1 - 10 bit total: 1sn, 8db, 1sb
	CLR TI			; Clear TI register

	SETB TR1		; Start Timer 1
;END BT Setup

;START On-Chip EEPROM Setup
	MOV EECON, #00011011b		; enable write to EEPROM
	MOV DPTR, #100H				; set data pointer position to 100H
	MOV R3, #5					; load R3 with 5
;END On-Chip EEPROM Setup

;START BT Receive Data
BT_AGAIN:
	CLR RI		; RI = 0

BT_RECEIVE:
	JNB RI, BT_RECEIVE		; wait for data to be received
	MOV A, SBUF				; Copy SBUF contents to ACC
	ACALL EEPROM_WRITE		; write data to EEPROM
	SJMP BT_AGAIN			; loop again
;END BT Receive Data

;START EEPROM Write Data
EEPROM_WRITE:
	MOVX @DPTR, A					; write data to EEPROM
CHECK_DATA:
	MOV R0, EECON					; copy EECON register value to R0
	CJNE R0, #00011011b, CHECK_DATA	; check if EEPROM write complete
	INC DPTR						; increment data pointer
	ACALL BT_SEND					; send BT data
	DJNZ R3, EEPROM_WRITE			; decrement R3 and loop from EEPROM_WRITE
	RET
;END EEPROM Write Data

;START BT Send Data
BT_SEND:
	CLR TI				; clear the tx buffer full flag
	MOV A, #31h			; send a "1"
	MOV SBUF, A			; put char in sbuf (scon.1 = TI)

TXLOOP:
	JNB TI, TXLOOP		; wait till char is sent
	RET					; leave subroutine
;END BT Send Data

END
