; 8052 Disassembly of SB DSP version 4.13

; ------------------------------
; Register/Memory Equates
; ------------------------------
.EQU rb0r0, 00h
.EQU rb1r0, 08h
.EQU rb1r1, 09h
.EQU rb1r2, 0ah
.EQU rb1r3, 0bh
.EQU rb1r4, 0ch
.EQU rb1r5, 0dh
.EQU dma_blk_len_lo, 0eh
.EQU dma_blk_len_hi, 0fh
.EQU rb2r0, 10h
.EQU rb2r1, 11h
.EQU rb2r2, 12h
.EQU rb2r3, 13h
.EQU rb2r4, 14h
.EQU rb2r5, 15h
.EQU rb2r6, 16h
.EQU rb2r7, 17h
.EQU rb3r0, 18h
.EQU rb3r1, 19h
.EQU rb3r2,	1ah
.EQU command_byte, 20h
.EQU len_left_lo, 21h
.EQU len_left_hi, 22h
.EQU status_register, 23h
.EQU dsp_dma_id0, 25h
.EQU dsp_dma_id1, 26h
.EQU vector_low, 29h
.EQU vector_high, 2bh
.EQU warmboot_magic1, 31h
.EQU warmboot_magic2, 32h

; ------------------------------
; SFR Equates
; ------------------------------
.EQU pin_dma_enablel, 22h		; 24.2h
.EQU midi_timestamp, 25h		; 24.5h
.EQU pin_mute_en, 1ch			; 23.4h

; ------------------------------
; SFR bit Equates
; ------------------------------
.EQU pin_dav_pc, 90h			; p1.0
.EQU pin_dav_dsp, 91h			; p1.1
.EQU pin_dsp_busy, 92h			; p1.2


; ------------------------------
; Memory bit Equates
; ------------------------------
.EQU command_byte_0, 0
.EQU command_byte_1, 1
.EQU command_byte_2, 2
.EQU command_byte_3, 3
;

    .org	0
;
RESET:
    ljmp	start
;
int0_vector:
    ljmp	int0_handler
;
    .db	66h,46h,56h,66h,46h
;
timer0_vector:
    ljmp	timer0_handler
;
    .db	66h,46h,66h,56h,56h
;
int1_vector:
    ljmp	int1_handler
	
; ------------------------------
; Timer/Counter 0 Interrupt Vector
; ------------------------------
int0_handler:
    push	psw
    setb	pin_dsp_busy
    push	acc
    push	dpl
    push	dph
    push	rb0r0
    mov	r0,#5
    movx	a,@r0
    setb	acc.6
    movx	@r0,a
    mov	dptr,#int0_table
    mov	a,rb1r3
    anl	a,#0fh
    movc	a,@a+dptr
    jmp	@a+dptr
;
int0_table:
        ;db	1eh,0fh,12h,15h,18h,1bh,1eh,1eh
    ;db	1eh,1eh,1eh,1eh,1eh,1eh,1eh

        .db int0_op_none_handler - int0_table
        .db dac_silence_vector - int0_table
        .db vector_dma_dac_adpcm2 - int0_table
        .db vector_dma_dac_adpcm2_6 - int0_table
        .db vector_dma_dac_adpcm4 - int0_table
        .db int0_op5_vector - int0_table
        .db int0_op_none_handler - int0_table
        .db int0_op_none_handler - int0_table
        .db int0_op_none_handler - int0_table
        .db int0_op_none_handler - int0_table
        .db int0_op_none_handler - int0_table
        .db int0_op_none_handler - int0_table
        .db int0_op_none_handler - int0_table
        .db int0_op_none_handler - int0_table
        .db int0_op_none_handler - int0_table
;
dac_silence_vector:
    ljmp	dac_silence
;
vector_dma_dac_adpcm2:
    ljmp	dma_dac_adpcm2
;
vector_dma_dac_adpcm2_6:
    ljmp	dma_dac_adpcm2_6
;
vector_dma_dac_adpcm4:
    ljmp	dma_dac_adpcm4
;
int0_op5_vector:
    ljmp	int0_op5_handler
;
int0_op_none_handler:
    clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    pop	rb0r0
    pop	dph
    pop	dpl
    pop	acc
    reti	
;
int1_handler:
    push	psw
    clr	pin_dsp_busy
    push	acc
    push	dpl
    push	dph
    push	rb0r0
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    mov	r0,#6
    movx	a,@r0
    jnb	acc.0,X0083
    lcall	X00ca
X0083:
	mov	r0,#6
    movx	a,@r0
    jnb	acc.1,X008c
    lcall	X0145
X008c:	
    pop	rb0r0
    pop	dph
    pop	dpl
    pop	acc
    pop	psw
    reti
;
timer0_handler:
    jb	midi_timestamp,midi_timestamp_int
    jnb	23h.6,X00a4
    mov	tl0,rb3r1
    mov	th0,rb3r2
    ljmp	X00a8
;
X00a4:
	clr	et0
    clr	tr0
X00a8:
	clr	p1.7
    setb	p1.7
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.7
    movx	@r0,a
    setb	acc.7
    movx	@r0,a
    pop	acc
    reti	
;
midi_timestamp_int:
	inc	r5
    cjne	r5,#0,X00c3
    inc	r6
    cjne	r6,#0,X00c3
    inc	r7
X00c3:
	mov	tl0,#2fh
    mov	th0,#0f8h
    reti	
;
X00ca:
	jb	24h.1,X0122
    jnb	pin_dma_enablel,X00e8
    mov	r0,#7
X00d2:
	jb	pin_dav_dsp,X00d9
    movx	a,@r0
    jb	acc.0,X00d2
X00d9:
	mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    ljmp	X013c
;
X00e8:
	mov	r0,#8
    movx	a,@r0
    anl	a,#0e7h
    orl	a,#2
    movx	@r0,a
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    jnb	2fh.1,X0102
    lcall	X0b09
X0102:
	mov	r0,#6
    setb	2fh.0
    mov	31h,#0
    mov	32h,#0
    jnb	23h.1,X0117
    lcall	X134a
    clr	23h.1
    ljmp	X0144
;
X0117:
	jnb	23h.0,X0144
    lcall	X1341
    clr	23h.0
    ljmp	X0144
;
X0122:
	clr	pin_dma_enablel
    clr	24h.1
    mov	a,rb2r1
    mov	r0,#0bh
    movx	@r0,a
    mov	a,rb2r2
    mov	r0,#0ch
    movx	@r0,a
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
X013c:
	mov	r0,#8
    mov	a,#4
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
X0144:
	ret	
;
X0145:
	jb	24h.3,X0195
    jnb	24h.4,X0162
    mov	r0,#7
X014d:
	jb	pin_dav_dsp,X0154
    movx	a,@r0
    jb	acc.1,X014d
X0154:
	mov	r0,#10h
    movx	a,@r0
    anl	a,#0
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    ljmp	X01ae
;
X0162:
	mov	r0,#10h
    movx	a,@r0
    anl	a,#0e7h
    orl	a,#2
    movx	@r0,a
    mov	r0,#10h
    movx	a,@r0
    anl	a,#0
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    jnb	2fh.0,X017b
    lcall	X0b09
X017b:
	mov	r0,#6
    setb	2fh.1
    jnb	23h.3,X018a
    lcall	X134a
    clr	23h.3
    ljmp	X01b6
;
X018a:
	jnb	23h.2,X01b6
    lcall	X1341
    clr	23h.2
    ljmp	X01b6
;
X0195:
	clr	24h.4
    clr	24h.3
    mov	a,rb2r5
    mov	r0,#13h
    movx	@r0,a
    mov	a,rb2r6
    mov	r0,#14h
    movx	@r0,a
    mov	r0,#10h
    movx	a,@r0
    anl	a,#0
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
X01ae:
	mov	r0,#10h
    mov	a,#4
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
X01b6:
	ret	
;
dma_dac_adpcm2:
    jnb	pin_dav_dsp,X01bf
    setb	24h.0
    ljmp	vector_dma_dac_adpcm2_end
;
X01bf:
	dec	r3
    cjne	r3,#0,vector_dma_dac_adpcm2_shiftin
    clr	a
    cjne	a,21h,X0220
    cjne	a,22h,X021e
    jb	24h.1,X0241
    jb	pin_dma_enablel,X01f0
    clr	24h.1
    clr	pin_dma_enablel
    clr	ex0
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    setb	2fh.0
    jnb	2fh.1,X01ea
    lcall	X0b09
X01ea:
	ljmp	vector_dma_dac_adpcm2_end
;
vector_dma_dac_adpcm2_shiftin:
	ljmp	X023b
;
X01f0:
	mov	len_left_lo,dma_blk_len_lo
    mov	len_left_hi,dma_blk_len_hi
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X0205:
	movx	a,@r0
    jnb	acc.6,X0205
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
    mov	r3,#4
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
	ljmp	vector_dma_dac_adpcm2_end
;
X021e:
	dec	22h
X0220:
	dec	21h
    mov	r3,#4
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X0233:
	movx	a,@r0
    jnb	acc.6,X0233
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
X023b:
	lcall	X1221
    ljmp	vector_dma_dac_adpcm2_end
;
X0241:
	clr	pin_dma_enablel
    clr	24h.1
    mov	len_left_lo,rb2r1
    mov	len_left_hi,rb2r2
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X025a:
	movx	a,@r0
    jnb	acc.6,X025a
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
    mov	r3,#4
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
vector_dma_dac_adpcm2_end:
    clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    ljmp	X008c
;
dma_dac_adpcm4:
    jnb	pin_dav_dsp,X028d
    setb	24h.0
    ljmp	vector_dma_dac_adpcm4_end
;
X028d:
	dec	r3
    cjne	r3,#0,vector_dma_dac_adpcm4_shiftin
    clr	a
    cjne	a,len_left_lo,X02ee
    cjne	a,len_left_hi,X02ec
    jb	24h.1,X030f
    jb	pin_dma_enablel,X02be
    clr	24h.1
    clr	pin_dma_enablel
    clr	ex0
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    setb	2fh.0
    jnb	2fh.1,X02b8
    lcall	X0b09
X02b8:
	ljmp	vector_dma_dac_adpcm4_end
;
vector_dma_dac_adpcm4_shiftin:
	ljmp	X0309
;
X02be:
	mov	len_left_lo,dma_blk_len_lo
    mov	len_left_hi,dma_blk_len_hi
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X02d3:
	movx	a,@r0
    jnb	acc.6,X02d3
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
    mov	r3,#2
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    ljmp	vector_dma_dac_adpcm4_end
;
X02ec:
	dec	len_left_hi
X02ee:
	dec	len_left_lo
    mov	r3,#2
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X0301:
	movx	a,@r0
    jnb	acc.6,X0301
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
X0309:
	lcall	X1278
    ljmp	vector_dma_dac_adpcm4_end
;
X030f:
	clr	pin_dma_enablel
    clr	24h.1
    mov	len_left_lo,rb2r1
    mov	len_left_hi,rb2r2
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X0328:
	movx	a,@r0
    jnb	acc.6,X0328
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
    mov	r3,#2
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
vector_dma_dac_adpcm4_end:
    clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    ljmp	X008c
;
dma_dac_adpcm2_6:
    jnb	pin_dav_dsp,X035b
    setb	24h.0
    ljmp	vector_dma_dac_adpcm2_6_end
;
X035b:
	dec	r3
    cjne	r3,#0,vector_dma_dac_adpcm2_6_shiftin
    clr	a
    cjne	a,len_left_lo,X038c
    cjne	a,len_left_hi,X038a
    jb	24h.1,X03db
    jb	pin_dma_enablel,X03ad
    clr	24h.1
    clr	pin_dma_enablel
    clr	ex0
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    jnb	2fh.1,X0384
    lcall	X0b09
X0384:
	ljmp	vector_dma_dac_adpcm2_6_end
;
vector_dma_dac_adpcm2_6_shiftin:
	ljmp	X03a7
;
X038a:
	dec	len_left_hi
X038c:
	dec	len_left_lo
    mov	r3,#3
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X039f:
	movx	a,@r0
    jnb	acc.6,X039f
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
X03a7:
	lcall	X12c3
    ljmp	vector_dma_dac_adpcm2_6_end
;
X03ad:
	mov	len_left_lo,dma_blk_len_lo
    mov	len_left_hi,dma_blk_len_hi
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X03c2:
	movx	a,@r0
    jnb	acc.6,X03c2
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
    mov	r3,#3
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    ljmp	vector_dma_dac_adpcm2_6_end
;
X03db:
	clr	pin_dma_enablel
    clr	24h.1
    mov	len_left_lo,rb2r1
    mov	len_left_hi,rb2r2
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X03f4:
	movx	a,@r0
    jnb	acc.6,X03f4
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
    mov	r3,#3
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
vector_dma_dac_adpcm2_6_end:
    clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    ljmp	X008c
;
dac_silence:
    jnb	pin_dav_dsp,X0427
    setb	24h.0
    ljmp	dac_silence_end
;
X0427:
	clr	a
    cjne	a,len_left_lo,X0449
    cjne	a,len_left_hi,X0447
    clr	ex0
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    setb	2fh.0
    jnb	2fh.1,dac_silence_end
    lcall	X0b09
    ljmp	dac_silence_end
;
X0447:
	dec	len_left_hi
X0449:
	dec	len_left_lo
dac_silence_end:
    clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    ljmp	X008c
;
int0_op5_handler:
    mov	dptr,#int0_op5_data
    mov	a,r7
    movc	a,@a+dptr
    cjne	a,#0,X046c
    mov	r7,#0
    clr	a
    movc	a,@a+dptr
X046c:
    mov	r0,#19h
    movx	@r0,a
    inc	r7
    clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    ljmp	X008c

; ------------------------------
; Start: Where we begin.
; ------------------------------
start:
    setb	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    setb	acc.6
    movx	@r0,a
    pop	acc
    clr	ea
    setb	p1.7
    setb	2fh.0
    setb	2fh.1
    clr	p1.4
    clr	p2.6
    mov	sp,#0c0h
    clr	p1.5
    setb	p2.7
    mov	scon,#42h
    mov	th1,#0fch
    mov	tl1,#0fch
    mov	tmod,#21h
    mov	pcon,#80h
    setb	tr1
    setb	ren
    setb	it0
    setb	it1
    mov	a,#34h
    cjne	a,31h,cold_boot
    mov	a,#12h
    cjne	a,32h,cold_boot
    mov	31h,#0
    mov	32h,#0
    ljmp	warm_boot

; ------------------------------
; Cold boot startup.
; ------------------------------
cold_boot:
	mov	r0,#4
    mov	a,#60h
    movx	@r0,a
    mov	r0,#8
    mov	a,#2
    movx	@r0,a
    mov	r0,#9
    mov	a,#0f8h
    movx	@r0,a
    mov	r0,#5
    mov	a,#0c3h
    movx	@r0,a
    mov	r0,#0eh
    mov	a,#5
    movx	@r0,a
    mov	r0,#0eh
    mov	a,#4
    movx	@r0,a
    mov	r0,#10h
    mov	a,#2
    movx	@r0,a
    mov	r0,#16h
    mov	a,#5
    movx	@r0,a
    mov	r0,#16h
    mov	a,#4
    movx	@r0,a
    mov	r7,#0
    mov	25h,#0aah
    mov	26h,#96h
    mov	dma_blk_len_lo,#0ffh
    mov	dma_blk_len_hi,#7
    mov	37h,#38h
    mov	23h,#0

; ------------------------------
; Warm boot, so we skipped over some initialization.
; ------------------------------
warm_boot:
	mov	r0,#5
    movx	a,@r0
    setb	acc.1
    movx	@r0,a
    mov	rb1r3,#0
    mov	2ch,#0
    mov	2dh,#0
    mov	2bh,#0
    mov	24h,#0
    clr	p2.5
    setb	p2.4
    clr	2fh.4
    clr	2fh.3
    clr	2fh.2
    setb	ea
    mov	a,#0aah
X0532:
	jb	pin_dav_pc,X0532
    mov	r0,#0
    nop	
    nop	
    movx	@r0,a

; Check for incoming commands. This is the start of the command monitoring
; loop, where we read commands, dispatch them, and then return back here.
check_cmd:
	jb	24h.0,X0564

; Wait for the host PC to write a command to the mailbox.
wait_for_cmd:
    clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    jb	23h.5,X0552
    jnb	p1.6,X0555
    lcall	X0c86
X0552:
	lcall	X0c9e
X0555:
	setb	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    setb	acc.6
    movx	@r0,a
    pop	acc
    jnb	pin_dav_dsp,wait_for_cmd
X0564:
	clr	ea
    clr	24h.0
    mov	30h,command_byte
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	command_byte,a
    swap	a
    anl	a,#0fh
    cjne	a,#0dh,dispatch_cmd
    ljmp	cmdg_speaker

; ------------------------------
; Dispatches a command.
; ------------------------------
dispatch_cmd:
	setb	ea
    clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    mov	dptr,#command_dispatch_table
    movc	a,@a+dptr
    jmp	@a+dptr
;
    sjmp	check_cmd
;
;X0590:	db	12h,15h,1eh,21h,27h,10h,10h,18h
;    .db	2ah,1bh,10h,36h,33h,30h,2dh,24h

command_dispatch_table:
     .db command_dispatch_G0 - command_dispatch_table
     .db command_dispatch_G1 - command_dispatch_table
     .db command_dispatch_G2 - command_dispatch_table
     .db command_dispatch_G3 - command_dispatch_table
     .db command_dispatch_G4 - command_dispatch_table
     .db cmd_NONE            - command_dispatch_table
     .db cmd_NONE            - command_dispatch_table
     .db command_dispatch_G7 - command_dispatch_table
     .db command_dispatch_G8 - command_dispatch_table
     .db command_dispatch_G9 - command_dispatch_table
     .db cmd_NONE            - command_dispatch_table
     .db command_dispatch_GB - command_dispatch_table
     .db command_dispatch_GC - command_dispatch_table
     .db command_dispatch_GD - command_dispatch_table
     .db command_dispatch_GE - command_dispatch_table
     .db command_dispatch_GF - command_dispatch_table

; 10h: invalid command group 5, 6, A
cmd_NONE:
    sjmp	check_cmd
; 12h: command group 0
command_dispatch_G0:
    ljmp	cmdg_status
; 15h: command group 1
command_dispatch_G1:
    ljmp	cmdg_dac
; 18h: command group 7
command_dispatch_G7:
    ljmp	cmdg_dac2
; 1bh: command group 9
command_dispatch_G9:
    ljmp	cmdg_hs
; 1eh: command group 2
command_dispatch_G2:
    ljmp	cmdg_adc
; 21h: command group 3
command_dispatch_G3:
    ljmp	cmdg_midi
; 24h: command group F
command_dispatch_GF:
    ljmp	cmdg_aux
; 27h: command group 4
command_dispatch_G4:
    ljmp	cmdg_setup
; 2ah: command group 8
command_dispatch_G8:
    ljmp	cmdg_silence
; 2dh: command group E
command_dispatch_GE:
    ljmp	cmdg_ident
; 30h: command group D
command_dispatch_GD:
    ljmp	cmdg_speaker
; 33h: command group C
command_dispatch_GC:
    ljmp	cmdg_dma8
; 36h: command group B
command_dispatch_GB:
    ljmp	cmdg_dma16
	
;
cmdg_dma8:
	lcall	X0af1
    mov	r0,#4
    movx	a,@r0
    anl	a,#0f0h
    jnb	command_byte_3,X05dd
    orl	a,#5
    mov	2eh,a
    setb	23h.1
    ljmp	X05e3
;
X05dd:
	orl	a,#4
    mov	2eh,a
    setb	23h.0
X05e3:
	jnb	command_byte_2,X05eb
    setb	pin_dma_enablel
    ljmp	X0606
;
X05eb:
	jnb	pin_dma_enablel,X0606
    clr	pin_dma_enablel
    lcall	dsp_input_data
    lcall	dsp_input_data
    mov	rb2r1,a
    lcall	dsp_input_data
    mov	rb2r2,a
    setb	24h.1
    clr	2fh.0
    setb	ex1
    ljmp	X067c
;
X0606:
	jnb	command_byte_1,X0618
    jb	command_byte_3,X0612
    lcall	X1353
    ljmp	X0627
;
X0612:
	lcall	X135c
    ljmp	X0627
;
X0618:
	jb	command_byte_3,X0621
    lcall	X1341
    ljmp	X0627
;
X0621:
	lcall	X134a
    ljmp	X0627
;
X0627:
	jnb	command_byte_0,X062a
X062a:
	lcall	dsp_input_data
    mov	2ch,a
    mov	a,2eh
    clr	acc.4
    jnb	2ch.4,X0638
    setb	acc.4
X0638:
	setb	acc.6
    jnb	2ch.5,X063f
    clr	acc.6
X063f:
	mov	r0,#4
    movx	@r0,a
    clr	ea
    mov	r0,#8
    mov	a,#1
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    setb	ea
    lcall	dsp_input_data
    mov	dma_blk_len_lo,a
    mov	r0,#0bh
    movx	@r0,a
    lcall	dsp_input_data
    mov	dma_blk_len_hi,a
    mov	r0,#0ch
    movx	@r0,a
    setb	2fh.4
    setb	ex1
    clr	2fh.0
    clr	ea
    mov	r0,#8
    mov	a,#4
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    mov	r0,#16h
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    mov	r0,#0eh
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    setb	ea
X067c:
	ljmp	check_cmd
;
cmdg_dma16:
	lcall	X0af1
    mov	r0,#4
    movx	a,@r0
    anl	a,#0f0h
    jnb	command_byte_3,X0693
    orl	a,#4
    mov	2eh,a
    setb	23h.3
    ljmp	X0699
;
X0693:
	orl	a,#5
    mov	2eh,a
    setb	23h.2
X0699:
	jnb	command_byte_2,X06a1
    setb	24h.4
    ljmp	X06bc
;
X06a1:
	jnb	24h.4,X06bc
    clr	24h.4
    lcall	dsp_input_data
    lcall	dsp_input_data
    mov	rb2r5,a
    lcall	dsp_input_data
    mov	rb2r6,a
    setb	24h.3
    clr	2fh.1
    setb	ex1
    ljmp	X0726
;
X06bc:
	jnb	command_byte_1,X06ce
    jb	command_byte_3,X06c8
    lcall	X1353
    ljmp	X06dd
;
X06c8:
	lcall	X135c
    ljmp	X06dd
;
X06ce:
	jb	command_byte_3,X06d7
    lcall	X1341
    ljmp	X06dd
;
X06d7:	lcall	X134a
    ljmp	X06dd
;
X06dd:
	jnb	command_byte_0,X06e0
X06e0:
	lcall	dsp_input_data
    mov	2dh,a
    mov	a,2eh
    clr	acc.5
    jnb	2dh.4,X06ee
    setb	acc.5
X06ee:
	setb	acc.7
    jnb	2dh.5,X06f5
    clr	acc.7
X06f5:
	mov	r0,#4
    movx	@r0,a
    lcall	dsp_input_data
    mov	rb1r4,a
    mov	r0,#13h
    movx	@r0,a
    lcall	dsp_input_data
    mov	rb1r5,a
    mov	r0,#14h
    movx	@r0,a
    setb	2fh.4
    setb	ex1
    clr	2fh.1
    clr	ea
    mov	r0,#10h
    mov	a,#4
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    mov	r0,#16h
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    mov	r0,#0eh
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    setb	ea
X0726:
	ljmp	check_cmd

;
; Command group 0: status
;
cmdg_status:	
	mov	dptr,#group_0_dispatch_table
    mov	a,command_byte
    anl	a,#0fh
    movc	a,@a+dptr
    jmp	@a+dptr
;
;X0732:	db	75h,0f8h,10h,43h,4ch,34h,55h,5ah
;    .db	6ch,91h,67h,9dh,0c8h,75h,78h,86h

