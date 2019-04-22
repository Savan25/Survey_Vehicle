; General Variables
COUNT 			equ 30h			; counter variable, to keep track of number of programmed moves
COUNT_TEMP 		equ 31h			; temporary variable for storing counter data
STEP_MULT 		equ 32h			; step multiplier variable
STEPS 			equ 33h			; number of steps variable
IN_LOOP_COUNT 	equ 34h			; delay loop variable
OUT_LOOP_COUNT 	equ 35h			; delay loop variable

; IR Sensor Port Pin Equates
IR1	equ 92h						;P1.2 - IR1
IR2	equ 93h						;P1.3 - IR2
IR3	equ 0B6h					;P3.6 - IR3
IR4	equ 0B7h					;P3.7 - IR4

; Mapping Variables ...
DIR		equ 36h					; vehicle direction variable (relative): N=0, NE=1, E=2, SE=3, S=4, SW=5, W=6, NW=7
PXMAP	equ 37h					; positive x distance counter
PYMAP	equ 38h					; positive y distance counter
NXMAP	equ 39h					; negative x distance counter
NYMAP	equ 3Ah					; negative y distance counter

ORG 0000H

; ... MAPPING Setup
	MOV DIR, #0h				; ... initital direction = relative north, start point = 0,0
	MOV PXMAP, #0h
	MOV PYMAP, #0h
	MOV NXMAP, #0h
	MOV NYMAP, #0h

	SETB IR1					; Setup Port Pins as Inputs for IR Sensors
	SETB IR2
	SETB IR3
	SETB IR4

	MOV P2, #00H				; Configure Port 2 as output ... motors

;Bluetooth setup
	MOV TMOD, #20H				; Timer 1, Mode 2 - 8 bit mode
	MOV TCON, #40h				; enable timer 1
	MOV TH1, #0FDH				; Baud rate = 9600
	MOV SCON, #50H				; Serial Mode 1 - 10 bit total: 1sn, 8db, 1sb
	CLR TI						; Clear TI register
	SETB TR1					; Start Timer 1

; Receive data over Bluetooth
BT_ready:
	CLR RI						; Clear receive interrupt flag ... acknowledge interrupt

BT_recv:
	JNB RI, BT_recv				; wait for data to be received
	MOV A, SBUF					; Copy SBUF contents (received data) to ACC
	CJNE A, #'H', CMD_check1 	; if 'H' not received check next valid character, else continue
	SJMP HELP_LIST				; if 'H' received, display list of commands (Help list)

CMD_check1:
	CJNE A, #'S', CMD_check2 	; if 'S' not received check next valid character, else continue
	MOV R0, A					; copy command to R0
	SJMP CMD_PROG				; if 'S' received goto CMD_PROG

CMD_check2:
	CJNE A, #'G', CMD_check3 	; if 'G' not received check next valid character, else continue
	MOV R0, A					; copy command to R0
	SJMP CMD_MOVE				; if 'G' received goto CMD_MOVE

CMD_check3:
	CJNE A, #'M', BT_ready 		; if 'M' not received wait to receive next character, else continue
	MOV R0, A					; copy command to R0
	SJMP CMD_PATH				; if 'M' received goto CMD_PATH

HELP_LIST:						; display help list ... list of valid commands
	MOV DPTR, #helplist			; load pointer for message
	LJMP BT_send_str			; transmit message

CMD_PROG:						; display message ... "entering programming mode"
	MOV DPTR, #startprog		; load pointer for message
	LJMP BT_send_str			; transmit message

CMD_MOVE:						; display message ... "starting movement"
	MOV DPTR, #startmove		; load pointer for message
	LJMP BT_send_str			; transmit message

CMD_PATH:						; display message ... "programmed path"
	MOV DPTR, #movelist			; load pointer for message
	LJMP BT_send_str			; transmit message

;--- Programming Mode
START_PROG:
	MOV DPTR, #00H				; set data pointer position to 00H
	MOV COUNT, #00h				; Counter, reset to 0

; Receive data over Bluetooth
BT_ready2:
	CLR RI						; RI = 0

BT_recv2:
	JNB RI, BT_recv2			; wait for data to be received
	MOV A, SBUF					; Copy SBUF contents (received data) to ACC
	CJNE A, #'F', CMD_check4 	; if 'F' not received check next valid character, else continue
	INC COUNT					; increment counter
	LCALL EEPROM_WRITE			; write data to EEPROM

CMD_check4:
	CJNE A, #'L', CMD_check5 	; if 'L' not received check next valid character, else continue
	INC COUNT					; increment counter
	LCALL EEPROM_WRITE			; write data to EEPROM

