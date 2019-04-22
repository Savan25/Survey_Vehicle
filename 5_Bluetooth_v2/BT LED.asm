; Bluetooth Code HC-05

ORG 00H
	MOV P1, #00H	; Configure Port 1 as output

	MOV TMOD, #20H	; Timer 1, Mode 2 - 8 bit mode
	MOV TCON, #40h	; enable timer 1
	MOV TH1, #0FDH	; Baud rate = 9600
	MOV SCON, #50H	; Serial Mode 1 - 10 bit total: 1sn, 8db, 1sb
	CLR TI	; Clear TI register

	SETB TR1	; Start Timer 1

AGAIN:
	CLR RI	; RI = 0

repeat:
	JNB RI, repeat	; wait for data to be received

	MOV A, SBUF	; Copy SBUF contents to ACC

	CJNE A, #'A', checknext
	CLR P1.0	; Turn LED1 on
	SJMP AGAIN

checknext:
	CJNE A, #'a', AGAIN
	SETB P1.0	; Turn LED1 off
	SJMP AGAIN

END