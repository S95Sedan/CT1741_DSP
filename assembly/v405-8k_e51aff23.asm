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
.EQU length_low, 11h
.EQU length_high, 12h
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
; SFR bit Equates
; ------------------------------
.EQU csp_pin_1, 80h
.EQU csp_pin_2, 81h
.EQU csp_pin_3, 82h
.EQU csp_pin_4, 83h
.EQU pin_dav_pc, 90h
.EQU pin_dav_dsp, 91h
.EQU pin_dsp_busy, 92h
.EQU pin_drequest, 95h
.EQU pin_dma_emable1, 0a5h

; ------------------------------
; Memory bit Equates
; ------------------------------
.EQU command_byte_0, 0
.EQU command_byte_1, 1
.EQU command_byte_2, 2
.EQU command_byte_3, 3
.EQU pin_mute_en, 1ch
.EQU cmd_avail, 20h
.EQU dma_mode_on, 21h
.EQU dma_8bit_mode, 22h
.EQU dma_16bit_mode, 24h
.EQU midi_timestamp, 25h
;

		.org	0
;
RESET:
		ljmp	start
;
int0_vector:
		ljmp	int0_handler
;
		.db		66h,46h,56h,66h,46h
;
timer0_vector:
		ljmp	timer0_handler
;
		.db		66h,46h,66h,56h,56h
;
int1_vector:
		ljmp	int1_handler

; ------------------------------
; Timer/Counter 0 Interrupt Vector
; ------------------------------
int0_handler:
		setb	pin_dsp_busy
		push	acc
		push	dpl
		push	dph
		push	rb0r0
		mov		dptr,#int0_table
		mov		a,rb1r3
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr
;
int0_table:
		.db		1eh,0fh,12h,15h,18h,1bh,1eh,1eh
		.db		1eh,1eh,1eh,1eh,1eh,1eh,1eh

; ------------------------------
; 0fh: DAC playback of silence.
int0_dac_silence:
	ljmp	vector_dac_silence
; ------------------------------
; 12h: DAC playback, 2-bit ADPCM
int0_dma_dac_adpcm2:
	ljmp	vector_dma_dac_adpcm2
; ------------------------------
; 15h: DAC playback, 2.6-bit ADPCM
int0_dma_dac_adpcm4:
	ljmp	vector_dma_dac_adpcm2_6
; ------------------------------
; 18h: DAC playback, 4-bit ADPCM
int0_dma_dac_adpcm2_6:
	ljmp	vector_dma_dac_adpcm4
; ------------------------------
; 1bh: ?
int0_op5_vector:
	ljmp	int0_op5_handler

; ------------------------------
; 1eh: no command
int0_op_none_handler:
		clr		pin_dsp_busy
		pop		rb0r0
		pop		dph
		pop		dpl
		pop		acc
		reti	

; ------------------------------
; 8bit/16-bit DMA Initialization?
; ------------------------------
int1_handler:
		clr		pin_dsp_busy
		push	acc
		push	dpl
		push	dph
		push	rb0r0
		mov		r0,#6
		movx	a,@r0
		jnb		acc.0,X0065
		lcall	vector_dma8_playback
X0065:	mov		r0,#6
		movx	a,@r0
		jnb		acc.1,X006e
		lcall	vector_dma16_playback
X006e:	pop		rb0r0
		pop		dph
		pop		dpl
		pop		acc
		reti	

; ------------------------------
; Midi Handler?
; ------------------------------
timer0_handler:
		jb		midi_timestamp,midi_timestamp_int
		jnb		23h.6,X0086
		mov		tl0,rb3r1
		mov		th0,rb3r2
		ljmp	X008a

X0086:	clr		et0
		clr		tr0
X008a:	clr		p1.7
		setb	p1.7
		reti	

; ------------------------------
; Handles MIDI timestamp counter.
; ------------------------------
midi_timestamp_int:
		inc		r5
		cjne	r5,#0,X0098
		inc		r6
		cjne	r6,#0,X0098
		inc		r7
X0098:	mov		tl0,#2fh
		mov		th0,#0f8h
		reti	

; ------------------------------
; Vector for 8-bit DMA Playback?
; ------------------------------
vector_dma8_playback:
		jb		dma_mode_on,X00f4
		jnb		dma_8bit_mode,X00bd
		mov		r0,#7
X00a7:	jb		pin_dav_dsp,X00ae
		movx	a,@r0
		jb		acc.0,X00a7
X00ae:	mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	X010e

X00bd:	mov		r0,#8
		movx	a,@r0
		anl		a,#0e7h
		orl		a,#2
		movx	@r0,a
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		lcall	X09f8
		mov		r0,#6
		setb	pin_dma_emable1
		mov		warmboot_magic1,#0
		mov		warmboot_magic2,#0
		jnb		23h.1,X00e9
		lcall	X117f
		clr		23h.1
		ljmp	vector_dma8_playback_end

X00e9:	jnb		23h.0,vector_dma8_playback_end
		lcall	X1176
		clr		23h.0
		ljmp	vector_dma8_playback_end

X00f4:	clr		dma_8bit_mode
		clr		dma_mode_on
		mov		a,length_low
		mov		r0,#0bh
		movx	@r0,a
		mov		a,length_high
		mov		r0,#0ch
		movx	@r0,a
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
X010e:	mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
vector_dma8_playback_end:
		ret	

; ------------------------------
; Vector for 16-bit DMA Playback?
; ------------------------------
vector_dma16_playback:
		jb		24h.3,X0164
		jnb		dma_16bit_mode,X0134
		mov		r0,#7
X011f:	jb		pin_dav_dsp,X0126
		movx	a,@r0
		jb		acc.1,X011f
X0126:	mov		r0,#10h
		movx	a,@r0
		anl		a,#0
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	X017d

X0134:	mov		r0,#10h
		movx	a,@r0
		anl		a,#0e7h
		orl		a,#2
		movx	@r0,a
		mov		r0,#10h
		movx	a,@r0
		anl		a,#0
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		lcall	X09f8
		mov		r0,#6
		setb	p2.4
		jnb		23h.3,X0159
		lcall	X117f
		clr		23h.3
		ljmp	vector_dma16_playback_end

X0159:	jnb		23h.2,vector_dma16_playback_end
		lcall	X1176
		clr		23h.2
		ljmp	vector_dma16_playback_end

X0164:	clr		dma_16bit_mode
		clr		24h.3
		mov		a,rb2r5
		mov		r0,#13h
		movx	@r0,a
		mov		a,rb2r6
		mov		r0,#14h
		movx	@r0,a
		mov		r0,#10h
		movx	a,@r0
		anl		a,#0
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
X017d:	mov		r0,#10h
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
vector_dma16_playback_end:
		ret	

; ------------------------------
; Vector for DAC playback, 2-bit ADPCM
; ------------------------------
; Register use:
; r3 = Packed samples remaining in current data byte
; r6 = Current data byte (contains 4 packed samples)
vector_dma_dac_adpcm2:
		; Is there a byte waiting in the mailbox already?
		jnb		pin_dav_dsp,vector_adpcm2_byte_available
		; Then it is a command, so quit.
		setb	cmd_avail
		ljmp	vector_dma_dac_adpcm2_end

vector_adpcm2_byte_available:
		; Figure out if we need to request another byte of sample data.
		dec		r3
		; If r3 hits 0, then we need more data.
		cjne	r3,#0,vector_dma_dac_adpcm2_shiftin
		; Check to see if we have any remaining data bytes to collect.
		clr		a
		cjne	a,len_left_lo,vector_adpcm2_get_data_lo
		cjne	a,len_left_hi,vector_adpcm2_get_data_hi
		; We do not, so end playback depending on the mode that we are in.
		jb		dma_mode_on,X01e1
		jb		dma_8bit_mode,X01bc
		; End auto-init playback mode.
		clr		dma_mode_on
		clr		dma_8bit_mode
		clr		ex0
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		setb	pin_dma_emable1
		lcall	X09f8
		ljmp	vector_dma_dac_adpcm2_end

vector_dma_dac_adpcm2_shiftin:
		ljmp	X021e

		; Ongoing auto-init DMA, so reset back to the beginning of the buffer
		; and continue playback from the start.
X01bc:	mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
; Ask for data byte
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X01c8:	movx	a,@r0
		jnb		acc.6,X01c8
		mov		r0,#1fh
		movx	a,@r0
		; Load it into r6 (data buffer)
		mov		r6,a
		; Since this is 2-bit ADPCM, each byte contains 4 samples.
		mov		r3,#4
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	vector_dma_dac_adpcm2_end

X01e1:	clr		dma_8bit_mode
		clr		dma_mode_on
		mov		len_left_lo,length_low
		mov		len_left_hi,length_high
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X01f1:	movx	a,@r0
		jnb		acc.6,X01f1
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
		mov		r3,#4
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	vector_dma_dac_adpcm2_end

vector_adpcm2_get_data_hi:
		dec		len_left_hi
vector_adpcm2_get_data_lo:
		dec		len_left_lo
		mov		r3,#4
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X0216:	movx	a,@r0
		jnb		acc.6,X0216
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
X021e:	lcall	adpcm_2_decode
vector_dma_dac_adpcm2_end:
		clr		pin_dsp_busy
		pop		rb0r0
		pop		dph
		pop		dpl
		pop		acc
		reti	

; ------------------------------
; Vector for DAC playback, 4-bit ADPCM
; ------------------------------
; Register use:
; r3 = Packed samples remaining in current data byte
vector_dma_dac_adpcm4:
		; If there's a byte waiting in the mailbox already, then it is a
		; a command, so go back to process that.
		jnb		pin_dav_dsp,vector_adpcm4_byte_available
		setb	cmd_avail
		ljmp	vector_dma_dac_adpcm4_end

		; First we need figure out if we need to request another
		; byte of sample data. r3 is that counter
vector_adpcm4_byte_available:
		dec		r3
		; If r3 hits 0, then we need more data.
		cjne	r3,#0,vector_dma_dac_adpcm4_shiftin
		; Check to see if we have any remaining data bytes to collect.
		clr		a
		cjne	a,len_left_lo,vector_adpcm4_get_data_lo
		cjne	a,len_left_hi,vector_adpcm4_get_data_hi
		; We do not, so end playback depending on the mode that we are in.
		jb		dma_mode_on,X0287
		jb		dma_8bit_mode,X0262
		; Exit auto-init DMA mode.
		clr		dma_mode_on
		clr		dma_8bit_mode
		clr		ex0
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		setb	pin_dma_emable1
		lcall	X09f8
		ljmp	vector_dma_dac_adpcm4_end

