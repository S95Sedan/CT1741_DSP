; 8052 Disassembly of SB DSP version 3.02

; ------------------------------
; Register/Memory Equates
; ------------------------------
.EQU ram_samples_x2, 10h
.EQU ram_pb_count, 11h
.EQU ram_pb_count2, 12h
.EQU ram_pb_unused, 13h
.EQU ram_loops2, 14h
.EQU ram_loops, 15h
.EQU ram_pb_unused2, 16h
.EQU rb2r7, 17h
.EQU time_constant, 18h
.EQU rb3r1, 19h
.EQU ram_smps_left,	1ah
.EQU length_low, 1bh
.EQU length_high, 1ch
.EQU dma_blk_len_lo, 1dh
.EQU dma_blk_len_hi, 1eh
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
.EQU port_dac_out, 90h

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
.EQU dma_mode_on, len_left_lo
.EQU dma_8bit_mode, len_left_hi
.EQU dma_16bit_mode, 24h
.EQU midi_timestamp, dsp_dma_id0
;

		.org	0
;
RESET:
		ljmp	start
;
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
;
		.org	0bh

; ------------------------------
; Timer/Counter 0 Interrupt Vector
; ------------------------------
int0_vector:
		jb		24h.5,hs_int
		jb		24h.3,midi_timestamp_int
		setb	int1
		push	acc
		push	dpl
		push	dph
		mov		dpl,2ch
		mov		dph,2dh
		clr		a
		jmp		@a+dptr

; ------------------------------
; Handles MIDI timestamp counter.
; ------------------------------
midi_timestamp_int:
		inc		r5
		cjne	r5,#0,X002a
		inc		r6
		cjne	r6,#0,X002a
		inc		r7
X002a:	mov		tl0,#17h
		mov		th0,#0fch
		reti

; ------------------------------
; Handle fast sample playback/record modes. These did not exist in the
; original SB firmware and were added later, removing interrupt overhead
; to allow for higher sample rates.
; ------------------------------
hs_int:	
		jb		24h.6,get_adc_sample
		setb	t1
		clr		t1
X0038:	jnb		p2.7,X0038
		movx	a,@r0
		mov		port_dac_out,a
		cjne	r6,#0,X0064
		cjne	r7,#0,X0063
		clr		int0
		setb	int0
		jb		command_byte_0,X0052
		mov		r6,dma_blk_len_lo
		mov		r7,dma_blk_len_hi
		ljmp	X0065

X0052:	clr		et0
		clr		tr0
		setb	t0
		mov		2eh,#0
		mov		2fh,#0
		clr		24h.5
		ljmp	X0065

X0063:	dec		r7
X0064:	dec		r6
X0065:	reti

; ------------------------------
; Collects a sample from the microphone input. This routine uses a SAR
; algorithm (successive approximation).
; ------------------------------
get_adc_sample:
		clr		p2.4
		mov		a,port_dac_out
		setb	p2.4
X006c:	jb		p2.6,X006c
		movx	@r0,a
		setb	t1
		clr		t1
		cjne	r6,#0,X009a
		cjne	r7,#0,X0099
		clr		int0
		setb	int0
		jb		command_byte_0,X0088
		mov		r6,dma_blk_len_lo
		mov		r7,dma_blk_len_hi
		ljmp	X009b

X0088:	clr		et0
		clr		tr0
		setb	t0
		mov		2eh,#0
		mov		2fh,#0
		clr		24h.5
		ljmp	X009b

X0099:	dec		r7
X009a:	dec		r6
X009b:	reti

; ------------------------------
; Vector for DAC playback, 8-bit DMA mode
; ------------------------------
vector_dma_dac_8:
		jnb		p2.7,X00a4
		setb	24h.0
		ljmp	vector_dma_dac_8_end

X00a4:	setb	t1
		clr		t1
X00a8:	jnb		p2.7,X00a8
		movx	a,@r0
		mov		port_dac_out,a
		clr		a
		cjne	a,len_left_lo,X00f3
		cjne	a,len_left_hi,X00f1
		jb		24h.4,X00be
		jb		24h.1,X00e0
		jb		24h.2,X00d3
X00be:	clr		24h.1
		clr		24h.2
		clr		24h.4
		clr		et0
		clr		tr0
		clr		int0
		setb	int0
		clr		status_register.7
		setb	t0
		ljmp	vector_dma_dac_8_end

X00d3:	mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		clr		int0
		setb	int0
		ljmp	vector_dma_dac_8_end

X00e0:	clr		24h.2
		clr		24h.1
		mov		len_left_lo,length_low
		mov		len_left_hi,length_high
		clr		int0
		setb	int0
		ljmp	vector_dma_dac_8_end

X00f1:	dec		len_left_hi
X00f3:	dec		len_left_lo
vector_dma_dac_8_end:
		clr		int1
		pop		dph
		pop		dpl
		pop		acc
		reti

; ------------------------------
; Vector for DAC playback, 2-bit ADPCM
; ------------------------------
vector_dma_dac_adpcm2:
		jnb		p2.7,X0106
		setb	24h.0
		ljmp	vector_dma_dac_adpcm2_end

X0106:	dec		r3
		cjne	r3,#0,vector_dma_dac_adpcm2_shiftin
		clr		a
		cjne	a,len_left_lo,X0165
		cjne	a,len_left_hi,X0163
		jb		24h.4,X011a
		jb		24h.1,X0147
		jb		24h.2,X012f
X011a:	clr		24h.1
		clr		24h.2
		clr		24h.4
		clr		et0
		clr		tr0
		clr		int0
		setb	int0
		clr		status_register.4
		setb	t0
		ljmp	vector_dma_dac_adpcm2_end

X012f:	mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		setb	t1
		clr		t1
X0139:	jnb		p2.7,X0139
		movx	a,@r0
		mov		r6,a
		mov		r3,#4
		clr		int0
		setb	int0
		ljmp	vector_dma_dac_adpcm2_end

