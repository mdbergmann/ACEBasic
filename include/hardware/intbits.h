#ifndef HARDWARE_INTBITS_H
#define HARDWARE_INTBITS_H 1
/*
** intbits.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/


#define  INTB_SETCLR    (15)  /* Set/Clear control bit. Determines if bits */
        /* written with a 1 get set or cleared. Bits */
        /* written with a zero are allways unchanged */
#define  INTB_INTEN (14)  /* Master interrupt (enable only ) */
#define  INTB_EXTER (13)  /* External interrupt */
#define  INTB_DSKSYNC   (12)  /* Disk re-SYNChronized */
#define  INTB_RBF   (11)  /* serial port Receive Buffer Full */
#define  INTB_AUD3  (10)  /* Audio channel 3 block finished */
#define  INTB_AUD2  (9)   /* Audio channel 2 block finished */
#define  INTB_AUD1  (8)   /* Audio channel 1 block finished */
#define  INTB_AUD0  (7)   /* Audio channel 0 block finished */
#define  INTB_BLIT  (6)   /* Blitter finished */
#define  INTB_VERTB (5)   /* start of Vertical Blank */
#define  INTB_COPER (4)   /* Coprocessor */
#define  INTB_PORTS (3)   /* I/O Ports and timers */
#define  INTB_SOFTINT   (2)   /* software interrupt request */
#define  INTB_DSKBLK    (1)   /* Disk Block done */
#define  INTB_TBE   (0)   /* serial port Transmit Buffer Empty */



#define  INTF_SETCLR    (32768&)
#define  INTF_INTEN (16384&)
#define  INTF_EXTER (8192&)
#define  INTF_DSKSYNC   (4096&)
#define  INTF_RBF   (2048&)
#define  INTF_AUD3  (1024&)
#define  INTF_AUD2  (512&)
#define  INTF_AUD1  (256&)
#define  INTF_AUD0  (128&)
#define  INTF_BLIT  (64&)
#define  INTF_VERTB (32&)
#define  INTF_COPER (16&)
#define  INTF_PORTS (8&)
#define  INTF_SOFTINT   (4&)
#define  INTF_DSKBLK    (2&)
#define  INTF_TBE   (1&)

#endif  /* HARDWARE_INTBITS_H */
