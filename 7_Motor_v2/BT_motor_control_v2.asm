ORG 00H

	MOV P2, #00H			; Configure Port 1 as output ... motors
	MOV P3, #11110001B		; Configure Port 3 Upper Nibble as input, lower nibble as output

	MOV TMOD, #20H		; Timer 1, Mode 2 - 8 bit mode
	MOV TCON, #40h		; enable timer 1
	MOV TH1, #0FDH		; Baud rate = 9600
	MOV SCON, #50H		; Serial Mode 1 - 10 bit total: 1sn, 8db, 1sb
	CLR TI				; Clear TI register

	SETB TR1			; Start Timer 1

LOOP:
	MOV P2, #00H
	CLR RI				; RI = 0

repeat:
	JNB RI, repeat		; wait for data to be received

	MOV A, SBUF			; Copy SBUF contents to ACC

backwards:
	CJNE A, #'B', forwards	; go Backwards
	ACALL BW
	SJMP LOOP

forwards:
	CJNE A, #'F', leftturn	; go Forwards
	ACALL FW
	SJMP LOOP

leftturn:
	CJNE A, #'L', rightturn	; turn Left
	ACALL LT
	SJMP LOOP

rightturn:
	CJNE A, #'R', LOOP	;turn Right
	ACALL RT
	SJMP LOOP

BW:    					; Clockwise Rotation Setup
	MOV A, #00010001B
	CLR P3.2			; turn on LED1 - active low
	SETB P3.3			; turn off LED2 - active low
	MOV R5, #010H		; step multiplier = 16
BWRepeatSteps:
	MOV R4, #080H		; steps = 128, total steps = 1*16*128=2048
BW1:
	MOV P2, A    		; Step
	RL A    			; Next Step
	ACALL DELAY
	DJNZ R4, BW1

BWStepCheck:
	DJNZ R5, BWRepeatSteps
	RET

FW:  					; Counter-Clockwise Rotation
	MOV A, #00010001B
	SETB P3.2			; turn off LED1 - active low
	CLR P3.3			; turn on LED2 - active low
	MOV R5, #010H		; step multiplier = 16
FWRepeatSteps:
	MOV R4, #080H		; steps = 128, total steps = 4*4*128=2048
FW1:
	MOV P2, A    		; Step
	RR A    			; Next step
	ACALL DELAY
	DJNZ R4, FW1

FWStepCheck:
	DJNZ R5, FWRepeatSteps
	RET

LT:    					; Clockwise Rotation Setup
	SETB P3.2			; turn on LED1 - active low
	SETB P3.3			; turn off LED2 - active low
	MOV R5, #04H		; step multiplier = 4
LTRepeatSteps:
	MOV R4, #080H		; steps = 128, total steps = 4*4*128=2048
LT1:
	MOV A, #00010001B	; Step 1
	MOV P2, A    		; Step
	ACALL DELAY
	MOV A, #00101000B	; Step 2
	MOV P2, A    		; Step
	ACALL DELAY
	MOV A, #01000100B	; Step 3
	MOV P2, A    		; Step
	ACALL DELAY
	MOV A, #10000010B	; Step 4
	MOV P2, A    		; Step
	ACALL DELAY
	DJNZ R4, LT1

LTStepCheck:
	DJNZ R5, LTRepeatSteps
	RET

RT:    					; Clockwise Rotation Setup
	SETB P3.2			; turn on LED1 - active low
	SETB P3.3			; turn off LED2 - active low
	MOV R5, #04H		; step multiplier = 4
RTRepeatSteps:
	MOV R4, #080H		; steps = 128, total steps = 4*4*128=2048
RT1:
	MOV A, #00010001B	; Step 1
	MOV P2, A    		; Step
	ACALL DELAY
	MOV A, #10000010B	; Step 2
	MOV P2, A    		; Step
	ACALL DELAY
	MOV A, #01000100B	; Step 3
	MOV P2, A    		; Step
	ACALL DELAY
	MOV A, #00101000B	; Step 4
	MOV P2, A    		; Step
	ACALL DELAY
	DJNZ R4, RT1

RTStepCheck:
	DJNZ R5, RTRepeatSteps
	RET

DELAY:
	MOV R2, #04h   		; initial 4
H1:
	MOV R3, #0FFh  		; initial 255
H2:
	DJNZ R3, H2
	DJNZ R2, H1
	RET

END
