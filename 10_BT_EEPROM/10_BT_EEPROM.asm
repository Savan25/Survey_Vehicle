ORG 0000H

SETUP:
	;Bluetooth setup
	MOV TMOD, #20H	; Timer 1, Mode 2 - 8 bit mode
	MOV TCON, #40h	; enable timer 1
	MOV TH1, #0FDH	; Baud rate = 9600
	MOV SCON, #50H	; Serial Mode 1 - 10 bit total: 1sn, 8db, 1sb
	CLR TI	; Clear TI register
	SETB TR1	; Start Timer 1
	;On-chip EEPROM setup
	MOV EECON, #00011011b		; enable write to EEPROM
	MOV DPTR, #00H				; set data pointer position to 100H

BT_AGAIN:
	CLR RI	; RI = 0

BT_REPEAT:
	JNB RI, BT_REPEAT	; wait for data to be received

	MOV A, SBUF	; Copy SBUF contents to ACC

	CJNE A, #'A', BT_CHECKNEXT
	CLR P1.0	; Turn LED1 on
	SJMP BT_AGAIN

BT_CHECKNEXT:
	CJNE A, #'a', BT_AGAIN
	SETB P1.0	; Turn LED1 off
	SJMP BT_AGAIN

EEPROM_WRITE:
	MOV A, #41h					; data to store "A"
	MOVX @DPTR, A				; write data to EEPROM
	ACALL DELAY4MS				; wait about ~4ms for programming EEPROM
	ACALL DELAY4MS				; wait about ~4ms for programming EEPROM
	ACALL DELAY4MS				; wait about ~4ms for programming EEPROM

	MOV EECON, #00001011b		; disable write to EEPROM

	ACALL DELAY4MS

	MOV EECON, #00011011b		; enable write to EEPROM

EEPROM_WRITE2:
	MOV DPTR, #200H				; set data pointer position to 200H
	MOV A, #52h					; data to store "R"
	MOVX @DPTR, A				; write data to EEPROM

	ACALL DELAY4MS
	ACALL DELAY4MS				; wait about ~4ms for programming EEPROM
	ACALL DELAY4MS				; wait about ~4ms for programming EEPROM
	MOV EECON, #00001011b		; disable write to EEPROM

	ACALL DELAY4MS

LOAD_DATA:
	MOV DPTR, #100H				; set data pointer position to 100H
	MOVX A, @DPTR				; get byte from EEPROM
	MOV R1, A					; store data in register 1

	ACALL DELAY4MS

LOAD_DATA2:
	MOV DPTR, #200H				; set data pointer position to 200H
	MOVX A, @DPTR				; get byte from EEPROM
	MOV R2, A					; store data in register 2

	ACALL DELAY4MS

	LJMP FINISH

; 4 millisecond delay
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

FINISH:
	ACALL DELAY4MS


FOREVER:
	SJMP FOREVER				; wait forever
END