vector_dma_dac_adpcm4_shiftin:
		ljmp	X02c4

		; Ongoing auto-init DMA, so reset back to the beginning of the buffer
		; and continue playback from the start.
X0262:	mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X026e:	movx	a,@r0
		jnb		acc.6,X026e
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
		mov		r3,#2
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	vector_dma_dac_adpcm4_end

X0287:	clr		dma_8bit_mode
		clr		dma_mode_on
		mov		len_left_lo,length_low
		mov		len_left_hi,length_high
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X0297:	movx	a,@r0
		jnb		acc.6,X0297
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
		mov		r3,#2
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	vector_dma_dac_adpcm4_end

vector_adpcm4_get_data_hi:
		dec		len_left_hi
vector_adpcm4_get_data_lo:
		dec		len_left_lo
		mov		r3,#2
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X02bc:	movx	a,@r0
		jnb		acc.6,X02bc
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
X02c4:	lcall	adpcm_4_decode
vector_dma_dac_adpcm4_end:
		clr		pin_dsp_busy
		pop		rb0r0
		pop		dph
		pop		dpl
		pop		acc
		reti	

; ------------------------------
; Vector for DAC playback, 2.6-bit ADPCM
; ------------------------------
vector_dma_dac_adpcm2_6:
		jnb		pin_dav_dsp,X02da
		setb	cmd_avail
		ljmp	vector_dma_dac_adpcm2_6_end

X02da:	dec		r3
		cjne	r3,#0,vector_dma_dac_adpcm2_6_shiftin
		clr	a
		cjne	a,len_left_lo,X0356
		cjne	a,len_left_hi,X0354
		jb		dma_mode_on,X032b
		jb		dma_8bit_mode,X0306
		clr		dma_mode_on
		clr		dma_8bit_mode
		clr		ex0
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		lcall	X09f8
		ljmp	vector_dma_dac_adpcm2_6_end

vector_dma_dac_adpcm2_6_shiftin:
		ljmp	X0368

X0306:	mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X0312:	movx	a,@r0
		jnb		acc.6,X0312
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
		mov		r3,#3
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	vector_dma_dac_adpcm2_6_end

X032b:	clr		dma_8bit_mode
		clr		dma_mode_on
		mov		len_left_lo,length_low
		mov		len_left_hi,length_high
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X033b:	movx	a,@r0
		jnb		acc.6,X033b
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
		mov		r3,#3
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	vector_dma_dac_adpcm2_6_end

X0354:	dec		len_left_hi
X0356:	dec		len_left_lo
		mov		r3,#3
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X0360:	movx	a,@r0
		jnb		acc.6,X0360
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
X0368:	lcall	adpcm_2_6_decode
vector_dma_dac_adpcm2_6_end:
		clr		pin_dsp_busy
		pop		rb0r0
		pop		dph
		pop		dpl
		pop		acc
		reti	

; ------------------------------
; Vector for DAC playback of silence.
; ------------------------------
vector_dac_silence:
		; If there's a byte waiting in the mailbox already, then it is a
		; a command, so go back to process that.
		jnb		pin_dav_dsp,vector_dac_silence_byte_available
		setb	cmd_avail
		ljmp	vector_dac_silence_end

vector_dac_silence_byte_available:
		clr		a
		cjne	a,len_left_lo,vector_dac_silence_get_data_lo
		cjne	a,len_left_hi,vector_dac_silence_get_data_hi
		; We do not, so end this playback operation.
		clr		ex0
		mov		r0,#8
		movx	a,@r0
vector_adpcm2_6_get_data_hi:
		anl		a,#3
vector_adpcm2_6_get_data_lo:
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		setb	pin_dma_emable1
		lcall	X09f8
		ljmp	vector_dac_silence_end

vector_dac_silence_get_data_hi:
		dec		len_left_hi
vector_dac_silence_get_data_lo:
		dec		len_left_lo
		; Normally we would request samples from the host PC, but in this case
		; we are playing silence, so we never request data nor do we update the
		; DAC output.
vector_dac_silence_end:
		clr		pin_dsp_busy
		pop		rb0r0
		pop		dph
		pop		dpl
		pop		acc
		reti	

; ------------------------------
; Vector for something, MIDI?
; ------------------------------
int0_op5_handler:
		mov		dptr,#int0_op5_data
		mov		a,r7
		movc	a,@a+dptr
		cjne	a,#0,X03b6
		mov		r7,#0
		clr		a
		movc	a,@a+dptr
X03b6:	mov		r0,#19h
		movx	@r0,a
		inc		r7
		clr		pin_dsp_busy
		pop		rb0r0
		pop		dph
		pop		dpl
		pop		acc
		reti	

; ------------------------------
; Start: Where we begin.
; ------------------------------
start:	; We are busy right now (this bit can be read by the host PC in the
		; status register).
		setb	pin_dsp_busy
		clr		ea
		setb	p1.7
		setb	pin_dma_emable1
		setb	p2.4
		clr		p1.4
		clr		p2.6
		mov		sp,#80h
		clr		pin_drequest
		mov		scon,#42h
		mov		th1,#0fch
		mov		tl1,#0fch
		mov		tmod,#21h
		mov		pcon,#80h
		setb	tr1
		setb	ren
		setb	it0
		setb	it1
		; Check for the warm boot magic number
		mov		a,#34h
		cjne	a,warmboot_magic1,cold_boot
		mov		a,#12h
		cjne	a,warmboot_magic2,cold_boot
		; We are in a warm boot situation, so first off, clear the magic
		; number.
		mov		warmboot_magic1,#0
		mov		warmboot_magic2,#0
		ljmp	warm_boot

; ------------------------------
; Cold boot startup.
; ------------------------------
cold_boot:
		mov		r0,#4
		mov		a,#60h
		movx	@r0,a
		mov		r0,#8
		mov		a,#2
		movx	@r0,a
		mov		r0,#9
		mov		a,#0f8h
		movx	@r0,a
		mov		r0,#0eh
		mov		a,#5
		movx	@r0,a
		mov		r0,#0eh
		mov		a,#4
		movx	@r0,a
		mov		r0,#10h
		mov		a,#2
		movx	@r0,a
		mov		r0,#16h
		mov		a,#5
		movx	@r0,a
		mov		r0,#16h
		mov		a,#4
		movx	@r0,a
		mov		r7,#0
		mov		dsp_dma_id0,#0aah
		mov		dsp_dma_id1,#96h
		mov		dma_blk_len_lo,#0ffh
		mov		dma_blk_len_hi,#7
		mov		37h,#38h
		mov		23h,#0

; ------------------------------
; Warm boot, so we skipped over some initialization.
; ------------------------------
warm_boot:
		mov		rb1r3,#0
		mov		2ch,#0
		mov		2dh,#0
		mov		vector_high,#0
		mov		24h,#0
		setb	p2.7
		clr		p2.3
		clr		p2.1
		clr		p2.2
		setb	ea
		mov		a,#0aah
X0459:	; Wait for mailbox to empty out.
		jb		pin_dav_pc,X0459
		mov		r0,#0
		nop	
		nop	
		; Then write 0xaa (reset successful) into the mailbox.
		movx	@r0,a

; ------------------------------
; Check for incoming commands. This is the start of the command monitoring
; loop, where we read commands, dispatch them, and then return back here.
; ------------------------------
check_cmd:
		; cmd_avail can be set in an interrupt handler in the case that we
		; receive a command while playback or recording is going on.
		jb		cmd_avail,X0477
wait_for_cmd:
		clr		pin_dsp_busy
		jb		23h.5,X046f
		jnb		p1.6,X0472
		lcall	X0b79
X046f:	lcall	X0b91
X0472:	setb	pin_dsp_busy
		jnb		pin_dav_dsp,wait_for_cmd
X0477:	clr		ea
		clr		cmd_avail
		mov		30h,command_byte
		mov		r0,#0
		nop	
		nop	
		; Get the command from the mailbox.
		movx	a,@r0
		mov		command_byte,a
		; Fetch the most significant 4 bits, which represent the command group.
		swap	a
		anl		a,#0fh
		; Dispatch ordinary commands
		cjne	a,#0dh,dispatch_cmd
		ljmp	cmdg_misc

; ------------------------------
; Dispatches a command.
; ------------------------------
dispatch_cmd:
		setb	ea
		; Look up the command group (4 MSBs of command byte) in the table of
		; major commands.
		mov		dptr,#table_major_cmds
		; Read the 8-bit offset for the current major command group.
		movc	a,@a+dptr
		clr		pin_dsp_busy
		; Jump to the table's address plus the offset we looked up.
		jmp		@a+dptr

		sjmp	check_cmd

table_major_cmds:
		.db	12h,15h,1eh,21h,27h,10h,10h,18h
		.db	2ah,1bh,10h,36h,33h,30h,2dh,24h

; ------------------------------
; 10h: invalid command group 5, 6, A
vector_cmdg_none:		sjmp	check_cmd
; ------------------------------
; 12h: command group 0: Status
vector_cmdg_status:		ljmp	cmdg_status
; ------------------------------
; 15h: command group 1: Audio playback - First
vector_cmdg_dac1:		ljmp	cmdg_dma_dac1
; ------------------------------
; 18h: command group 7: Audio playback - Second
vector_cmdg_dac2:		ljmp	cmdg_dma_dac2
; ------------------------------
; 1bh: command group 9: High speed
vector_cmdg_hs:			ljmp	cmdg_hs
; ------------------------------
; 1eh: command group 2: Recording?
vector_cmdg_rec:		ljmp	cmdg_rec
; ------------------------------
; 21h: command group 3: MIDI commands
vector_cmdg_midi:		ljmp	cmdg_midi
; ------------------------------
; 24h: command group F: Auxiliary commands
vector_cmdg_aux:		ljmp	cmdg_aux
; ------------------------------
; 27h: command group 4: Setup
vector_cmdg_setup:		ljmp	cmdg_setup
; ------------------------------
; 2ah: command group 8: Generate silence
vector_cmdg_silence:	ljmp	cmdg_silence
; ------------------------------
; 2dh: command group E: DSP identification
vector_cmdg_ident:		ljmp	cmdg_ident
; ------------------------------
; 30h: command group D: Miscellaneous commands
vector_cmdg_misc:		ljmp	cmdg_misc
; ------------------------------
; 33h: command group C: Program 8-bit DMA mode digitized sound I/O
vector_cmd_dma8:		ljmp	cmd_dma8
; ------------------------------
; 36h: command group B: Program 16-bit DMA mode digitized sound I/O
vector_cmd_dma16:		ljmp	cmd_dma16

