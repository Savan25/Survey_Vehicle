ORG 00H
	MOV P0, #00H
	MOV P1, #00H		; Configure Port 1 as output ... motors
	MOV P3, #0F0H		; Configure Port 3 Upper Nibble as input, lower nibble as output
	MOV A, #00010001B	; Wave driving 2 motors simultaneously, 1 rev = 2048 steps

buttoncheck:
	JNB P3.4, pressed1	; If button1 pressed ... CW
	;JB P0.0, CW			; button1 not pressed but CW is toggled
	JNB P3.5, pressed2	; If button2 pressed ... CCW
	;JB P0.1, CCW		; button2 not pressed but CCW is toggled
	SJMP buttoncheck	; if buttons not pressed ... loop

pressed1:				; toggle CW state
	;CPL P0.0			; CW toggle
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

pressed2:				; toggle CCW state
	;CPL P0.1			; CCW toggle
CCW:  					; Counter-Clockwise Rotation
	SETB P3.0			; turn off LED1 - active low
	CLR P3.1			; turn on LED2 - active low
	MOV R5, #00000100B
here2:
	MOV R4, #11100000B
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