X0147:	clr		24h.2
		clr		24h.1
		mov		len_left_lo,length_low
		mov		len_left_hi,length_high
		setb	t1
		clr		t1
X0155:	jnb		p2.7,X0155
		movx	a,@r0
		mov		r6,a
		mov		r3,#4
		clr		int0
		setb	int0
		ljmp	vector_dma_dac_adpcm2_end

X0163:	dec		len_left_hi
X0165:	dec		len_left_lo
		mov		r3,#4
		setb	t1
		clr		t1
X016d:	jnb		p2.7,X016d
		movx	a,@r0
		mov		r6,a
vector_dma_dac_adpcm2_shiftin:
		lcall	adpcm_2_decode
vector_dma_dac_adpcm2_end:
		clr		int1
		pop		dph
		pop		dpl
		pop		acc
		reti

; ------------------------------
; Vector for DAC playback, 4-bit ADPCM
; ------------------------------
vector_dma_dac_adpcm4:
		jnb		p2.7,X0186
		setb	24h.0
		ljmp	vector_dma_dac_adpcm4_end

X0186:	dec		r3
		cjne	r3,#0,vector_dma_dac_adpcm4_shiftin
		clr		a
		cjne	a,len_left_lo,X01e5
		cjne	a,len_left_hi,X01e3
		jb		24h.4,X019a
		jb		24h.1,X01c7
		jb		24h.2,X01af
X019a:	clr		24h.1
		clr		24h.2
		clr		24h.4
		clr		et0
		clr		tr0
		clr		int0
		setb	int0
		clr		status_register.6
		setb	t0
		ljmp	vector_dma_dac_adpcm4_end

X01af:	mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		setb	t1
		clr		t1
X01b9:	jnb		p2.7,X01b9
		movx	a,@r0
		mov		r6,a
		mov		r3,#2
		clr		int0
		setb	int0
		ljmp	vector_dma_dac_adpcm4_end

X01c7:	clr		24h.2
		clr		24h.1
		mov		len_left_lo,length_low
		mov		len_left_hi,length_high
		setb	t1
		clr		t1
X01d5:	jnb		p2.7,X01d5
		movx	a,@r0
		mov		r6,a
		mov		r3,#2
		clr		int0
		setb	int0
		ljmp	vector_dma_dac_adpcm4_end

X01e3:	dec		len_left_hi
X01e5:	dec		len_left_lo
		mov		r3,#2
		setb	t1
		clr		t1
X01ed:	jnb		p2.7,X01ed
		movx	a,@r0
		mov		r6,a
vector_dma_dac_adpcm4_shiftin:
		lcall	adpcm_4_decode
vector_dma_dac_adpcm4_end:
		clr		int1
		pop		dph
		pop		dpl
		pop		acc
		reti

; ------------------------------
; Vector for DAC playback, 2.6-bit ADPCM
; ------------------------------
vector_dma_dac_adpcm2_6:
		jnb		p2.7,X0206
		setb	24h.0
		ljmp	vector_dma_dac_adpcm2_6_end

X0206:	dec		r3
		cjne	r3,#0,vector_dma_dac_adpcm2_6_shiftin
		clr		a
		cjne	a,len_left_lo,X0265
		cjne	a,len_left_hi,X0263
		jb		24h.4,X021a
		jb		24h.1,X0247
		jb		24h.2,X022f
X021a:	clr		24h.1
		clr		24h.2
		clr		24h.4
		clr		et0
		clr		tr0
		clr		int0
		setb	int0
		clr		status_register.5
		setb	t0
		ljmp	vector_dma_dac_adpcm2_6_end

X022f:	mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		setb	t1
		clr		t1
X0239:	jnb		p2.7,X0239
		movx	a,@r0
		mov		r6,a
		mov		r3,#3
		clr		int0
		setb	int0
		ljmp	vector_dma_dac_adpcm2_6_end

X0247:	clr		24h.2
		clr		24h.1
		mov		len_left_lo,length_low
		mov		len_left_hi,length_high
		setb	t1
		clr		t1
X0255:	jnb		p2.7,X0255
		movx	a,@r0
		mov		r6,a
		mov		r3,#3
		clr		int0
		setb	int0
		ljmp	vector_dma_dac_adpcm2_6_end

X0263:	dec		len_left_hi
X0265:	dec		len_left_lo
		mov		r3,#3
		setb	t1
		clr		t1
X026d:	jnb		p2.7,X026d
		movx	a,@r0
		mov		r6,a
vector_dma_dac_adpcm2_6_shiftin:
		lcall	adpcm_2_6_decode
vector_dma_dac_adpcm2_6_end:
		clr		int1
		pop		dph
		pop		dpl
		pop		acc
		reti

; ------------------------------
; Vector for DAC playback of silence.
; ------------------------------
vector_dac_silence:
		jnb		p2.7,X0286
		setb	24h.0
		ljmp	vector_dac_silence_end

X0286:	clr		a
		cjne	a,len_left_lo,X029e
		cjne	a,len_left_hi,X029c
		clr		et0
		clr		tr0
		clr		int0
		setb	int0
		clr		status_register.3
		setb	t0
		ljmp	vector_dac_silence_end

X029c:	dec		len_left_hi
X029e:	dec		len_left_lo
vector_dac_silence_end:
		clr		int1
		pop		dph
		pop		dpl
		pop		acc
		reti

; ------------------------------
; Vector for 8-bit DMA recording.
; ------------------------------
vector_dma_adc:
		jnb		p2.7,X02b1
		setb	24h.0
		ljmp	vector_dma_adc_end

X02b1:	clr		p2.4
		mov		a,port_dac_out
		setb	p2.4