; ------------------------------
; Program 8-bit DMA mode digitized sound I/O
; ------------------------------
cmd_dma8:
		lcall	X09f2
		mov		r0,#4
		movx	a,@r0
		anl		a,#0f0h
		jnb		command_byte_3,X04ef
		orl		a,#5
		mov		2eh,a
		mov		r0,#8
		movx	a,@r0
		orl		a,#40h
		movx	@r0,a
		anl		a,#0bfh
		movx	@r0,a
		setb	23h.1
		ljmp	X04f5

X04ef:	orl		a,#4
		mov		2eh,a
		setb	23h.0
X04f5:	jnb		command_byte_2,X04fd
		setb	dma_8bit_mode
		ljmp	X0518

X04fd:	jnb		dma_8bit_mode,X0518
		clr		dma_8bit_mode
		lcall	dsp_input_data
		lcall	dsp_input_data
		mov		length_low,a
		lcall	dsp_input_data
		mov		length_high,a
		setb	dma_mode_on
		clr		pin_dma_emable1
		setb	ex1
		ljmp	X058e

X0518:	jnb		command_byte_1,X052a
		jb		command_byte_3,X0524
		lcall	X1188
		ljmp	X0539

X0524:	lcall	X1191
		ljmp	X0539

X052a:	jb		command_byte_3,X0533
		lcall	X1176
		ljmp	X0539

X0533:	lcall	X117f
		ljmp	X0539

X0539:	jnb		command_byte_0,X053c
X053c:	lcall	dsp_input_data
		mov		2ch,a
		mov		a,2eh
		clr		acc.4
		jnb		2ch.4,X054a
		setb	acc.4
X054a:	setb	acc.6
		jnb		2ch.5,X0551
		clr		acc.6
X0551:	mov		r0,#4
		movx	@r0,a
		clr		ea
		mov		r0,#8
		mov		a,#1
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		setb	ea
		lcall	dsp_input_data
		mov		dma_blk_len_lo,a
		mov		r0,#0bh
		movx	@r0,a
		lcall	dsp_input_data
		mov		dma_blk_len_hi,a
		mov		r0,#0ch
		movx	@r0,a
		setb	p2.3
		setb	ex1
		clr		pin_dma_emable1
		clr		ea
		mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		mov		r0,#16h
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		mov		r0,#0eh
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		setb	ea
X058e:	ljmp	check_cmd

; ------------------------------
; Program 16-bit DMA mode digitized sound I/O
; ------------------------------
cmd_dma16:
		lcall	X09f2
		mov		r0,#4
		movx	a,@r0
		anl		a,#0f0h
		jnb		command_byte_3,X05ae
		orl		a,#4
		mov		2eh,a
		mov		r0,#10h
		movx	a,@r0
		orl		a,#40h
		movx	@r0,a
		anl		a,#0bfh
		movx	@r0,a
		setb	23h.3
		ljmp	X05b4

X05ae:	orl		a,#5
		mov		2eh,a
		setb	23h.2
X05b4:	jnb		command_byte_2,X05bc
		setb	dma_16bit_mode
		ljmp	X05d7

X05bc:	jnb		dma_16bit_mode,X05d7
		clr		dma_16bit_mode
		lcall	dsp_input_data
		lcall	dsp_input_data
		mov		rb2r5,a
		lcall	dsp_input_data
		mov		rb2r6,a
		setb	24h.3
		clr		p2.4
		setb	ex1
		ljmp	X064d

X05d7:	jnb		command_byte_1,X05e9
		jb		command_byte_3,X05e3
		lcall	X1188
		ljmp	X05f8

X05e3:	lcall	X1191
		ljmp	X05f8

X05e9:	jb		command_byte_3,X05f2
		lcall	X1176
		ljmp	X05f8
;
X05f2:	lcall	X117f
		ljmp	X05f8

X05f8:	jnb		command_byte_0,X05fb
X05fb:	lcall	dsp_input_data
		mov		2dh,a
		mov		a,2eh
		clr		acc.5
		jnb		2dh.4,X0609
		setb	acc.5
X0609:	setb	acc.7
		jnb		2dh.5,X0610
		clr		acc.7
X0610:	mov		r0,#4
		movx	@r0,a
		clr		ea
		mov		r0,#10h
		mov		a,#1
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		setb	ea
		lcall	dsp_input_data
		mov		rb1r4,a
		mov		r0,#13h
		movx	@r0,a
		lcall	dsp_input_data
		mov		rb1r5,a
		mov		r0,#14h
		movx	@r0,a
		setb	p2.3
		setb	ex1
		clr		p2.4
		clr		ea
		mov		r0,#10h
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		mov		r0,#16h
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		mov		r0,#0eh
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		setb	ea
X064d:	ljmp	check_cmd

; ------------------------------
; Command group 0: status
; ------------------------------
cmdg_status:
		mov		dptr,#table_status_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

table_status_cmds:
		.db	75h,0f8h,10h,43h,4ch,34h,55h,5ah
		.db	6ch,91h,67h,9dh,0c8h,75h,78h,86h
		
; ------------------------------
; 10h: command 02
; ------------------------------
cmd_02:	lcall	dsp_input_data
		mov		r0,#80h
		movx	@r0,a
		mov		a,#0f2h
		mov		2eh,a
		mov		r0,#81h
		movx	@r0,a
X0676:	mov		r0,#80h
		movx	a,@r0
		jb		pin_dav_dsp,X068a
		cjne	a,2eh,X0676
		mov		r0,#10h
		movx	a,@r0
		anl		a,#0
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
X068a:	ljmp	X06e7

; ------------------------------
; 34h: command 05
; ------------------------------
cmd_05:	lcall	dsp_input_data
		mov		r0,#80h
		movx	@r0,a
		lcall	dsp_input_data
		mov		r0,#81h
		movx	@r0,a
		ljmp	X06e7

; ------------------------------
; 43h: command 03
; ------------------------------
cmd_03:	mov		r0,#80h
		movx	a,@r0
		lcall	dsp_output_data
		ljmp	X06e7

; ------------------------------
; 4ch: command 04
; ------------------------------
cmd_04:	lcall	dsp_input_data
		mov		r0,#82h
		movx	@r0,a
		ljmp	X06e7

; ------------------------------
; 55h: command 06
; ------------------------------
cmd_06:	inc		vector_high
		ljmp	X06e7

; ------------------------------
; 5ah: command 07
; ------------------------------
cmd_07:	mov		a,vector_high
		cjne	a,#0,X06bb
		ljmp	X06e7

X06bb:	dec		vector_high
		ljmp	X06e7

; ------------------------------
; 67h: command 0A
; ------------------------------
cmd_0A:	mov		a,vector_high
		lcall	dsp_output_data

; ------------------------------
; 6ch: command 08
; ------------------------------
cmd_08:	mov		r0,#82h
		movx	a,@r0
		lcall	dsp_output_data
		ljmp	X06e7

; ------------------------------
; 75h: command 00, 0D
; ------------------------------
cmd_00:
cmd_0D:
		ljmp	wait_for_cmd

; ------------------------------
; 78h: command 0E: X-Bus poke function
; ------------------------------
cmd_0E:	lcall	dsp_input_data
		mov		b,a
		lcall	dsp_input_data
		mov		r0,b
		movx	@r0,a
		ljmp	wait_for_cmd

; ------------------------------
; 86h: command 0F: X-Bus peek function
; ------------------------------
cmd_0F:	lcall	dsp_input_data
		mov		r0,a
		movx	a,@r0
		lcall	dsp_output_data
X06e7:	ljmp	wait_for_cmd

; ------------------------------
; 91h: command 09
; ------------------------------
cmd_09:	mov		a,rb1r0
		lcall	dsp_output_data
		mov		a,rb1r1
		lcall	dsp_output_data
		sjmp	X06e7

; ------------------------------
; 9dh: command 0B
; ------------------------------
cmd_0B:	lcall	dsp_input_data
		mov		len_left_lo,a
		mov		r0,#80h
		movx	@r0,a
		mov		a,#0c0h
		mov		2eh,a
		mov		r0,#81h
		movx	@r0,a
X0705:	mov		r0,#80h
		movx	a,@r0
		cjne	a,2eh,X0705
X070b:	lcall	dsp_input_data
		mov		r0,#80h
		movx	@r0,a
		lcall	dsp_input_data
		mov		r0,#81h
		movx	@r0,a
		clr		a
		cjne	a,len_left_lo,X071d
		sjmp	X06e7

X071d:	dec		len_left_lo
		sjmp	X070b

; ------------------------------
; 0c8h: command 0C
; ------------------------------
cmd_0C:	lcall	dsp_input_data
		mov		len_left_lo,a
		mov		r0,#80h
		movx	@r0,a
		mov		a,#0c1h
		mov		2eh,a
		mov		r0,#81h
		movx	@r0,a
X0730:	mov		r0,#80h
		movx	a,@r0
		cjne	a,2eh,X0730
		mov		a,2eh
		mov		r0,#81h
		movx	@r0,a
X073b:	mov		r0,#80h
		movx	a,@r0
		lcall	dsp_output_data
		mov		r0,#80h
		movx	a,@r0
		lcall	dsp_output_data
		clr		a
		cjne	a,len_left_lo,X074d
		sjmp	X06e7

X074d:	dec		len_left_lo
		sjmp	X073b

; ------------------------------
; 0f8h: command 01
; ------------------------------
cmd_01:	mov		a,vector_high
		cjne	a,#0,X06e7
		lcall	dsp_output_data
		mov		a,#0
		mov		33h,a
		mov		34h,a
		mov		r0,#80h
		movx	@r0,a
		mov		r0,#81h
		movx	@r0,a
		lcall	dsp_input_data
		clr		c
		subb	a,#4
		mov		len_left_lo,a
		lcall	dsp_input_data
		jnc		X0773
		dec		a
X0773:	mov		len_left_hi,a
		mov		a,#8ch
		mov		r0,#82h
		movx	@r0,a
		mov		a,#8ah
		mov		r0,#82h
		movx	@r0,a
X077f:	lcall	dsp_input_data
		mov		r0,#83h
		movx	@r0,a
		add		a,33h
		mov		33h,a
		jnc		X078d
		inc		34h
