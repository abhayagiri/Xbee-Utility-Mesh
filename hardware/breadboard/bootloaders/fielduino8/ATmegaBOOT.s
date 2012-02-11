	.file	"ATmegaBOOT.c"
__SREG__ = 0x3f
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__CCP__  = 0x34
__tmp_reg__ = 0
__zero_reg__ = 1
	.global __do_copy_data
	.global __do_clear_bss
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.text
.Ltext0:
	.section	.text.putch,"ax",@progbits
.global	putch
	.type	putch, @function
putch:
.LFB15:
/* prologue: function */
/* frame size = 0 */
.L2:
	sbis 43-32,5
	rjmp .L2
	out 44-32,r24
/* epilogue start */
	ret
.LFE15:
	.size	putch, .-putch
	.section	.text.getch,"ax",@progbits
.global	getch
	.type	getch, @function
getch:
.LFB16:
	push r14
	push r15
	push r16
	push r17
/* prologue: function */
/* frame size = 0 */
	clr r14
	clr r15
	movw r16,r14
	rjmp .L11
.L7:
	sec
	adc r14,__zero_reg__
	adc r15,__zero_reg__
	adc r16,__zero_reg__
	adc r17,__zero_reg__
	ldi r24,lo8(2000001)
	cp r14,r24
	ldi r24,hi8(2000001)
	cpc r15,r24
	ldi r24,hlo8(2000001)
	cpc r16,r24
	ldi r24,hhi8(2000001)
	cpc r17,r24
	brlo .L11
	lds r30,app_start
	lds r31,(app_start)+1
	icall
.L11:
	sbis 43-32,7
	rjmp .L7
	in r24,44-32
/* epilogue start */
	pop r17
	pop r16
	pop r15
	pop r14
	ret
.LFE16:
	.size	getch, .-getch
	.section	.text.getNch,"ax",@progbits
.global	getNch
	.type	getNch, @function
getNch:
.LFB17:
	push r16
	push r17
/* prologue: function */
/* frame size = 0 */
	mov r16,r24
	ldi r17,lo8(0)
	rjmp .L13
.L14:
	rcall getch
	subi r17,lo8(-(1))
.L13:
	cp r17,r16
	brlo .L14
/* epilogue start */
	pop r17
	pop r16
	ret
.LFE17:
	.size	getNch, .-getNch
	.section	.text.byte_response,"ax",@progbits
.global	byte_response
	.type	byte_response, @function
byte_response:
.LFB18:
	push r17
/* prologue: function */
/* frame size = 0 */
	mov r17,r24
	rcall getch
	cpi r24,lo8(32)
	brne .L18
	ldi r24,lo8(20)
	rcall putch
	mov r24,r17
	rcall putch
	ldi r24,lo8(16)
	rcall putch
.L18:
/* epilogue start */
	pop r17
	ret
.LFE18:
	.size	byte_response, .-byte_response
	.section	.text.nothing_response,"ax",@progbits
.global	nothing_response
	.type	nothing_response, @function
nothing_response:
.LFB19:
/* prologue: function */
/* frame size = 0 */
	rcall getch
	cpi r24,lo8(32)
	brne .L21
	ldi r24,lo8(20)
	rcall putch
	ldi r24,lo8(16)
	rcall putch
.L21:
	ret
.LFE19:
	.size	nothing_response, .-nothing_response
	.section	.text.main,"ax",@progbits
.global	main
	.type	main, @function
main:
.LFB14:
	push r16
	push r17
	push r28
	push r29
/* prologue: function */
/* frame size = 0 */
/* #APP */
 ;  137 "ATmegaBOOT.c" 1
	nop
	
 ;  0 "" 2
/* #NOAPP */
	out 64-32,__zero_reg__
	ldi r24,lo8(12)
	out 41-32,r24
	ldi r24,lo8(24)
	out 42-32,r24
	ldi r24,lo8(-122)
	out 64-32,r24
	sbi 55-32,5
	sts i,__zero_reg__
	ldi r18,lo8(0)
	ldi r19,lo8(32)
.LBB9:
.LBB10:
	ldi r20,lo8(0)
	ldi r21,hi8(0)
	rjmp .L23
.L24:
.LBE10:
.LBE9:
	in r24,56-32
	eor r24,r19
	out 56-32,r24
.LBB12:
.LBB11:
	movw r24,r20
/* #APP */
 ;  105 "c:/documents and settings/david/my documents/arduino-0022/hardware/tools/avr/lib/gcc/../../avr/include/util/delay_basic.h" 1
	1: sbiw r24,1
	brne 1b
 ;  0 "" 2