group_0_dispatch_table:
     .db cmd_00 - group_0_dispatch_table
     .db cmd_01 - group_0_dispatch_table
     .db cmd_02 - group_0_dispatch_table
     .db cmd_03 - group_0_dispatch_table
     .db cmd_04 - group_0_dispatch_table
     .db cmd_05 - group_0_dispatch_table
     .db cmd_06 - group_0_dispatch_table
     .db cmd_07 - group_0_dispatch_table
     .db cmd_08 - group_0_dispatch_table
     .db cmd_09 - group_0_dispatch_table
     .db cmd_0A - group_0_dispatch_table
     .db cmd_0B - group_0_dispatch_table
     .db cmd_0C - group_0_dispatch_table
     .db cmd_0D - group_0_dispatch_table
     .db cmd_0E - group_0_dispatch_table
     .db cmd_0F - group_0_dispatch_table

;
cmd_02:
	lcall	dsp_input_data
    mov	r0,#80h
    movx	@r0,a
    mov	a,#0f2h
    mov	2eh,a
    mov	r0,#81h
    movx	@r0,a
X074f:
	mov	r0,#80h
    movx	a,@r0
    jb	pin_dav_dsp,X0763
    cjne	a,2eh,X074f
    mov	r0,#10h
    movx	a,@r0
    anl	a,#0
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
X0763:
	ljmp	X07c0
;
cmd_05:
	lcall	dsp_input_data
    mov	r0,#80h
    movx	@r0,a
    lcall	dsp_input_data
    mov	r0,#81h
    movx	@r0,a
    ljmp	X07c0
;
cmd_03:
	mov	r0,#80h
    movx	a,@r0
    lcall	dsp_output_data
    ljmp	X07c0
;
cmd_04:
	lcall	dsp_input_data
    mov	r0,#82h
    movx	@r0,a
    ljmp	X07c0
;
cmd_06:
	inc	2bh
    ljmp	X07c0
;
cmd_07:
	mov	a,2bh
    cjne	a,#0,X0794
    ljmp	X07c0
;
X0794:
	dec	2bh
    ljmp	X07c0
;
cmd_0A:
	mov	a,2bh
    lcall	dsp_output_data
cmd_08:
	mov	r0,#82h
    movx	a,@r0
    lcall	dsp_output_data
    ljmp	X07c0
;
cmd_00:
cmd_0D:
    ljmp	wait_for_cmd
;
cmd_0E:
	lcall	dsp_input_data
    mov	b,a
    lcall	dsp_input_data
    mov	r0,b
    movx	@r0,a
    ljmp	wait_for_cmd
;
cmd_0F:
	lcall	dsp_input_data
    mov	r0,a
    movx	a,@r0
    lcall	dsp_output_data
X07c0:
	ljmp	wait_for_cmd
;
cmd_09:
	mov	a,rb1r0
    lcall	dsp_output_data
    mov	a,rb1r1
    lcall	dsp_output_data
    sjmp	X07c0
;
cmd_0B:
	lcall	dsp_input_data
    mov	len_left_lo,a
    mov	r0,#80h
    movx	@r0,a
    mov	a,#0c0h
    mov	2eh,a
    mov	r0,#81h
    movx	@r0,a
X07de:
	mov	r0,#80h
    movx	a,@r0
    cjne	a,2eh,X07de
X07e4:
	lcall	dsp_input_data
    mov	r0,#80h
    movx	@r0,a
    lcall	dsp_input_data
    mov	r0,#81h
    movx	@r0,a
    clr	a
    cjne	a,len_left_lo,X07f6
    sjmp	X07c0
;
X07f6:
	dec	len_left_lo
    sjmp	X07e4
;
cmd_0C:
	lcall	dsp_input_data
    mov	len_left_lo,a
    mov	r0,#80h
    movx	@r0,a
    mov	a,#0c1h
    mov	2eh,a
    mov	r0,#81h
    movx	@r0,a
X0809:
	mov	r0,#80h
    movx	a,@r0
    cjne	a,2eh,X0809
    mov	a,2eh
    mov	r0,#81h
    movx	@r0,a
X0814:
	mov	r0,#80h
    movx	a,@r0
    lcall	dsp_output_data
    mov	r0,#80h
    movx	a,@r0
    lcall	dsp_output_data
    clr	a
    cjne	a,len_left_lo,X0826
    sjmp	X07c0
;
X0826:
	dec	len_left_lo
    sjmp	X0814
;
cmd_01:
	mov	a,2bh
    cjne	a,#0,X07c0
    lcall	dsp_output_data
    mov	a,#0
    mov	33h,a
    mov	34h,a
    mov	r0,#80h
    movx	@r0,a
    mov	r0,#81h
    movx	@r0,a
    lcall	dsp_input_data
    clr	c
    subb	a,#4
    mov	len_left_lo,a
    lcall	dsp_input_data
    jnc	X084c
    dec	a
X084c:
	mov	22h,a
    mov	a,#8ch
    mov	r0,#82h
    movx	@r0,a
    mov	a,#8ah
    mov	r0,#82h
    movx	@r0,a
X0858:
	lcall	dsp_input_data
    mov	r0,#83h
    movx	@r0,a
    add	a,33h
    mov	33h,a
    jnc	X0866
    inc	34h
X0866:
	clr	a
    cjne	a,len_left_lo,X08aa
    cjne	a,len_left_hi,X08a8
    lcall	dsp_input_data
    mov	35h,a
    lcall	dsp_input_data
    mov	36h,a
    mov	a,#0
    mov	r0,#82h
    movx	@r0,a
    mov	a,#70h
    mov	r0,#82h
    movx	@r0,a
    mov	a,33h
    cjne	a,35h,X0896
    mov	a,34h
    cjne	a,36h,X0896
    mov	r0,#80h
    movx	a,@r0
    cjne	a,#0aah,X0898
    mov	a,#0
    ljmp	X0898
;
X0896:
	mov	a,#0ffh
X0898:
	lcall	dsp_output_data
    lcall	dsp_input_data
    mov	rb1r0,a
    lcall	dsp_input_data
    mov	rb1r1,a
    ljmp	X07c0
;
X08a8:	
	dec	len_left_hi
X08aa:
	dec	len_left_lo
    sjmp	X0858

;
; Command group 4: Setup
;
cmdg_setup:
	mov	dptr,#group_4_dispatch_table
    mov	a,command_byte
    anl	a,#0fh
    movc	a,@a+dptr
    jmp	@a+dptr
;
;X08b7:	db	6fh,82h,82h,9fh,10h,15h,1ah,1fh
;    .db	0c0h,24h,24h,24h,51h,60h,27h,2ch
group_4_dispatch_table:
     .db cmd_40 - group_4_dispatch_table
     .db cmd_41 - group_4_dispatch_table
     .db cmd_42 - group_4_dispatch_table
     .db cmd_43 - group_4_dispatch_table
     .db cmd_44 - group_4_dispatch_table
     .db cmd_45 - group_4_dispatch_table
     .db cmd_46 - group_4_dispatch_table
     .db cmd_47 - group_4_dispatch_table
     .db cmd_48 - group_4_dispatch_table
     .db cmd_49 - group_4_dispatch_table
     .db cmd_4A - group_4_dispatch_table
     .db cmd_4B - group_4_dispatch_table
     .db cmd_4C - group_4_dispatch_table
     .db cmd_4D - group_4_dispatch_table
     .db cmd_4E - group_4_dispatch_table
     .db cmd_4F - group_4_dispatch_table

;
cmd_44:
	setb	2fh.3
    ljmp	X0984
;
cmd_45:
	clr	2fh.3
    ljmp	X0984
;
cmd_46:
	setb	2fh.2
    ljmp	X0984
;
cmd_47:
	clr	2fh.2
    ljmp	X0984
;
cmd_49:
cmd_4A:
cmd_4B:
    ljmp	wait_for_cmd
;
cmd_4E:
	clr	23h.6
    ljmp	X08f1
;
cmd_4F:
	jnb	23h.6,X08ef
    clr	23h.6
    clr	tr0
    clr	et0
    ljmp	X0984
;
X08ef:
	setb	23h.6
X08f1:
	lcall	dsp_input_data
    cpl	a
    mov	tl0,a
    mov	rb3r1,a
    lcall	dsp_input_data
    cpl	a
    mov	th0,a
    mov	rb3r2,a
    setb	et0
    setb	tr0
    ljmp	X0984
;
cmd_4C:
	lcall	dsp_input_data
    anl	a,#3
    add	a,#1bh
    mov	r0,a
    lcall	dsp_input_data
    movx	@r0,a
    ljmp	X0984
;
cmd_4D:
	lcall	dsp_input_data
    anl	a,#3
    add	a,#1bh
    mov	r0,a
    mov	a,@r0
    lcall	dsp_output_data
    ljmp	X0984
;
cmd_40:
	lcall	dsp_input_data
    cjne	a,#0ebh,X092c
X092c:
	jc	X0930
    mov	a,#0ebh
X0930:
	lcall	convert_samplerate
    lcall	X0ad9
    ljmp	X0984
;
cmd_41:
cmd_42:
    jnb	pin_dav_dsp,cmd_41
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	rb2r4,a
X0943:
	jnb	pin_dav_dsp,X0943
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	rb2r3,a
    lcall	X0a78
    lcall	X0ad9
    ljmp	X0984
;
cmd_43:
	jnb	pin_dav_dsp,cmd_43
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	rb2r4,a
X0960:
	jnb	pin_dav_dsp,X0960
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	rb2r3,a
    lcall	X0a78
    mov	r0,#9
    mov	37h,a
    movx	@r0,a
    clr	23h.7
    ljmp	X0984
;
cmd_48:
	lcall	dsp_input_data
    mov	dma_blk_len_lo,a
    lcall	dsp_input_data
    mov	dma_blk_len_hi,a
    ljmp	X0984
;
X0984:
	ljmp	wait_for_cmd
;
convert_samplerate:
    mov	dptr,#samplerate_table
    movc	a,@a+dptr
    ret	
;
samplerate_table:	
	.db	15h,16h,16h,16h,16h,16h,16h,16h
    .db	16h,16h,16h,16h,17h,17h,17h,17h
    .db	17h,17h,17h,17h,17h,17h,18h,18h
    .db	18h,18h,18h,18h,18h,18h,18h,18h
    .db	19h,19h,19h,19h,19h,19h,19h,19h
    .db	1ah,1ah,1ah,1ah,1ah,1ah,1ah,1ah
    .db	1bh,1bh,1bh,1bh,1bh,1bh,1bh,1bh
    .db	1ch,1ch,1ch,1ch,1ch,1ch,1ch,1dh
    .db	1dh,1dh,1dh,1dh,1dh,1eh,1eh,1eh
    .db	1eh,1eh,1eh,1fh,1fh,1fh,1fh,1fh
    .db	1fh,20h,20h,20h,20h,20h,21h,21h
    .db	21h,21h,21h,22h,22h,22h,22h,22h
    .db	23h,23h,23h,23h,24h,24h,24h,24h
    .db	25h,25h,25h,25h,26h,26h,26h,26h
    .db	27h,27h,27h,27h,28h,28h,28h,29h
    .db	29h,29h,29h,2ah,2ah,2ah,2bh,2bh
    .db	2bh,2ch,2ch,2dh,2dh,2dh,2eh,2eh
    .db	2eh,2fh,2fh,30h,30h,30h,31h,31h
    .db	32h,32h,33h,33h,34h,34h,35h,35h
    .db	36h,36h,37h,37h,38h,38h,39h,39h
    .db	3ah,3bh,3bh,3ch,3dh,3dh,3eh,3fh
    .db	3fh,40h,41h,42h,42h,43h,44h,45h
    .db	46h,47h,48h,49h,49h,4ah,4bh,4dh
    .db	4eh,4fh,50h,51h,52h,53h,55h,56h
    .db	57h,59h,5ah,5ch,5dh,5fh,60h,62h
    .db	64h,66h,68h,6ah,6ch,6eh,70h,72h
    .db	75h,77h,7ah,7ch,7fh,82h,85h,89h
    .db	8ch,90h,93h,97h,9ch,0a0h,0a5h,0aah
    .db	0afh,0b5h,0bbh,0c1h,0c8h,0d0h,0d8h,0e0h
    .db	0eah,0f4h,0ffh,0ffh
