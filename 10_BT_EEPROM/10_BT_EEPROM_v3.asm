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

BT_ready:
	CLR RI						; RI = 0

BT_recv:
	JNB RI, BT_recv				; wait for data to be received
	MOV A, SBUF					; Copy SBUF contents to ACC
	CJNE A, #'H', CMD_check1 	; if 'H' not received goto CMD_check2, else continue
	SJMP HELP_LIST				; if 'H' received goto HELP_LIST

CMD_check1:
	CJNE A, #'S', CMD_check2 	; if 'S' not received goto CMD_check2, else continue
	MOV R0, A					; copy cmd to R0
	SJMP CMD_PROG				; if 'S' received goto CMD_PROG

CMD_check2:
	CJNE A, #'G', CMD_check3 	; if 'G' not received goto CMD_check3, else continue
	MOV R0, A					; copy cmd to R0
	SJMP CMD_MOVE				; if 'G' received goto CMD_MOVE

CMD_check3:
	CJNE A, #'M', BT_ready 		; if 'M' not received goto BT_ready, else continue
	MOV R0, A					; copy cmd to R0
	SJMP CMD_PATH				; if 'M' received goto CMD_PATH

HELP_LIST:
	MOV DPTR, #helplist			; load pointer for message
	LJMP BT_send_str

CMD_PROG:
	MOV DPTR, #startprog		; load pointer for message
	LJMP BT_send_str

CMD_MOVE:
	MOV DPTR, #startmove		; load pointer for message
	LJMP BT_send_str

CMD_PATH:
	MOV DPTR, #movelist			; load pointer for message
	LJMP BT_send_str

;--- Programming Mode
START_PROG:
	MOV DPTR, #00H				; set data pointer position to 00H
	MOV R7, #00h				; R7 as counter, reset to 0

BT_ready2:
	CLR RI						; RI = 0

BT_recv2:
	JNB RI, BT_recv2			; wait for data to be received
	MOV A, SBUF					; Copy SBUF contents to ACC
	CJNE A, #'F', CMD_check4 	; if 'F' not received goto CMD_check4, else continue
	;MOV EECON, #00011011b		; enable write to EEPROM
	INC R7
	LCALL EEPROM_WRITE			; if 'F' received goto EEPROM_WRITE

CMD_check4:
	CJNE A, #'L', CMD_check5 	; if 'L' not received goto CMD_check5, else continue
	INC R7
	LCALL EEPROM_WRITE			; if 'L' received goto EEPROM_WRITE

CMD_check5:
	CJNE A, #'R', CMD_check6 	; if 'R' not received goto CMD_check6, else continue
	INC R7
	LCALL EEPROM_WRITE			; if 'R' received goto EEPROM_WRITE

CMD_check6:
	CJNE A, #'E', CMD_check7 	; if 'E' not received goto CMD_check7, else continue
	INC R7
	LCALL EEPROM_WRITE			; if 'E' received goto EEPROM_WRITE

CMD_check7:
	CJNE A, #'W', CMD_check8 	; if 'W' not received goto CMD_check8, else continue
	INC R7
	LCALL EEPROM_WRITE			; if 'W' received goto EEPROM_WRITE

CMD_check8:
	CJNE A, #'X', BT_ready2 	; if 'X' not received goto BT_ready2, else continue
	MOV R0, A
	LJMP CMD_STOP				; if 'X' received goto CMD_STOP

START_MOVE:
	MOV DPTR, #00h				; set data pointer to 0
	MOV A, R7
	MOV R6, A
	INC R7

MOVE_LOOP:
	MOV A, #00h
	LCALL LOAD_DATA				; retrieve movement command from memory
	INC DPTR					; get ready to retrieve next value
	DJNZ R7, forwards			; decrement counter, if R7==0 then movement complete and exit MOVE_LOOP

MOV_FIN:
	MOV DPTR, #stopmove
	MOV P2, #00h
	LJMP BT_send_str

STOP_MOVE:
	LJMP BT_ready

forwards:
	CJNE A, #'F', left90turn	; if 'F' not received goto BT_ready2, else continue
	LCALL FW					; go Forwards
	SJMP MOVE_LOOP

left90turn:
	CJNE A, #'L', right90turn	; if 'L' not received goto BT_ready2, else continue
	LCALL LT					; turn 90 degrees left
	SJMP MOVE_LOOP

right90turn:
	CJNE A, #'R', left45turn	; if 'R' not received goto BT_ready2, else continue
	LCALL RT					; turn 90 degrees right
	SJMP MOVE_LOOP

