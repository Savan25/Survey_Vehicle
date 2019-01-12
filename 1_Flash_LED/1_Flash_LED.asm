MOV P1, #00H	; Configure Port 1 as output

BACK:
CPL P1.0	; Toggle P1.0 (LED)
ACALL DELAY	; Long Delay - about 0.6 seconds
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
SJMP BACK

DELAY:
MOV R7, #0FFh ;set R7 to 48 (increasing slows down LED blink rate)
delay1:
MOV R6, #0FFh	;Set R6 to 255
delay2:
DJNZ R6, delay2	;Decrement R6 and jump to delay2 if R6 not zero
DJNZ R7, delay1	;Decrement R7 and jump to delay1 if R7s not zero
RET	;END DELAY LOOP

END