INCLUDE 'test.asm'

main:
my_cpl P0
mov a, p0
cpl a
mov p0, a
sjmp main
end