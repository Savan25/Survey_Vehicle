ORG 00H
	MOV P1, #00H		; Configure Port 1 as output ... motors
	MOV P3, #0F0H		; Configure Port 3 Upper Nibble as input, lower nibble as output
	MOV A, #00010001B	; Wave driving 2 motors simultaneously, 1 rev = 2048 steps

buttoncheck:
	JNB P3.4, CW		; If button1 pressed ... CW
	JNB P3.5, CCW		; If button2 pressed ... CCW
	SJMP buttoncheck	; if buttons not pressed ... loop

CW:    					; Clockwise Rotation Setup
	CLR P3.0			; turn on LED1 - active low
	SETB P3.1			; turn off LED2 - active low
	MOV R5, #010H		; step multiplier = 16
here1:
	MOV R4, #080H		; steps = 128, total steps = 16*128=2048
CW1:
	MOV P1, A    		; Step
	RL A    			; Next Step
	ACALL DELAY
	DJNZ R4, CW1

CHECK:
	DJNZ R5, here1
	LJMP buttoncheck

CHECK1:
	DJNZ R5, here2
	LJMP buttoncheck

CCW:  					; Counter-Clockwise Rotation
	SETB P3.0			; turn off LED1 - active low
	CLR P3.1			; turn on LED2 - active low
	MOV R5, #010H
here2:
	MOV R4, #080H
CCW1:
	MOV P1, A    		; Step
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