/* #NOAPP */
	subi r18,lo8(-(1))
.L23:
.LBE11:
.LBE12:
	cpi r18,lo8(16)
	brlo .L24
	sts i,r18
.L67:
	rcall getch
	cpi r24,lo8(48)
	breq .L70
.L25:
	cpi r24,lo8(49)
	brne .L27
	rcall getch
	cpi r24,lo8(32)
	brne .L67
	ldi r24,lo8(20)
	rcall putch
	ldi r24,lo8(65)
	rcall putch
	ldi r24,lo8(86)
	rcall putch
	ldi r24,lo8(82)
	rcall putch
	ldi r24,lo8(32)
	rcall putch
	ldi r24,lo8(73)
	rcall putch
	ldi r24,lo8(83)
	rcall putch
	ldi r24,lo8(80)
	rjmp .L68
.L27:
	cpi r24,lo8(64)
	brne .L28
	rcall getch
	cpi r24,lo8(-122)
	brlo .L70
	rcall getch
	rjmp .L70
.L28:
	cpi r24,lo8(65)
	brne .L30
	rcall getch
	cpi r24,lo8(-128)
	brne .L31
	ldi r24,lo8(2)
	rjmp .L71
.L31:
	cpi r24,lo8(-127)
	brne .L32
	ldi r24,lo8(1)
	rjmp .L71
.L32:
	cpi r24,lo8(-126)
	breq .+2
	rjmp .L73
	ldi r24,lo8(18)
	rjmp .L71
.L30:
	cpi r24,lo8(66)
	brne .L34
	ldi r24,lo8(20)
.L72:
	rcall getNch
.L70:
	rcall nothing_response
	rjmp .L67
.L34:
	cpi r24,lo8(69)
	brne .L35
	ldi r24,lo8(5)
	rjmp .L72
.L35:
	cpi r24,lo8(80)
	breq .L70
.L36:
	cpi r24,lo8(81)
	breq .L70
.L37:
	cpi r24,lo8(82)
	breq .L70
.L38:
	cpi r24,lo8(85)
	brne .L39
	rcall getch
	sts address,r24
	rcall getch
	sts address+1,r24
	rjmp .L70
.L39:
	cpi r24,lo8(86)
	brne .L40
	ldi r24,lo8(4)
	rcall getNch
	rjmp .L73
.L40:
	cpi r24,lo8(100)
	breq .+2
	rjmp .L41
	rcall getch
	sts length+1,r24
	rcall getch
	sts length,r24
	lds r24,flags
	andi r24,lo8(-2)
	sts flags,r24
	rcall getch
	cpi r24,lo8(69)
	brne .L42
	lds r24,flags
	ori r24,lo8(1)
	sts flags,r24
.L42:
	ldi r16,lo8(0)
	ldi r17,hi8(0)
	rjmp .L43
.L44:
	rcall getch
	movw r30,r16
	subi r30,lo8(-(buff))
	sbci r31,hi8(-(buff))
	st Z,r24
	subi r16,lo8(-(1))
	sbci r17,hi8(-(1))
.L43:
	lds r24,length
	lds r25,(length)+1
	cp r16,r24
	cpc r17,r25
	brlo .L44
	rcall getch
	cpi r24,lo8(32)
	breq .+2
	rjmp .L67
	lds r24,flags
	sbrs r24,0
	rjmp .L45
	lds r22,length
	lds r23,(length)+1
	lds r18,address
	lds r19,(address)+1
	ldi r24,lo8(0)
	ldi r25,hi8(0)
	rjmp .L46
.L48:
	movw r20,r24
	add r20,r18
	adc r21,r19
	movw r30,r24
	subi r30,lo8(-(buff))
	sbci r31,hi8(-(buff))
	ld r30,Z
.L47:
.LBB13:
.LBB14:
	sbic 60-32,1
	rjmp .L47
	out (62)+1-32,r21
	out 62-32,r20
	out 61-32,r30
/* #APP */
 ;  324 "c:/documents and settings/david/my documents/arduino-0022/hardware/tools/avr/lib/gcc/../../avr/include/avr/eeprom.h" 1
	/* START EEPROM WRITE CRITICAL SECTION */
	in	r0, 63		
	cli				
	sbi	28, 2	
	sbi	28, 1	
	out	63, r0		
	/* END EEPROM WRITE CRITICAL SECTION */
 ;  0 "" 2
/* #NOAPP */
.LBE14:
.LBE13:
	adiw r24,1
.L46:
	cp r24,r22
	cpc r25,r23
	brlo .L48
	add r18,r22
	adc r19,r23
	sts (address)+1,r19
	sts address,r18
	rjmp .L49
