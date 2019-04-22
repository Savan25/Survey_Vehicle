IR1	equ 92h				;P1.2 - IR1
IR2	equ 93h				;P1.3 - IR2
IR3	equ 0B6h			;P3.6 - IR3
IR4	equ 0B7h			;P3.7 - IR4

COUNT	equ 30h			; counter variable
DIR		equ 31h			; vehicle direction variable (relative): N=0, NE=1, E=2, SE=3, S=4, SW=5, W=6, NW=7
;XMAP	equ 32h			; vehicle x coordinates
;YMAP	equ 33h			; vehicle y coordinates
PXMAP	equ 34h			; positive x distance
PYMAP	equ 35h			; positive y distance
NXMAP	equ 36h			; negative x distance
NYMAP	equ 37h			; negative y distance

org 00h

; ... MAPPING
; ... initital direction = relative north, start point = 0,0
MOV DIR, #0h
MOV PXMAP, #0h
MOV PYMAP, #0h
MOV NXMAP, #0h
MOV NYMAP, #0h

; --------------------------
;FWSTEPCHECK:
;SJMP N
;FWRETURN:
;DJNZ R5 ....
; ... direction check
N:
	MOV A, #0h
	CJNE A, DIR, NE		; check if facing relative north
	INC PYMAP			; increment positive y coordinate
	SJMP FWRETURN

NE:
	MOV A, #1h
	CJNE A, DIR, E		; check if facing relative north-east
	INC PYMAP			; increment positive y coordinate
	INC PXMAP			; increment positive x coordinate
	SJMP FWRETURN

E:
	MOV A, #2h
	CJNE A, DIR, SE		; check if facing relative east
	INC PXMAP			; increment positive x coordinate
	SJMP FWRETURN

SE:
	MOV A, #3h
	CJNE A, DIR, S		; check if facing relative south-east
	INC NYMAP			; increment negative y coordinate
	INC PXMAP			; increment positive x coordinate
	SJMP FWRETURN

S:
	MOV A, #4h
	CJNE A, DIR, SW		; check if facing relative south
	INC NYMAP			; increment negative y coordinate
	SJMP FWRETURN

SW:
	MOV A, #5h
	CJNE A, DIR, W		; check if facing relative south-west
	INC NYMAP			; increment negative y coordinate
	INC NXMAP			; increment negative x coordinate
	SJMP FWRETURN

W:
	MOV A, #6h
	CJNE A, DIR, NW		; check if facing relative west
	INC NXMAP			; increment negative x coordinate
	SJMP FWRETURN

NW:						; must be facing relative north-west
	INC PYMAP			; increment positive y coordinate
	INC NXMAP			; increment negative x coordinate
	SJMP FWRETURN
; --------------------------


; --------------------------
; ... turn right 90 degrees
; ... previous line of code
; RT:
; check if facing relative west
CHECK_FACE_W:
	MOV A, #6
	CJNE A, DIR, NOT_FACE_W
	MOV DIR, #0h
	SJMP RT_CONTINUE

NOT_FACE_W:
	INC DIR
	INC DIR
; next line of code ...
; RT_CONTINUE:
; MOV R5 ....
; RTRepeatSteps
; --------------------------

; --------------------------
; ... turn left 90 degrees
; ... previous line of code
; LT:
; check if facing relative north
CHECK_FACE_N:
	MOV A, #0
	CJNE A, DIR, NOT_FACE_N
	MOV DIR, #6
	SJMP LT_CONTINUE

NOT_FACE_N:
	DEC DIR
	DEC DIR
; next line of code ...
; LT_CONTINUE:
; MOV R5 ....
; LTRepeatSteps
; --------------------------

; --------------------------
; ... turn right 45 degrees
; ... previous line of code
; RT_half(ENTER CORRECT NAME):
; check if facing relative north-west
CHECK_FACE_NW:
	MOV A, #7
	CJNE A, DIR, NOT_FACE_NW
	MOV DIR, #0h
	SJMP RT_half_CONTINUE;(ENTER CORRECT NAME)

NOT_FACE_NW:
	INC DIR
; next line of code ...
; RT_half_CONTINUE(ENTER CORRECT NAME):
; MOV R5 ....
; RT_halfRepeatSteps(ENTER CORRECT NAME)
; --------------------------

; --------------------------
; ... turn left 45 degrees
; ... previous line of code
; LT_half(ENTER CORRECT NAME):
; check if facing relative north
CHECK_FACE_N2:
	MOV A, #0
	CJNE A, DIR, NOT_FACE_N2
	MOV DIR, #7
	SJMP LT_half_CONTINUE;(ENTER CORRECT NAME)

NOT_FACE_N2:
	DEC DIR
; next line of code ...
; LT_half_CONTINUE(ENTER CORRECT NAME):
; MOV R5 ....
; LT_halfRepeatSteps(ENTER CORRECT NAME)
; --------------------------



; ... code: move forward - check every 128 steps ...
; ... stepcheck
; jump to DETECTED when object found
JNB IR_IN1, DETECTED
JB IR_IN2, DETECTED
JNB IR_IN3, DETECTED
JNB IR_IN4, DETECTED

Detected:
