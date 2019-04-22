MYDATA EQU 100H
COUNT EQU 5

	SETB EECON.3		; set EEMEN bit to select on-chip EEPROM data memory
	SETB EECON.4		; set EEMWE bit to write to EEPROM

	MOV P1, #0FFH		; port 1 as input
	MOV DPTR, #MYDATA	; set data pointer position to 100H
	MOV R3, #COUNT		; load R3 with 5

AGAIN:
	MOV A, P1			; read data from P1 to Accumulator
	MOVX @DPTR, A		; write data to EEPROM
	ACALL DELAY			; wait for some time
	INC DPTR			; increment data pointer
	DJNZ R3, AGAIN		; decrement R3 and loop from AGAIN

DELAY:
	MOV R4, #04h   		; initial 4
H1:
	MOV R5, #0FFh  		; initial 255
H2:
	DJNZ R5, H2
	DJNZ R4, H1
	RET

END