.L45:
/* #APP */
 ;  306 "ATmegaBOOT.c" 1
	cli
 ;  0 "" 2
/* #NOAPP */
.L50:
	sbic 60-32,1
	rjmp .L50
/* #APP */
 ;  308 "ATmegaBOOT.c" 1
	clr	r17		
	lds	r30,address	
	lds	r31,address+1	
	lsl r30				
	rol r31				
	ldi	r28,lo8(buff)	
	ldi	r29,hi8(buff)	
	lds	r24,length	
	lds	r25,length+1	
	sbrs r24,0		
	rjmp length_loop		
	adiw r24,1		
	length_loop:		
	cpi	r17,0x00	
	brne	no_page_erase	
	rcall  wait_spm		
	ldi	r16,0x03	
	sts	87,r16		
	spm			
	rcall  wait_spm		
	ldi	r16,0x11	
	sts	87,r16		
	spm			
	no_page_erase:		
	ld	r0,Y+		
	ld	r1,Y+		
	rcall  wait_spm		
	ldi	r16,0x01	
	sts	87,r16		
	spm			
	inc	r17		
	cpi r17,32	        
	brlo	same_page	
	write_page:		
	clr	r17		
	rcall  wait_spm		
	ldi	r16,0x05	
	sts	87,r16		
	spm			
	rcall  wait_spm		
	ldi	r16,0x11	
	sts	87,r16		
	spm			
	same_page:		
	adiw	r30,2		
	sbiw	r24,2		
	breq	final_write	
	rjmp	length_loop	
	wait_spm:  
	lds	r16,87		
	andi	r16,1           
	cpi	r16,1           
	breq	wait_spm       
	ret			
	final_write:		
	cpi	r17,0		
	breq	block_done	
	adiw	r24,2		
	rjmp	write_page	
	block_done:		
	clr	__zero_reg__	
	
 ;  0 "" 2
/* #NOAPP */
.L49:
	ldi r24,lo8(20)
	rjmp .L68
.L41:
	cpi r24,lo8(116)
	breq .+2
	rjmp .L51
	rcall getch
	sts length+1,r24
	rcall getch
	sts length,r24
	rcall getch
	lds r25,flags
	cpi r24,lo8(69)
	brne .L52
	ori r25,lo8(1)
	sts flags,r25
	rjmp .L53
.L52:
	andi r25,lo8(-2)
	sts flags,r25
	lds r24,address
	lds r25,(address)+1
	lsl r24
	rol r25
	sts (address)+1,r25
	sts address,r24
.L53:
	rcall getch
	cpi r24,lo8(32)
	breq .+2
	rjmp .L67
	ldi r24,lo8(20)
	rcall putch
	ldi r16,lo8(0)
	ldi r17,hi8(0)
	rjmp .L54
.L59:
	lds r24,flags
	sbrs r24,0
	rjmp .L55
	lds r24,address
	lds r25,(address)+1
.L56:
.LBB15:
.LBB16:
	sbic 60-32,1
	rjmp .L56
	out (62)+1-32,r25
	out 62-32,r24
/* #APP */
 ;  208 "c:/documents and settings/david/my documents/arduino-0022/hardware/tools/avr/lib/gcc/../../avr/include/avr/eeprom.h" 1
	/* START EEPROM READ CRITICAL SECTION */ 
	sbi 28, 0 
	in r24, 29 
	/* END EEPROM READ CRITICAL SECTION */ 
	
 ;  0 "" 2
/* #NOAPP */
	rjmp .L74
.L55:
.LBE16:
.LBE15:
	sbrc r24,1
	rjmp .L58
.LBB17:
	lds r30,address
	lds r31,(address)+1
/* #APP */
 ;  425 "ATmegaBOOT.c" 1
	lpm r30, Z
	
 ;  0 "" 2
/* #NOAPP */
.LBE17:
	mov r24,r30
.L74:
	rcall putch
.L58:
	lds r24,address
	lds r25,(address)+1
	adiw r24,1
	sts (address)+1,r25
	sts address,r24
	subi r16,lo8(-(1))
	sbci r17,hi8(-(1))
.L54:
	lds r24,length
	lds r25,(length)+1
	cp r16,r24
	cpc r17,r25
	brlo .L59
	rjmp .L69
.L51:
	cpi r24,lo8(117)
	brne .L60
	rcall getch
	cpi r24,lo8(32)
	breq .+2
	rjmp .L67
	ldi r24,lo8(20)
	rcall putch
	ldi r24,lo8(30)
	rcall putch
	ldi r24,lo8(-109)
	rcall putch
	ldi r24,lo8(7)
