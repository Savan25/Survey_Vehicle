#include <reg51.h>
#include "UART_H_file.h"	/* Include UART library */

/* sbit LED = P1^0; */

void main()
{
	char Data_in;
	UART_Init();		/* Initialize UART */
	P1 = 0;			/* Clear port initially */
	P1^0 = 0;		/* Initially LED turn OFF */
	while(1)
	{
		Data_in = UART_RxChar();  /* Receive char serially */
		if(Data_in == '1')
		{
			P1^0 = 1;/* Turn ON LED */
			UART_SendString("LED_ON");  /* Send status of LED*/
		}
		else if(Data_in == '2')
		{
			P1^0 = 0;/* Turn OFF LED */
			UART_SendString("LED_OFF");  /* Send status of LED*/
		
		}
		else
			UART_SendString("Select proper option");
	
	}
}