X02b7:	jb		p2.6,X02b7
		movx	@r0,a
		setb	t1
		clr		t1
		clr		a
		cjne	a,len_left_lo,X0307
		cjne	a,len_left_hi,X0305
		jb		24h.4,X02cf
		jb		24h.1,X02f4
		jb		24h.2,X02e7
X02cf:	clr		24h.1
		clr		24h.2
		clr		24h.4
		clr		et0
		clr		tr0
X02d9:	jb		p2.6,X02d9
		clr		int0
		setb	int0
		clr		status_register.2
		setb	t0
		ljmp	vector_dma_adc_end

X02e7:	mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		clr		int0
		setb	int0
		ljmp	vector_dma_adc_end

X02f4:	clr		24h.2
		clr		24h.1
		mov		len_left_lo,length_low
		mov		len_left_hi,length_high
		clr		int0
		setb	int0
		ljmp	vector_dma_adc_end

X0305:	dec		len_left_hi
X0307:	dec		len_left_lo
vector_dma_adc_end:
		clr		int1
		pop		dph
		pop		dpl
		pop		acc
		reti

; ------------------------------
; Vector for DAC playback from onboard SRAM
; ------------------------------
vector_cmd_ram_playback:
		mov		a,@r1
		mov		port_dac_out,a
		inc		r1
		djnz	ram_smps_left,vector_cmd_ram_playback_end
		mov		r1,#40h
		djnz	ram_loops,X0321
		mov		ram_loops,ram_pb_count2
X0321:	djnz	ram_loops2,vector_cmd_ram_playback_end
		clr		tr0
		clr		et0
vector_cmd_ram_playback_end:
		clr		int1
		pop		dph
		pop		dpl
		pop		acc
		reti

; ------------------------------
; Vector for sine wave playback
; ------------------------------
vector_sine:
		mov		a,@r1
		mov		port_dac_out,a
		mov		a,r7
		add		a,r1
		cjne	a,#7fh,X033c
		ljmp	X033e

X033c:	jnc		X0342
X033e:	mov		r1,a
		ljmp	X0344

X0342:	mov		r1,#40h
X0344:	clr		int1
		pop		dph
		pop		dpl
		pop		acc
		reti

; ------------------------------
; Start: Where we begin.
; ------------------------------
start:	setb	int1
		setb	pt0
		mov		sp,#30h
		clr		t1
		setb	t0
		setb	wr
		setb	rd
		setb	p2.4
		mov		scon,#42h
		mov		th1,#0feh
		mov		tl1,#0feh
		mov		tmod,#len_left_hi
		mov		pcon,#80h
		setb	tr1
		setb	ren
		mov		port_dac_out,#0ffh
		clr		p2.4
		mov		a,port_dac_out
		setb	p2.4
		mov		a,#34h
		cjne	a,2eh,cold_boot
		mov		a,#12h
		cjne	a,2fh,cold_boot
		mov		2eh,#0
		mov		2fh,#0
		jnb		status_register.0,X0392
		mov		port_dac_out,#80h
		clr		p2.0
X0392:	jb		status_register.1,warm_boot
		clr		p2.3
		ljmp	warm_boot

; ------------------------------
; Cold boot startup.
; ------------------------------
cold_boot:
		mov		port_dac_out,#80h
		mov		rb2r7,#80h
		mov		ram_loops,#0
		mov		r7,#2
		mov		time_constant,#9ch
		mov		dsp_dma_id0,#0aah
		mov		dsp_dma_id1,#96h
		mov		r0,#40h
		mov		r1,#40h
		mov		r4,#40h
		mov		dma_blk_len_lo,#0ffh
		mov		dma_blk_len_hi,#7
		clr		p2.3
		clr		p2.2
		mov		status_register,#0

; ------------------------------
; Warm boot, so we skipped over some initialization.
; ------------------------------
warm_boot:
		mov		a,time_constant
		mov		th0,a
		mov		tl0,a
		mov		24h,#0
		mov		r3,#0
		setb	ea
		clr		int1
		mov		a,#0aah
X03d2:	jb		p2.6,X03d2
		movx	@r0,a

; ------------------------------
; Check for incoming commands. This is the start of the command monitoring
; loop, where we read commands, dispatch them, and then return back here.
; ------------------------------
check_cmd:
		jb		24h.0,X03dc
wait_for_cmd:
		jnb		p2.7,wait_for_cmd
X03dc:	clr		tr0
		setb	int1
		clr		24h.0
		movx	a,@r0
		mov		20h,a
		swap	a
		anl		a,#0fh
		cjne	a,#0dh,dispatch_cmd
		lcall	cmdg_misc
		jnb		et0,wait_for_cmd
		setb	tr0
		sjmp	wait_for_cmd

; ------------------------------
; Dispatches a command.
; ------------------------------
dispatch_cmd:
		mov		dptr,#table_major_cmds
		movc	a,@a+dptr
		jmp		@a+dptr

table_major_cmds:
		.db	5fh,11h,1ah,1fh,35h,3dh,55h,14h
		.db	45h,17h,5ah,55h,55h,55h,4dh,2dh
		.db	55h

; ------------------------------
; 11h: command group 1: Audio playback - First
cmdg_dac:				ljmp	cmdg_dac_e
; ------------------------------
; 14h: command group 7: Audio playback - Second
cmdg_dac2:				ljmp	cmdg_dac2_e
; ------------------------------
; 17h: command group 9: High speed
cmdg_hs:				ljmp	cmdg_hs_e
; ------------------------------
; 1ah: command group 2: Recording
cmdg_adc:				clr		int1
						ljmp	cmdg_adc_e
; ------------------------------
; 1fh: command group 3: MIDI commands
cmdg_midi:				clr		int1
						jnb		t0,X0421
						ljmp	do_midi_cmd
						
						X0421:	jnb	command_byte_3,continue_dma_op
						ljmp	do_midi_cmd
; ------------------------------
; 2dh: command group F: Auxiliary commands
cmdg_aux:				clr		int1
						jnb		t0,continue_dma_op
						ljmp	cmdg_aux_e
