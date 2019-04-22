	MOV P1, #11111110B			; turn OFF all LEDs except LED.0
	CLR C						; clear carry flag
	MOV A, P1					; load LED bits to acc
	RLC A						; left shift acc
	MOV P1, A					; reload new LED bits to P1
	end