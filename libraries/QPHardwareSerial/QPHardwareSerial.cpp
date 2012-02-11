/* Modified by SVB to provide QP signaling on USART Rx */

/*
  QPHardwareSerial.cpp - Hardware serial library for Wiring
  Copyright (c) 2006 Nicholas Zambetti.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

  Modified 23 November 2006 by David A. Mellis
  Modified 28 September 2010 by Mark Sproul
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include "wiring.h"
#include "wiring_private.h"

#include <qp_port.h>


// this next line disables the entire QPHardwareSerial.cpp,
// this is so I can support Attiny series and any other chip without a uart
#if defined(UBRRH) || defined(UBRR0H) || defined(UBRR1H) || defined(UBRR2H) || defined(UBRR3H)

#include "QPHardwareSerial.h"
Q_DEFINE_THIS_FILE
// Define constants and variables for buffering incoming serial data.  We're
// using a ring buffer (I think), in which rx_buffer_head is the index of the
// location to which to write the next incoming character and rx_buffer_tail
// is the index of the location from which to read.

#if defined(UBRRH) || defined(UBRR0H)
  uint8_t signalID;
  QActive * targetAO;
#endif
#if defined(UBRR1H)
  uint8_t signalID;
  QActive * targetAO1;
#endif
#if defined(UBRR2H)
  uint8_t signalID;
  QActive * targetAO2;
#endif
#if defined(UBRR3H)
  uint8_t signalID3;
  QActive * targetAO3;
#endif
	
inline void post_char(unsigned char c, QActive * const activeObject,
					   uint8_t signal)
{
	  QSerialRxEvent* evt = Q_NEW(QSerialRxEvent, signal);
	  evt->c = c;
	  activeObject->postFIFO(evt);
}


inline void publish_char(unsigned char c, uint8_t signal)
{
  QSerialRxEvent* evt = Q_NEW(QSerialRxEvent, signal);
  evt->c = c;
  QF::publish(evt);
}

#if defined(USART_RX_vect)
  SIGNAL(USART_RX_vect)
  {
  #if defined(UDR0)
    unsigned char c  =  UDR0;
  #elif defined(UDR)
    unsigned char c  =  UDR;  //  atmega8535
  #else
    #error UDR not defined
  #endif
  post_char(c, targetAO, signalID);
  }
#elif defined(SIG_USART0_RECV) && defined(UDR0)
  SIGNAL(SIG_USART0_RECV)
  {
    unsigned char c  =  UDR0;
	switch(rxMethod) {
	case BUFFER_METHOD:
		buffer_char(c, &qrx_buffer);
		break;
	case POST_METHOD:
		post_char(c, targetAO, signalID);
		break;
	case PUB_METHOD:
		publish_char(c, signalID);
		break;
	}
  }
#elif defined(SIG_UART0_RECV) && defined(UDR0)
  SIGNAL(SIG_UART0_RECV)
  {
    unsigned char c  =  UDR0;
	switch(rxMethod) {
	case BUFFER_METHOD:
		buffer_char(c, &qrx_buffer);
		break;
	case POST_METHOD:
		post_char(c, targetAO, signalID);
		break;
	case PUB_METHOD:
		publish_char(c, signalID);
		break;
	}
  }
//#elif defined(SIG_USART_RECV)
#elif defined(USART0_RX_vect)
  // fixed by Mark Sproul this is on the 644/644p
  //SIGNAL(SIG_USART_RECV)
  SIGNAL(USART0_RX_vect)
  {
  #if defined(UDR0)
    unsigned char c  =  UDR0;
  #elif defined(UDR)
    unsigned char c  =  UDR;  //  atmega8, atmega32
  #else
    #error UDR not defined
  #endif
	switch(rxMethod) {
	case BUFFER_METHOD:
		buffer_char(c, &qrx_buffer);
		break;
	case POST_METHOD:
		post_char(c, targetAO, signalID);
		break;
	case PUB_METHOD:
		publish_char(c, signalID);
		break;
	}
  }
#elif defined(SIG_UART_RECV)
  // this is for atmega8
  SIGNAL(SIG_UART_RECV)
  {
  #if defined(UDR0)
    unsigned char c  =  UDR0;  //  atmega645
  #elif defined(UDR)
    unsigned char c  =  UDR;  //  atmega8
  #endif
	switch(rxMethod) {
	case BUFFER_METHOD:
		buffer_char(c, &qrx_buffer);
		break;
	case POST_METHOD:
		post_char(c, targetAO, signalID);
		break;
	case PUB_METHOD:
		publish_char(c, signalID);
		break;
	}
  }
#elif defined(USBCON)
  #warning No interrupt handler for usart 0
  #warning QPSerial(0) is on USB interface
#else
  #error No interrupt handler for usart 0
#endif

//#if defined(SIG_USART1_RECV)
#if defined(USART1_RX_vect)
  //SIGNAL(SIG_USART1_RECV)
  SIGNAL(USART1_RX_vect)
  {
    unsigned char c = UDR1;
	switch(rxMethod1) {
	case BUFFER_METHOD:
		buffer_char(c, &qrx_buffer1);
		break;
	case POST_METHOD:
		post_char(c, targetAO1, signalID1);
		break;
	case PUB_METHOD:
		publish_char(c, signalID1);
		break;
	}
  }
#elif defined(SIG_USART1_RECV)
  #error SIG_USART1_RECV
#endif

#if defined(USART2_RX_vect) && defined(UDR2)
  SIGNAL(USART2_RX_vect)
  {
    unsigned char c = UDR2;
	switch(rxMethod2) {
	case BUFFER_METHOD:
		buffer_char(c, &qrx_buffer2);
		break;
	case POST_METHOD:
		post_char(c, targetAO2, signalID2);
		break;
	case PUB_METHOD:
		publish_char(c, signalID2);
		break;
	}
  }
#elif defined(SIG_USART2_RECV)
  #error SIG_USART2_RECV
#endif

#if defined(USART3_RX_vect) && defined(UDR3)
  SIGNAL(USART3_RX_vect)
  {
    unsigned char c = UDR3;
	switch(rxMethod3) {
	case BUFFER_METHOD:
		buffer_char(c, &qrx_buffer3);
		break;
	case POST_METHOD:
		post_char(c, targetAO3, signalID3);
		break;
	case PUB_METHOD:
		publish_char(c, signalID3);
		break;
	}
  }
#elif defined(SIG_USART3_RECV)
  #error SIG_USART3_RECV
#endif



// Constructors ////////////////////////////////////////////////////////////////

QPHardwareSerial::QPHardwareSerial(
  QActive * *targetAO, uint8_t *signalID,
  volatile uint8_t *ubrrh, volatile uint8_t *ubrrl,
  volatile uint8_t *ucsra, volatile uint8_t *ucsrb,
  volatile uint8_t *udr,
  uint8_t rxen, uint8_t txen, uint8_t rxcie, uint8_t udre, uint8_t u2x)
{
  _targetAO = targetAO;
  _signalID = signalID;
  
  _ubrrh = ubrrh;
  _ubrrl = ubrrl;
  _ucsra = ucsra;
  _ucsrb = ucsrb;
  _udr = udr;
  _rxen = rxen;
  _txen = txen;
  _rxcie = rxcie;
  _udre = udre;
  _u2x = u2x;
}

// Public Methods //////////////////////////////////////////////////////////////

void QPHardwareSerial::begin(long baud, QActive *targetAO, uint8_t signalID)
{
  uint16_t baud_setting;
  bool use_u2x = true;
  
#if F_CPU == 16000000UL
  // hardcoded exception for compatibility with the bootloader shipped
  // with the Duemilanove and previous boards and the firmware on the 8U2
  // on the Uno and Mega 2560.
  if (baud == 57600) {
    use_u2x = false;
  }
#endif

  if (use_u2x) {
    *_ucsra = 1 << _u2x;
    baud_setting = (F_CPU / 4 / baud - 1) / 2;
  } else {
    *_ucsra = 0;
    baud_setting = (F_CPU / 8 / baud - 1) / 2;
  }

  // assign the baud_setting, a.k.a. ubbr (USART Baud Rate Register)
  *_ubrrh = baud_setting >> 8;
  *_ubrrl = baud_setting;
  
  *_targetAO = targetAO;
  *_signalID = signalID;

  sbi(*_ucsrb, _rxen);
  sbi(*_ucsrb, _txen);
  sbi(*_ucsrb, _rxcie);
}

void QPHardwareSerial::end()
{
  cbi(*_ucsrb, _rxen);
  cbi(*_ucsrb, _txen);
  cbi(*_ucsrb, _rxcie);
}

// int QPHardwareSerial::available(void)
// {
	// if (!_rx_buffer->buffer) return 0;
  // return (unsigned int)(_rx_buffer->capacity + _rx_buffer->head - _rx_buffer->tail) % _rx_buffer->capacity;
// }

// int QPHardwareSerial::peek(void)
// {
	// if (!_rx_buffer->buffer) return 0;
  // if (_rx_buffer->head == _rx_buffer->tail) {
    // return -1;
  // } else {
    // return _rx_buffer->buffer[_rx_buffer->tail];
  // }
// }

// int QPHardwareSerial::read(void)
// {
	// if (!_rx_buffer->buffer) return 0;
 // if the head isn't ahead of the tail, we don't have any characters
  // if (_rx_buffer->head == _rx_buffer->tail) {
    // return -1;
  // } else {
    // unsigned char c = _rx_buffer->buffer[_rx_buffer->tail];
    // _rx_buffer->tail = (unsigned int)(_rx_buffer->tail + 1) % _rx_buffer->capacity;
    // return c;
  // }
// }

// void QPHardwareSerial::flush()
// {
  // don't reverse this or there may be problems if the RX interrupt
  // occurs after reading the value of rx_buffer_head but before writing
  // the value to rx_buffer_tail; the previous value of rx_buffer_head
  // may be written to rx_buffer_tail, making it appear as if the buffer
  // don't reverse this or there may be problems if the RX interrupt
  // occurs after reading the value of rx_buffer_head but before writing
  // the value to rx_buffer_tail; the previous value of rx_buffer_head
  // may be written to rx_buffer_tail, making it appear as if the buffer
  // were full, not empty.
  // _rx_buffer->head = _rx_buffer->tail;
// }

void QPHardwareSerial::write(uint8_t c)
{	
  while (!((*_ucsra) & (1 << _udre)))
    ;

  *_udr = c;
}

// Preinstantiate Objects //////////////////////////////////////////////////////

#if defined(UBRRH) && defined(UBRRL)
  QPHardwareSerial QPSerial(&targetAO, &signalID, &UBRRH, &UBRRL, &UCSRA, &UCSRB, &UDR, RXEN, TXEN, RXCIE, UDRE, U2X);
#elif defined(UBRR0H) && defined(UBRR0L)
  QPHardwareSerial QPSerial(&targetAO, &signalID, &UBRR0H, &UBRR0L, &UCSR0A, &UCSR0B, &UDR0, RXEN0, TXEN0, RXCIE0, UDRE0, U2X0);
#elif defined(USBCON)
  #warning no serial port defined  (port 0)
#else
  #error no serial port defined  (port 0)
#endif

#if defined(UBRR1H)
  QPHardwareSerial QPSerial1(&targetAO1, &signalID1, &UBRR1H, &UBRR1L, &UCSR1A, &UCSR1B, &UDR1, RXEN1, TXEN1, RXCIE1, UDRE1, U2X1);
#endif
#if defined(UBRR2H)
  QPHardwareSerial QPSerial2(&targetAO2, &signalID2, &UBRR2H, &UBRR2L, &UCSR2A, &UCSR2B, &UDR2, RXEN2, TXEN2, RXCIE2, UDRE2, U2X2);
#endif
#if defined(UBRR3H)
  QPHardwareSerial QPSerial3(&targetAO3, &signalID3, &UBRR3H, &UBRR3L, &UCSR3A, &UCSR3B, &UDR3, RXEN3, TXEN3, RXCIE3, UDRE3, U2X3);
#endif

#endif // whole file