; ------------------------------
; 27h: command group 4: Setup
cmdg_setup:				clr		int1
						jnb		t0,continue_dma_op
						ljmp	cmdg_setup_e
; ------------------------------
; 3dh: command group 5: RAM playback
cmdg_ram_playback:		clr		int1
						jnb		t0,continue_dma_op
						ljmp	cmdg_ram_playback_e
; ------------------------------
; 45h: command group 8: Generate silence
cmdg_silence:			clr		int1
						jnb		t0,continue_dma_op
						ljmp	cmdg_silence_e
; ------------------------------
; 4dh: command group E: DSP identification
cmdg_ident:				clr		int1
						jnb		t0,continue_dma_op
						ljmp	cmd_ident_e
; ------------------------------
; length_high: command group x: Something
cmdg_something:			clr		int1
						jb		t0,check_cmd
						clr		int1
						ljmp	cmdg_something_e

; ------------------------------
; Command group 0: status
; ------------------------------
cmdg_status:
		clr		int1
cmd_halt:
		jb		command_byte_3,cmd_halt
		jnb		command_byte_2,X046a
		mov		a,status_register
X0463:	jb		p2.6,X0463
		movx	@r0,a
		jnb		t0,continue_dma_op
X046a:	ljmp	wait_for_cmd

continue_dma_op:
		setb	tr0
		ljmp	check_cmd

; ------------------------------
; Command group 0: status
; ------------------------------
cmdg_setup_e:
		jb		command_byte_3,cmd_set_dma_block_size
X0475:	jnb		p2.7,X0475
		movx	a,@r0
		mov		th0,a
		mov		tl0,a
		mov		time_constant,a
		ljmp	wait_for_cmd

cmd_set_dma_block_size:
		jnb		p2.7,cmd_set_dma_block_size
		movx	a,@r0
		mov		dma_blk_len_lo,a
X0488:	jnb		p2.7,X0488
		movx	a,@r0
		mov		dma_blk_len_hi,a
		ljmp	wait_for_cmd

; ------------------------------
; Command group 0: status
; ------------------------------
cmdg_something_e:
		jnb		command_byte_3,X049d
		clr		p2.3
		setb	p2.3
		setb	status_register.1
		ljmp	X04a4

X049d:	clr	p2.3
		clr		status_register.1
		ljmp	X04ae

X04a4:	jnb		command_byte_2,cmdg_invalid
		setb	p2.2
		ljmp	X04ae

; ------------------------------
; 55h: command groups 6, A, B, C, and D are unimplemented.
; ------------------------------
cmdg_invalid:
		clr		p2.2
X04ae:	ljmp	wait_for_cmd

; ------------------------------
; Command group F: Auxiliary commands
; ------------------------------
cmdg_aux_e:
		jb		command_byte_3,cmd_sram_test
		jb		command_byte_2,cmd_checksum
		jb		command_byte_1,cmd_force_interrupt
		jb		command_byte_0,cmd_aux_status
		ljmp	cmd_sine_gen

; ------------------------------
; Command F2: Forced host PC interrupt
; ------------------------------
cmd_force_interrupt:
		clr		int0
		setb	int0
		ljmp	check_cmd

; ------------------------------
; Command F8: Test the internal SRAM from 7Fh to 00h.
; ------------------------------
cmd_sram_test:
		mov		r0,#7fh
		mov		a,#0aah
sram_test_loop1:
		mov		@r0,a
		cjne	@r0,#0aah,sram_test_end
		djnz	r0,sram_test_loop1
		mov		r0,#7fh
		mov		a,#55h
sram_test_loop2:
		mov		@r0,a
		cjne	@r0,#55h,sram_test_end
		djnz	r0,sram_test_loop2
sram_test_end:
		mov		a,r0
		movx	@r0,a
		ljmp	check_cmd

; ------------------------------
; Command F4: Perform ROM checksum
; ------------------------------
cmd_checksum:
		mov		r0,#0
		mov		r1,#0
		mov		dptr,#RESET
csum_loop:
		clr		a
		movc	a,@a+dptr
		add		a,r0
		mov		r0,a
		jnc		X04ee
		inc		r1
X04ee:	mov		a,dph
		cjne	a,#10h,csum_not_done
		ljmp	csum_done

csum_not_done:
		inc		dptr
		sjmp	csum_loop

csum_done:
		mov		a,r1
		movx	@r0,a
		mov		a,r0
X04fc:	jb		p2.6,X04fc
		movx	@r0,a
		ljmp	check_cmd

; ------------------------------
; Command F1: Get auxiliary DSP status
; ------------------------------
cmd_aux_status:
		mov		a,p2
X0505:	jb		p2.6,X0505
		movx	@r0,a
		ljmp	check_cmd

; ------------------------------
; Command F0: Generates sine wave
; ------------------------------
cmd_sine_gen:
		mov		r0,#40h
		mov		dptr,#sine_table
gen_sine_loop:
		clr		a
		movc	a,@a+dptr
		mov		@r0,a
		inc		dptr
		inc		r0
		cjne	r0,#80h,gen_sine_loop
		mov		r1,#40h
		mov		ram_loops,#0ffh
		mov		r7,#8
		mov		th0,#0c2h
		mov		dptr,#vector_sine
		mov		2ch,dpl
		mov		2dh,dph
		clr		p2.0
		setb	et0
		setb	tr0
		ljmp	check_cmd

sine_table:
		.db	7fh,73h,67h,5bh,4fh,44h,39h,2fh
		.db	26h,1dh,16h,0fh,0ah,6,3,1
		.db	1,1,3,6,0ah,0fh,16h,1dh
		.db	26h,2fh,39h,44h,4fh,5bh,67h,73h
		.db	80h,8ch,98h,0a4h,0b0h,0bbh,0c6h,0d0h
		.db	0d9h,0e2h,0e9h,0f0h,0f5h,0f9h,0fch,0feh
		.db	0ffh,0feh,0fch,0f9h,0f5h,0f0h,0e9h,0e2h
		.db	0d9h,0d0h,0c6h,0bbh,0b0h,0a4h,98h,8ch

