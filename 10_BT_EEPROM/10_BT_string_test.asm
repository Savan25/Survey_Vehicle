org 0

	mov p2, #0ffh		;make p2 an input port
	mov tmod, #20h		;timer 1, mode 2 (auto-reload)
	mov th1, #0fah		;4800 baud rate
	mov scon, #50h		;8-bit, 1 stop, REN enabled
	setb tr1			;start timer 1
	mov dptr, #mydata	;load pointer for message

h_1:
	clr a
	movc a, @a+dptr		;get the character
	jz b_1				;if last character, get out
	acall send			;otherwise call transfer
	inc dptr			;next one
	sjmp h_1			;stay in loop

b_1:
	mov a, p2			;read data on p2
	acall send			;transfer it serially
	acall recv			;get the serial data
	mov p1, a			;display it on LEDs
	sjmp b_1			;stay in loop indefinitely

;--- serial data transfer. ACC has the data
send:
	mov sbuf, a			;load the data

h_2:
	jnb ti, h_2			;stay here until last bit gone
	clr ti				;get ready for next char
	ret					;return to caller

;--- receive data serially in ACC
recv:
	jnb ri, recv		;wait here for char
	mov a, sbuf			;save it in ACC
	clr ri				;get ready for next char
	ret					;return to caller

;--- the message
mydata:
	db 0Ah, 0Dh, 'we are ready', 0

end