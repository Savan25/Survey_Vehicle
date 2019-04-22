/*
 * UART_C_file.h
 *
 * http://www.electronicwings.com
 */

#ifndef UART_H_file_H
#define UART_H_file_H

#include<reg51.h>

void UART_Init();
void UART_TxChar(char);
char UART_RxChar();
void UART_SendString(char *);

#endif