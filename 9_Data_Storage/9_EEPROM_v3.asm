ORG 0000H
LJMP SETUP

SETUP:
	MOV P1, #00h				; Port 1 as output, status LEDs, 0 for ON, 1 for OFF
	MOV P2, #00h				; Port 2 as output, data LEDs
	MOV P1, #0FFh				; turn OFF all LEDs

;START On-Chip EEPROM Setup
	MOV EECON, #00011011b		; enable write to EEPROM
	MOV DPTR, #100H				; set data pointer position to 100H
;END On-Chip EEPROM Setup

	CLR P1.3

;START EEPROM Write Data
EEPROM_WRITE:
	MOV A, #01010101b			; data to store 01010101
	MOVX @DPTR, A				; write data to EEPROM
CHECK_DATA:
	ACALL DELAY4MS				; wait about ~4ms for programming EEPROM
	INC DPTR					; increment data pointer
	CLR P1.0
;END EEPROM Write Data

;START EEPROM Write Data
EEPROM_WRITE2:
	MOV A, #11001100b			; data to store 11001100
	MOVX @DPTR, A				; write data to EEPROM
CHECK_DATA2:
	ACALL DELAY4MS				; wait about ~4ms for programming EEPROM
	INC DPTR					; increment data pointer
	CLR P1.1
;END EEPROM Write Data

LOAD_DATA:
	MOV DPTR, #100H				; set data pointer position to 100H
	MOVX A, @DPTR				; get byte from EEPROM
	MOV P2, A					; output data to LEDs
	CLR P1.2

	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY

LOAD_DATA2:
	INC DPTR
	MOVX A, @DPTR				; get byte from EEPROM
	MOV P2, A					; output data to LEDs
	CLR P1.3

	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY

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

DELAY:
	MOV R7, #0FFh ;set R7 to 48 (increasing slows down LED blink rate)
delay1:
	MOV R6, #0FFh	;Set R6 to 255
delay2:
	DJNZ R6, delay2	;Decrement R6 and jump to delay2 if R6 not zero
	DJNZ R7, delay1	;Decrement R7 and jump to delay1 if R7s not zero
	RET	;END DELAY LOOP

FOREVER:
	SJMP FOREVER				; wait forever
END
