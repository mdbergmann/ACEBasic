/* << ACE >> - db.lib module: Serial Port functions.
** Copyright (C) 1998 David Benn
** 
** This program is free software; you can redistribute it and/or
** modify it under the terms of the GNU General Public License
** as published by the Free Software Foundation; either version 2
** of the License, or (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

   Author: David J Benn
     Date: 22nd-25th September 1991, 
	   2nd October 1991, 
	   18th January 1992,
	   6th August 1993,
	   4th-6th,12th,25th September 1993,
	   18th December 1993,
	   19th March 1994,
	   10th,11th September 1994,
	   2nd October 1994
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <devices/serial.h>

#define BRK_TIME 750000L

/* error codes */
#define OPEN_ERR	300L
#define CLOSE_ERR	301L
#define READ_ERR	302L
#define WRITE_ERR	303L
#define BAD_CHANNEL	304L

#define DEFDEVNAME	"serial.device"
#define MAXCHANNELS	255
#define MAXPARAMS	7

/* function protos */
void	OpenSerial();
void	CloseSerial();
void	SetParameters();
ULONG	BytesIncoming();
ULONG 	SerialStatus();
void	ReadSerial();
void	WriteSerial();

/* external functions */
extern	void 	stringcopy();
extern	ULONG	stringlength();

/* external variables */
extern 	ULONG 	error_code;

/* serial port structures */
typedef struct serialsym {
			  struct MsgPort  *SerRPort;	
			  struct MsgPort  *SerWPort;	/* message ports */

			  struct IOExtSer *SerRdReq;
			  struct IOExtSer *SerWtReq;	/* I/O requests */

			  char   *device_name;		/* name of device */

			  ULONG	 unit;			/* unit number */
			  ULONG	 baud;			/* baud rate */	
			  ULONG	 parity;		/* parity (NEOMS) */	
			  ULONG	 data;			/* data bits */	
			  ULONG	 stop;			/* stop bits */	
			  ULONG	 wires;			/* # of wires (7,3) */	
			  ULONG	 Xon;			/* Xon (0,1) */	
			  ULONG	 shared;		/* access (0,1) */
			  ULONG  fast;			/* fast mode (0,1) */	
			  ULONG	 bufsize;		/* bufsize */	
			 } SERIAL;

/* globals */
SERIAL 	serial[MAXCHANNELS];
BOOL 	first_time=TRUE;

/* functions */

void GetParameters(params,parity,data,stop,wires,Xon,shared,fast)
UBYTE *params,*parity,*data,*stop,*wires,*Xon,*shared,*fast;
{
int  i,j;
UBYTE p[MAXPARAMS];

 	/* extract parameters from string */
	
	for (i=0;i<MAXPARAMS && params[i];i++) p[i] = params[i];
	
	for (j=i;j<MAXPARAMS;j++) p[j] = '?'; /* non-specified parameters='?' */

	/* essential */
	*parity	= p[0];
	*data 	= p[1]-'0';
	*stop 	= p[2]-'0';

	/* optional */
	*wires  = '?';
	*Xon	= '?';
	*shared = '?';
	*fast	= '?';

	for (i=3;i<MAXPARAMS;i++)
       	{ 
	   switch(p[i])
	   {
	   	case '3' : *wires = '3';
			   break;

		case 'X' : 
		case 'x' : *Xon	= 'X';
			   break;

		case 'S' : 
		case 's' : *shared = 'S';
			   break;

		case 'F' : 
		case 'f' : *fast = 'F';
			   break;
 	   }
	}
}