;
X0a78:
	mov	a,rb2r4
    cjne	a,#0b1h,X0a82
    mov	a,#0ffh
    ljmp	X0ad8
;
X0a82:
	jc	X0a89
    mov	a,#0ffh
    ljmp	X0ad8
;
X0a89:
	mov	a,rb2r4
    clr	c
    subb	a,#13h
    jnc	X0a95
    mov	a,#1ch
    ljmp	X0ad8
;
X0a95:
	mov	a,#17h
    mov	b,rb2r4
    mul	ab
    mov	rb3r0,b
    mov	rb2r7,a
    mov	a,#17h
    mov	b,rb2r3
    mul	ab
    xch	a,b
    add	a,rb2r7
    mov	rb2r7,a
    mov	a,rb3r0
    addc	a,#0
    rrc	a
    mov	rb3r0,a
    mov	a,rb2r7
    rrc	a
    mov	rb2r7,a
    mov	a,rb3r0
    rrc	a
    mov	rb3r0,a
    mov	a,rb2r7
    rrc	a
    mov	rb2r7,a
    mov	a,rb3r0
    rrc	a
    mov	rb3r0,a
    mov	a,rb2r7
    rrc	a
    mov	rb2r7,a
    mov	a,rb3r0
    rrc	a
    mov	rb3r0,a
    mov	a,rb2r7
    rrc	a
    addc	a,#0
    mov	rb2r7,a
X0ad8:
	ret	
;
X0ad9:
	mov	r0,#9
    jb	p2.4,X0ae2
    movx	@r0,a
    ljmp	X0af0
;
X0ae2:
	mov	37h,a
    cjne	a,#0f8h,X0ae7
X0ae7:
	jnc	X0aee
    setb	23h.7
    ljmp	X0af0
;
X0aee:
	clr	23h.7
X0af0:
	ret	
;
X0af1:
	jnb	p2.4,X0b08
    mov	r0,#9
    mov	a,37h
    cjne	a,#5ah,X0afe
    ljmp	X0b00
;
X0afe:
	jnc	X0b05
X0b00:
	setb	p2.5
    ljmp	X0b07
;
X0b05:
	clr	p2.5
X0b07:
	movx	@r0,a
X0b08:
	ret	
;
X0b09:
	jnb	p2.4,X0b14
    jnb	23h.7,X0b14
    mov	r0,#9
    mov	a,#0f8h
    movx	@r0,a
X0b14:
	ret	
;
cmdg_aux:
	mov	dptr,#group_F_dispatch_table
    mov	a,command_byte
    anl	a,#0fh
    movc	a,@a+dptr
    jmp	@a+dptr
;
;X0b1e:	db	7eh,41h,44h,53h,61h,41h,41h,41h
;    .db	6eh,10h,1bh,31h,39h,29h,41h,41h
group_F_dispatch_table:
     .db cmd_F0 - group_F_dispatch_table
     .db cmd_F1 - group_F_dispatch_table
     .db cmd_F2 - group_F_dispatch_table
     .db cmd_F3 - group_F_dispatch_table
     .db cmd_F4 - group_F_dispatch_table
     .db cmd_F5 - group_F_dispatch_table
     .db cmd_F6 - group_F_dispatch_table
     .db cmd_F7 - group_F_dispatch_table
     .db cmd_F8 - group_F_dispatch_table
     .db cmd_F9 - group_F_dispatch_table
     .db cmd_FA - group_F_dispatch_table
     .db cmd_FB - group_F_dispatch_table
     .db cmd_FC - group_F_dispatch_table
     .db cmd_FD - group_F_dispatch_table
     .db cmd_FE - group_F_dispatch_table
     .db cmd_FF - group_F_dispatch_table

;
cmd_F9:
	lcall	dsp_input_data
    mov	r0,a
    mov	a,@r0
    lcall	dsp_output_data
    ljmp	group_F_exit
;
cmd_FA:
	lcall	dsp_input_data
    mov	b,a
    lcall	dsp_input_data
    mov	r0,b
    mov	@r0,a
    ljmp	group_F_exit
;
cmd_FD:
	mov	a,30h
    lcall	dsp_output_data
    ljmp	group_F_exit
;
cmd_FB:
	mov	a,23h
    lcall	dsp_output_data
    ljmp	group_F_exit
;
cmd_FC:
	mov	a,24h
    lcall	dsp_output_data
    ljmp	group_F_exit
;
cmd_F1:
cmd_F5:
cmd_F6:
cmd_F7:
cmd_FE:
cmd_FF:
    ljmp	group_F_exit
;
cmd_F2:
	mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    ljmp	group_F_exit
;
cmd_F3:
	mov	r0,#10h
    movx	a,@r0
    anl	a,#0
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
    ljmp	group_F_exit
;
cmd_F4:
	mov	a,#0a4h
    lcall	dsp_output_data
    mov	a,#6fh
    lcall	dsp_output_data
    ljmp	group_F_exit
;
cmd_F8:
	mov	a,#0
    mov	r0,#0
    nop	
    nop	
    movx	@r0,a
    ljmp	group_F_exit
;
    lcall	X1365
    ljmp	group_F_exit
;
cmd_F0:
	mov	a,#5ah
    lcall	X0ad9
    lcall	X0af1
    mov	rb1r3,#5
    mov	rb1r2,#0
    mov	a,#60h
    mov	r0,#4
    movx	@r0,a
    setb	ex0
    ljmp	group_F_exit
;
group_F_exit:
	clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    ljmp	check_cmd
;
int0_op5_data:	
	.db	7fh,26h,1,26h,80h,0d9h,0ffh,0d9h
    .db	0
;
cmdg_midi:	
	jb	command_byte_3,cmd_midi_write_poll
    jnb	command_byte_2,cmd_midi_read_write_poll
    mov	31h,#34h
    mov	32h,#12h
    ljmp	cmd_midi_read_write_poll
;
cmd_midi_write_poll:	
	jnb	ti,cmd_midi_write_poll
    clr	ti
    lcall	dsp_input_data
    mov	sbuf,a
    ljmp	check_cmd
;
cmd_midi_read_write_poll:	
	jnb	command_byte_1,skip_midi_timestamp_setup
    mov	tmod,#21h
    setb	midi_timestamp
    mov	tl0,#2fh
    mov	th0,#0f8h
    mov	r5,#0
    mov	r6,#0
    mov	r7,#0
    setb	et0
    setb	tr0
skip_midi_timestamp_setup:	
	mov	a,sbuf
    clr	ri
    mov	r1,#40h
    mov	r2,#40h
    mov	r4,#80h
    ljmp	midi_check_for_input_data
;
midi_main_loop:	
	jnb	ti,midi_check_for_input_data
    jnb	pin_dav_dsp,midi_check_for_input_data
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    jb	command_byte_2,midi_write_poll
    clr	et0
    clr	tr0
    mov	31h,#0
    mov	32h,#0
    clr	midi_timestamp
    ljmp	check_cmd
;
midi_write_poll:
	clr	ti
    mov	sbuf,a
midi_check_for_input_data:	
	jb	ri,X0c3b
    cjne	r4,#80h,X0c36
    sjmp	midi_main_loop
;
X0c36:
	jnb	pin_dav_pc,midi_flush_buffer_to_host
    sjmp	midi_main_loop
;
X0c3b:
	jnb	command_byte_1,midi_read_no_timestamp
    clr	tr0
    mov	a,r5
    lcall	midi_store_read_data
    mov	a,r6
    lcall	midi_store_read_data
    mov	a,r7
    lcall	midi_store_read_data
    setb	tr0
midi_read_no_timestamp:	
	mov	a,sbuf
    lcall	midi_store_read_data
    clr	ri
    sjmp	midi_main_loop
;
midi_flush_buffer_to_host:	
	mov	a,r2
    mov	r0,a
    mov	a,@r0
    inc	r2
    inc	r4
    cjne	r2,#0c0h,midi_nowrap_readbuffer
    mov	r2,#40h
midi_nowrap_readbuffer:	
	mov	r0,#0
    nop	
    nop	
    movx	@r0,a
    jnb	command_byte_0,midi_skip_interrupt
    mov	r0,#8
    movx	a,@r0
    anl	a,#3
    movx	@r0,a
    orl	a,#80h
    movx	@r0,a
    anl	a,#7fh
    movx	@r0,a
midi_skip_interrupt:	
	sjmp	midi_main_loop
;
midi_store_read_data:	
	cjne	r4,#0,midi_store_read_data_to_buffer
    ljmp	midi_ready_to_receive_more
;
midi_store_read_data_to_buffer:	
	mov	@r1,a
    inc	r1
    dec	r4
    cjne	r1,#0c0h,midi_ready_to_receive_more
    mov	r1,#40h
midi_ready_to_receive_more:	
	ret	
;
X0c86:
	mov	r0,#2
    mov	a,#0feh
    movx	@r0,a
    setb	23h.5
    mov	a,sbuf
    clr	ri
    mov	r1,#40h
    mov	r2,#40h
    mov	r4,#80h
    mov	31h,#34h
    mov	32h,#12h
    ret	
;
X0c9e:
	mov	31h,#34h
    mov	32h,#12h
    mov	a,38h
    cjne	a,#52h,X0cb1
    mov	a,39h
    cjne	a,#86h,X0cb1
    ljmp	X0d13
;
X0cb1:
	clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    jb	pin_dav_dsp,X0cf2
    jnb	p1.6,X0ce7
    jb	ri,X0cfb
    cjne	r4,#80h,X0cf3
X0cc9:
	jnb	ti,X0cb1
    mov	r0,#2
    movx	a,@r0
    setb	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    setb	acc.6
    movx	@r0,a
    pop	acc
    jnb	acc.6,X0cb1
    mov	r0,#1
    movx	a,@r0
    clr	ti
    mov	sbuf,a
    sjmp	X0cb1
;
X0ce7:
	mov	r0,#1
    movx	a,@r0
    clr	23h.5
    mov	31h,#0
    mov	32h,#0
X0cf2:
	ret	
;
X0cf3:
	mov	r0,#2
    movx	a,@r0
    jb	acc.7,X0d04
    sjmp	X0cc9
;
X0cfb:
	mov	a,sbuf
    lcall	midi_store_read_data
    clr	ri
    sjmp	X0cc9
;
X0d04:
	mov	a,r2
    mov	r0,a
    mov	a,@r0
    inc	r2
    inc	r4
    cjne	r2,#0c0h,X0d0e
    mov	r2,#40h
X0d0e:
	mov	r0,#2
    movx	@r0,a
    sjmp	X0cc9
;
X0d13:
	clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    jb	pin_dav_dsp,X0d5e
    jnb	p1.6,X0d53
    jnb	2fh.5,X0d2b
    jnb	ti,X0d13
X0d2b:
	mov	r0,#2
    movx	a,@r0
    setb	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    setb	acc.6
    movx	@r0,a
    pop	acc
    jnb	acc.7,X0d13
    mov	r0,#2
    movx	a,@r0
    jnb	acc.6,X0d13
    mov	r0,#1
    movx	a,@r0
    clr	ea
    clr	p2.7
    mov	r0,#2
    movx	@r0,a
    setb	p2.7
    setb	ea
    sjmp	X0d13
;
X0d53:
	mov	r0,#1
    movx	a,@r0
    clr	23h.5
    mov	31h,#0
    mov	32h,#0
X0d5e:
	ret	
;
cmdg_adc:	
	clr	2fh.4
    jb	command_byte_3,cmd_adc_autoinit
    jb	command_byte_2,cmd_adc_dma
    ljmp	cmd_adc_direct
;
cmd_adc_autoinit:	
	lcall	X0af1
    setb	pin_dma_enablel
    clr	ea
    mov	r0,#8
    mov	a,#1
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    setb	ea
    mov	a,dma_blk_len_lo
    mov	len_left_lo,a
    mov	r0,#0bh
    movx	@r0,a
    mov	a,dma_blk_len_hi
    mov	len_left_hi,a
    mov	r0,#0ch
    movx	@r0,a
    ljmp	X0dd1
;
cmd_adc_dma:	
	lcall	X0af1
    jb	2fh.0,X0dab