CMD_check5:
	CJNE A, #'R', CMD_check6 	; if 'R' not received goto check next valid character, else continue
	INC COUNT					; increment counter
	LCALL EEPROM_WRITE			; write data to EEPROM

CMD_check6:
	CJNE A, #'E', CMD_check7 	; if 'E' not received check next valid character, else continue
	INC COUNT					; increment counter
	LCALL EEPROM_WRITE			; write data to EEPROM

CMD_check7:
	CJNE A, #'W', CMD_check8 	; if 'W' not received check next valid character, else continue
	INC COUNT					; increment counter
	LCALL EEPROM_WRITE			; write data to EEPROM

CMD_check8:
	CJNE A, #'X', BT_ready2 	; if 'X' not received wait to receive next character, else continue
	MOV R0, A					; copy command to R0
	LJMP CMD_STOP				; if 'X' received goto CMD_STOP

START_MOVE:
	MOV DPTR, #00h				; set data pointer to 0
	MOV COUNT_TEMP, COUNT		; backup counter data
	INC COUNT					; increment counter

MOVE_LOOP:						; movement loop, repeat until last command
	MOV A, #00h					; clear accumulator
	LCALL LOAD_DATA				; retrieve movement command from memory
	INC DPTR					; get ready to retrieve next value
	DJNZ COUNT, forwards		; decrement counter, if COUNT==0 then movement complete and exit MOVE_LOOP

MOV_FIN:						; movement complete
	MOV DPTR, #stopmove			; display message ... "movement complete"
	MOV P2, #00h				; turn off motors
	LJMP BT_send_str			; transmit message

STOP_MOVE:						; movement complete
	LJMP BT_ready				; get ready to wait for commands

forwards:
	CJNE A, #'F', left90turn	; if 'F' not received check next valid character, else continue
	LCALL FW					; move Forwards
	SJMP MOVE_LOOP				; process next movement command

left90turn:
	CJNE A, #'L', right90turn	; if 'L' not received check next valid character, else continue
	LCALL LT					; turn 90 degrees left
	SJMP MOVE_LOOP				; process next movement command

right90turn:
	CJNE A, #'R', left45turn	; if 'R' not received check next valid character, else continue
	LCALL RT					; turn 90 degrees right
	SJMP MOVE_LOOP				; process next movement command

left45turn:
	CJNE A, #'W', right45turn	; if 'W' not received check next valid character, else continue
	LCALL LT_half				; turn 45 degrees left
	SJMP MOVE_LOOP				; process next movement command

right45turn:
	CJNE A, #'E', MOVE_LOOP		; if 'E' not received wait to receive next character, else continue
	LCALL RT_half				; turn 45 degrees right
	SJMP MOVE_LOOP				; process next movement command

FW:  							; Counter-Clockwise Rotation
	MOV A, #00010001B			; set up steps for wave driving
	MOV STEP_MULT, #010H		; step multiplier = 16
FWRepeatSteps:
	MOV STEPS, #080H			; steps = 128, total steps = 4*4*128 = 2048
FW1:
	MOV P2, A    				; Step
	RR A    					; Next step
	ACALL DELAY4ms				; 4 ms delay for stepping
	DJNZ STEPS, FW1				; decrement step counter

FWStepCheck:
	;JNB IR_IN1, DETECTED
	;JNB IR_IN2, DETECTED
	;JNB IR_IN3, DETECTED
	;JNB IR_IN4, DETECTED		; jump to DETECTED when object found
	DJNZ STEP_MULT, FWRepeatSteps

; Vehicle location mapping/tracking
N:	MOV A, #0h
	CJNE A, DIR, NE				; check if facing relative north
	INC PYMAP					; increment positive y coordinate
	RET							; return from subrouting call

NE:	MOV A, #1h
	CJNE A, DIR, E				; check if facing relative north-east
	INC PYMAP					; increment positive y coordinate
	INC PXMAP					; increment positive x coordinate
	RET							; return from subrouting call

E:	MOV A, #2h
	CJNE A, DIR, SE				; check if facing relative east
	INC PXMAP					; increment positive x coordinate
	RET							; return from subrouting call

SE:	MOV A, #3h
	CJNE A, DIR, S				; check if facing relative south-east
	INC NYMAP					; increment negative y coordinate
	INC PXMAP					; increment positive x coordinate
	RET							; return from subrouting call

S:	MOV A, #4h
	CJNE A, DIR, SW				; check if facing relative south
	INC NYMAP					; increment negative y coordinate
	RET							; return from subrouting call

