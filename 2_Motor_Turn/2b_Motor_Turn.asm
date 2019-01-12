MOV P1, #00H	; Configure Port as output
MOV P3, #00H
MOV A, #00010001B

CW:    ; Clockwise Rotation Setup
;ACALL DELAY
CLR P3.4
SETB P3.5
MOV P0, #00H    ; Clear ports to use as counters
MOV P2, #00H
CW1:
MOV P1, A    ; Step
RR A    ; Next Step
ACALL DELAY
INC P0    ; Increment counter for number of steps
JB P0.6, CHECK    ; Check if x steps complete
SJMP CW1    ; Loop Clockwise

CHECK:
INC P2    ; Increment counter for x number of angle rotations
JB P2.1, CCW    ; Start counter-clockwise rotation
LJMP CW1    ; Resume clockwise rotation

CHECK1:
INC P2    ; Increment counter for x number of angle rotations
JB P2.1, CW    ; Start clockwise rotation
LJMP CCW1    ; Resume counter-clockwise rotation

CCW:    ; Counter-Clockwise Rotation
;ACALL DELAY
MOV P0, #00H    ; Clear ports to use as counters
MOV P2, #00H
SETB P3.4
CLR P3.5
CCW1:
MOV P1, A    ; Step
RL A    ; Next step
ACALL DELAY
INC P0    ; Increment counter for number of steps
JB P0.6, CHECK1    ; Check if x steps complete
SJMP CCW1    ; Loop counter-clockwise

DELAY:
MOV R2, #04h    ; initial 4
H1:
MOV R3, #0FFh    ; initial 255
H2:
DJNZ R3, H2
DJNZ R2, H1
RET

END