X0d92:
	jnb	pin_dav_dsp,X0d92
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	rb2r1,a
X0d9c:
	jnb	pin_dav_dsp,X0d9c
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	rb2r2,a
    setb	24h.1
    ljmp	X0e1a
;
X0dab:
	clr	ea
    mov	r0,#8
    mov	a,#1
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    setb	ea
X0db7:
	jnb	pin_dav_dsp,X0db7
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	len_left_lo,a
    mov	r0,#0bh
    movx	@r0,a
X0dc4:
	jnb	pin_dav_dsp,X0dc4
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	len_left_hi,a
    mov	r0,#0ch
    movx	@r0,a
X0dd1:
	setb	23h.1
    mov	rb1r2,#5
    lcall	X1317
    mov	r0,#8
    movx	a,@r0
    orl	a,#40h
    movx	@r0,a
    anl	a,#0bfh
    movx	@r0,a
    clr	2fh.0
    setb	ex1
    lcall	X134a
    clr	ea
    mov	r0,#8
    mov	a,#4
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    mov	r0,#16h
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    mov	r0,#0eh
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    setb	ea
    ljmp	check_cmd
;
cmd_adc_direct:	
	mov	a,#61h
    mov	r0,#4
    movx	@r0,a
    mov	r0,#17h
X0e0b:
	movx	a,@r0
    jnb	acc.7,X0e0b
    mov	r0,#1bh
    movx	a,@r0
X0e12:
	jb	pin_dav_pc,X0e12
    mov	r0,#0
    nop	
    nop	
    movx	@r0,a
X0e1a:
	ljmp	check_cmd
;
cmdg_hs:
	lcall	X0af1
    clr	2fh.4
    jnb	command_byte_3,X0e43
    mov	rb1r2,#5
    setb	23h.1
    mov	r0,#8
    movx	a,@r0
    orl	a,#40h
    movx	@r0,a
    anl	a,#0bfh
    movx	@r0,a
    lcall	X134a
    jb	command_byte_0,X0e3e
    setb	pin_dma_enablel
    ljmp	X0e55
;
X0e3e:
	clr	pin_dma_enablel
    ljmp	X0e55
;
X0e43:
	mov	rb1r2,#4
    setb	23h.0
    lcall	X1341
    jb	command_byte_0,X0e53
    setb	pin_dma_enablel
    ljmp	X0e55
;
X0e53:
	clr	pin_dma_enablel
X0e55:
	clr	ea
    mov	r0,#8
    mov	a,#1
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    setb	ea
    mov	a,dma_blk_len_lo
    mov	r0,#0bh
    movx	@r0,a
    mov	a,dma_blk_len_hi
    mov	r0,#0ch
    movx	@r0,a
    mov	31h,#34h
    mov	32h,#12h
    clr	2fh.0
    lcall	X1317
    setb	ex1
    clr	ea
    mov	r0,#8
    mov	a,#4
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    mov	r0,#16h
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    mov	r0,#0eh
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    setb	ea
    ljmp	check_cmd
;
cmdg_dac:	
	clr	2fh.4
    jb	command_byte_3,cmd_dac_autoinit
    jb	command_byte_2,cmd_dac_dma
    ljmp	X0f77
;
cmd_dac_autoinit:	
	lcall	X0af1
    setb	pin_dma_enablel
    clr	ea
    mov	r0,#8
    mov	a,#1
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    setb	ea
    mov	a,dma_blk_len_lo
    mov	21h,a
    mov	r0,#0bh
    movx	@r0,a
    mov	a,dma_blk_len_hi
    mov	22h,a
    mov	r0,#0ch
    movx	@r0,a
    ljmp	X0efa
;
cmd_dac_dma:
	lcall	X0af1
    jnb	pin_dma_enablel,X0edc
    jnb	command_byte_1,X0ecb
    clr	ex0
X0ecb:	
	lcall	dsp_input_data
    mov	rb2r1,a
    lcall	dsp_input_data
    mov	rb2r2,a
    setb	24h.1
    setb	ex0
    ljmp	X0f24
;
X0edc:
	clr	24h.1
    clr	ea
    mov	r0,#8
    mov	a,#1
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    setb	ea
    lcall	dsp_input_data
    mov	len_left_lo,a
    mov	r0,#0bh
    movx	@r0,a
    lcall	dsp_input_data
    mov	len_left_hi,a
    mov	r0,#0ch
    movx	@r0,a
X0efa:
	jb	command_byte_1,X0f27
    setb	23h.0
    mov	rb1r2,#4
    lcall	X1317
    clr	2fh.0
    setb	ex1
    lcall	X1341
    clr	ea
    mov	r0,#8
    mov	a,#4
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    mov	r0,#16h
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    mov	r0,#0eh
    movx	a,@r0
    anl	a,#4
    movx	@r0,a
    setb	ea
X0f24:
	ljmp	check_cmd
;
X0f27:
	clr	2fh.0
    mov	rb1r3,#2
    mov	rb1r2,#2
    lcall	X1317
    lcall	X1326
    jb	command_byte_0,X0f54
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X0f47:
	movx	a,@r0
    jnb	acc.6,X0f47
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
    mov	r3,#4
    ljmp	X0f72
;
X0f54:
	setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X0f63:
	movx	a,@r0
    jnb	acc.6,X0f63
    mov	r0,#1fh
    movx	a,@r0
    mov	r2,a
    mov	r0,#19h
    movx	@r0,a
    mov	r5,#1
    mov	r3,#1
X0f72:
	setb	ex0
    ljmp	check_cmd
;
X0f77:
	mov	a,#60h
    mov	r0,#4
    movx	@r0,a
X0f7c:
	jnb	pin_dav_dsp,X0f7c
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    mov	r0,#19h
    movx	@r0,a
    ljmp	check_cmd
;
cmdg_dac2:
	lcall	X0af1
    clr	2fh.4
    jb	command_byte_3,cmd_dac_autoinit_adpcm
    jb	command_byte_2,cmd_dac_adpcm
cmd_dac_autoinit_adpcm:	
	setb	pin_dma_enablel
    mov	len_left_lo,dma_blk_len_lo
    mov	len_left_hi,dma_blk_len_hi
    ljmp	X0fd1
;
cmd_dac_adpcm:	
	jb	pin_dma_enablel,X0fa6
    ljmp	X0fb9
;
X0fa6:
	clr	ex0
    lcall	dsp_input_data
    mov	rb2r1,a
    lcall	dsp_input_data
    mov	rb2r2,a
    setb	24h.1
    setb	ex0
    ljmp	check_cmd
;
X0fb9:
	clr	24h.1
    lcall	dsp_input_data
    mov	len_left_lo,a
    lcall	dsp_input_data
    mov	len_left_hi,a
    setb	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    setb	acc.6
    movx	@r0,a
    pop	acc
X0fd1:
	clr	2fh.0
    jnb	command_byte_1,cmd_exit_autoinit8c_adpcm_use_4bit
    mov	rb1r3,#3
    ljmp	X0fdf
;
cmd_exit_autoinit8c_adpcm_use_4bit:	
	mov	rb1r3,#4
X0fdf:
	mov	rb1r2,#2
    lcall	X1317
    lcall	X1326
    jnb	command_byte_0,dac_no_reference
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X0ffa:
	movx	a,@r0
    jnb	acc.6,X0ffa
    mov	r0,#1fh
    movx	a,@r0
    mov	r2,a
    mov	r0,#19h
    movx	@r0,a
    mov	r5,#1
    mov	r3,#1
    ljmp	X102d
;
dac_no_reference:	
	setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
    mov	r0,#0fh
X101b:
	movx	a,@r0
    jnb	acc.6,X101b
    mov	r0,#1fh
    movx	a,@r0
    mov	r6,a
    jnb	command_byte_1,X102b
    mov	r3,#3
    ljmp	X102d
;
X102b:
	mov	r3,#4
X102d:
	setb	ex0
    ljmp	check_cmd

;
; Command group 8: Generate silence
;
cmdg_silence:
	lcall	X0af1
    clr	2fh.0
    lcall	dsp_input_data
    mov	len_left_lo,a
    lcall	dsp_input_data
    mov	len_left_hi,a
    mov	rb1r3,#1
    mov	rb1r2,#2
    lcall	X1317
    setb	ex0
    ljmp	check_cmd

;
; Command group D: Enable speaker
;
cmdg_speaker:
	mov	dptr,#group_D_dispatch_table
    mov	a,command_byte
    anl	a,#0fh
    movc	a,@a+dptr
    jmp	@a+dptr
;
;X1058:	db	50h,3ch,10h,41h,94h,7fh,0e0h,10h
;    .db	25h,4bh,46h,10h,0fdh,0f2h,13h,1ch
group_D_dispatch_table:
     .db cmd_dma8_pause - group_D_dispatch_table
     .db cmd_speaker_on - group_D_dispatch_table
     .db cmd_D2 - group_D_dispatch_table
     .db cmd_speaker_off - group_D_dispatch_table
     .db cmd_D4 - group_D_dispatch_table
     .db cmd_dma16_pause - group_D_dispatch_table
     .db cmd_D6 - group_D_dispatch_table
     .db cmd_D7 - group_D_dispatch_table
     .db cmd_spk_stat - group_D_dispatch_table
     .db cmd_exit_autoinit16 - group_D_dispatch_table
     .db cmd_exit_autoinit8 - group_D_dispatch_table
     .db cmd_DB - group_D_dispatch_table
     .db cmd_DC - group_D_dispatch_table
     .db cmd_DD - group_D_dispatch_table
     .db cmd_undoc_de - group_D_dispatch_table
     .db cmd_undoc_df - group_D_dispatch_table
	 
; 10h: invalid command D2, D7, DB
cmd_D2:
cmd_D7:
cmd_DB:
    ljmp	cmdg_d_exit
	
; 13h: command DE (undocumented)
cmd_undoc_de:	
	mov	r0,#5
    movx	a,@r0
    setb	acc.1
    movx	@r0,a
    ljmp	cmdg_d_exit
	
; 1ch: command DF (undocumented)
cmd_undoc_df:
	mov	r0,#5
    movx	a,@r0
    clr	acc.1
    movx	@r0,a
    ljmp	cmdg_d_exit
	
; 25h: command D8
cmd_spk_stat:
	jb	command_byte_1,cmd_exit_autoinit8
    jb	pin_mute_en,X1087
    clr	a
    ljmp	X1089
;
X1087:
	mov	a,#0ffh
X1089:
	jb	pin_dav_pc,X1089
    mov	r0,#0
    nop	
    nop	
    movx	@r0,a
    ljmp	cmdg_d_exit
	
; 3ch: command D1
cmd_speaker_on:	
	setb	pin_mute_en
    ljmp	cmdg_d_exit
	
; 41h: command D3
cmd_speaker_off:
	clr	pin_mute_en
    ljmp	cmdg_d_exit
	
; 46h: command DA
cmd_exit_autoinit8:
	clr	pin_dma_enablel
    ljmp	cmdg_d_exit
	
; 4bh: command D9
cmd_exit_autoinit16:
	clr	24h.4
    ljmp	cmdg_d_exit
	
; 5ah: command D0
cmd_dma8_pause:
	setb	2fh.0
    mov	r0,#4
    movx	a,@r0
    jb	acc.2,X10bb
    clr	ex0
    jnb	2fh.1,X10d4
    lcall	X0b09
    ljmp	cmdg_d_exit
;
X10bb:
	mov	r0,#8
    movx	a,@r0
    anl	a,#0e7h
    orl	a,#42h
    movx	@r0,a
    mov	2eh,#64h
X10c6:
	djnz	2eh,X10c6
    anl	a,#0a7h
    movx	@r0,a
    clr	ex1
    jnb	2fh.1,X10d4
    lcall	X0b09
X10d4:
	ljmp	cmdg_d_exit

; 83h: command D5
cmd_dma16_pause:
	mov	r0,#10h
    movx	a,@r0
    anl	a,#0e7h
    orl	a,#2
    movx	@r0,a
    setb	2fh.1
    clr	ex1
    jnb	2fh.0,X10e9
    lcall	X0b09
X10e9:
	ljmp	cmdg_d_exit

