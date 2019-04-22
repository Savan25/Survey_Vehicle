px equ 40h
py equ 41h
nx equ 42h
ny equ 43h
subval equ 44h	; variable to store value after subtraction
posval equ 45h		;variable to store positive value
negval equ 46h	; variable to store negative value, without sign
x equ 47h
y equ 48h
minus bit 0h	; variable to store carry flag, if '1' then negative
xsign bit 1h
ysign bit 2h

org 0h

mov px, #20d
mov nx, #31d
mov py, #15d
mov ny, #10d

CALC_X:
clr c	;clear carry flag
mov a, px
subb a, nx		; px - nx = 20 - 31 = -11
jc CALC_NX			; if carry flag set, result is negative, then goto CALC_NX
CALC_PX:
mov x, a		; store positive result
clr xsign
sjmp CALC_Y
CALC_NX:
cpl a		;two's complement to decimal
inc a
mov x, a		; store negative result, without sign, (magnitude)
setb xsign

CALC_Y:
clr c	;clear carry flag
mov a, py
subb a, ny		; py - ny = 15 - 10 = 5
jc CALC_NY			; if carry flag set, result is negative, then goto CALC_NX
CALC_PY:
mov y, a		; store positive result
clr ysign
sjmp CALC_FIN
CALC_NY:
cpl a		;two's complement to decimal
inc a
mov y, a		; store negative result, without sign, (magnitude)
setb ysign

calc_fin:
sjmp calc_fin

end