left45turn:
	CJNE A, #'W', right45turn	; if 'W' not received goto BT_ready2, else continue
	LCALL LT_half				; turn 45 degrees left
	SJMP MOVE_LOOP

right45turn:
	CJNE A, #'E', MOVE_LOOP		; if 'E' not received goto BT_ready2, else continue
	LCALL RT_half				; turn 45 degrees right
	SJMP MOVE_LOOP

FW:  							; Counter-Clockwise Rotation
	MOV A, #00010001B
	MOV R5, #010H				; step multiplier = 16
FWRepeatSteps:
	MOV R4, #080H				; steps = 128, total steps = 4*4*128 = 2048
FW1:
	MOV P2, A    				; Step
	RR A    					; Next step
	ACALL DELAY4ms
	DJNZ R4, FW1

FWStepCheck:
	DJNZ R5, FWRepeatSteps
	RET

LT:    							; Clockwise Rotation Setup
	MOV R5, #012H				; step multiplier = 18, for 90 degree turn
LTRepeatSteps:
	MOV R4, #010H				; steps = 128, total steps = 2*4*128 = 1024
LT1:
	MOV A, #00010001B			; Step 1
	MOV P2, A    				; Step
	ACALL DELAY4ms
	MOV A, #00101000B			; Step 2
	MOV P2, A    				; Step
	ACALL DELAY4ms
	MOV A, #01000100B			; Step 3
	MOV P2, A    				; Step
	ACALL DELAY4ms
	MOV A, #10000010B			; Step 4
	MOV P2, A    				; Step
	ACALL DELAY4ms
	DJNZ R4, LT1

LTStepCheck:
	DJNZ R5, LTRepeatSteps
	RET

RT:    					; Clockwise Rotation Setup
	MOV R5, #012H		; step multiplier = 18, for 90 degree turn
RTRepeatSteps:
	MOV R4, #010H		; steps = 16, total steps = 18*4*16 = 1104
RT1:
	MOV A, #00010001B	; Step 1
	MOV P2, A    		; Step
	ACALL DELAY4ms
	MOV A, #10000010B	; Step 2
	MOV P2, A    		; Step
	ACALL DELAY4ms
	MOV A, #01000100B	; Step 3
	MOV P2, A    		; Step
	ACALL DELAY4ms
	MOV A, #00101000B	; Step 4
	MOV P2, A    		; Step
	ACALL DELAY4ms
	DJNZ R4, RT1

RTStepCheck:
	DJNZ R5, RTRepeatSteps
	RET

LT_half:  				; Clockwise Rotation Setup
	MOV R5, #01H		; step multiplier = 1, for 45 degree turn
LT_halfRepeatSteps:
	MOV R4, #040H		; steps = 64, total steps = 1*4*64 = 256
LT_half1:
	MOV A, #00010001B			; Step 1
	MOV P2, A    				; Step
	ACALL DELAY4ms
	MOV A, #00101000B			; Step 2
	MOV P2, A    				; Step
	ACALL DELAY4ms
	MOV A, #01000100B			; Step 3
	MOV P2, A    				; Step
	ACALL DELAY4ms
	MOV A, #10000010B			; Step 4
	MOV P2, A    				; Step
	ACALL DELAY4ms
	DJNZ R4, LT_half1

LT_halfStepCheck:
	DJNZ R5, LT_halfRepeatSteps
	RET

RT_half:  				; Clockwise Rotation Setup
	MOV R5, #01H		; step multiplier = 1, for 45 degree turn
RT_halfRepeatSteps:
	MOV R4, #040H		; steps = 64, total steps = 1*4*64 = 256
RT_half1:
	MOV A, #00010001B	; Step 1
	MOV P2, A    		; Step
	ACALL DELAY4ms
	MOV A, #10000010B	; Step 2
	MOV P2, A    		; Step
	ACALL DELAY4ms
	MOV A, #01000100B	; Step 3
	MOV P2, A    		; Step
	ACALL DELAY4ms
	MOV A, #00101000B	; Step 4
	MOV P2, A    		; Step
	ACALL DELAY4ms
	DJNZ R4, RT_half1

RT_halfStepCheck:
	DJNZ R5, RT_halfRepeatSteps
	RET

MOVE_LIST:
	LCALL LOAD_DATA				; retrieve movement command from memory
	LCALL BT_send_char			; send the data via bluetooth
	INC DPTR					; get ready to retrieve next value
	DJNZ R7, MOVE_LIST			; decrement counter, if R7==0 then movement complete and exit MOVE_LIST

LIST_FIN:
	MOV A, R6
	MOV R7, A
	MOV DPTR, #listfin
	MOV R1, #'Z'
	LJMP BT_send_str