.L68:
	rcall putch
.L69:
	ldi r24,lo8(16)
	rcall putch
	rjmp .L67
.L60:
	cpi r24,lo8(118)
	breq .+2
	rjmp .L67
.L73:
	ldi r24,lo8(0)
.L71:
	rcall byte_response
	rjmp .L67
.LFE14:
	.size	main, .-main
.global	pagesz
	.section	.data.pagesz,"aw",@progbits
	.type	pagesz, @object
	.size	pagesz, 1
pagesz:
	.byte	-128
.global	app_start
	.section	.bss.app_start,"aw",@nobits
	.type	app_start, @object
	.size	app_start, 2
app_start:
	.skip 2,0
	.comm address,2,1
	.comm length,2,1
	.comm flags,1,1
	.comm buff,256,1
	.comm i,1,1
	.section	.debug_frame,"",@progbits
.Lframe0:
	.long	.LECIE0-.LSCIE0
.LSCIE0:
	.long	0xffffffff
	.byte	0x1
	.string	""
	.uleb128 0x1
	.sleb128 -1
	.byte	0x24
	.byte	0xc
	.uleb128 0x20
	.uleb128 0x0
	.p2align	2
.LECIE0:
.LSFDE0:
	.long	.LEFDE0-.LASFDE0
.LASFDE0:
	.long	.Lframe0
	.long	.LFB15
	.long	.LFE15-.LFB15
	.p2align	2
.LEFDE0:
.LSFDE2:
	.long	.LEFDE2-.LASFDE2
.LASFDE2:
	.long	.Lframe0
	.long	.LFB16
	.long	.LFE16-.LFB16
	.p2align	2
.LEFDE2:
.LSFDE4:
	.long	.LEFDE4-.LASFDE4
.LASFDE4:
	.long	.Lframe0
	.long	.LFB17
	.long	.LFE17-.LFB17
	.p2align	2
.LEFDE4:
.LSFDE6:
	.long	.LEFDE6-.LASFDE6
.LASFDE6:
	.long	.Lframe0
	.long	.LFB18
	.long	.LFE18-.LFB18
	.p2align	2
.LEFDE6:
.LSFDE8:
	.long	.LEFDE8-.LASFDE8
.LASFDE8:
	.long	.Lframe0
	.long	.LFB19
	.long	.LFE19-.LFB19
	.p2align	2
.LEFDE8:
.LSFDE10:
	.long	.LEFDE10-.LASFDE10
.LASFDE10:
	.long	.Lframe0
	.long	.LFB14
	.long	.LFE14-.LFB14
	.p2align	2
.LEFDE10:
	.text