void OpenSerial(devname,rbuf_len,params,baud,unit,channel)
char  *devname;
ULONG rbuf_len;
UBYTE *params;
ULONG baud;
ULONG unit;
ULONG channel;
{
ULONG error;
ULONG i,length;	
BYTE  *b,*c;
char  msgportname[40];
UBYTE  parity,data,stop,wires,Xon,shared,fast;

        /* open a serial port channel */

	if (first_time)
	{
		/* clear all channels first */
		first_time = FALSE;
		for (i=0;i<MAXCHANNELS;i++) 
		{
		    serial[i].SerRdReq = NULL;
		    serial[i].SerWtReq = NULL;
		    serial[i].SerRPort = NULL;
		    serial[i].SerWPort = NULL;
		    serial[i].device_name  = NULL;
		}
	}

	channel--;

	if (channel < 0 || channel > 254) 
	   { error_code = BAD_CHANNEL; return; }

	GetParameters(params,&parity,&data,&stop,&wires,&Xon,&shared,&fast);

	if (baud == '?' || data == '?' || stop == '?') 
	   { error_code = OPEN_ERR; return; }

	/* store information -> rest is stored later */
	serial[channel].baud = baud;
	serial[channel].data = data;
	serial[channel].stop = stop;
	serial[channel].bufsize = rbuf_len;

	/* create a reply port to which serial device can return request */
	stringcopy(msgportname,"serial_read_port");
	length = stringlength(msgportname);
	msgportname[length] = (char)channel + '0';	
	msgportname[length+1] = '\0';
	serial[channel].SerRPort = (struct MsgPort *)CreatePort(msgportname,0);
	if (serial[channel].SerRPort == NULL) 
	{
		error_code = OPEN_ERR;
		return;		

	}

	/* create a serial read request block */	
	serial[channel].SerRdReq = (struct IOExtSer *)
		CreateExtIO(serial[channel].SerRPort,sizeof(struct IOExtSer));

	if (serial[channel].SerRdReq == NULL)
	{
		DeletePort(serial[channel].SerRPort);
		error_code = OPEN_ERR;
		return;
	}

	/* use 3 or 7 wires? */
 	if (wires == '3')
	{
		/* three wires */
		serial[channel].SerRdReq->io_SerFlags = 0;		
		serial[channel].wires = 3;
	}	
	else
	{
		/* seven wires */ 
		serial[channel].SerRdReq->io_SerFlags = SERF_7WIRE;
		serial[channel].wires = 7;
	}
		
	/* shared access to serial port */
	if (shared == 'S')
	{
		/* shared access */
		serial[channel].SerRdReq->io_SerFlags |= SERF_SHARED;
		serial[channel].shared = 1;
	}
	else
		/* exclusive access */
		serial[channel].shared = 0;	

	/* open serial device */

	/* store serial device name */
	if (devname == NULL) devname = DEFDEVNAME;
	
	serial[channel].device_name = 
		(char *)AllocMem(stringlength(devname)+1,MEMF_ANY);

	stringcopy(serial[channel].device_name,devname);

	/* store unit number */
	serial[channel].unit = unit;

	/* open device */
	error = (ULONG)OpenDevice(serial[channel].device_name,unit,
			          serial[channel].SerRdReq,0L);

	if (error != 0)
	{
		DeleteExtIO(serial[channel].SerRdReq,sizeof(struct IOExtSer));
		DeletePort(serial[channel].SerRPort);
		error_code = OPEN_ERR;
		return;
	}

	/* clone a serial write request block */
	stringcopy(msgportname,"serial_write_port");
	length = stringlength(msgportname);
	msgportname[length] = (char)channel + '0';	
	msgportname[length+1] = '\0';
	serial[channel].SerWPort = (struct MsgPort *)CreatePort(msgportname,0);

	serial[channel].SerWtReq = (struct IOExtSer *)
		CreateExtIO(serial[channel].SerWPort,sizeof(struct IOExtSer));

	b = (BYTE *)serial[channel].SerRdReq;
	c = (BYTE *)serial[channel].SerWtReq;

	for (i=0;i<sizeof(struct IOExtSer);i++) *c++ = *b++;

	serial[channel].SerWtReq->IOSer.io_Message.mn_ReplyPort = 
                                  serial[channel].SerWPort;

	/* disable Xon/Xoff feature? */
	if (Xon != 'X')
	{
		/* disable Xon/off feature */
	   	serial[channel].SerRdReq->io_SerFlags |= SERF_XDISABLED;
		serial[channel].Xon = 0;
	}
	else
		/* enable Xon/off feature */
		serial[channel].Xon = 1;

	/* enable fast mode? */
	if (fast == 'F')
	{
		/* enable fast (RAD_BOOGIE) mode */
		serial[channel].SerRdReq->io_SerFlags |= SERF_RAD_BOOGIE;
		serial[channel].fast = 1;
	}
	else
		/* don't enable fast mode */
		serial[channel].fast = 0;

	SetParameters(rbuf_len,baud,parity,data,stop,channel);
}