SW:	MOV A, #5h
	CJNE A, DIR, W				; check if facing relative south-west
	INC NYMAP					; increment negative y coordinate
	INC NXMAP					; increment negative x coordinate
	RET							; return from subrouting call

W:	MOV A, #6h
	CJNE A, DIR, NW				; check if facing relative west
	INC NXMAP					; increment negative x coordinate
	RET							; return from subrouting call

; must be facing relative north-west otherwise
NW:	INC PYMAP					; increment positive y coordinate
	INC NXMAP					; increment negative x coordinate
	RET							; return from subrouting call

LT:    							; Clockwise Rotation Setup
	MOV STEP_MULT, #012H		; step multiplier = 18, for 90 degree turn
LTRepeatSteps:
	MOV STEPS, #010H			; steps = 128, total steps = 2*4*128 = 1024
LT1:
	MOV A, #00010001B			; Step 1
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #00101000B			; Step 2
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #01000100B			; Step 3
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #10000010B			; Step 4
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	DJNZ STEPS, LT1				; decrement step counter

LTStepCheck:
	DJNZ STEP_MULT, LTRepeatSteps	; decrement step multiplier counter

CHECK_FACE_N:					; check if facing relative north
	MOV A, #0
	CJNE A, DIR, CHECK_FACE_NE	; check direction, if facing relative north, continue
	MOV DIR, #6					; set direction to relative west
	RET							; return from subroutine call

CHECK_FACE_NE:					; check if facing relative north-east
	MOV A, #1
	CJNE A, DIR, NOT_FACE_N_NE	; check direction, if facing relative north-east, continue
	MOV DIR, #7					; set direction to relative north-west
	RET							; return from subroutine call

NOT_FACE_N_NE:					; not facing relative north or north-east
	DEC DIR
	DEC DIR						; adjust direction
	RET							; return from subroutine call

RT:    							; Clockwise Rotation Setup
	MOV STEP_MULT, #012H		; step multiplier = 18, for 90 degree turn
RTRepeatSteps:
	MOV STEPS, #010H			; steps = 16, total steps = 18*4*16 = 1104
RT1:
	MOV A, #00010001B			; Step 1
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #10000010B			; Step 2
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #01000100B			; Step 3
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #00101000B			; Step 4
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	DJNZ STEPS, RT1				; decrement step counter

RTStepCheck:
	DJNZ STEP_MULT, RTRepeatSteps	; decrement step multiplier counter


CHECK_FACE_W:					; check if facing relative west
	MOV A, #6
	CJNE A, DIR, CHECK_FACE_NW	; check direction, if facing relative west, continue
	MOV DIR, #0h				; set direction to relative north
	RET							; return from subroutine call

CHECK_FACE_NW:					; check if facing relative north-west
	MOV A, #7
	CJNE A, DIR, NOT_FACE_W_NW	; check direction, if facing relative north-west, continue
	MOV DIR, #1h				; set direction to relative north-east
	RET							; return from subroutine call

NOT_FACE_W_NW:					; not facing relative north or north-west
	INC DIR
	INC DIR						; adjust direction
	RET							; return from subroutine call

LT_half:  						; Clockwise Rotation Setup
	MOV STEP_MULT, #06H			; step multiplier = 1, for 45 degree turn
LT_halfRepeatSteps:
	MOV STEPS, #010H			; steps = 64, total steps = 1*4*64 = 256
LT_half1:
	MOV A, #00010001B			; Step 1
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #00101000B			; Step 2
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #01000100B			; Step 3
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #10000010B			; Step 4
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	DJNZ STEPS, LT_half1		; decrement step counter

LT_halfStepCheck:
	DJNZ STEP_MULT, LT_halfRepeatSteps	; decrement step multiplier counter

CHECK_FACE_N2:					; check if facing relative north
	MOV A, #0
	CJNE A, DIR, NOT_FACE_N2	; check direction, if facing relative north, continue
	MOV DIR, #7					; set direction to relative north-west
	RET							; return from subroutine call

NOT_FACE_N2:					; not facing relative north
	DEC DIR						; adjust direction
	RET							; return from subroutine call

RT_half:  						; Clockwise Rotation Setup
	MOV STEP_MULT, #06H			; step multiplier = 1, for 45 degree turn
RT_halfRepeatSteps:
	MOV STEPS, #010H			; steps = 64, total steps = 1*4*64 = 256
