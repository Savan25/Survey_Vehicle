
MOV A, #5d
MOV R6, #5d
sjmp minus
continue:
NOP
inc R1
minus:
DJNZ R6, continue
finish:
MOV R5, 10


end