ORG 0000H
LJMP SETUP

SETUP:
	MOV P1, #00h				; Port 2 as output, data LEDs

;START On-Chip EEPROM Setup
	MOV EECON, #00011011b		; enable write to EEPROM
	MOV DPTR, #100H				; set data pointer position to 100H
;END On-Chip EEPROM Setup

;START EEPROM Write Data
EEPROM_WRITE:
	MOV A, #01100110b			; data to store 01010101
	MOVX @DPTR, A				; write data to EEPROM
CHECK_DATA:
	ACALL DELAY4MS				; wait about ~4ms for programming EEPROM
	INC DPTR					; increment data pointer
;END EEPROM Write Data

LOAD_DATA:
	MOV DPTR, #100H				; set data pointer position to 100H
	MOVX A, @DPTR				; get byte from EEPROM
	MOV P1, A					; output data to LEDs

	LJMP FOREVER

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

FOREVER:
	SJMP FOREVER				; wait forever
END