.Letext0:
	.section	.debug_info
	.long	0xb2
	.word	0x2
	.long	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.long	.LASF9
	.byte	0x1
	.long	.LASF10
	.long	.LASF11
	.long	0x0
	.long	0x0
	.long	.Ldebug_ranges0+0x0
	.uleb128 0x2
	.long	.LASF0
	.byte	0x1
	.byte	0x68
	.byte	0x3
	.uleb128 0x3
	.long	.LASF1
	.byte	0x2
	.word	0x134
	.byte	0x3
	.uleb128 0x2
	.long	.LASF2
	.byte	0x2
	.byte	0xc4
	.byte	0x3
	.uleb128 0x4
	.byte	0x1
	.long	.LASF3
	.byte	0x3
	.word	0x1ca
	.long	.LFB15
	.long	.LFE15
	.byte	0x2
	.byte	0x90
	.uleb128 0x20
	.uleb128 0x4
	.byte	0x1
	.long	.LASF4
	.byte	0x3
	.word	0x1d1
	.long	.LFB16
	.long	.LFE16
	.byte	0x2
	.byte	0x90
	.uleb128 0x20
	.uleb128 0x4
	.byte	0x1
	.long	.LASF5
	.byte	0x3
	.word	0x1de
	.long	.LFB17
	.long	.LFE17
	.byte	0x2
	.byte	0x90
	.uleb128 0x20
	.uleb128 0x4
	.byte	0x1
	.long	.LASF6
	.byte	0x3
	.word	0x1e9
	.long	.LFB18
	.long	.LFE18
	.byte	0x2
	.byte	0x90
	.uleb128 0x20
	.uleb128 0x4
	.byte	0x1
	.long	.LASF7
	.byte	0x3
	.word	0x1f2
	.long	.LFB19
	.long	.LFE19
	.byte	0x2
	.byte	0x90
	.uleb128 0x20
	.uleb128 0x5
	.byte	0x1
	.long	.LASF8
	.byte	0x3
	.byte	0x82
	.long	.LFB14
	.long	.LFE14
	.byte	0x2
	.byte	0x90
	.uleb128 0x20
	.byte	0x0
	.section	.debug_abbrev
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x52
	.uleb128 0x1
	.uleb128 0x55
	.uleb128 0x6
	.byte	0x0
	.byte	0x0
	.uleb128 0x2
	.uleb128 0x2e
	.byte	0x0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x20
	.uleb128 0xb
	.byte	0x0
	.byte	0x0
	.uleb128 0x3
	.uleb128 0x2e
	.byte	0x0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x20
	.uleb128 0xb
	.byte	0x0
	.byte	0x0
	.uleb128 0x4
	.uleb128 0x2e
	.byte	0x0
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x40
	.uleb128 0xa
	.byte	0x0
	.byte	0x0
	.uleb128 0x5
	.uleb128 0x2e
	.byte	0x0
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x40
	.uleb128 0xa
	.byte	0x0
	.byte	0x0
	.byte	0x0
	.section	.debug_pubnames,"",@progbits
	.long	0x5d
	.word	0x2
	.long	.Ldebug_info0
	.long	0xb6
	.long	0x3e
	.string	"putch"
	.long	0x52
	.string	"getch"
	.long	0x66
	.string	"getNch"
	.long	0x7a
	.string	"byte_response"
	.long	0x8e
	.string	"nothing_response"
	.long	0xa2
	.string	"main"
	.long	0x0
	.section	.debug_aranges,"",@progbits
	.long	0x44
	.word	0x2
	.long	.Ldebug_info0
	.byte	0x4
	.byte	0x0
	.word	0x0
	.word	0x0
	.long	.LFB15
	.long	.LFE15-.LFB15
	.long	.LFB16
	.long	.LFE16-.LFB16
	.long	.LFB17
	.long	.LFE17-.LFB17
	.long	.LFB18
	.long	.LFE18-.LFB18
	.long	.LFB19
	.long	.LFE19-.LFB19
	.long	.LFB14
	.long	.LFE14-.LFB14
	.long	0x0
	.long	0x0
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.long	.Ltext0
	.long	.Letext0
	.long	.LFB15
	.long	.LFE15
	.long	.LFB16
	.long	.LFE16
	.long	.LFB17
	.long	.LFE17
	.long	.LFB18
	.long	.LFE18
	.long	.LFB19
	.long	.LFE19
	.long	.LFB14
	.long	.LFE14
	.long	0x0
	.long	0x0
	.section	.debug_line
	.long	.LELT0-.LSLT0
.LSLT0:
	.word	0x2
	.long	.LELTP0-.LASLTP0
.LASLTP0:
	.byte	0x1
	.byte	0x1
	.byte	0xf6
	.byte	0xf5
	.byte	0xa
	.byte	0x0
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x0
	.byte	0x0
	.byte	0x0
	.byte	0x1
	.ascii	"c:/documents and settings/david/my documents/arduino-0022/ha"
	.ascii	"rdware/tools/avr/lib/gcc/../../avr/include/avr"
	.byte	0
	.ascii	"c:/documents and settings/david/my documents/arduino-0022/ha"
	.ascii	"rdware/tools/avr/lib/gcc/../../avr/include/util"
	.byte	0
	.byte	0x0
	.string	"delay_basic.h"
	.uleb128 0x2
	.uleb128 0x0
	.uleb128 0x0
	.string	"eeprom.h"
	.uleb128 0x1
	.uleb128 0x0
	.uleb128 0x0
	.string	"ATmegaBOOT.c"
	.uleb128 0x0
	.uleb128 0x0
	.uleb128 0x0
	.byte	0x0
.LELTP0:
	.byte	0x0
	.uleb128 0x5
	.byte	0x2
	.long	.Letext0
	.byte	0x0
	.uleb128 0x1
	.byte	0x1
.LELT0:
	.section	.debug_str,"MS",@progbits,1
.LASF4:
	.string	"getch"
.LASF0:
	.string	"_delay_loop_2"
.LASF10:
	.string	"ATmegaBOOT.c"
.LASF9:
	.string	"GNU C 4.3.2"
.LASF11:
	.ascii	"C:\\Documents and Settings\\David"
	.string	"\\My Documents\\Arduino\\hardware\\breadboard\\bootloaders\\fielduino8"
.LASF2:
	.string	"eeprom_read_byte"
.LASF8:
	.string	"main"
.LASF6:
	.string	"byte_response"
.LASF7:
	.string	"nothing_response"
.LASF5:
	.string	"getNch"
.LASF1:
	.string	"eeprom_write_byte"
.LASF3:
	.string	"putch"
