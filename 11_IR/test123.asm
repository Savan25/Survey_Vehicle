clr a

again:
inc dptr
mov dptr, #time
movc a, @a+dptr
mov r1, a
sjmp again






time:
db 03h, 13h, 27h, 3ah