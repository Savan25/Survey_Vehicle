ORG 0000H
LJMP SETUP

ORG 0003H						; interrupt vector
	LCALL EEPROM_WRITE
	RETI

SETUP:
	MOV IE, #10000001B			; enable external interrupt 0
	MOV P1, #00h				; Port 1 as output, status LEDs, 0 for ON, 1 for OFF
	MOV P2, #00h				; Port 2 as output, data LEDs
	MOV P3, #0FFh				; Port 3 as input, upper 4 bits = buttons, P3.2 = int0
	MOV P1, #0FFh				; turn OFF all LEDs

;START On-Chip EEPROM Setup
	MOV EECON, #00011011b		; enable write to EEPROM
	MOV DPTR, #100H				; set data pointer position to 100H
	MOV R3, #1					; load R3 with 5, counter for storing data to EEPROM
	;MOV R2, #1					; load R2 with 5, counter for reading data from EEPROM
;END On-Chip EEPROM Setup

wait:
	CJNE R3, #00h, LOAD_DATA			; if R3 == 0, read data from EEPROM
	SJMP wait

LOAD_DATA:
	MOV DPTR, #100H				; set data pointer position to 100H
	MOVX A, @DPTR				; get byte from EEPROM
	MOV P2, A					; output data to LEDs

	MOV IE, #00000000B			; disable all interrupts
	LJMP FOREVER

;START EEPROM Write Data
EEPROM_WRITE:
	; turn ON next LED, starting with LED.0
	CLR C						; clear carry flag
	MOV A, P1					; load LED bits to acc
	RLC A						; left shift acc
	MOV P1, A					; reload new LED bits to P1
	MOV A, P3					; store inputs from P2 to acc
	MOVX @DPTR, A				; write data to EEPROM
CHECK_DATA:
	; turn ON next LED
	CLR C						; clear carry flag
	MOV A, P1					; load LED bits to acc
	RLC A						; left shift acc
	MOV P1, A					; reload new LED bits to P1
	ACALL DELAY4MS				; wait about ~4ms for programming EEPROM
	INC DPTR					; increment data pointer
	DEC R3						; decrement R3, counter
	; turn ON next LED
	CLR C						; clear carry flag
	MOV A, P1					; load LED bits to acc
	RLC A						; left shift acc
	MOV P1, A					; reload new LED bits to P1
	RET
;END EEPROM Write Data

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