; ------------------------------
; Command group 3: MIDI commands
; ------------------------------
do_midi_cmd:
		jb		command_byte_3,cmd_midi_write_poll
		jnb		command_byte_2,cmd_midi_read_write_poll
		mov		2eh,#34h
		mov		2fh,#12h
		ljmp	cmd_midi_read_write_poll

; ------------------------------
; Command 38: MIDI write poll.
; ------------------------------
cmd_midi_write_poll:
		jnb		ti,cmd_midi_write_poll
		clr		ti
X0589:	jnb		p2.7,X0589
		movx	a,@r0
		setb	tr0
		mov		sbuf,a
		ljmp	check_cmd

; ------------------------------
; Commands 34 to 37: MIDI read/write poll
; ------------------------------
cmd_midi_read_write_poll:
		jnb		command_byte_1,skip_midi_timestamp_setup
		mov		tmod,#len_left_lo
		setb	24h.3
		mov		tl0,#17h
		mov		th0,#0fch
		mov		r5,#0
		mov		r6,#0
		mov		r7,#0
		setb	et0
		setb	tr0
skip_midi_timestamp_setup:
		mov		a,sbuf
		clr		ri
		mov		r0,#40h
		mov		r1,#40h
		mov		r4,#40h
		ljmp	midi_check_for_input_data

midi_main_loop:
		jnb		ti,midi_check_for_input_data
		jnb		p2.7,midi_check_for_input_data
		movx	a,@r0
		jb		command_byte_2,midi_write_poll
		mov		r0,#40h
		mov		r1,#40h
		mov		r4,#40h
		clr		et0
		clr		tr0
		mov		2eh,#0
		mov		2fh,#0
		clr		24h.3
		mov		tmod,#len_left_hi
		ljmp	check_cmd

midi_write_poll:
		clr		ti
		mov		sbuf,a
midi_check_for_input_data:
		jb		ri,midi_has_input_data
		cjne	r4,#40h,X05e7
		sjmp	midi_main_loop

X05e7:	jnb		p2.6,midi_flush_buffer_to_host
		sjmp	midi_main_loop

midi_has_input_data:
		jnb		command_byte_1,midi_read_no_timestamp
		clr		tr0
		mov		a,r5
		cjne	r4,#0,midi_write_r5
		sjmp	midi_nowrap_writebuffer

midi_write_r5:
		mov		@r0,a
		inc		r0
		dec		r4
		cjne	r0,#80h,midi_nowrap_writebuffer
		mov		r0,#40h
midi_nowrap_writebuffer:
		mov		a,r6
		cjne	r4,#0,midi_write_r6
		sjmp	X060d

midi_write_r6:
		mov		@r0,a
		inc		r0
		dec		r4
		cjne	r0,#80h,X060d
		mov		r0,#40h
X060d:	mov		a,r7
		cjne	r4,#0,midi_write_r7
		sjmp	X061b

midi_write_r7:
		mov		@r0,a
		inc		r0
		dec		r4
		cjne	r0,#80h,X061b
		mov		r0,#40h
X061b:	setb	tr0
midi_read_no_timestamp:
		mov		a,sbuf
		cjne	r4,#0,midi_store_read_data_to_buffer
		sjmp	midi_ready_to_receive_more

midi_store_read_data_to_buffer:
		mov		@r0,a
		inc		r0
		dec		r4
		cjne	r0,#80h,midi_ready_to_receive_more
		mov		r0,#40h
midi_ready_to_receive_more:
		clr		ri
		sjmp	midi_main_loop

		cjne	r4,#40h,midi_space_in_buffer
		ljmp	midi_nowrap_readbuffer

midi_space_in_buffer:
		mov		@r0,a
		inc		r0
		dec		r4
		cjne	r0,#80h,midi_flush_buffer_to_host
		mov		r0,#40h
midi_flush_buffer_to_host:
		mov		a,@r1
		inc		r1
		inc		r4
		cjne	r1,#80h,midi_nowrap_readbuffer
		mov		r1,#40h
midi_nowrap_readbuffer:
		movx	@r0,a
		jnb		command_byte_0,midi_skip_interrupt
		clr		int0
		setb	int0
midi_skip_interrupt:
		ljmp	midi_main_loop

; ------------------------------
; Command group 2: Recording commands
; ------------------------------
cmdg_adc_e:
		mov		port_dac_out,#0ffh
		jb		command_byte_3,cmd_adc_autoinit_direct
		jb		command_byte_2,cmd_adc_dma
		ljmp	cmd_adc_direct

cmd_adc_autoinit_direct:
		setb	24h.2
		mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		ljmp	X0688

cmd_adc_dma:
		jb		t0,X067c
X066b:	jnb		p2.7,X066b
		movx	a,@r0
		mov		length_low,a
X0671:	jnb		p2.7,X0671
		movx	a,@r0
		mov		length_high,a
		setb	24h.1
		ljmp	X0688

X067c:	jnb		p2.7,X067c
		movx	a,@r0
		mov		len_left_lo,a
X0682:	jnb		p2.7,X0682
		movx	a,@r0
		mov		len_left_hi,a
X0688:	clr		t0
		mov		dptr,#vector_dma_adc
		mov		2ch,dpl
		mov		2dh,dph
		setb	status_register.2
		setb	tr0
		setb	et0
		ljmp	check_cmd

; ------------------------------
; Command 20: Direct ADC. This immediately takes one sample and returns it.
; ------------------------------
cmd_adc_direct:
		clr		p2.4
		mov		a,port_dac_out
		setb	p2.4
