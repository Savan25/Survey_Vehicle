org 0

	MOV TMOD, #20H	; Timer 1, Mode 2 - 8 bit mode
	MOV TCON, #40h	; enable timer 1
	MOV TH1, #0FDH	; Baud rate = 9600
	MOV SCON, #50H	; Serial Mode 1 - 10 bit total: 1sn, 8db, 1sb
	clr ti
	setb tr1			;start timer 1


	CLR RI	; RI = 0

repeat:DELAY5MS
	JNB RI, repeat	; wait for data to be received
	MOV A, SBUF	; Copy SBUF contents to ACC
	CJNE A, #'A', checknext ;if 'A' not received goto checknext, else continue
	SJMP msg1 ; if 'A' received goto msg1

checknext:
	CJNE A, #'B', AGAIN ;if 'B' not received goto AGAIN, else continue
	SJMP msg2 ; if 'B' received goto msg1

msg1:
	mov dptr, #mydata	;load pointer for message
	SJMP h_1

msg2:
	mov dptr, #mydata2	;load pointer for message
	SJMP h_1

leave:
SJMP AGAIN

h_1:
	clr a
	movc a, @a+dptr		;get the character
	jz leave				;if last character, get out
	acall send			;otherwise call transfer
	inc dptr			;next one
	sjmp h_1			;stay in loop


;--- serial data transfer. ACC has the data
send:
	mov sbuf, a			;load the data

h_2:
	jnb ti, h_2			;stay here until last bit gone
	clr ti				;get ready for next char
	ret					;return to caller

;--- the message
mydata:
	db 'A: Hello!', 0Ah, 0

mydata2:
	db 'B: Goodbye!', 0Ah, 0

end
