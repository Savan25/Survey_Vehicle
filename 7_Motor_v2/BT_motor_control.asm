ORG 00H

	MOV P2, #00H			; Configure Port 1 as output ... motors
	MOV P3, #11110001B		; Configure Port 3 Upper Nibble as input, lower nibble as output

	MOV TMOD, #20H		; Timer 1, Mode 2 - 8 bit mode
	MOV TCON, #40h		; enable timer 1
	MOV TH1, #0FDH		; Baud rate = 9600
	MOV SCON, #50H		; Serial Mode 1 - 10 bit total: 1sn, 8db, 1sb
	CLR TI				; Clear TI register

	SETB TR1			; Start Timer 1

AGAIN:
	MOV P2, #00H
	CLR RI				; RI = 0

repeat:
	JNB RI, repeat		; wait for data to be received

	MOV A, SBUF			; Copy SBUF contents to ACC

	CJNE A, #'A', checknext	; go Backwards
	ACALL CW
	SJMP AGAIN

checknext:
	CJNE A, #'B', AGAIN	; go Forwards
	ACALL CCW
	SJMP AGAIN

CW:    					; Clockwise Rotation Setup
	MOV A, #00010001B
	CLR P3.2			; turn on LED1 - active low
	SETB P3.3			; turn off LED2 - active low
	MOV R5, #010H		; step multiplier = 16
here1:
	MOV R4, #080H		; steps = 128, total steps = 16*128=2048
CW1:
	MOV P2, A    		; Step
	RL A    			; Next Step
	ACALL DELAY
	DJNZ R4, CW1

CHECK:
	DJNZ R5, here1
	RET

CHECK1:
	DJNZ R5, here2
	RET

CCW:  					; Counter-Clockwise Rotation
	MOV A, #00010001B
	SETB P3.2			; turn off LED1 - active low
	CLR P3.3			; turn on LED2 - active low
	MOV R5, #010H
here2:
	MOV R4, #080H
CCW1:
	MOV P2, A    		; Step
	RR A    			; Next step
	ACALL DELAY
	DJNZ R4, CCW1
	LJMP check1

DELAY:
	MOV R2, #04h   		; initial 4
H1:
	MOV R3, #0FFh  		; initial 255
H2:
	DJNZ R3, H2
	DJNZ R2, H1
	RET

END