X078d:	clr		a
		cjne	a,len_left_lo,X07d1
		cjne	a,len_left_hi,X07cf
		lcall	dsp_input_data
		mov		35h,a
		lcall	dsp_input_data
		mov		36h,a
		mov		a,#0
		mov		r0,#82h
		movx	@r0,a
		mov		a,#70h
		mov		r0,#82h
		movx	@r0,a
		mov		a,33h
		cjne	a,35h,X07bd
		mov		a,34h
		cjne	a,36h,X07bd
		mov		r0,#80h
		movx	a,@r0
		cjne	a,#0aah,X07bf
		mov		a,#0
		ljmp	X07bf

X07bd:	mov		a,#0ffh
X07bf:	lcall	dsp_output_data
		lcall	dsp_input_data
		mov		rb1r0,a
		lcall	dsp_input_data
		mov		rb1r1,a
		ljmp	X06e7

X07cf:	dec		len_left_hi
X07d1:	dec		len_left_lo
		sjmp	X077f

; ------------------------------
; Command group 4: Setup
; ------------------------------
cmdg_setup:
		mov		dptr,#table_setup_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

table_setup_cmds:
		.db	6fh,82h,82h,24h,10h,15h,1ah,1fh
		.db	9fh,24h,24h,24h,51h,60h,27h,2ch

; ------------------------------
; 10h: command 44
; ------------------------------
cmd_44:	setb	p2.1
		ljmp	X088a

; ------------------------------
; 15h: command 45
; ------------------------------
cmd_45:	clr	p2.1
		ljmp	X088a

; ------------------------------
; 1ah: command 46
; ------------------------------
cmd_46:	setb	p2.2
		ljmp	X088a

; ------------------------------
; 1fh: command 47
; ------------------------------
cmd_47:	clr	p2.2
		ljmp	X088a

; ------------------------------
; 24h: invalid command 49, 4A, 4B
; ------------------------------
cmd_4_none:
		ljmp	wait_for_cmd

; ------------------------------
; 27h: command 4E
; ------------------------------
cmd_4E:	clr		23h.6
		ljmp	X0818

; ------------------------------
; 2ch: command 4F
; ------------------------------
cmd_4F:	jnb	23h.6,X0816
		clr	23h.6
		clr	tr0
		clr	et0
		ljmp	X088a

X0816:	setb	23h.6
X0818:	lcall	dsp_input_data
		cpl		a
		mov		tl0,a
		mov		rb3r1,a
		lcall	dsp_input_data
		cpl		a
		mov		th0,a
		mov		rb3r2,a
		setb	et0
		setb	tr0
		ljmp	X088a

; ------------------------------
; 51h: command 4C
; ------------------------------
cmd_4C:	lcall	dsp_input_data
		anl		a,#3
		add		a,#1bh
		mov		r0,a
		lcall	dsp_input_data
		movx	@r0,a
		ljmp	X088a

; ------------------------------
; 60h: command 4D
; ------------------------------
cmd_4D:	lcall	dsp_input_data
		anl		a,#3
		add		a,#1bh
		mov		r0,a
		mov		a,@r0
		lcall	dsp_output_data
		ljmp	X088a

; ------------------------------
; 6fh: command 40: DSP time constant
; ------------------------------
cmd_40:	lcall	dsp_input_data
		cjne	a,#0ebh,X0853
X0853:	jc		X0857
		mov		a,#0ebh
X0857:	lcall	convert_samplerate
		lcall	X09e1
		ljmp	X088a

; ------------------------------
; 82h: command 41, 42
; ------------------------------
cmd_41:
cmd_42:
		jnb		pin_dav_dsp,cmd_41
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		rb2r4,a
X086a:	jnb		pin_dav_dsp,X086a
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		rb2r3,a
		lcall	X097e
		lcall	X09e1
		ljmp	X088a

; ------------------------------
; 0c0h: command 48: DSP block transfer size.
; ------------------------------
cmd_48:	lcall	dsp_input_data
		mov		dma_blk_len_lo,a
		lcall	dsp_input_data
		mov		dma_blk_len_hi,a
		ljmp	X088a
;
X088a:	ljmp	wait_for_cmd

; ------------------------------
; Samplerate table
; ------------------------------
convert_samplerate:
		mov	dptr,#samplerate_table
		movc	a,@a+dptr
		ret	

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
		.db	2bh,2ch,2ch,2ch,2dh,2dh,2eh,2eh
		.db	2eh,2fh,2fh,30h,30h,30h,31h,31h
		.db	32h,32h,33h,33h,34h,34h,35h,35h
		.db	36h,36h,37h,37h,38h,38h,39h,39h
		.db	3ah,3bh,3bh,3ch,3dh,3dh,3eh,3fh
		.db	3fh,40h,41h,42h,42h,43h,44h,45h
		.db	46h,47h,48h,49h,49h,4ah,4bh,4dh
		.db	4eh,4fh,50h,51h,52h,53h,55h,56h
		.db	57h,59h,5ah,5ch,5dh,5fh,60h,62h
		.db	0c8h,66h,68h,6ah,6ch,6eh,70h,72h
		.db	75h,77h,7ah,7ch,7fh,82h,85h,89h
		.db	8ch,90h,93h,97h,9ch,0a0h,0a5h,0aah
		.db	0afh,0b5h,0bbh,0c1h,0c8h,0d0h,0d8h,0e0h
		.db	0eah,0f4h,0ffh,0ffh

; ------------------------------
; ?
; ------------------------------
X097e:	mov		a,rb2r4
		cjne	a,#0b1h,X0988
		mov		a,#0ffh
		ljmp	X09e0

X0988:	jc		X098f
		mov		a,#0ffh
		ljmp	X09e0

X098f:	mov		a,rb2r4
		clr		c
		subb	a,#13h
		jnc		X099b
		mov		a,#1ch
		ljmp	X09e0

X099b:	mov		a,#17h
		mov		b,rb2r4
		mul		ab
		mov		rb3r0,b
		mov		rb2r7,a
		mov		a,#17h
		mov		b,rb2r3
		mul		ab
		xch		a,b
		add		a,rb2r7
		mov		rb2r7,a
		mov		a,rb3r0
		addc	a,#0
		mov		a,rb3r0
		rrc		a
		mov		rb3r0,a
		mov		a,rb2r7
		rrc		a
		mov		rb2r7,a
		mov		a,rb3r0
		rrc		a
		mov		rb3r0,a
		mov		a,rb2r7
		rrc		a
		mov		rb2r7,a
		mov		a,rb3r0
		rrc		a
		mov		rb3r0,a
		mov		a,rb2r7
		rrc		a
		mov		rb2r7,a
		mov		a,rb3r0
		rrc		a
		mov		rb3r0,a
		mov		a,rb2r7
		rrc		a
		addc	a,#0
		mov		rb2r7,a
X09e0:	ret	

; ------------------------------
; ?
; ------------------------------
X09e1:	mov		r0,#9
		mov		37h,a
		cjne	a,#0f8h,X09e8
X09e8:	jnc		X09ef
		setb	23h.7
		ljmp	X09f1
;
X09ef:	clr		23h.7
X09f1:	ret	
;
X09f2:	mov		r0,#9
		mov		a,37h
		movx	@r0,a
		ret	

; ------------------------------
; ?
; ------------------------------
X09f8:	jnb		23h.7,X0a00
		mov		r0,#9
		mov		a,#0f8h
		movx	@r0,a
X0a00:	ret	

; ------------------------------
; Command group F: Auxiliary commands
; ------------------------------
cmdg_aux:
		mov		dptr,#table_aux_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

table_aux_cmds:
		.db	81h,41h,44h,53h,61h,41h,41h,41h
		.db	6eh,10h,1bh,31h,39h,29h,41h,41h

; ------------------------------
; 10h: command F9: Internal RAM peek function
; ------------------------------
cmd_F9:	lcall	dsp_input_data
		mov		r0,a
		mov		a,@r0
		lcall	dsp_output_data
		ljmp	group_F_exit

; ------------------------------
; 1bh: command FA: Internal RAM poke function
; ------------------------------
cmd_FA:	lcall	dsp_input_data
		mov		b,a
		lcall	dsp_input_data
		mov		r0,b
		mov		@r0,a
		ljmp	group_F_exit

; ------------------------------
; 29h: command FD
; ------------------------------
cmd_FD:	mov		a,30h
		lcall	dsp_output_data
		ljmp	group_F_exit

; ------------------------------
; 31h: command FB
; ------------------------------
cmd_FB:	mov	a,23h
		lcall	dsp_output_data
		ljmp	group_F_exit

; ------------------------------
; 39h: command FC
; ------------------------------
cmd_FC:	mov	a,24h
		lcall	dsp_output_data
		ljmp	group_F_exit

; ------------------------------
; 41h: invalid command F1, F5, F6, F7, FE, FG
; ------------------------------
cmd_f_none:
		ljmp	group_F_exit

; ------------------------------
; 44h: command F2
; ------------------------------
cmd_F2:	mov	r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	group_F_exit

; ------------------------------
; 53h: command F3
; ------------------------------
cmd_F3:	mov		r0,#10h
		movx	a,@r0
		anl		a,#0
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	group_F_exit

; ------------------------------
; 61h: command F4
; ------------------------------
cmd_F4:	mov		a,#7dh
		lcall	dsp_output_data
		mov		a,#1bh
		lcall	dsp_output_data
		ljmp	group_F_exit

; ------------------------------
; 6eh: command F8
; ------------------------------
cmd_F8:	jb		command_byte_2,X0a85
		mov		a,#0
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
		ljmp	group_F_exit

X0a85:	lcall	X119a
		ljmp	group_F_exit

; ------------------------------
; 7eh: command F0
; ------------------------------
cmd_F0:	mov		a,#5ah
		lcall	X09e1
		lcall	X09f2
		mov		rb1r3,#5
		mov		rb1r2,#0
		mov		a,#60h
		mov		r0,#4
		movx	@r0,a
		setb	ex0
		ljmp	group_F_exit

; ------------------------------
; Command: Group F Exit
; ------------------------------
group_F_exit:
		clr		pin_dsp_busy
		ljmp	check_cmd

int0_op5_data:
		.db	7fh,26h,1,26h,80h,0d9h,0ffh,0d9h
		.db	0

; ------------------------------
; Command group 3: MIDI commands
; ------------------------------
cmdg_midi:
		jb		command_byte_3,cmd_midi_write_poll
		jnb		command_byte_2,cmd_midi_read_write_poll
		mov		warmboot_magic1,#34h
		mov		warmboot_magic2,#12h
		ljmp	cmd_midi_read_write_poll