X06a2:	jb		p2.6,X06a2
		movx	@r0,a
		clr		int1
		ljmp	check_cmd

; ------------------------------
; Command group 9: High speed record and playback
; ------------------------------
cmdg_hs_e:
		setb	24h.5
		jnb		command_byte_3,X06b8
		setb	24h.6
		mov		port_dac_out,#0ffh
		ljmp	X06ba

X06b8:	clr		24h.6
X06ba:	mov		r6,dma_blk_len_lo
		mov		r7,dma_blk_len_hi
		mov		2eh,#34h
		mov		2fh,#12h
		clr		t0
		setb	et0
		setb	tr0
X06ca:	jb		et0,X06ca
		clr		int1
		ljmp	check_cmd

; ------------------------------
; Command group 1: Audio playback - First
; ------------------------------
cmdg_dac_e:
		jb		command_byte_3,cmd_dac_autoinit
		jb		command_byte_2,cmd_dac_dma
		ljmp	cmd_dac_direct

; ------------------------------
; Command 18h: DMA playback with auto init DMA.
; ------------------------------
cmd_dac_autoinit:
		setb	24h.2
		mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		ljmp	X0710

; ------------------------------
; Command 14h: DMA playback
; ------------------------------
cmd_dac_dma:
		jb		t0,X0700
		clr		int1
X06eb:	jnb		p2.7,X06eb
		movx	a,@r0
		mov		length_low,a
X06f1:	jnb		p2.7,X06f1
		movx	a,@r0
		mov		length_high,a
		setb	24h.1
		setb	et0
		setb	tr0
		ljmp	check_cmd

X0700:	clr		int1
X0702:	jnb		p2.7,X0702
		movx	a,@r0
		mov		len_left_lo,a
X0708:	jnb		p2.7,X0708
		movx	a,@r0
		mov		len_left_hi,a
		setb	int1
X0710:	clr		t0
		jb		command_byte_1,cmd_dac_dma_use_adpcm_2
		mov		dptr,#vector_dma_dac_8
		setb	status_register.7
		ljmp	X0742

; ------------------------------
; Command 16h: DMA DAC with 2-bit ADPCM.
; ------------------------------
cmd_dac_dma_use_adpcm_2:
		mov		dptr,#vector_dma_dac_adpcm2
		setb	status_register.4
		jb		command_byte_0,cmd_dac_dma_use_reference
		setb	t1
		clr		t1
X0729:	jnb		p2.7,X0729
		movx	a,@r0
		mov		r6,a
		mov		r3,#4
		ljmp	X0742

cmd_dac_dma_use_reference:
		setb	t1
		clr		t1
X0737:	jnb		p2.7,X0737
		movx	a,@r0
		mov		r2,a
		mov		port_dac_out,a
		mov		r5,#1
		mov		r3,#1
X0742:	mov		2ch,dpl
		mov		2dh,dph
		clr		int1
		setb	et0
		setb	tr0
		ljmp	check_cmd

; ------------------------------
; Command 10h: Direct DAC.
; ------------------------------
cmd_dac_direct:
		clr		int1
X0753:	jnb		p2.7,X0753
		movx	a,@r0
		mov		port_dac_out,a
		ljmp	check_cmd

; ------------------------------
; Command group 7. ADPCM DAC output commands.
; ------------------------------
cmdg_dac2_e:
		jb		command_byte_3,cmd_dac_autoinit_adpcm
		jb		command_byte_2,cmd_dac_adpcm

; ------------------------------
; Command 78: Auto-init DMA ADPCM
; ------------------------------
cmd_dac_autoinit_adpcm:
		setb	24h.2
		mov		len_left_lo,dma_blk_len_lo
		mov		len_left_hi,dma_blk_len_hi
		ljmp	X0797

; ------------------------------
; Command 74: Standard DMA ADPCM
; ------------------------------
cmd_dac_adpcm:
		jb		t0,X0787
		clr		int1
X0772:	jnb		p2.7,X0772
		movx	a,@r0
		mov		length_low,a
X0778:	jnb		p2.7,X0778
		movx	a,@r0
		mov		length_high,a
		setb	24h.1
		setb	et0
		setb	tr0
		ljmp	check_cmd

X0787:	clr		int1
X0789:	jnb		p2.7,X0789
		movx	a,@r0
		mov		len_left_lo,a
X078f:	jnb		p2.7,X078f
		movx	a,@r0
		mov		len_left_hi,a
		setb	int1
X0797:	clr	t0
		jnb		command_byte_1,cmd_dac_adpcm_use_4bit
		mov		dptr,#vector_dma_dac_adpcm2_6
		setb	status_register.5
		ljmp	X07a9

cmd_dac_adpcm_use_4bit:
		mov		dptr,#vector_dma_dac_adpcm4
		setb	status_register.6
X07a9:	jnb		command_byte_0,dac_no_reference
		setb	t1
		clr		t1
X07b0:	jnb		p2.7,X07b0
		movx	a,@r0
		mov		r2,a
		mov		port_dac_out,a
		mov		r5,#1
		mov		r3,#1
		ljmp	X07d1

dac_no_reference:
		setb	t1
		clr		t1
X07c2:	jnb		p2.7,X07c2
		movx	a,@r0
		mov		r6,a
		jnb		command_byte_1,dac_no_ref_adpcm4
		mov		r3,#3
		ljmp	X07d1

dac_no_ref_adpcm4:
		mov		r3,#4
X07d1:	mov		2ch,dpl
		mov		2dh,dph
		clr		int1
		setb	et0
		setb	tr0
		ljmp	check_cmd

; ------------------------------
; Command 80: Generate silence
; ------------------------------
cmdg_silence_e:
		clr		t0
X07e2:	jnb		p2.7,X07e2
		movx	a,@r0
		mov		len_left_lo,a