; 9eh: command D4
cmd_D4:
	lcall	X0af1
    clr	2fh.0
    mov	r0,#4
    movx	a,@r0
    jb	acc.2,X10fc
    setb	ex0
    ljmp	cmdg_d_exit
;
X10fc:
	mov	r0,#8
    movx	a,@r0
    jnb	acc.1,X1131
    mov	r0,#0ah
    movx	a,@r0
    push	acc
    mov	r0,#0dh
    movx	a,@r0
    push	acc
    mov	r0,#8
    movx	a,@r0
    orl	a,#3
    movx	@r0,a
    anl	a,#0feh
    movx	@r0,a
    mov	r0,#0ch
    pop	acc
    movx	@r0,a
    mov	r0,#0bh
    pop	acc
    movx	@r0,a
    mov	r0,#8
    mov	a,#6
    movx	@r0,a
    mov	a,#0
    movx	@r0,a
    mov	r0,#0ch
    mov	a,dma_blk_len_hi
    movx	@r0,a
    mov	r0,#0bh
    mov	a,dma_blk_len_lo
    movx	@r0,a
X1131:
	setb	ea
    setb	ex1
    ljmp	cmdg_d_exit
	
; h: command D6
cmd_D6:
	lcall	X0af1
    clr	2fh.1
    mov	r0,#10h
    movx	a,@r0
    anl	a,#0e5h
    movx	@r0,a
    setb	ea
    setb	ex1
    ljmp	cmdg_d_exit
	
; h: command DD
cmd_DD:
	mov	38h,#0
    mov	39h,#0
    clr	2fh.5
    ljmp	cmdg_d_exit
;
cmd_DC:
	mov	38h,#52h
    mov	39h,#86h
    clr	2fh.5
X115d:
	jnb	pin_dav_dsp,X115d
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    cjne	a,#1,cmdg_d_exit
    setb	2fh.5
    ljmp	cmdg_d_exit
;
cmdg_d_exit:
	clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    setb	ea
    ljmp	check_cmd

;
; Command group E: DSP identification
;
cmdg_ident:
	mov	dptr,#group_E_dispatch_table
    mov	a,command_byte
    anl	a,#0fh
    movc	a,@a+dptr
    jmp	@a+dptr
;
;X1187:	db	13h,5fh,2dh,7ah,25h,10h,10h,10h
;    .db	1dh,10h,10h,10h,10h,10h,10h,10h
group_E_dispatch_table:
     .db cmd_invert_bits - group_E_dispatch_table
     .db cmd_dsp_version - group_E_dispatch_table
     .db cmd_dsp_dma_id - group_E_dispatch_table
     .db cmd_dsp_copyright - group_E_dispatch_table
     .db cmd_write_test_reg - group_E_dispatch_table
     .db cmd_E5 - group_E_dispatch_table
     .db cmd_E6 - group_E_dispatch_table
     .db cmd_E7 - group_E_dispatch_table
     .db cmd_read_test_reg - group_E_dispatch_table
     .db cmd_E9 - group_E_dispatch_table
     .db cmd_EA - group_E_dispatch_table
     .db cmd_EB - group_E_dispatch_table
     .db cmd_EC - group_E_dispatch_table
     .db cmd_ED - group_E_dispatch_table
     .db cmd_EE - group_E_dispatch_table
     .db cmd_EF - group_E_dispatch_table

; 10h: command E5, E6, E7, E9, EA, EB, EC, ED, EE, EF
cmd_E5:
cmd_E6:
cmd_E7:
cmd_E9:
cmd_EA:
cmd_EB:
cmd_EC:
cmd_ED:
cmd_EE:
cmd_EF:
    ljmp	cmdg_e_exit
	
; 13h: command E0 (undocumented)
cmd_invert_bits:
	lcall	dsp_input_data
    cpl	a
    lcall	dsp_output_data
    ljmp	cmdg_e_exit
	
; 1dh: command E8 (undocumented)
cmd_read_test_reg:
	mov	a,2ah
    lcall	dsp_output_data
    ljmp	cmdg_e_exit
	
; 25h: command E4 (undocumented)
cmd_write_test_reg:
	lcall	dsp_input_data
    mov	2ah,a
    ljmp	cmdg_e_exit
	
; 2dh: command E2 (undocumented)
cmd_dsp_dma_id:
	mov	rb1r2,#3
    lcall	X1317
    lcall	dsp_input_data
    xrl	a,26h
    add	a,25h
    mov	25h,a
    mov	a,26h
    rr	a
    rr	a
    mov	26h,a
    mov	a,25h
    mov	r0,#1dh
    movx	@r0,a
    clr	2fh.0
    setb	p1.5
    clr	p1.5
    mov	r0,#5
    movx	a,@r0
    setb	acc.5
    movx	@r0,a
    clr	acc.5
    movx	@r0,a
X11dd:
	jb	pin_dav_pc,X11dd
    nop	
    setb	2fh.0
    ljmp	cmdg_e_exit

; 56h: command E1
cmd_dsp_version:
	mov	dptr,#dspver
    clr	a
    movc	a,@a+dptr
X11eb:
	jb	pin_dav_pc,X11eb
    mov	r0,#0
    nop	
    nop	
    movx	@r0,a
    mov	a,#1
    movc	a,@a+dptr
X11f6:
	jb	pin_dav_pc,X11f6
    mov	r0,#0
    nop	
    nop	
    movx	@r0,a
    ljmp	cmdg_e_exit
	
; 71h: command E3 (undocumented)
cmd_dsp_copyright:
	mov	dptr,#copyright_string
    clr	a
X1205:
	mov	b,a
    movc	a,@a+dptr
    lcall	dsp_output_data
    jz	cmdg_e_exit
    mov	a,b
    inc	a
    sjmp	X1205
;
cmdg_e_exit:
	clr	pin_dsp_busy
    push	acc
    mov	r0,#5
    movx	a,@r0
    clr	acc.6
    movx	@r0,a
    pop	acc
    ljmp	wait_for_cmd
;
X1221:
	mov	a,r6
    rlc	a
    jc	X124c
    rlc	a
    mov	r6,a
    mov	a,r5
    jc	X1239
    rrc	a
    mov	r5,a
    jnz	X1231
    inc	r5
    sjmp	X1273
;
X1231:
    add	a,r2
    jnc	X1236
    mov	a,#0ffh
X1236:
	mov	r2,a
    sjmp	X1273
;
X1239:
	clr	c
    rrc	a
    add	a,r5
    add	a,r2
    jnc	X1241
    mov	a,#0ffh
X1241:
	mov	r2,a
    cjne	r5,#20h,X1247
    sjmp	X1273
;
X1247:
	mov	a,r5
    add	a,r5
    mov	r5,a
    sjmp	X1273
;
X124c:
	rlc	a
    mov	r6,a
    mov	a,r5
    jc	X1261
    rrc	a
    mov	r5,a
    jnz	X1258
    inc	r5
    sjmp	X1273
;
X1258:
	xch	a,r2
    clr	c
    subb	a,r2
    jnc	X125e
    clr	a
X125e:
	mov	r2,a
    sjmp	X1273
;
X1261:
	clr	c
    rrc	a
    add	a,r5
    xch	a,r2
    clr	c
    subb	a,r2
    jnc	X126a
    clr	a
X126a:
	mov	r2,a
    cjne	r5,#20h,X1270
    sjmp	X1273
;
X1270:
	mov	a,r5
    add	a,r5
    mov	r5,a
X1273:
	mov	a,r2
    mov	r0,#19h
    movx	@r0,a
    ret	
;
X1278:
	mov	a,r5
    clr	c
    rrc	a
    mov	27h,a
    mov	a,r6
    mov	rb2r0,a
    swap	a
    mov	r6,a
    anl	a,#7
    mov	28h,a
    mov	b,r5
    mul	ab
    add	a,27h
    mov	29h,a
    mov	a,rb2r0
    rlc	a
    jc	X129c
    mov	a,29h
    add	a,r2
    jnc	X12a3
    mov	a,#0ffh
    ljmp	X12a3
;
X129c:
	mov	a,r2
    clr	c
    subb	a,29h
    jnc	X12a3
    clr	a
X12a3:
	mov	r2,a
    mov	a,28h
    jz	X12b7
    clr	c
    subb	a,#5
    jc	X12be
    mov	a,r5
    rl	a
    cjne	a,#10h,X12bd
    mov	a,#8
    ljmp	X12bd
;
X12b7:
	mov	a,27h
    jnz	X12bd
    mov	a,#1
X12bd:
	mov	r5,a
X12be:
	mov	a,r2
    mov	r0,#19h
    movx	@r0,a
    ret	
;
X12c3:
	mov	a,r5
    clr	c
    rrc	a
    mov	27h,a
    mov	a,r6
    mov	rb2r0,a
    rl	a
    rl	a
    cjne	r3,#1,X12d5
    anl	a,#1
    ljmp	X12d6
;
X12d5:
	rl	a
X12d6:
	mov	r6,a
    anl	a,#3
    mov	28h,a
    mov	b,r5
    mul	ab
    add	a,27h
    mov	29h,a
    mov	a,rb2r0
    rlc	a
    jc	X12f1
    mov	a,29h
    add	a,r2
    jnc	X12f8
    mov	a,#0ffh
    ljmp	X12f8
;
X12f1:
	mov	a,r2
    clr	c
    subb	a,29h
    jnc	X12f8
    clr	a
X12f8:
	mov	r2,a
    mov	a,28h
    jz	X130b
    cjne	a,#3,X1312
    cjne	r5,#10h,X1306
    ljmp	X1312
;
X1306:
	mov	a,r5
    rl	a
    ljmp	X1311
;
X130b:
	mov	a,27h
    jnz	X1311
    mov	a,#1
X1311:
	mov	r5,a
X1312:
	mov	a,r2
    mov	r0,#19h
    movx	@r0,a
    ret	
;
X1317:
	push	acc
    mov	r0,#4
    movx	a,@r0
    anl	a,#0f0h
    orl	a,rb1r2
    mov	rb1r2,a
    movx	@r0,a
    pop	acc
    ret	
;
X1326:
	mov	r0,#0eh
    mov	a,#7
    movx	@r0,a
    mov	a,#4
    movx	@r0,a
    ret	
;
dsp_input_data:
	jnb	pin_dav_dsp,dsp_input_data
    mov	r0,#0
    nop	
    nop	
    movx	a,@r0
    ret	
;
dsp_output_data:
	jb	pin_dav_pc,dsp_output_data
    mov	r0,#0
    nop	
    nop	
    movx	@r0,a
    ret	
;
X1341:
	mov	r0,#0eh
    mov	a,#7
    movx	@r0,a
    mov	a,#6
    movx	@r0,a
    ret	
;
X134a:
	mov	r0,#16h
    mov	a,#7
    movx	@r0,a
    mov	a,#6
    movx	@r0,a
    ret	
;
X1353:
	mov	r0,#0eh
    mov	a,#3
    movx	@r0,a
    mov	a,#2
    movx	@r0,a
    ret	
;
X135c:
	mov	r0,#16h
    mov	a,#3
    movx	@r0,a
    mov	a,#2
    movx	@r0,a
    ret	
;
X1365:
	mov	a,#0
    mov	r0,#80h
    movx	@r0,a
    mov	r0,#81h
    movx	@r0,a
    mov	len_left_lo,#0bbh
    mov	len_left_hi,#3
    mov	a,#8ch
    mov	r0,#82h
    movx	@r0,a
    mov	a,#8ah
    mov	r0,#82h
    movx	@r0,a
    mov	dptr,#asp_code
X1380:
	mov	a,#0
    movc	a,@a+dptr
    mov	r0,#83h
    movx	@r0,a
    cjne	a,len_left_lo,X139b
    cjne	a,len_left_hi,X1399
    mov	a,#0
    mov	r0,#82h
    movx	@r0,a
    mov	a,#70h
    mov	r0,#82h
    movx	@r0,a
    ljmp	X13a0
;
X1399:
	dec	len_left_hi
X139b:
	dec	len_left_lo
    inc	dptr
    sjmp	X1380
;
X13a0:
	ret	
;

