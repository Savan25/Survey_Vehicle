/*
	HC-05 Bluetooth interfacing with 8051 to control LED via smartphone
	http://www.electronicwings.com

*/

#include <reg51.h>
#include "UART_H_file.h"			    /* include UART library */

sbit LED=P1^0;

void main()
{
	char Data_in;
	UART_Init();						/* initialize UART */
	P1 = 0;								/* clear port initially */
	LED = 0;   							/* initially LED turn OFF */
	while(1)
	{
		Data_in = UART_RxChar();			/* receive char serially */
		if(Data_in == '1')
		{
			  LED = 1;				   		/* turn ON LED */
			  UART_SendString("LED_ON");	/* send status of LED*/
		}
		else if(Data_in == '2')
		{
			  LED=0;						/* turn OFF LED */
			  UART_SendString("LED_OFF");	/* send status of LED*/
		
		}
		else
			UART_SendString("Select proper option");	/* send msg to select proper option */	
	
	}



}
