PHONBIT BIT 12H

ORG 0000H
	LJMP SETUP				;skip ISR code

ORG 0003H					;external interrupt 0 ISR
	CPL PHONBIT
	RETI

SETUP:
	MOV IE, #10000001B		;enable external interrupt 0
	MOV P2, #00H			;configure port 2 as output
	MOV P3, #0FFH			;configure port 3 is input
	MOV C, PHONBIT			; C is carry

LOOP:
	JNB PHONBIT, NO
YES:
	SETB P2.2
	SJMP LOOP
NO:
	CLR P2.2
	SJMP LOOP

END