void CloseSerial(channel)
ULONG channel;
{
	/* close serial device */

	channel--;

	if (channel < 0 || channel > 254) 
	   { error_code = BAD_CHANNEL; return; }
 
	if (serial[channel].SerRdReq != NULL && 
	    serial[channel].SerWtReq != NULL &&
	    serial[channel].SerRPort != NULL &&
	    serial[channel].SerWPort != NULL)
        {
		CloseDevice(serial[channel].SerRdReq);

		DeleteExtIO(serial[channel].SerRdReq);
		DeleteExtIO(serial[channel].SerWtReq);

		DeletePort(serial[channel].SerRPort);
		DeletePort(serial[channel].SerWPort);
	}
	else 
	  	{ error_code = CLOSE_ERR; return; }

	if (serial[channel].device_name)
  	   FreeMem(serial[channel].device_name,
		   stringlength(serial[channel].device_name)+1);

	/* clear this channel's stored information */
	serial[channel].SerRdReq = NULL;
	serial[channel].SerWtReq = NULL;
	serial[channel].SerRPort = NULL;
	serial[channel].SerWPort = NULL;
  	serial[channel].device_name = NULL;
  	serial[channel].unit=0;
	serial[channel].baud=0;	
	serial[channel].parity='?';
	serial[channel].data=0;
	serial[channel].stop=0;
	serial[channel].wires=0;
	serial[channel].Xon=0;
	serial[channel].shared=0;	
	serial[channel].fast=0;
	serial[channel].bufsize=0;
}

void SetParameters(rbuf_len,baud,parity,data,stop,channel)
ULONG rbuf_len;
ULONG baud;
UBYTE parity,data,stop;
ULONG channel;
{
UBYTE flags;
ULONG extflags;

	/* set serial port parameters */

	flags = serial[channel].SerRdReq->io_SerFlags;
	extflags = 0;

	switch(parity)
	{
		/* NO parity */
	  case	'N' :
	  case	'n' : 	flags |= 0;
			serial[channel].parity = 'N';
			break;

		/* EVEN parity */
	  case	'E' :
	  case	'e' : 	flags |= SERF_PARTY_ON;	
			flags &= ~SERF_PARTY_ODD;	
			serial[channel].parity = 'E';
			break;

		/* ODD parity */
	  case	'O' :
	  case	'o' :	flags |= (SERF_PARTY_ON | SERF_PARTY_ODD);
			serial[channel].parity = 'O';
			break;

		/* MARK parity */
	  case	'M' :
	  case	'm' :	flags |= SERF_PARTY_ON;
			extflags = SEXTF_MSPON | SEXTF_MARK;
			serial[channel].parity = 'M';
			break;

		/* SPACE parity */
	  case	'S' :
	  case	's' :	flags |= SERF_PARTY_ON;
			extflags = SEXTF_MSPON;
			serial[channel].parity = 'S';
			break;

		/* default is NO parity */
	  default:	flags |= 0;
			serial[channel].parity = 'N';
			break;
	}

	if (serial[channel].SerWtReq)
	{
	 serial[channel].SerWtReq->io_ReadLen	= data;
	 serial[channel].SerWtReq->io_BrkTime	= BRK_TIME;
	 serial[channel].SerWtReq->io_Baud	= baud;
	 serial[channel].SerWtReq->io_WriteLen	= data;
	 serial[channel].SerWtReq->io_StopBits	= stop;
	 serial[channel].SerWtReq->io_RBufLen	= rbuf_len;
	 serial[channel].SerWtReq->io_ExtFlags	= extflags;
	 serial[channel].SerWtReq->io_SerFlags	= flags;
	 serial[channel].SerWtReq->IOSer.io_Command = SDCMD_SETPARAMS;

	 if (DoIO(serial[channel].SerWtReq)) 
		error_code = OPEN_ERR;
	}
	else
		error_code = OPEN_ERR;
}