; ------------------------------
; Command 38: MIDI write poll.
; ------------------------------
cmd_midi_write_poll:
		jnb		ti,cmd_midi_write_poll
		clr		ti
		lcall	dsp_input_data
		mov		sbuf,a
		ljmp	check_cmd

; ------------------------------
; Commands 34 to 37: MIDI read/write poll
; with optional time stamp and interrupt.
; ------------------------------
; Registers:
; r1: Write pointer to SRAM buffer
; r2: Read pointer to SRAM buffer
; r4: Bytes remaining in SRAM buffer
; r5, r6, r7: MIDI time stamp value
; ------------------------------
cmd_midi_read_write_poll:
		jnb		command_byte_1,skip_midi_timestamp_setup
		; Set up timer for MIDI time stamping
		mov		tmod,#21h
		setb	midi_timestamp
		mov		tl0,#2fh
		mov		th0,#0f8h
		mov		r5,#0
		mov		r6,#0
		mov		r7,#0
		setb	et0
		setb	tr0
skip_midi_timestamp_setup:
		; Clear the receive data buffer
		mov		a,sbuf
		clr		ri
		; Initialize write pointer
		mov		r1,#40h
		; Initialize read pointer
		mov		r2,#40h
		; Initialize bytes remaining counter
		mov		r4,#40h
		ljmp	midi_check_for_input_data

midi_main_loop:
		jnb		ti,midi_check_for_input_data
		jnb		pin_dav_dsp,midi_check_for_input_data
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		jb		command_byte_2,midi_write_poll
		clr		et0
		clr		tr0
		mov		warmboot_magic1,#0
		mov		warmboot_magic2,#0
		clr		midi_timestamp
		ljmp	check_cmd

midi_write_poll:
		clr		ti
		mov		sbuf,a
midi_check_for_input_data:
		; Check to see if there is data in the serial input buffer
		jb		ri,midi_has_input_data
		cjne	r4,#40h,X0b1b
		sjmp	midi_main_loop

X0b1b:	jnb	pin_dav_pc,midi_flush_buffer_to_host
		sjmp	midi_main_loop

midi_has_input_data:
		; There is data in the serial data buffer.
		; Check to see if we need to add a time stamp.
		jnb		command_byte_1,midi_read_no_timestamp
		; Stop the timer
		clr		tr0
		mov		a,r5
		lcall	midi_store_read_data
		mov		a,r6
		lcall	midi_store_read_data
		mov		a,r7
		lcall	midi_store_read_data
		setb	tr0
midi_read_no_timestamp:
		mov		a,sbuf
		lcall	midi_store_read_data
		clr		ri
		sjmp	midi_main_loop

		cjne	r4,#40h,X0b42
		ljmp	midi_nowrap_readbuffer

X0b42:	mov		@r1,a
		inc		r1
		dec		r4
		cjne	r1,#80h,midi_flush_buffer_to_host
		mov		r1,#40h
midi_flush_buffer_to_host:
		; Send contents of entire SRAM buffer to host PC.
		mov		a,r2
		mov		r0,a
		mov		a,@r0
		inc		r2
		; More space is available now
		inc		r4
		; When we hit the end, wrap back to the beginning
		cjne	r2,#80h,midi_nowrap_readbuffer
		mov		r2,#40h
midi_nowrap_readbuffer:
		mov		r0,#0
		nop	
		nop	
		; Place MIDI data byte in mailbox
		movx	@r0,a
		; Optionally, send an interrupt to the host PC.
		jnb		command_byte_0,midi_skip_interrupt
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
midi_skip_interrupt:
		; Done, go back to the main loop
		sjmp	midi_main_loop

midi_store_read_data:
		cjne	r4,#0,midi_store_read_data_to_buffer
		ljmp	midi_ready_to_receive_more

midi_store_read_data_to_buffer:
		; Store the received data to the SRAM.
		mov		@r1,a
		inc		r1
		dec		r4
		cjne	r1,#80h,midi_ready_to_receive_more
		mov		r1,#40h
midi_ready_to_receive_more:
		ret	

; ------------------------------
; ?
; ------------------------------
X0b79:	mov		r0,#2
		mov		a,#0feh
		movx	@r0,a
		setb	23h.5
		mov		a,sbuf
		clr		ri
		mov		r1,#40h
		mov		r2,#40h
		mov		r4,#40h
		mov		warmboot_magic1,#34h
		mov		warmboot_magic2,#12h
		ret	

X0b91:	clr		pin_dsp_busy
		jb		pin_dav_dsp,X0bbe
		jnb		p1.6,X0bb3
		jb		ri,X0bc7
		cjne	r4,#40h,X0bbf
X0b9f:	jnb		ti,X0b91
		mov		r0,#2
		movx	a,@r0
		setb	pin_dsp_busy
		jnb		acc.6,X0b91
		mov		r0,#1
		movx	a,@r0
		clr		ti
		mov		sbuf,a
		sjmp	X0b91

X0bb3:	mov		r0,#1
		movx	a,@r0
		clr		23h.5
		mov		warmboot_magic1,#0
		mov		warmboot_magic2,#0
X0bbe:	ret	

; ------------------------------
; ?
; ------------------------------
X0bbf:	mov		r0,#2
		movx	a,@r0
		jb		acc.7,X0bde
		sjmp	X0b9f

X0bc7:	mov		a,sbuf
		lcall	midi_store_read_data
		clr		ri
		sjmp	X0b9f

		cjne	r4,#40h,X0bd6
		ljmp	X0be8

X0bd6:	mov		@r1,a
		inc		r1
		dec		r4
		cjne	r1,#80h,X0bde
		mov		r1,#40h
X0bde:	mov		a,r2
		mov		r0,a
		mov		a,@r0
		inc		r2
		inc		r4
		cjne	r2,#80h,X0be8
		mov		r2,#40h
X0be8:	mov		r0,#2
		movx	@r0,a
		sjmp	X0b9f

; ------------------------------
; Command group 2: Recording
; ------------------------------
cmdg_rec:
		clr		p2.3
		jb		command_byte_3,dma_rec_autoinit
		jb		command_byte_2,dma_rec_normal
		ljmp	dma_rec_direct

; ------------------------------
; Starts auto-init DMA Recording
; ------------------------------
dma_rec_autoinit:
		lcall	X09f2
		setb	dma_8bit_mode
		mov		a,dma_blk_len_lo
		mov		len_left_lo,a
		mov		r0,#0bh
		movx	@r0,a
		mov		a,dma_blk_len_hi
		mov		len_left_hi,a
		mov		r0,#0ch
		movx	@r0,a
		ljmp	X0c53

; ------------------------------
; Starts normal DMA Recording
; ------------------------------
dma_rec_normal:
		lcall	X09f2
		jb		pin_dma_emable1,X0c2d
X0c14:	jnb		pin_dav_dsp,X0c14
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		length_low,a
X0c1e:	jnb		pin_dav_dsp,X0c1e
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		length_high,a
		setb	dma_mode_on
		ljmp	X0c9c

X0c2d:	clr		ea
		mov		r0,#8
		mov		a,#1
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		setb	ea
X0c39:	jnb		pin_dav_dsp,X0c39
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		len_left_lo,a
		mov		r0,#0bh
		movx	@r0,a
X0c46:	jnb		pin_dav_dsp,X0c46
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		len_left_hi,a
		mov		r0,#0ch
		movx	@r0,a
X0c53:	setb	23h.1
		mov		rb1r2,#5
		lcall	X114c
		mov		r0,#8
		movx	a,@r0
		orl		a,#40h
		movx	@r0,a
		anl		a,#0bfh
		movx	@r0,a
		clr		pin_dma_emable1
		setb	ex1
		lcall	X117f
		clr		ea
		mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		mov		r0,#16h
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		mov		r0,#0eh
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		setb	ea
		ljmp	check_cmd

; ------------------------------
; Immediately Immediately reads a sample from the
; microphone input and returns it as a byte.
; ------------------------------
dma_rec_direct:
		mov		a,#61h
		mov		r0,#4
		movx	@r0,a
		mov		r0,#17h
X0c8d:	movx	a,@r0
		jnb		acc.7,X0c8d
		mov		r0,#1bh
		movx	a,@r0
X0c94:	jb		pin_dav_pc,X0c94
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
X0c9c:	ljmp	check_cmd

; ------------------------------
; Command group 9: High speed
; ------------------------------
; Starts high speed DMA record mode.
; ------------------------------
cmdg_hs:
		lcall	X09f2
		clr		p2.3
		jnb		command_byte_3,hs_dma_playback
		mov		rb1r2,#5
		setb	23h.1
		mov		r0,#8
		movx	a,@r0
		orl		a,#40h
		movx	@r0,a
		anl		a,#0bfh
		movx	@r0,a
		lcall	X117f
		jb		command_byte_0,hs_dma_record_exit
		setb	dma_8bit_mode
		ljmp	hs_dma_continuous

hs_dma_record_exit:
		clr		dma_8bit_mode
		ljmp	hs_dma_continuous

; ------------------------------
; Starts high speed DMA playback mode
; ------------------------------
hs_dma_playback:
		mov		rb1r2,#4
		setb	23h.0
		lcall	X1176
		jb		command_byte_0,hs_dma_playback_exit
		setb	dma_8bit_mode
		ljmp	hs_dma_continuous

hs_dma_playback_exit:
		clr		dma_8bit_mode
hs_dma_continuous:
		clr		ea
		mov		r0,#8
		mov		a,#1
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		setb	ea
		mov		a,dma_blk_len_lo
		mov		r0,#0bh
		movx	@r0,a
		mov		a,dma_blk_len_hi
		mov		r0,#0ch
		movx	@r0,a
		mov		warmboot_magic1,#34h
		mov		warmboot_magic2,#12h
		clr		pin_dma_emable1
		lcall	X114c
		setb	ex1
		clr		ea
		mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		mov		r0,#16h
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		mov		r0,#0eh
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		setb	ea
		ljmp	check_cmd

; ------------------------------
; Command group 1: Audio playback - First
; ------------------------------
cmdg_dma_dac1:
		clr		p2.3
		jb		command_byte_3,dma_dac1_autoinit
		jb		command_byte_2,dma_dac1_normal
		ljmp	dma_dac1_direct