X07e8:	jnb		p2.7,X07e8
		movx	a,@r0
		mov		len_left_hi,a
		mov		dptr,#vector_dac_silence
		mov		2ch,dpl
		mov		2dh,dph
		setb	status_register.3
		setb	et0
		setb	tr0
		ljmp	check_cmd

; ------------------------------
; Command group 5: SRAM playback
; ------------------------------
cmdg_ram_playback_e:
		jb		command_byte_3,cmd_ram_load
		jb		command_byte_0,cmd_ram_playback
		ljmp	cmd_stop_ram_playback

cmd_ram_load:
		jnb		p2.7,cmd_ram_load
		movx	a,@r0
		mov		ram_samples_x2,a
X080f:	jnb		p2.7,X080f
		movx	a,@r0
		mov		ram_pb_count,a
X0815:	jnb		p2.7,X0815
		movx	a,@r0
		mov		ram_pb_count2,a
X081b:	jnb		p2.7,X081b
		movx	a,@r0
		mov		ram_pb_unused,a
		mov		r0,#40h
X0823:	jnb		p2.7,X0823
		movx	a,@r0
		mov		@r0,a
		inc		r0
		dec		ram_samples_x2
		djnz	ram_samples_x2,X0823
		mov		r1,#40h
		jb		command_byte_0,cmd_ram_playback
		ljmp	check_cmd

; ------------------------------
; Command 51: Plays back samples stored in SRAM.
; ------------------------------
cmd_ram_playback:
		setb	int1
		mov		ram_loops2,ram_pb_count
		mov		ram_loops,ram_loops
		mov		ram_pb_unused2,ram_pb_unused
		mov		ram_smps_left,ram_samples_x2
		mov		dptr,#vector_cmd_ram_playback
		mov		2ch,dpl
		mov		2dh,dph
		setb	et0
		setb	tr0
		ljmp	check_cmd

; ------------------------------
; Command 50: Stops playback of SRAM samples
; ------------------------------
cmd_stop_ram_playback:
		clr		et0
		clr		tr0
		ljmp	check_cmd

; ------------------------------
; Command group D: Miscellaneous commands
; ------------------------------
cmdg_misc:
		jb		command_byte_2,cmd_dma_continue
		jb		command_byte_3,cmd_spk_stat
		jb		command_byte_0,cmd_speaker_en_dis
		clr		et0
		clr		tr0
		setb	t0
		ljmp	cmdg_misc_exit

; ------------------------------
; Command D4: Continue DMA operation
; ------------------------------
cmd_dma_continue:
		clr		t0
		setb	et0
		setb	tr0
		ljmp	cmdg_misc_exit

; ------------------------------
; Command D8: Speaker status
; ------------------------------
cmd_spk_stat:
		jb		command_byte_1,cmd_exit_autoinit
		jnb		p2.0,X0880
		clr		a
		ljmp	X0882

X0880:	mov		a,#0ffh
X0882:	jb		p2.6,X0882
		movx	@r0,a
		ljmp	cmdg_misc_exit

; ------------------------------
; Command DA: Exit auto-init DMA operation
; ------------------------------
cmd_exit_autoinit:
		setb	24h.4
		ljmp	cmdg_misc_exit

; ------------------------------
; Command D1: Enable speaker
; ------------------------------
cmd_speaker_en_dis:
		jb		command_byte_1,X0897
		lcall	cmd_speaker_on
		ljmp	cmdg_misc_exit

; ------------------------------
; Command D3: Disable speaker
; ------------------------------
X0897:	lcall	cmd_speaker_off
cmdg_misc_exit:
		clr		int1
		ret	

cmd_speaker_on:
		push	acc
		clr		int1
		mov		port_dac_out,#80h
		clr		p2.0
		setb	status_register.0
		pop		acc
		ret	

cmd_speaker_off:
		push	acc
		clr		int1
		setb	p2.0
		clr		status_register.0
		pop		acc
		ret

; ------------------------------
; Command group E: DSP identification
; ------------------------------
cmd_ident_e:
		jb		command_byte_3,cmd_read_test_reg
		jb		command_byte_2,cmd_write_test_reg
		jb		command_byte_1,cmd_dsp_dma_id
		jb		command_byte_0,cmd_dsp_version
X08c2:	jnb		p2.7,X08c2
		movx	a,@r0
		cpl		a
X08c7:	jb		p2.6,X08c7
		movx	@r0,a
		ljmp	check_cmd

; ------------------------------
; Command E8: Read test register
; ------------------------------
cmd_read_test_reg:
		mov		a,2ah
X08d0:	jb		p2.6,X08d0
		movx	@r0,a
		ljmp	check_cmd

; ------------------------------
; Command E4: Write test register
; ------------------------------
cmd_write_test_reg:
		jnb		p2.7,cmd_write_test_reg
		movx	a,@r0
		mov		2ah,a
		ljmp	check_cmd

; ------------------------------
; Command E2: Firmware validation check. Uses challenge/response algorithm.
; ------------------------------
cmd_dsp_dma_id:
		jnb		p2.7,cmd_dsp_dma_id
		movx	a,@r0
		setb	int1
		clr		t0
		xrl		a,dsp_dma_id1
		add		a,dsp_dma_id0
		mov		dsp_dma_id0,a
		mov		a,dsp_dma_id1
		rr		a
		rr		a
		mov		dsp_dma_id1,a
		mov		a,dsp_dma_id0
X08f6:	jb		p2.6,X08f6
		movx	@r0,a
		setb	t1
		clr		t1
X08fe:	jb		p2.6,X08fe
		nop	
		setb	t0
		clr		int1
		ljmp	check_cmd

; ------------------------------
; Command E1: Get DSP version
; ------------------------------
cmd_dsp_version:
		mov		dptr,#dsp_version
		clr		a
		movc	a,@a+dptr
X090e:	jb		p2.6,X090e
		movx	@r0,a
		mov		a,#1
		movc	a,@a+dptr
