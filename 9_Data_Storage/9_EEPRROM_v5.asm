ORG 0000H

SETUP:
	MOV P1, #0FFh
	MOV EECON, #00011011b		; enable write to EEPROM
	MOV DPTR, #100H				; set data pointer position to 100H

EEPROM_WRITE:
	SETB P1.0
	SETB P1.4
	SETB P1.6
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
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS
	ACALL DELAY4MS

	CLR P1.0
	CLR P1.4
	CLR P1.6

FOREVER:
	SJMP FOREVER				; wait forever
END