; ------------------------------
; Starts auto-init DMA playback
; ------------------------------
dma_dac1_autoinit:
		lcall	X09f2
		setb	dma_8bit_mode
		mov		a,dma_blk_len_lo
		mov		len_left_lo,a
		mov		r0,#0bh
		movx	@r0,a
		mov		a,dma_blk_len_hi
		mov		len_left_hi,a
		mov		r0,#0ch
		movx	@r0,a
		ljmp	X0d70

; ------------------------------
; Starts normal DMA playback.
; ------------------------------
dma_dac1_normal:
		lcall	X09f2
		jnb		dma_8bit_mode,X0d52
		jnb		command_byte_1,X0d41
		clr		ex0
X0d41:	lcall	dsp_input_data
		mov		length_low,a
		lcall	dsp_input_data
		mov		length_high,a
		setb	dma_mode_on
		setb	ex0
		ljmp	X0d9a

X0d52:	clr		dma_mode_on
		clr		ea
		mov		r0,#8
		mov		a,#1
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		setb	ea
		lcall	dsp_input_data
		mov		len_left_lo,a
		mov		r0,#0bh
		movx	@r0,a
		lcall	dsp_input_data
		mov		len_left_hi,a
		mov		r0,#0ch
		movx	@r0,a
X0d70:	jb		command_byte_1,dma_dac1_adpcm_use_2bit
		setb	23h.0
		mov		rb1r2,#4
		lcall	X114c
		clr		pin_dma_emable1
		setb	ex1
		lcall	X1176
		clr		ea
		mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		mov		r0,#16h
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		mov		r0,#0eh
		movx	a,@r0
		anl		a,#4
		movx	@r0,a
		setb	ea
X0d9a:	ljmp	check_cmd

; ------------------------------
; Use 2-bit ADPCM compression
; ------------------------------
dma_dac1_adpcm_use_2bit:
		clr		pin_dma_emable1
		mov		rb1r3,#2
		mov		rb1r2,#2
		lcall	X114c
		lcall	X115b
		jb		command_byte_0,dma_dac1_reference
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X0db4:	movx	a,@r0
		jnb		acc.6,X0db4
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
		mov		r3,#4
		ljmp	X0dd6

dma_dac1_reference:
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X0dc7:	movx	a,@r0
		jnb		acc.6,X0dc7
		mov		r0,#1fh
		movx	a,@r0
		mov		r2,a
		mov		r0,#19h
		movx	@r0,a
		mov		r5,#1
		mov		r3,#1
X0dd6:	setb	ex0
		ljmp	check_cmd

; ------------------------------
; Immediately loads DAC with provided sample byte
; ------------------------------
dma_dac1_direct:
		mov		a,#60h
		mov		r0,#4
		movx	@r0,a
X0de0:	jnb		pin_dav_dsp,X0de0
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		r0,#19h
		movx	@r0,a
		ljmp	check_cmd

; ------------------------------
; Command group 7: Audio playback - Second
; ------------------------------
cmdg_dma_dac2:
		lcall	X09f2
		clr		p2.3
		jb		command_byte_3,dma_dac2_adpcm_autoinit
		jb		command_byte_2,dma_dac2_adpcm

; ------------------------------
; Starts auto-init DMA playback
; ------------------------------
dma_dac2_adpcm_autoinit:
		setb	dma_8bit_mode
		mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		ljmp	X0e2b

; ------------------------------
; Starts normal DMA playback
; ------------------------------
dma_dac2_adpcm:
		jb		dma_8bit_mode,X0e0a
		ljmp	X0e1d

X0e0a:	clr		ex0
		lcall	dsp_input_data
		mov		length_low,a
		lcall	dsp_input_data
		mov		length_high,a
		setb	dma_mode_on
		setb	ex0
		ljmp	check_cmd

; ------------------------------
; Check if DMA is on?
; ------------------------------
X0e1d:	clr		dma_mode_on
		lcall	dsp_input_data
		mov		len_left_lo,a
		lcall	dsp_input_data
		mov		len_left_hi,a
		setb	pin_dsp_busy
X0e2b:	clr		pin_dma_emable1
		jnb		command_byte_1,dma_dac2_adpcm_use_4bit
		mov		rb1r3,#3
		ljmp	dma_dac2_adpcm_use_2_6bit

; ------------------------------
; Use 2.6-bit or 4bit ADPCM 
; ------------------------------
dma_dac2_adpcm_use_4bit:
		mov		rb1r3,#4
dma_dac2_adpcm_use_2_6bit:
		mov		rb1r2,#2
		lcall	X114c
		lcall	X115b
		jnb		command_byte_0,dma_dac2_no_reference
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X0e4b:	movx	a,@r0
		jnb		acc.6,X0e4b
		mov		r0,#1fh
		movx	a,@r0
		mov		r2,a
		mov		r0,#19h
		movx	@r0,a
		mov		r5,#1
		mov		r3,#1
		ljmp	X0e75

dma_dac2_no_reference:
		setb	pin_drequest
		clr		pin_drequest
		mov		r0,#0fh
X0e63:	movx	a,@r0
		jnb		acc.6,X0e63
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
		jnb		command_byte_1,dac_no_ref_adpcm4
		mov		r3,#3
		ljmp	X0e75

dac_no_ref_adpcm4:
		mov		r3,#4
X0e75:	setb	ex0
		ljmp	check_cmd

; ------------------------------
; 2ah: Command group 8: Generate silence
; ------------------------------
cmdg_silence:
		lcall	X09f2
		clr		pin_dma_emable1
		lcall	dsp_input_data
		mov		len_left_lo,a
		lcall	dsp_input_data
		mov		len_left_hi,a
		mov		rb1r3,#1
		mov		rb1r2,#2
		lcall	X114c
		setb	ex0
		ljmp	check_cmd

; ------------------------------
; Command group D: Miscellaneous commands
; ------------------------------
cmdg_misc:
		mov		dptr,#table_misc_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

table_misc_cmds:
		.db	5ah,3ch,10h,41h,9eh,83h,0e4h,10h
		.db	25h,4bh,46h,10h,50h,55h,13h,1ch

; ------------------------------ 
; 10h: invalid command D2, D7, DB
; ------------------------------
cmd_d_none:
		ljmp	cmdg_d_exit

; ------------------------------
; 13h: command DE (undocumented)
; ------------------------------
cmd_undoc_de:
		mov		r0,#5
		movx	a,@r0
		setb	acc.0
		movx	@r0,a
		ljmp	cmdg_d_exit

; ------------------------------
; 1ch: command DF (undocumented)
; ------------------------------
cmd_undoc_df:
		mov		r0,#5
		movx	a,@r0
		clr		acc.0
		movx	@r0,a
		ljmp	cmdg_d_exit

; ------------------------------
; 25h: Command D8: Speaker status
; ------------------------------
cmd_spk_stat:
		jb		command_byte_1,cmd_exit_autoinit8
		jb		pin_mute_en,X0ecf
		clr		a
		ljmp	X0ed1
;
X0ecf:	mov		a,#0ffh
X0ed1:	; Wait for mailbox to empty out
		jb		pin_dav_pc,X0ed1
		mov		r0,#0
		nop	
		nop	
		; Send speaker status. FFh=enabled, 00h=disabled
		movx	@r0,a
		ljmp	cmdg_d_exit

; ------------------------------
; 3ch: Command D1: Enable speaker
; ------------------------------
cmd_speaker_on:
		setb	pin_mute_en
		ljmp	cmdg_d_exit

; ------------------------------
; 41h: Command D3: Disable speaker
; ------------------------------
cmd_speaker_off:
		clr		pin_mute_en
		ljmp	cmdg_d_exit

; ------------------------------
; 46h: Command DA: Exit 8-bit DMA mode
; ------------------------------
cmd_exit_autoinit8:
		clr		dma_8bit_mode
		ljmp	cmdg_d_exit

; ------------------------------
; 4bh: Command D9: Exit 16-bit DMA mode
; ------------------------------
cmd_exit_autoinit16:
		clr		dma_16bit_mode
		ljmp	cmdg_d_exit

; ------------------------------
; 0f2h: command DD
; ------------------------------
cmd_DD:	clr	p2.7
		ljmp	cmdg_d_exit

; ------------------------------
; 0fdh: command DC
; ------------------------------
cmd_DC:	setb	p2.7
		ljmp	cmdg_d_exit

; ------------------------------
; 50h: Command D0: Pause 8-bit DMA mode
; ------------------------------
cmd_dma8_pause:
		setb	pin_dma_emable1
		mov		r0,#4
		movx	a,@r0
		jb		acc.2,X0f0a
		clr		ex0
		lcall	X09f8
		ljmp	cmdg_d_exit

X0f0a:	mov		r0,#8
		movx	a,@r0
		anl		a,#0e7h
		orl		a,#42h
		movx	@r0,a
		mov		2eh,#64h
X0f15:	djnz	2eh,X0f15
		anl		a,#0a7h
		movx	@r0,a
		clr		ex1
		lcall	X09f8
		ljmp	cmdg_d_exit

; ------------------------------
; 7fh: Command D5: Pause 16-bit DMA mode
; ------------------------------
cmd_dma16_pause:
		mov		r0,#10h
		movx	a,@r0
		anl		a,#0e7h
		orl		a,#42h
		movx	@r0,a
		mov		2eh,#64h
X0f2e:	djnz	2eh,X0f2e
		anl		a,#0a7h
		movx	@r0,a
		setb	p2.4
		clr		ex1
		lcall	X09f8
		ljmp	cmdg_d_exit

; ------------------------------
; 94h: Command D4: Continue 8-bit DMA mode
; ------------------------------
cmd_dma8_resume:
		lcall	X09f2
		clr		pin_dma_emable1
		mov		r0,#4
		movx	a,@r0
		jb		acc.2,X0f4e
		setb	ex0
		ljmp	cmdg_d_exit

X0f4e:	mov		r0,#0ah
		movx	a,@r0
		push	acc
		mov		r0,#0dh
		movx	a,@r0
		push	acc
		mov		r0,#8
		movx	a,@r0
		orl		a,#3
		movx	@r0,a
		anl		a,#0feh
		movx	@r0,a
		mov		r0,#0ch
		pop		acc
		movx	@r0,a
		mov		r0,#0bh
		pop		acc
		movx	@r0,a
		mov		r0,#8
		mov		a,#6
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		mov		r0,#0ch
		mov		a,dma_blk_len_hi
		movx	@r0,a
		mov		r0,#0bh
		mov		a,dma_blk_len_lo
		movx	@r0,a
		setb	ea
		setb	ex1
		ljmp	cmdg_d_exit