asp_code:	
	.db	4,20h,0,44h,8,0,0,44h
    .db	0,60h,0,44h,0ch,60h,0,44h
    .db	0,1,0,45h,0,3,0,45h
    .db	0ffh,2eh,21h,49h,0ffh,0bh,0d4h,49h
    .db	40h,4bh,39h,0ach,0,4,71h,8bh
    .db	0c0h,0,4,19h,0c2h,0,4,19h
    .db	0,0,0b9h,3eh,0,0bh,0f9h,7eh
    .db	0,0,0f9h,3eh,14h,5ah,71h,8bh
    .db	0a8h,1,0,80h,0ffh,0fbh,71h,8bh
    .db	88h,5,61h,80h,88h,7,0b1h,80h
    .db	88h,7,23h,80h,88h,3,0e9h,80h
    .db	88h,1,0,80h,88h,3,0b1h,80h
    .db	80h,1,0,80h,27h,0,71h,8bh
    .db	0c0h,40h,4,19h,0ach,0,71h,8bh
    .db	0c2h,40h,4,19h,55h,55h,71h,8bh
    .db	20h,5,61h,80h,44h,4,4,39h
    .db	0,40h,0,14h,51h,0,71h,8bh
    .db	0ffh,0bh,0f4h,49h,0ch,40h,0,44h
    .db	0,40h,61h,0ah,90h,40h,9,8fh
    .db	0,1,0,45h,2,40h,61h,0ah
    .db	0,0,9,8fh,0,1,0,45h
    .db	0,0,9,3eh,0,5,63h,0a1h
    .db	50h,7,0a3h,80h,30h,0,61h,88h
    .db	4,0c0h,4,54h,0,1,33h,80h
    .db	0d0h,1,0,82h,0ch,0b0h,0,44h
    .db	0,0ffh,0c2h,8bh,20h,0,0,80h
    .db	0,55h,42h,8bh,0,0,0,0c4h
    .db	0,4,42h,8bh,0,0b1h,0,0c4h
    .db	0,24h,42h,8bh,8,72h,0,0c4h
    .db	0,14h,42h,8bh,8,22h,0,0c4h
    .db	0,34h,42h,8bh,4,61h,0,0c4h
    .db	0,84h,42h,8bh,8,41h,0,0c4h
    .db	0,0ch,42h,8bh,4,0c2h,0,0c4h
    .db	0,2ch,42h,8bh,0,1,0,0c4h
    .db	8,40h,0,44h,0,0,9,4fh
    .db	0f7h,0a3h,9,5ch,0,1,0b1h,80h
    .db	0aah,0aah,51h,8bh,20h,4,61h,80h
    .db	0e0h,7,0e9h,82h,0,1,42h,80h
    .db	20h,0,7ah,80h,0e0h,7,0e9h,82h
    .db	2,1,42h,80h,20h,0,7ah,80h
    .db	0,0,9,3eh,0fbh,0a0h,9,5ch
    .db	0a0h,7,0e9h,80h,0,1,42h,82h
    .db	20h,0,7ah,80h,0a0h,7,0e9h,80h
    .db	8,1,42h,82h,20h,0,7ah,80h
    .db	0,0,9,0cfh,0ffh,0a0h,9,5ch
    .db	60h,7,0e9h,80h,0,1,42h,0c0h
    .db	20h,0,7ah,80h,60h,7,0e9h,80h
    .db	0,21h,42h,0c0h,20h,0,7ah,80h
    .db	0,20h,9,0cfh,0ffh,0a0h,9,5ch
    .db	60h,7,0e9h,80h,0,1,42h,0c0h
    .db	20h,0,7ah,80h,60h,7,0e9h,80h
    .db	0,21h,42h,0c0h,20h,0,7ah,80h
    .db	4,52h,0,84h,0,1,0a3h,0a0h
    .db	50h,1,0b1h,80h,0ffh,8,0f4h,49h
    .db	0,72h,0,44h,0,22h,9,8eh
    .db	0ffh,20h,9,5ch,0,1,0e1h,0c0h
    .db	40h,21h,0,80h,0ch,0b0h,0,44h
    .db	0,22h,9,8eh,20h,0,51h,8bh
    .db	80h,0,0,80h,20h,1,0,80h
    .db	0ffh,0,0e2h,8bh,50h,3,0,80h
    .db	20h,5,61h,80h,0cbh,0,71h,8bh
    .db	0ffh,8,0f4h,49h,0ch,0d2h,0,44h
    .db	20h,3,41h,0a0h,40h,24h,60h,82h
    .db	8,40h,4,54h,4,0d2h,0,44h
    .db	0,22h,9,8eh,20h,0,51h,8bh
    .db	80h,0,0,80h,20h,1,0,80h
    .db	0ffh,0,0e2h,8bh,50h,3,0,80h
    .db	80h,1,0,80h,54h,0,71h,8bh
    .db	0ffh,8,0f4h,49h,8,11h,0,44h
    .db	0ch,11h,4,4,0,21h,71h,0c0h
    .db	70h,1,0a3h,80h,26h,0,51h,8bh
    .db	20h,4,61h,80h,0ffh,4,0f4h,49h
    .db	0,81h,0,44h,50h,1,0,80h
    .db	96h,0,51h,8bh,20h,4,61h,80h
    .db	0ffh,4,0f4h,49h,8,0a1h,0,44h
    .db	20h,0,60h,1bh,80h,1,0,80h
    .db	4,91h,4,54h,0ch,11h,0,44h
    .db	0,5,0a3h,0a0h,0ch,0b0h,0,44h
    .db	0e5h,0,51h,8bh,0c0h,40h,0,39h
    .db	47h,0,71h,8bh,0c2h,40h,0,39h
    .db	0ch,0b0h,0,44h,17h,0,51h,8bh
    .db	0c0h,40h,0,39h,9ch,0,71h,8bh
    .db	0c2h,40h,0,39h,0ch,0b0h,0,44h
    .db	0e5h,0,51h,8bh,0c0h,40h,0,39h
    .db	0aeh,0,71h,8bh,0c2h,40h,0,39h
    .db	0bh,0,71h,8bh,83h,0,4,19h
    .db	0ch,0b0h,0,44h,9,4,61h,0a8h
    .db	40h,0,4,19h,0bh,4,61h,0a8h
    .db	42h,0,4,19h,8,40h,0,44h
    .db	8,40h,0,0d4h,9,4,61h,0a8h
    .db	40h,4,4,19h,0bh,4,61h,0a8h
    .db	42h,4,4,19h,8,40h,0,44h
    .db	0,0,9,0fh,0,0,61h,0a8h
    .db	22h,0c1h,0,80h,0,0,0ch,39h
    .db	0,1,65h,80h,0c1h,40h,4,19h
    .db	48h,4,4,19h,2,0,61h,0a8h
    .db	23h,0c1h,0,80h,0,0,0ch,39h
    .db	0,1,65h,80h,0c3h,40h,4,19h
    .db	4ah,4,4,19h,8,40h,0,44h
    .db	8,53h,4,0d4h,0,0,9,0fh
    .db	1,4,61h,0a8h,22h,0c1h,0,80h
    .db	0,0,0ch,39h,0,1,65h,80h
    .db	0c1h,40h,4,19h,48h,4,4,19h
    .db	3,4,61h,0a8h,23h,0c1h,0,80h
    .db	0,0,0ch,39h,0,1,65h,80h
    .db	0c3h,40h,4,19h,4ah,4,4,19h
    .db	8,40h,0,44h,0,0,9,0fh
    .db	0,0,0b9h,3eh,0,0bh,0f8h,7eh
    .db	3,0,61h,18h,0a0h,0,0,88h
    .db	8,1,61h,10h,22h,0c1h,0,80h
    .db	0,0,0ch,39h,0,1,65h,80h
    .db	0c1h,40h,4,19h,48h,4,4,19h
    .db	8,1,61h,10h,83h,0,4,9
    .db	23h,0c1h,0,80h,0,0,0ch,39h
    .db	0,1,65h,80h,0c3h,40h,4,19h
    .db	4ah,4,4,19h,10h,0,9,49h
    .db	8,40h,0,44h,1,40h,61h,0ah
    .db	48h,4,4,19h,3,40h,61h,0ah
    .db	4ah,4,4,19h,8,40h,0,44h
    .db	0e1h,0fbh,55h,55h


;
; Copyright notice
copyright_string:	
	.db	43h,4fh,50h,59h,52h,49h,47h,48h
    .db	54h,20h,28h,43h,29h,20h,43h,52h
    .db	45h,41h,54h,49h,56h,45h,20h,54h
    .db	45h,43h,48h,4eh,4fh,4ch,4fh,47h
    .db	59h,20h,4ch,54h,44h,2ch,20h,31h
    .db	39h,39h,32h,2eh,0


;
; Stored DSP version number
dspver:	
	.db	4,0dh