X0915:	jb		p2.6,X0915
		movx	@r0,a
		ljmp	check_cmd

; ------------------------------
; ADPCM 2-bit decode routine
; ------------------------------
adpcm_2_decode:
		mov		a,r6
		rlc		a
		jc		adpcm_2_decode_negative
		rlc		a
		mov		r6,a
		mov		a,r5
		jc		X0934
		rrc		a
		mov		r5,a
		jnz		X092c
		inc		r5
		sjmp	adpcm_2_output

X092c:	add		a,r2
		jnc		X0931
		; BUG: this should be #0ffh.
		mov		a,0ffh
X0931:	mov		r2,a
		sjmp	adpcm_2_output

X0934:	clr		c
		rrc		a
		add		a,r5
		add		a,r2
		jnc		X093c
		mov		a,#0ffh
X093c:	mov		r2,a
		cjne	r5,#20h,X0942
		sjmp	adpcm_2_output

X0942:	mov		a,r5
		add		a,r5
		mov		r5,a
		sjmp	adpcm_2_output

adpcm_2_decode_negative:
		rlc		a
		mov		r6,a
		mov		a,r5
		jc		X095c
		rrc		a
		mov		r5,a
		jnz		X0953
		inc		r5
		sjmp	adpcm_2_output

X0953:	xch		a,r2
		clr		c
		subb	a,r2
		jnc		X0959
		clr		a
X0959:	mov		r2,a
		sjmp	adpcm_2_output

X095c:	clr		c
		rrc		a
		add		a,r5
		xch		a,r2
		clr		c
		subb	a,r2
		jnc		X0965
		clr		a
X0965:	mov		r2,a
		cjne	r5,#20h,X096b
		sjmp	adpcm_2_output

X096b:	mov		a,r5
		add		a,r5
		mov		r5,a
adpcm_2_output:
		mov		port_dac_out,r2
		ret

; ------------------------------
; ADPCM 4-bit decode routine
; ------------------------------
adpcm_4_decode:
		mov		a,r5
		clr		c
		rrc		a
		mov		27h,a
		mov		a,r6
		mov		rb3r1,a
		swap	a
		mov		r6,a
		anl		a,#7
		mov		28h,a
		mov		b,r5
		mul		ab
		add		a,27h
		mov		vector_low,a
		mov		a,rb3r1
		rlc		a
		jc		X0995
		mov		a,vector_low
		add		a,r2
		jnc		X099c
		mov		a,#0ffh
		ljmp	X099c

X0995:	mov		a,r2
		clr		c
		subb	a,vector_low
		jnc		X099c
		clr		a
X099c:	mov		r2,a
		mov		a,28h
		jz		X09b0
		clr		c
		subb	a,#5
		jc		adpcm_4_output
		mov		a,r5
		rl		a
		cjne	a,#10h,X09b6
		mov		a,#8
		ljmp	X09b6

X09b0:	mov		a,27h
		jnz		X09b6
		mov		a,#1
X09b6:	mov		r5,a
adpcm_4_output:
		mov		port_dac_out,r2
		ret

; ------------------------------
; ADPCM 2.6-bit decode routine
; ------------------------------
adpcm_2_6_decode:
		mov		a,r5
		clr		c
		rrc		a
		mov		27h,a
		mov		a,r6
		mov		rb3r1,a
		rl		a
		rl		a
		cjne	r3,#1,X09cc
		anl		a,#1
		ljmp	X09cd

X09cc:	rl		a
X09cd:	mov		r6,a
		anl		a,#3
		mov		28h,a
		mov		b,r5
		mul		ab
		add		a,27h
		mov		vector_low,a
		mov		a,rb3r1
		rlc		a
		jc		X09e8
		mov		a,vector_low
		add		a,r2
		jnc		X09ef
		mov		a,#0ffh
		ljmp	X09ef

X09e8:	mov		a,r2
		clr		c
		subb	a,vector_low
		jnc		X09ef
		clr		a
X09ef:	mov		r2,a
		mov		a,28h
		jz		X0a02
		cjne	a,#3,adpcm_2_6_output
		cjne	r5,#10h,X09fd
		ljmp	adpcm_2_6_output

X09fd:	mov		a,r5
		rl		a
		ljmp	X0a08

X0a02:	mov		a,27h
		jnz		X0a08
		mov		a,#1
X0a08:	mov		r5,a
adpcm_2_6_output:
		mov		port_dac_out,r2

; ------------------------------
; Copyright notice
; ------------------------------
dsp_copyright:
		.db	22h,43h,4fh,50h,59h,52h,49h,47h
		.db	48h,54h,28h,43h,29h,20h,43h,52h
		.db	45h,41h,54h,49h,56h,45h,20h,54h
		.db	45h,43h,48h,4eh,4fh,4ch,4fh,47h
		.db	59h,20h,50h,54h,45h,2eh,20h,4ch
		.db	54h,44h,2eh,20h,28h,31h,39h,39h
		.db	31h,29h,20h

; ------------------------------
; Unused data. Perhaps some sort of ADPCM lookup table?
; ------------------------------
unused_data:
		.db	0e9h,0e5h,0fah,0f3h,0f8h,0e3h,0edh,0e2h
		.db	0feh,82h,0e9h,83h,8ah,0e9h,0f8h,0efh
		.db	0ebh,0feh,0e3h,0fch,0efh,8ah,0feh,0efh
		.db	0e9h,0e2h,0e4h,0e5h,0e6h,0e5h,0edh,0f3h
		.db	8ah,0fah,0feh,0efh,84h,8ah,0e6h,0feh
		.db	0eeh,84h,8ah,82h,9bh,93h,92h,93h
		.db	83h

; ------------------------------
; Stored DSP version number
; ------------------------------
dsp_version:
		.db	3,2

; ------------------------------
; Padding
; ------------------------------
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		.db	0ffh