; ------------------------------
; 0e0h: Command D6: Continue 16-bit DMA mode
; ------------------------------
cmd_dma16_resume:
		lcall	X09f2
		clr		p2.4
		mov		r0,#12h
		movx	a,@r0
		push	acc
		mov		r0,#15h
		movx	a,@r0
		push	acc
		mov		r0,#10h
		movx	a,@r0
		orl		a,#3
		movx	@r0,a
		anl		a,#0feh
		movx	@r0,a
		mov		r0,#14h
		pop		acc
		movx	@r0,a
		mov		r0,#13h
		pop		acc
		movx	@r0,a
		mov		r0,#10h
		mov		a,#6
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		mov		r0,#14h
		mov		a,rb1r5
		movx	@r0,a
		mov		r0,#13h
		mov		a,rb1r4
		movx	@r0,a
		setb	ea
		setb	ex1
		ljmp	cmdg_d_exit

; ------------------------------
; 10h: Command: Group D Exit
; ------------------------------
cmdg_d_exit:
		clr		pin_dsp_busy
		setb	ea
		ljmp	check_cmd

; ------------------------------
; Command group E: DSP identification
; ------------------------------
cmdg_ident:
		mov		dptr,#table_ident_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr
;
table_ident_cmds:
		.db	13h,56h,2dh,71h,25h,10h,10h,10h
		.db	1dh,10h,10h,10h,10h,10h,10h,10h

; ------------------------------
; 10h: command E5, E6, E7, E9, EA, EB, EC, ED, EE, EF
; ------------------------------
cmd_e_none:
	ljmp	cmdg_e_exit

; ------------------------------
; 13h: Command E0: Invert Bits
; ------------------------------
cmd_invert_bits:
		lcall	dsp_input_data
		cpl		a
		lcall	dsp_output_data
		ljmp	cmdg_e_exit

; ------------------------------
; 1dh: Command E8: Read test register
; ------------------------------
cmd_read_test_reg:
		mov		a,2ah
		lcall	dsp_output_data
		ljmp	cmdg_e_exit

; ------------------------------
; 25h: Command E4: Write test register
; ------------------------------
cmd_write_test_reg:
		lcall	dsp_input_data
		mov		2ah,a
		ljmp	cmdg_e_exit

; ------------------------------
; 2dh: Command E2: Firmware validation check. Uses challenge/response algorithm.
; ------------------------------
cmd_dsp_dma_id:
		mov		rb1r2,#3
		lcall	X114c
		lcall	dsp_input_data
		; dsp_dma_id0 += dsp_dma_id1 XOR challenge_byte
		xrl		a,dsp_dma_id1
		add		a,dsp_dma_id0
		mov		dsp_dma_id0,a
		; dsp_dma_id1 = dsp_dma_id1 >> 2 (actually a rotate)
		mov		a,dsp_dma_id1
		rr		a
		rr		a
		mov		dsp_dma_id1,a
		; Get current value of dsp_dma_id0 and send it to host PC (response)
		mov		a,dsp_dma_id0
		mov		r0,#1dh
		movx	@r0,a
		clr		pin_dma_emable1
		setb	pin_drequest
		clr		pin_drequest
X101c:	jb		pin_dav_pc,X101c
		nop	
		setb	pin_dma_emable1
		ljmp	cmdg_e_exit

; ------------------------------
; 56h: Command E1: Get DSP version
; ------------------------------
cmd_dsp_version:
		; Locate dsp version number
		mov		dptr,#dsp_version
		clr		a
		movc	a,@a+dptr
X102a:	; Transmit major version number
		jb		pin_dav_pc,X102a
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
		mov		a,#1
		movc	a,@a+dptr
X1035:	; Transmit minor version number
		jb		pin_dav_pc,X1035
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
		ljmp	cmdg_e_exit

; ------------------------------
; 71h: Command E3: Get Copyright Notice
; ------------------------------
cmd_dsp_copyright:
		mov		dptr,#dsp_copyright
		clr		a
X1044:	mov		b,a
		movc	a,@a+dptr
		lcall	dsp_output_data
		jz		cmdg_e_exit
		mov		a,b
		inc		a
		sjmp	X1044

; ------------------------------
; 10h: Command: Group E Exit
; ------------------------------
cmdg_e_exit:
		clr		pin_dsp_busy
		ljmp	wait_for_cmd

; ------------------------------
; ADPCM routines
; ------------------------------
; Register uses:
; r2 = ADPCM output sample
; r3 = Number of packed samples remaining in current data byte
; r5 = ADPCM accumulator
; r6 = Current data byte being decoded
; ------------------------------
; ADPCM 2-bit decode routine
; ------------------------------
adpcm_2_decode:
		; Take current data byte, examine
		; the two MSBs.
		mov		a,r6
		rlc		a
		jc		adpcm_2_decode_negative
		; Sign bit is positive, so continue
		rlc		a
		; Store it back to the data byte since we know the two MSBs now.
		mov		r6,a
		mov		a,r5
		jc		X106e
		; So far the value is 00.
		; delta = r5 / 2
		rrc		a
		mov		r5,a
		jnz		X1066
		; If r5 = 0, then set it to 1.
		inc		r5
		sjmp	adpcm_2_output

X1066:	; r5 != 0 case
		; Add delta to output sample, then store in output sample.
		add		a,r2
		jnc		X106b
		; If there is a carry out, then saturate it to FF.
		; BUG in v4.05
		; Should be #0ffh.
		mov		a,0ffh
X106b:	mov		r2,a
		sjmp	adpcm_2_output

X106e:	; The value is 01.
		clr		c
		; delta = (r5 / 2) + r5
		rrc		a
		add		a,r5
		; Add delta to output sample
		add		a,r2
		jnc		X1076
		; If there is a carry out, saturate it to ffh.
		mov		a,#0ffh
X1076:	; Store the result back to the output sample
		mov		r2,a
		cjne	r5,#20h,X107c
		sjmp	adpcm_2_output

X1247:	; If the ADPCM accumulator != 20h, then multiply it by two.
X107c:	mov		a,r5
		add		a,r5
		mov		r5,a
		sjmp	adpcm_2_output
		; Incoming bits are either 10 or 11. (sign bit is negative)
adpcm_2_decode_negative:
		; Get the next bit
		rlc		a
		; Save r6 shifted left by two, lining up the next 2 bits for us.
		mov		r6,a
		; Get the ADPCM accumulator value
		mov		a,r5
		jc		X1096
		; Incoming bits are 10.
		rrc		a
		; delta = r5 / 2
		mov		r5,a
		jnz		X108d
		; If ADPCM accumulator is 0, set it to 1.
		inc		r5
		sjmp	adpcm_2_output

X108d:	; a = Current output sample - delta
		xch		a,r2
		clr		c
		subb	a,r2
		jnc		X1093
		; Saturate the result at 0 if a borrow occurred.
		clr		a
X1093:	; Output the resulting sample
		mov		r2,a
		sjmp	adpcm_2_output

X1096:	; Incoming bits are 11.
		clr		c
		rrc		a
		; delta = (r5 / 2) + r5
		add		a,r5
		xch		a,r2
		clr		c
		; a = Current output sample - delta
		subb	a,r2
		jnc		X109f
		; Saturate the result at 0 if a borrow occurred.
		clr		a
X109f:	; Output the result.
		mov		r2,a
		cjne	r5,#20h,X10a5
		sjmp	adpcm_2_output

X10a5:	; If the ADPCM accumulator != 20h, then multiply it by two.
		mov		a,r5
		add		a,r5
		mov		r5,a
adpcm_2_output:
		mov		a,r2
		mov		r0,#19h
		movx	@r0,a
		ret	

; ------------------------------
; ADPCM 4-bit decode routine
; ------------------------------
adpcm_4_decode:
		mov		a,r5
		clr		c
		rrc		a
		; 27h <- r5 / 2
		mov		27h,a
		; rb2r0 <- r6 (current data byte)
		mov		a,r6
		mov		rb2r0,a
		; Get the most significant nybble of the incoming data
		swap	a
		; Store it back (we process the other nybble later)
		mov		r6,a
		; Mask off the three least significant bits
		anl		a,#7
		; Store in 28h
		mov		28h,a
		; delta = nybble * ADPCM accumulator + (ADPCM accumulator / 2)
		mov		b,r5
		mul		ab
		add		a,27h
		; And store the result in 29h (delta)
		mov		vector_low,a
		; Grab original data byte again 
		mov		a,rb2r0
		rlc		a
		; Check MSB (the sign bit)
		jc		X10d1
		; MSB is zero, so value is positive. Add the delta to the
		; current sample output value.
		mov		a,vector_low
		add		a,r2
		jnc		X10d8
		; Saturate it to FFh if there was a carry.
		mov		a,#0ffh
		ljmp	X10d8

X10d1:	; Sign bit is negative
		mov		a,r2
		; Subtract the delta from the current sample output value.
		clr		c
		subb	a,vector_low
		jnc		X10d8
		; Saturate it at 00h if there was a borrow.
		clr		a
X10d8:	; Set the new sample output value to what we calculated just now
		mov		r2,a
		; Check original 4-bit value to see if it is zero
		mov		a,28h
		jz		X10ec
		; It is not zero, so subtract five
		clr		c
		subb	a,#5
		jc		adpcm_4_output
		; Take ADPCM accumulator, multiply by two.
		mov		a,r5
		rl		a
		cjne	a,#10h,X10f2
		; If it is 10h, make it 8.
		mov		a,#8
		ljmp	X10f2
X10ec:	; Value coming in is zero
		; Get old r5/2 value
		mov		a,27h
		; Store it to r5 unless it's zero; in that case, set r5=1.
		jnz		X10f2
		mov		a,#1

X10f2:	; Store ADPCM accumulator
		mov		r5,a
adpcm_4_output:
		mov		a,r2
		mov		r0,#19h
		movx	@r0,a
		ret	

; ------------------------------
; ADPCM 2.6-bit decode routine
; ------------------------------
adpcm_2_6_decode:
		; 27h = r5 / 2.
		mov		a,r5
		clr		c
		rrc		a
		mov		27h,a
		; rb2r0 = r6 (Store off incoming data)
		mov		a,r6
		mov		rb2r0,a
		; Grab two bits
		rl		a
		rl		a
		cjne	r3,#1,X110a
		; Bytes remaining = 1, this is the special case
		; Throw away everything except for the LSB.
		anl		a,#1
		ljmp	X110b

