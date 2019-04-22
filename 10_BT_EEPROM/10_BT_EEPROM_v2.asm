ORG 0000H

SETUP:
	;Bluetooth setup
	MOV TMOD, #20H				; Timer 1, Mode 2 - 8 bit mode
	MOV TCON, #40h				; enable timer 1
	MOV TH1, #0FDH				; Baud rate = 9600
	MOV SCON, #50H				; Serial Mode 1 - 10 bit total: 1sn, 8db, 1sb
	CLR TI						; Clear TI register
	SETB TR1					; Start Timer 1
	;On-chip EEPROM setup
	MOV EECON, #00011011b		; enable write to EEPROM
	MOV DPTR, #00H				; set data pointer position to 100H

BT_ready:
	CLR RI						; RI = 0

BT_recv:
	JNB RI, BT_recv				; wait for data to be received
	MOV A, SBUF					; Copy SBUF contents to ACC
	CJNE A, #'A', checknext 	;if 'A' not received goto checknext, else continue
	SJMP msg1 					; if 'A' received goto msg1

checknext:
	CJNE A, #'B', BT_ready 		;if 'B' not received goto AGAIN, else continue
	SJMP msg2 					; if 'B' received goto msg1

msg1:
	MOV DPTR, #mydata			;load pointer for message
	SJMP BT_send_str

msg2:
	MOV DPTR, #mydata2			;load pointer for message
	SJMP BT_send_str

leave:
	SJMP BT_ready

BT_send_str:
	CLR A
	MOVC A, @A+DPTR				;get the character
	JZ leave					;if last character, get out
	ACALL BT_send				;otherwise call transfer
	INC DPTR					;next one
	SJMP BT_send_str			;stay in loop


;--- serial data transfer. ACC has the data
BT_send:
	MOV SBUF, A					;load the data

BT_send_str_2:
	JNB TI, BT_send_str_2		;stay here until last bit gone
	CLR TI						;get ready for next char
	RET							;return to caller

;--- the message
mydata:
	DB 'A: Hello!', 0Ah, 0

mydata2:
	DB 'B: Goodbye!', 0Ah, 0

END
