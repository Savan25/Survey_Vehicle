IR1	equ 92h				;P1.2 - IR1
IR2	equ 93h				;P1.3 - IR2
IR3	equ 0B6h			;P3.6 - IR3
IR4	equ 0B7h			;P3.7 - IR4

org 00h

; config inputs
SETB IR1
SETB IR2
SETB IR3
SETB IR4

; config outputs
MOV P2, #00h

AGAIN:
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY

; jump to DETECTED when object found
jmp1:
JB IR1, NO_DETECT1
CPL P2.0
jmp2:
JB IR2, NO_DETECT2
CPL P2.1
jmp3:
JB IR3, NO_DETECT3
CPL P2.2
jmp4:
JB IR4, NO_DETECT4
CPL P2.3
SJMP AGAIN

NO_DETECT1:
SJMP jmp2

NO_DETECT2:
SJMP jmp3

NO_DETECT3:
SJMP jmp4

NO_DETECT4:
SJMP AGAIN

DELAY:
	MOV R2, #0ffh
DELAY_AGAIN:
	MOV R3, #0ffh
DELAY_HERE:
	NOP
	NOP
	DJNZ R3, DELAY_HERE
	DJNZ R2, DELAY_AGAIN
	RET

end
