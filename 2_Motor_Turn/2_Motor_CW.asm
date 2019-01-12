MOV P1, #00H	; Configure Port 1 as output

CW:	; Clockwise Rotation
SETB P1.4
CLR P1.1
ACALL DELAY	; End step 1
SETB P1.3
ACALL DELAY	; End step 2
CLR P1.4
ACALL DELAY	; End step 3
SETB P1.2
ACALL DELAY	; End step 4
CLR P1.3
ACALL DELAY	; End step 5
SETB P1.1
ACALL DELAY	; End step 6
CLR P1.2
ACALL DELAY	; End step 7
CPL P1.0    ; Toggle LED
LJMP CW

DELAY:
MOV R7, #0FFh ;set R7 to 255 (increasing slows down LED blink rate)
delay1:
MOV R6, #08h	;Set R6 to 255
delay2:
DJNZ R6, delay2	;Decrement R6 and jump to delay2 if R6 not zero
DJNZ R7, delay1	;Decrement R7 and jump to delay1 if R7s not zero
RET	;END DELAY LOOP

END