RT_half1:
	MOV A, #00010001B			; Step 1
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #10000010B			; Step 2
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #01000100B			; Step 3
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	MOV A, #00101000B			; Step 4
	MOV P2, A    				; Step
	ACALL DELAY4ms				; 4 ms delay for stepping
	DJNZ STEPS, RT_half1		; decrement step counter

RT_halfStepCheck:
	DJNZ STEP_MULT, RT_halfRepeatSteps	; decrement step multiplier counter

CHECK_FACE_NW2:					; check if facing relative north-west
	MOV A, #7
	CJNE A, DIR, NOT_FACE_NW	; check direction, if facing relative north-west, continue
	MOV DIR, #0h				; set direction to relative north
	RET							; return from subroutine call

NOT_FACE_NW:					; not facing relative north-west
	INC DIR						; adjust direction
	RET 						; return from subroutine call

MOVE_LIST:						; display programmed path
	LCALL LOAD_DATA				; retrieve movement command from memory
	LCALL BT_send_char			; send the data via bluetooth
	INC DPTR					; get ready to retrieve next value
	DJNZ COUNT, MOVE_LIST		; decrement counter, if COUNT==0 then movement complete and exit MOVE_LIST

LIST_FIN:						; finished display programmed path
	MOV COUNT, COUNT_TEMP		; restore counter data
	MOV DPTR, #listfin
	MOV R1, #'Z'				; store command in R1
	LJMP BT_send_str			; transmit message

CMD_STOP:
	MOV DPTR, #cmdstop			; display message ... "exitting programming mode"
	LJMP BT_send_str			; transmit message

escape:
	LJMP BT_ready				; wait to receive next character

leave:
	CJNE R0, #'S', leave2		; if command is not 'S' check next character, else continue
	MOV EECON, #00011011b		; enable write to EEPROM
	MOV R0, #00h				; clear R0
	LJMP START_PROG				; goto START_PROG - enter programming mode

leave2:
	CJNE R0, #'G', leave3		; if command is not 'G' check next character, else continue
	MOV R0, #00h				; clear R0
	LJMP START_MOVE				; goto START_MOVE - start moving with stored path

leave3:
	CJNE R0, #'X', leave4		; if command is not 'X' check next character, else continue
	MOV EECON, #00001011b		; disable write to EEPROM
	MOV R0, #00h				; clear R0
	LJMP STOP_MOVE				; goto STOP_MOVE - movement complete

leave4:
	CJNE R0, #'Z', leave5		; if command is not 'Z' check next character, else continue
	MOV R0, #00h				; clear R0
	SJMP escape					; goto escape - finished sending MOVE_LIST

leave5:
	CJNE R0, #'M', escape		; if command is not 'M' goto escape, else continue
	MOV R0, #00h				; clear R0
	MOV DPTR, #00h
	LJMP MOVE_LIST				; goto MOVE_LIST - show current path

BT_send_str:					;--- Send a string of text via serial Bluetooth communication
	CLR A						; clear accumulator
	MOVC A, @A+DPTR				; get the character
	JZ leave					; if last character, get out
	ACALL BT_send				; otherwise call transfer
	INC DPTR					; next one
	SJMP BT_send_str			; stay in loop

EEPROM_WRITE:					;--- Internal EEPROM data write
	MOVX @DPTR, A				; write data to EEPROM
	LCALL DELAY4MS
	LCALL DELAY4MS
	LCALL DELAY4MS				; wait for about 12ms to program EEPROM
	INC DPTR					; get ready for next EEPROM write
	RET							; return from subroutine call

LOAD_DATA:						;--- Load data from internal EEPROM
	MOVX A, @DPTR				; get byte from EEPROM
	RET							; return from subroutine call

BT_send:						;--- Serial data transfer. ACC has the data
	MOV SBUF, A					; load the data
BT_send_str_2:					; transmit data
	JNB TI, BT_send_str_2		; stay here until last bit gone
	CLR TI						; get ready for next char
	RET							; return to caller

BT_Send_char:					;--- Serial data transfer.
	CLR TI
	MOV SBUF, A					; put char in sbuf (scon.1 = TI)

TXLOOP:							; wait for transmission to finish
	JNB TI, TXLOOP				; wait till char is sent
	CLR TI						; get ready for next char
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

;--- ~4 millisecond delay (4ms + 395ns)
DELAY4ms:
	MOV OUT_LOOP_COUNT, #5
AGAIN:
	MOV IN_LOOP_COUNT, #183
HERE:
	NOP
	NOP
	DJNZ IN_LOOP_COUNT, HERE
	DJNZ OUT_LOOP_COUNT, AGAIN
	NOP
	NOP
	NOP
	RET

END
