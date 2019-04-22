IN_LOOP_COUNT 	equ 34h			; delay loop variable
OUT_LOOP_COUNT 	equ 35h			; delay loop variable

org 00h

main:
nop
nop
acall delay4ms

nop


DELAY4ms:
	MOV OUT_LOOP_COUNT, #5
AGAIN:
	MOV IN_LOOP_COUNT, #183
HERE:
	NOP
	NOP
	DJNZ IN_LOOP_COUNT, HERE
	DJNZ OUT_LOOP_COUNT, AGAIN
	NOP
	NOP
	NOP
	ret

end