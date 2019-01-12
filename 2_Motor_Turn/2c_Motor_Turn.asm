MOV P1, #00H	; Configure Port as output
MOV P3, #00H
MOV A, #00010001B

CW:    ; Clockwise Rotation Setup
CLR P3.4
SETB P3.5
MOV R5, #00000100B
here1: MOV R4, #11100000B
CW1:
MOV P1, A    ; Step
RR A    ; Next Step
ACALL DELAY
DJNZ R4, CW1    ; Decrement counter, if x steps complete continue, else loop clockwise

CHECK:
DJNZ R5, here1
SJMP CCW    ; Start counter-clockwise rotation

CHECK1:
DJNZ R5, here2
LJMP CW    ; Start clockwise rotation

CCW:    ; Counter-Clockwise Rotation
SETB P3.4
CLR P3.5
MOV R5, #00000100B
here2: MOV R4, #11100000B
CCW1:
MOV P1, A    ; Step
RL A    ; Next step
ACALL DELAY
DJNZ R4, CCW1    ; Decrement counter, if x steps complete continue, else loop clockwise
LJMP CHECK1    ; Loop counter-clockwise

DELAY:
MOV R2, #04h    ; initial 4
H1:
MOV R3, #0FFh    ; initial 255
H2:
DJNZ R3, H2
DJNZ R2, H1
RET

END