;
unused:	
	.db	67h,12h,7fh,8ch,98h,0a4h,0b0h,0bbh
    .db	0c6h,0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h
    .db	0fch,0feh,0ffh,0feh,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,80h,8ch,98h
    .db	0a4h,0b0h,0bbh,0c6h,0d0h,0d9h,0e2h,0e9h
    .db	0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,7fh,73h,67h
    .db	5bh,4fh,44h,39h,2fh,26h,1dh,16h
    .db	0fh,0ah,6,3,1,1,1,3
    .db	6,0ah,0fh,16h,1dh,26h,2fh,39h
    .db	44h,4fh,5bh,67h,73h,80h,8ch,98h
    .db	0a4h,0b0h,0bbh,0c6h,0d0h,0d9h,0e2h,0e9h
    .db	0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,46h,4bh,50h
    .db	4dh,52h,5eh,66h,64h,6eh,7ch,88h
    .db	80h,8dh,8fh,8ch,76h,78h,80h,82h
    .db	7dh,87h,8eh,90h,94h,0a2h,0bah,0c1h
    .db	0c2h,0c5h,0c4h,7fh,73h,67h,5bh,4fh
    .db	44h,39h,2fh,26h,1dh,16h,0fh,0ah
    .db	6,3,1,1,1,3,6,4ch
    .db	0b0h,0aeh,0b0h,0b2h,9eh,9ch,9bh,9ch
    .db	0a4h,0b0h,7fh,73h,67h,5bh,4fh,44h
    .db	39h,2fh,26h,1dh,0bch,0b8h,0b0h,0b2h
    .db	9dh,98h,91h,70h,6ah,69h,68h,6eh
    .db	78h,82h,80h,7ah,7eh,80h,78h,78h
    .db	6eh,50h,4ch,49h,0fch,0f9h,0f5h,0f0h
    .db	0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h
    .db	98h,8ch,7fh,73h,67h,5bh,4fh,44h
    .db	39h,2fh,26h,1dh,16h,0fh,0ah,6
    .db	3,1,1,1,3,6,0d9h,0e2h
    .db	0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh
    .db	0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h
    .db	0c6h,0bbh,0b0h,0a4h,98h,8ch,46h,4bh
    .db	50h,4dh,52h,5eh,66h,64h,6eh,7ch
    .db	88h,80h,8dh,8fh,8ch,76h,78h,80h
    .db	82h,7dh,7fh,73h,67h,5bh,4fh,44h
    .db	39h,2fh,26h,1dh,87h,8eh,90h,94h
    .db	0a2h,0bah,0c1h,0c2h,0c5h,0c4h,50h,46h
    .db	4bh,50h,4dh,52h,5eh,66h,64h,6eh
    .db	7ch,68h,6eh,78h,82h,80h,7ah,7eh
    .db	80h,78h,78h,6eh,50h,4ch,49h,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,7fh,73h,67h
    .db	5bh,4fh,44h,39h,2fh,26h,1dh,16h
    .db	0fh,0ah,6,3,1,1,1,3
    .db	6,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch
    .db	0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h,0e9h
    .db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h
    .db	8ch,46h,4bh,50h,4dh,52h,5eh,66h
    .db	64h,6eh,7ch,88h,80h,8dh,8fh,8ch
    .db	76h,78h,80h,82h,7dh,98h,8ch,80h
    .db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,98h,8ch,80h,8ch,98h,0a4h,0b0h
    .db	0bbh,0c6h,0d0h,0d9h,0e2h,0e9h,0f0h,0f5h
    .db	0f9h,0fch,0feh,0ffh,0feh,87h,8eh,90h
    .db	94h,0a2h,0bah,0c1h,0c2h,0c5h,0c4h,98h
    .db	8ch,80h,8ch,98h,0a4h,0b0h,0bbh,0c6h
    .db	0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch
    .db	0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h,0e9h
    .db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h
    .db	8ch,7fh,73h,67h,5bh,4fh,44h,39h
    .db	2fh,26h,1dh,16h,0fh,0ah,6,3
    .db	1,1,1,3,6,0ah,0fh,16h
    .db	1dh,26h,2fh,39h,44h,4fh,5bh,67h
    .db	73h,80h,8ch,98h,0a4h,0b0h,0bbh,0c6h
    .db	0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch
    .db	0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h,0e9h
    .db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h
    .db	8ch,46h,4bh,50h,4dh,52h,5eh,66h
    .db	64h,6eh,7ch,88h,80h,8dh,8fh,8ch
    .db	76h,78h,80h,82h,7dh,87h,8eh,90h
    .db	94h,0a2h,0bah,0c1h,0c2h,0c5h,0c4h,0b0h
    .db	0aeh,0b0h,0b2h,9eh,9ch,9bh,9ch,0a4h
    .db	0b0h,0bch,0b8h,0b0h,0b2h,9dh,98h,91h
    .db	70h,6ah,69h,68h,6eh,78h,82h,80h
    .db	7ah,7eh,80h,78h,78h,6eh,50h,4ch
    .db	49h,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,7fh
    .db	73h,67h,5bh,4fh,44h,39h,2fh,26h
    .db	1dh,16h,0fh,0ah,6,3,1,1
    .db	1,3,6,0d9h,0e2h,0e9h,0f0h,0f5h
    .db	0f9h,0fch,0feh,0ffh,0feh,0fch,0f9h,0f5h
    .db	0f0h,0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h
    .db	0a4h,98h,8ch,46h,4bh,50h,4dh,52h
    .db	5eh,66h,64h,6eh,7ch,88h,80h,8dh
    .db	8fh,8ch,76h,78h,80h,82h,7dh,87h
    .db	8eh,90h,94h,0a2h,0bah,0c1h,0c2h,0c5h
    .db	0c4h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,80h
    .db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,7fh
    .db	73h,67h,5bh,4fh,44h,39h,2fh,26h
    .db	1dh,16h,0fh,0ah,6,3,1,1
    .db	1,3,6,0ah,0fh,16h,1dh,26h
    .db	2fh,39h,44h,4fh,5bh,67h,73h,80h
    .db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,46h
    .db	4bh,50h,4dh,52h,5eh,66h,64h,6eh
    .db	7ch,88h,80h,8dh,8fh,8ch,76h,78h
    .db	80h,82h,7dh,87h,8eh,90h,94h,0a2h
    .db	0bah,0c1h,0c2h,0c5h,0c4h,0b0h,0aeh,0b0h
    .db	0b2h,9eh,9ch,9bh,9ch,0a4h,0b0h,0bch
    .db	0b8h,0b0h,0b2h,9dh,98h,91h,70h,6ah
    .db	69h,68h,6eh,78h,82h,80h,7ah,7eh
    .db	80h,78h,78h,6eh,50h,4ch,49h,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,7fh,73h,67h
    .db	5bh,4fh,44h,39h,2fh,26h,1dh,16h
    .db	0fh,0ah,6,3,1,1,1,3
    .db	6,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch
    .db	0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h,0e9h
    .db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h
    .db	8ch,46h,4bh,50h,4dh,52h,5eh,66h
    .db	64h,6eh,7ch,88h,80h,8dh,8fh,8ch
    .db	76h,78h,80h,82h,7dh,98h,8ch,80h
    .db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,98h,8ch,80h,8ch,98h,0a4h,0b0h
    .db	0bbh,0c6h,0d0h,0d9h,0e2h,0e9h,0f0h,0f5h
    .db	0f9h,0fch,0feh,0ffh,0feh,87h,8eh,90h
    .db	94h,0a2h,0bah,0c1h,0c2h,0c5h,0c4h,0b0h
    .db	0aeh,0b0h,0b2h,9eh,9ch,9bh,9ch,0a4h
    .db	0b0h,0bch,0b8h,0b0h,0b2h,9dh,98h,91h
    .db	70h,6ah,69h,68h,6eh,78h,82h,80h
    .db	7ah,7eh,80h,78h,78h,6eh,50h,4ch
    .db	49h,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,7fh
    .db	73h,67h,5bh,4fh,44h,39h,2fh,26h
    .db	1dh,16h,0fh,0ah,6,3,1,1
    .db	1,3,6,0d9h,0e2h,0e9h,0f0h,0f5h
    .db	0f9h,0fch,0feh,0ffh,0feh,0fch,0f9h,0f5h
    .db	0f0h,0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h
    .db	0a4h,98h,8ch,46h,4bh,50h,4dh,52h
    .db	5eh,66h,64h,6eh,7ch,88h,80h,8dh
    .db	8fh,8ch,76h,78h,80h,82h,7dh,98h
    .db	8ch,80h,8ch,98h,0a4h,0b0h,0bbh,0c6h
    .db	0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch
    .db	0feh,0ffh,0feh,98h,8ch,80h,8ch,98h
    .db	0a4h,0b0h,0bbh,0c6h,0d0h,0d9h,0e2h,0e9h
    .db	0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh,87h
    .db	8eh,90h,94h,0a2h,0bah,0c1h,0c2h,0c5h
    .db	0c4h,0b0h,0aeh,0b0h,0b2h,9eh,9ch,9bh
    .db	9ch,0a4h,0b0h,0bch,0b8h,0b0h,0b2h,9dh
    .db	98h,91h,70h,6ah,69h,68h,6eh,78h
    .db	82h,80h,7ah,7eh,80h,78h,78h,6eh
    .db	50h,4ch,49h,0fch,0f9h,0f5h,0f0h,0e9h
    .db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h
    .db	8ch,7fh,73h,67h,5bh,4fh,44h,39h
    .db	2fh,26h,1dh,16h,0fh,0ah,6,3
    .db	1,1,1,3,6,0d9h,0e2h,0e9h
    .db	0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,46h,4bh,50h
    .db	4dh,52h,5eh,66h,64h,6eh,7ch,88h
    .db	80h,8dh,8fh,8ch,76h,78h,80h,82h
    .db	7dh,87h,8eh,90h,94h,0a2h,0bah,0c1h
    .db	0c2h,0c5h,0c4h,0e9h,0f0h,0f5h,0f9h,0fch
    .db	0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h,0e9h
    .db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,7fh
    .db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,80h
    .db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,7fh
    .db	73h,67h,5bh,4fh,44h,39h,2fh,26h
    .db	1dh,16h,0fh,0ah,6,3,1,1
    .db	1,3,6,0ah,0fh,16h,1dh,26h
    .db	2fh,39h,44h,4fh,5bh,67h,73h,80h
    .db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,46h
    .db	4bh,50h,4dh,52h,5eh,66h,64h,6eh
    .db	7ch,88h,80h,8dh,8fh,8ch,76h,78h
    .db	80h,82h,7dh,87h,8eh,90h,94h,0a2h
    .db	0bah,0c1h,0c2h,0c5h,0c4h,0b0h,0aeh,0b0h
    .db	0b2h,9eh,9ch,9bh,9ch,0a4h,0b0h,0bch
    .db	0b8h,0b0h,0b2h,9dh,98h,91h,70h,6ah
    .db	69h,68h,6eh,78h,82h,80h,7ah,7eh
    .db	80h,78h,78h,6eh,50h,4ch,49h,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,7fh,73h,67h
    .db	5bh,4fh,44h,39h,2fh,26h,1dh,16h
    .db	0fh,0ah,6,3,1,1,1,3
    .db	6,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch
    .db	0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h,0e9h
    .db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h
    .db	8ch,46h,4bh,50h,4dh,52h,5eh,66h
    .db	64h,6eh,7ch,88h,80h,8dh,8fh,8ch
    .db	76h,78h,80h,82h,7dh,87h,8eh,90h
    .db	94h,0a2h,0bah,0c1h,0c2h,0c5h,0c4h,0e9h
    .db	0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,80h,8ch,98h
    .db	0a4h,0b0h,0bbh,0c6h,0d0h,0d9h,0e2h,0e9h
    .db	0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,7fh,73h,67h
    .db	5bh,4fh,44h,39h,2fh,26h,1dh,16h
    .db	0fh,0ah,6,3,1,1,1,3
    .db	6,0ah,0fh,16h,1dh,26h,2fh,39h
    .db	44h,4fh,5bh,67h,73h,80h,8ch,98h
    .db	0a4h,0b0h,0bbh,0c6h,0d0h,0d9h,0e2h,0e9h
    .db	0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,46h,4bh,50h
    .db	4dh,52h,5eh,66h,64h,6eh,7ch,88h
    .db	80h,8dh,8fh,8ch,76h,78h,80h,82h
    .db	7dh,87h,8eh,90h,94h,0a2h,0bah,0c1h
    .db	0c2h,0c5h,0c4h,0b0h,0aeh,0b0h,0b2h,9eh
    .db	9ch,9bh,9ch,0a4h,0b0h,0bch,0b8h,0b0h
    .db	0b2h,9dh,98h,91h,70h,6ah,69h,68h
    .db	6eh,78h,82h,80h,7ah,7eh,80h,78h
    .db	78h,6eh,50h,4ch,49h,0fch,0f9h,0f5h
    .db	0f0h,0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h
    .db	0a4h,98h,8ch,7fh,73h,67h,5bh,4fh
    .db	44h,39h,2fh,26h,1dh,16h,0fh,0ah
    .db	6,3,1,1,1,3,6,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,46h
    .db	4bh,50h,4dh,52h,5eh,66h,64h,6eh
    .db	7ch,88h,80h,8dh,8fh,8ch,76h,78h
    .db	80h,82h,7dh,98h,8ch,80h,8ch,98h
    .db	0a4h,0b0h,0bbh,0c6h,0d0h,0d9h,0e2h,0e9h
    .db	0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh,98h
    .db	8ch,80h,8ch,98h,0a4h,0b0h,0bbh,0c6h
    .db	0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch
    .db	0feh,0ffh,0feh,87h,8eh,90h,94h,0a2h
    .db	0bah,0c1h,0c2h,0c5h,0c4h,98h,8ch,80h
    .db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,7fh
    .db	73h,67h,5bh,4fh,44h,39h,2fh,26h
    .db	1dh,16h,0fh,0ah,6,3,1,1
    .db	1,3,6,0ah,0fh,16h,1dh,26h
    .db	2fh,39h,44h,4fh,5bh,67h,73h,80h
    .db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
    .db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
    .db	0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h,0d9h
    .db	0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch,46h
    .db	4bh,50h,4dh,52h,5eh,66h,64h,6eh
    .db	7ch,88h,80h,8dh,8fh,8ch,76h,78h
    .db	80h,82h,7dh,87h,8eh,90h,94h,0a2h
    .db	0bah,0c1h,0c2h,0c5h,0c4h,0b0h,0aeh,0b0h
    .db	0b2h,9eh,9ch,9bh,9ch,0a4h,0b0h,0bch
    .db	0b8h,0b0h,0b2h,9dh,98h,91h,70h,6ah
    .db	69h,68h,6eh,78h,82h,80h,7ah,7eh
    .db	80h,78h,78h,6eh,50h,4ch,49h,0fch
    .db	0f9h,0f5h,0f0h,0e9h,0e2h,0d9h,0d0h,0c6h
    .db	0bbh,0b0h,0a4h,98h,8ch,7fh,73h,67h
    .db	5bh,4fh,44h,39h,2fh,26h,1dh,16h
    .db	0fh,0ah,6,3,1,1,1,3
    .db	6,16h,0fh,0ah,6,3,1,1
    .db	1,3,6,7fh,73h,67h,5bh,4fh
    .db	44h,39h,2fh,26h,1dh,0ah,0fh,16h
    .db	1dh,26h,2fh,39h,44h,4fh,5bh,0b0h
	.db	0b2h,9dh,98h,91h,70h,6ah,69h
	