ULONG BytesIncoming(channel)
ULONG channel;
{
	/* return number of bytes in serial port buffer */
	
	if (serial[channel].SerRdReq)
	{
	 	serial[channel].SerRdReq->IOSer.io_Command = SDCMD_QUERY;

	 	if (DoIO(serial[channel].SerRdReq))
			error_code = READ_ERR;
	}
	else
	    { error_code = BAD_CHANNEL; return(0); }

	/* # of bytes incoming */
	return(serial[channel].SerRdReq->IOSer.io_Actual);  
}

ULONG SerialStatus(channel)
ULONG channel;
{
	/* return serial port status bits */
	
	if (serial[channel].SerRdReq)
	{
	 	serial[channel].SerRdReq->IOSer.io_Command = SDCMD_QUERY;

	 	if (DoIO(serial[channel].SerRdReq))
			error_code = READ_ERR;
	}
	else
	    { error_code = BAD_CHANNEL; return(0); }

	/* status of lines and registers */
	return((ULONG)serial[channel].SerRdReq->io_Status);
}

void ReadSerial(len,buf,channel)
ULONG len;
UBYTE *buf;
ULONG channel;
{
	/* read len bytes of data from serial port into buf */

	channel--;

	if (channel < 0 || channel > 254) 
	   { error_code = BAD_CHANNEL; return; }

	if (serial[channel].SerRdReq)
	{
	  serial[channel].SerRdReq->IOSer.io_Data	= (APTR)buf;
	  serial[channel].SerRdReq->IOSer.io_Length	= len;
	  serial[channel].SerRdReq->IOSer.io_Command	= CMD_READ;

	  if (DoIO(serial[channel].SerRdReq))
		error_code = READ_ERR;
	}
	else
	    { error_code = BAD_CHANNEL; buf[0] = '\0'; return; }
 
	buf[len] = '\0';	/* NULL terminated C/ACE string */
}

void WriteSerial(len,buf,channel)
ULONG len;
UBYTE *buf;
ULONG channel;
{
	/* write len bytes of data to serial port from buf */

	channel--;

	if (channel < 0 || channel > 254) 
	   { error_code = BAD_CHANNEL; return; }

	if (serial[channel].SerWtReq)
	{
	  serial[channel].SerWtReq->IOSer.io_Data	= (APTR)buf;
	  serial[channel].SerWtReq->IOSer.io_Length	= len;
	  serial[channel].SerWtReq->IOSer.io_Command	= CMD_WRITE;

	  if (DoIO(serial[channel].SerWtReq))
		error_code = WRITE_ERR;
	}
	else
	    error_code = BAD_CHANNEL;
}

ULONG serial_func(n,channel)
ULONG n;
ULONG channel;
{
/* serial port function: returns status information about
   a serial port channel. 
*/

 channel--;

 if (channel < 0 || channel > 254) 
    { error_code = BAD_CHANNEL; return(0L); }
 
 switch(n)
 {
	/* # of pending characters */
  	case 0 : 	return(BytesIncoming(channel));
			break;

	/* device unit # being used */
	case 1 :	return(serial[channel].unit);
			break;

	/* baud rate being used */
	case 2 :	return(serial[channel].baud);
			break;

	/* parity being used */
	case 3 :	return(serial[channel].parity);
			break;

	/* data bits being used */
	case 4 :	return(serial[channel].data);
			break;

	/* stop bits being used */
	case 5 :	return(serial[channel].stop);
			break;

	/* number of wires being used */
	case 6 :	return(serial[channel].wires);
			break;

	/* Xon/Xoff ON or OFF? */
	case 7 :	return(serial[channel].Xon);
			break;

	/* shared access to serial device? */
	case 8 :	return(serial[channel].shared);
			break;

	/* fast mode? */
	case 9 :	return(serial[channel].fast);
			break;

	/* buffer size being used */
	case 10 :	return(serial[channel].bufsize);
			break;

	/* address of serial device name */
	case 11 :	return((char *)serial[channel].device_name);
			break;

	/* serial port line and register status */
	case 12 :	return(SerialStatus(channel));
			break;
 }
}