X110a:	; "Normal" case where bytes remaining != 1.
		; Grab the 3rd bit
		rl		a
X110b:	; Store back to current data byte (so we can grab the next one next
		; time around).
		mov		r6,a
		; Mask off so we just have the three bits we want
		anl		a,#3
		; Store in 28h
		mov		28h,a
		; Fetch ADPCM accumulator, multiply it by our 3-bit value
		mov		b,r5
		mul		ab
		; Take LSB of result and add r5 / 2 to it.
		; delta = bits * ADPCM accumulator + (ADPCM accumulator / 2)
		add		a,27h
		; Store the result in 29h (delta)
		mov		vector_low,a
		; Get the original version of our incoming data byte back
		mov		a,rb2r0
		rlc		a
		; Check the sign bit
		jc		X1126
		; Positive, so get our result again and add it to the current output
		; sample
		mov		a,vector_low
		add		a,r2
		jnc		X112d
		; Saturate it at FFh if there was a carry.
		mov		a,#0ffh
		ljmp	X112d

X1126:	; Sign bit is negative so we subtract it from our current output sample
		mov		a,r2
		clr		c
		subb	a,vector_low
		jnc		X112d
		; Saturate it at 00h if there was a borrow.
		clr		a
X112d:	; Store it back to the current output sample
		mov		r2,a
		; Get the three bits again
		mov		a,28h
		jz		X1140
		cjne	a,#3,adpcm_2_6_output
		; The three bits were 011, so check our accumulator
		cjne	r5,#10h,X113b
		; ADPCM accumulator is 10h, so just output the sample
		ljmp	adpcm_2_6_output

X113b:	; ADPCM accumulator wasn't 10h, so multiply it by two.
		mov		a,r5
		rl		a
		ljmp	X1146

X1140:	; Original 3 bits were 000
		mov		a,27h
		; New reference value (r5) becomes r5 / 2 unless it was 0, in which
		; case it becomes 1.
		jnz		X1146
		mov		a,#1
X1146:	; Store ADPCM accumulator
		mov		r5,a
adpcm_2_6_output:
		mov		a,r2
		mov		r0,#19h
		movx	@r0,a
		ret	

; ------------------------------
; ?
; ------------------------------
X114c:	push	acc
		mov		r0,#4
		movx	a,@r0
		anl		a,#0f0h
		orl		a,rb1r2
		mov		rb1r2,a
		movx	@r0,a
		pop		acc
		ret	

; ------------------------------
; ?
; ------------------------------
X115b:	mov		r0,#0eh
		mov		a,#7
		movx	@r0,a
		mov		a,#4
		movx	@r0,a
		ret	

; ------------------------------
; ?
; ------------------------------
dsp_input_data:
		jnb		pin_dav_dsp,dsp_input_data
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		ret	

; ------------------------------
; ?
; ------------------------------
dsp_output_data:
		jb		pin_dav_pc,dsp_output_data
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
		ret	

; ------------------------------
; ?
; ------------------------------
X1176:	mov		r0,#0eh
		mov		a,#7
		movx	@r0,a
		mov		a,#6
		movx	@r0,a
		ret	

; ------------------------------
; ?
; ------------------------------
X117f:	mov		r0,#16h
		mov		a,#7
		movx	@r0,a
		mov		a,#6
		movx	@r0,a
		ret	

; ------------------------------
; ?
; ------------------------------
X1188:	mov		r0,#0eh
		mov		a,#3
		movx	@r0,a
		mov		a,#2
		movx	@r0,a
		ret	

; ------------------------------
; ?
; ------------------------------
X1191:	mov		r0,#16h
		mov		a,#3
		movx	@r0,a
		mov		a,#2
		movx	@r0,a
		ret	

; ------------------------------
; Unimplemented CSP Diagnostics Routine
; ------------------------------
X119a:	mov		a,#0
		mov		r0,#80h
		movx	@r0,a
		mov		r0,#81h
		movx	@r0,a
		mov		len_left_lo,#0bbh
		mov		len_left_hi,#3
		mov		a,#8ch
		mov		r0,#82h
		movx	@r0,a
		mov		a,#8ah
		mov		r0,#82h
		movx	@r0,a
		mov		dptr,#asp_code
X11b5:	mov		a,#0
		movc	a,@a+dptr
		mov		r0,#83h
		movx	@r0,a
		cjne	a,len_left_lo,X11d0
		cjne	a,len_left_hi,X11ce
		mov		a,#0
		mov		r0,#82h
		movx	@r0,a
		mov		a,#70h
		mov		r0,#82h
		movx	@r0,a
		ljmp	X11d5

X11ce:	dec		len_left_hi
X11d0:	dec		len_left_lo
		inc		dptr
		sjmp	X11b5

X11d5:	ret	

; ------------------------------
; CSP Chip Data?
; ------------------------------
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

; ------------------------------
; Copyright notice
; ------------------------------
dsp_copyright:
		.db	43h,4fh,50h,59h,52h,49h,47h,48h
		.db	54h,20h,28h,43h,29h,20h,43h,52h
		.db	45h,41h,54h,49h,56h,45h,20h,54h
		.db	45h,43h,48h,4eh,4fh,4ch,4fh,47h
		.db	59h,20h,4ch,54h,44h,2ch,20h,31h
		.db	39h,39h,32h,2eh,0

; ------------------------------
; DSP version number
; ------------------------------
dsp_version:	
		.db	4,5

; ------------------------------
; Unused data?
; ------------------------------
unused:	
		.db	67h,12h,7fh,8ch,98h,0a4h,0b0h,0bbh
		.db	0c6h,0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h
		.db	0fch,0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h
		.db	0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h
		.db	98h,8ch,80h,8ch,98h,0a4h,0b0h,0bbh
		.db	0c6h,0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h
		.db	0fch,0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h
		.db	0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h
		.db	98h,8ch,7fh,73h,67h,5bh,4fh,44h
		.db	39h,2fh,26h,1dh,16h,0fh,0ah,6
		.db	3,1,1,1,3,6,0ah,0fh
		.db	16h,1dh,26h,2fh,39h,44h,4fh,5bh
		.db	67h,73h,80h,8ch,98h,0a4h,0b0h,0bbh
		.db	0c6h,0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h
		.db	0fch,0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h
		.db	0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h
		.db	98h,8ch,46h,4bh,50h,4dh,52h,5eh
		.db	66h,64h,6eh,7ch,88h,80h,8dh,8fh
		.db	8ch,76h,78h,80h,82h,7dh,87h,8eh
		.db	90h,94h,0a2h,0bah,0c1h,0c2h,0c5h,0c4h
		.db	7fh,73h,67h,5bh,4fh,44h,39h,2fh
		.db	26h,1dh,16h,0fh,0ah,6,3,1
		.db	1,1,3,6,4ch,0b0h,0aeh,0b0h
		.db	0b2h,9eh,9ch,9bh,9ch,0a4h,0b0h,7fh
		.db	73h,67h,5bh,4fh,44h,39h,2fh,26h
		.db	1dh,0bch,0b8h,0b0h,0b2h,9dh,98h,91h
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
		.db	8fh,8ch,76h,78h,80h,82h,7dh,7fh
		.db	73h,67h,5bh,4fh,44h,39h,2fh,26h
		.db	1dh,87h,8eh,90h,94h,0a2h,0bah,0c1h
		.db	0c2h,0c5h,0c4h,0e9h,0f0h,0f5h,0f9h,0fch
		.db	0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h,0e9h
		.db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h
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
		.db	8fh,8ch,76h,78h,80h,82h,7dh,98h
		.db	8ch,80h,8ch,98h,0a4h,0b0h,0bbh,0c6h
		.db	0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch
		.db	0feh,0ffh,0feh,98h,8ch,80h,8ch,98h
		.db	0a4h,0b0h,0bbh,0c6h,0d0h,0d9h,0e2h,0e9h
		.db	0f0h,0f5h,0f9h,0fch,0feh,0ffh,0feh,87h
		.db	8eh,90h,94h,0a2h,0bah,0c1h,0c2h,0c5h
		.db	0c4h,98h,8ch,80h,8ch,98h,0a4h,0b0h
		.db	0bbh,0c6h,0d0h,0d9h,0e2h,0e9h,0f0h,0f5h
		.db	0f9h,0fch,0feh,0ffh,0feh,0fch,0f9h,0f5h
		.db	0f0h,0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h
		.db	0a4h,98h,8ch,7fh,73h,67h,5bh,4fh
		.db	44h,39h,2fh,26h,1dh,16h,0fh,0ah
		.db	6,3,1,1,1,3,6,0ah
		.db	0fh,16h,1dh,26h,2fh,39h,44h,4fh
		.db	5bh,67h,73h,80h,8ch,98h,0a4h,0b0h
		.db	0bbh,0c6h,0d0h,0d9h,0e2h,0e9h,0f0h,0f5h
		.db	0f9h,0fch,0feh,0ffh,0feh,0fch,0f9h,0f5h
		.db	0f0h,0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h
		.db	0a4h,98h,8ch,46h,4bh,50h,4dh,52h
		.db	5eh,66h,64h,6eh,7ch,88h,80h,8dh
		.db	8fh,8ch,76h,78h,80h,82h,7dh,87h
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
		.db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h
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
		.db	7dh,98h,8ch,80h,8ch,98h,0a4h,0b0h
		.db	0bbh,0c6h,0d0h,0d9h,0e2h,0e9h,0f0h,0f5h
		.db	0f9h,0fch,0feh,0ffh,0feh,98h,8ch,80h
		.db	8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h,0d9h
		.db	0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh,0ffh
		.db	0feh,87h,8eh,90h,94h,0a2h,0bah,0c1h
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
		.db	80h,82h,7dh,87h,8eh,90h,94h,0a2h
		.db	0bah,0c1h,0c2h,0c5h,0c4h,0e9h,0f0h,0f5h
		.db	0f9h,0fch,0feh,0ffh,0feh,0fch,0f9h,0f5h
		.db	0f0h,0e9h,0e2h,0d9h,0d0h,0c6h,0bbh,0b0h
		.db	0a4h,7fh,8ch,98h,0a4h,0b0h,0bbh,0c6h
		.db	0d0h,0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch
		.db	0feh,0ffh,0feh,0fch,0f9h,0f5h,0f0h,0e9h
		.db	0e2h,0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h
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
		.db	0feh,98h,8ch,80h,8ch,98h,0a4h