CMD_STOP:
	MOV DPTR, #cmdstop
	LJMP BT_send_str

escape:
	LJMP BT_ready

leave:
	CJNE R0, #'S', leave2		; if command is not 'S' goto leave2, else continue
	MOV EECON, #00011011b		; enable write to EEPROM
	MOV R0, #00h				; clear R0
	LJMP START_PROG				; goto START_PROG - enter programming mode
leave2:
	CJNE R0, #'G', leave3		; if command is not 'G' goto leave3, else continue
	MOV R0, #00h				; clear R0
	LJMP START_MOVE				; goto START_MOVE - start moving with stored path
leave3:
	CJNE R0, #'X', leave4		; if command is not 'X' goto leave4, else continue
	MOV EECON, #00001011b		; disable write to EEPROM
	MOV R0, #00h				; clear R0
	LJMP STOP_MOVE				; goto STOP_MOVE - movement complete

leave4:
	CJNE R0, #'Z', leave5		; if command is not 'Z' goto leave5, else continue
	MOV R0, #00h				; clear R0
	SJMP escape					; goto escape - finished sending MOVE_LIST

leave5:
	CJNE R0, #'M', escape		; if command is not 'M' goto escape, else continue
	MOV R0, #00h				; clear R0
	MOV DPTR, #00h
	LJMP MOVE_LIST				; goto MOVE_LIST - show current path

;--- Send a string of text via serial Bluetooth communication
BT_send_str:
	CLR A						; clear accumulator
	MOVC A, @A+DPTR				; get the character
	JZ leave					; if last character, get out
	ACALL BT_send				; otherwise call transfer
	INC DPTR					; next one
	SJMP BT_send_str			; stay in loop

;--- Internal EEPROM data write
EEPROM_WRITE:
	MOVX @DPTR, A				; write data to EEPROM
	LCALL DELAY4MS
	LCALL DELAY4MS
	LCALL DELAY4MS				; wait about ~12ms for programming EEPROM
	INC DPTR					; get ready for next EEPROM write
	RET

;--- Load data from internal EEPROM
LOAD_DATA:
	MOVX A, @DPTR				; get byte from EEPROM
	;MOV R1, A					; store data in register 1
	RET

;--- Serial data transfer. ACC has the data
BT_send:
	MOV SBUF, A					; load the data

BT_send_str_2:
	JNB TI, BT_send_str_2		;stay here until last bit gone
	CLR TI						; get ready for next char
	RET							; return to caller

BT_Send_char:
	CLR TI						; clear the tx buffer full flag
	MOV SBUF, A					; put char in sbuf (scon.1 = TI)

TXLOOP:
	JNB TI, TXLOOP				; wait till char is sent
	RET							; leave subroutine

;--- Message List
helplist:
	DB 'Available Commands:', 0Ah
	DB 'S - Start Path Programming', 0Ah
	DB 'M - Display Programmed Path', 0Ah
	DB 'G - Start Movement', 0Ah
	DB 'H - Show This Help List', 0Ah
	DB 'Path Programming Mode ...', 0Ah
	DB 'Movement commands will be stored in memory.', 0Ah
	DB 'Path Programming Mode Commands :', 0Ah
	DB 'F - Move Forwards One Vehicle Length', 0Ah
	DB 'L - 90 Degree Left Turn', 0Ah
	DB 'R - 90 Degree Right Turn', 0Ah
	DB 'E - 45 Degree Right Turn', 0Ah
	DB 'W - 45 Degree Left Turn', 0Ah
	DB 'X - Stop Programming', 0Ah, 0

startprog:
	DB 'Entering Programming Mode', 0Ah, 0

startmove:
	DB 'Starting Movement, Please Wait ...', 0Ah, 0

movelist:
	DB 'Movement List:', 0Ah, 0

stopmove:
	DB 'Movement Complete ...', 0Ah
	DB 'Returning to Startup Mode.', 0Ah, 0

cmdstop:
	DB 'Exiting Programming Mode', 0Ah, 0

listfin:
	DB 'End of Movement List.', 0Ah, 0

;--- 5.035 millisecond delay
DELAY5MS:
	MOV R2, #11
DELAY_AGAIN:
	MOV R3, #96
DELAY_HERE:
	NOP
	NOP
	DJNZ R3, DELAY_HERE
	DJNZ R2, DELAY_AGAIN
	RET

;--- ~4 millisecond delay
DELAY4ms:
	MOV R2, #4
AGAIN:
	MOV R3, #194
HERE:
	NOP
	NOP
	DJNZ R3, HERE
	DJNZ R2, AGAIN
	RET

END
