;=================================================================================
; SB DSP CT1741 (8052) Firmware Disassembly - Version 4.04
;=================================================================================

;---------------------------------- Command Bytes --------------------------------------
.EQU command_byte_0,			0		; 			Command Byte Bit 0 (LSB)
.EQU command_byte_1,			1		; 			Command Byte Bit 1
.EQU command_byte_2,			2		; 			Command Byte Bit 2
.EQU command_byte_3,			3		; 			Command Byte Bit 3 (MSB)

;---------------------------------- Global Variables -----------------------------------
; Stock, Stack=80h
.EQU init_stack,				80h		;			Stack Pointer
.EQU init_scon,					42h		;			Serial Control
.EQU init_pcon,					80h		;			Power Control
.EQU init_tmod,					21h		;			Timer Mode
.EQU init_timer1_byte_lo,		0fch	;			Timer 1 Low byte
.EQU init_timer1_byte_hi,		0fch	;			Timer 1 High byte

;---------------------------------- MIDI Buffer ----------------------------------------
; Stock, Size=40h, End=80h
.EQU midi_buffer_size,			40h		;			MIDI Buffer - Size
.EQU midi_buffer_pt_write,		40h		;			MIDI Buffer - Write Pointer
.EQU midi_buffer_pt_read,		40h		;			MIDI Buffer - Read Pointer
.EQU midi_buffer_end,			80h		;			MIDI Buffer - End

;================================== SYSTEM ARCHITECTURE ================================
.EQU isr_temp_storage,			00h		; rb0r0		ISR Temporary Storage

;=============================== PERIPHERAL REGISTER MAP ===============================
;---------------------------------- ADPCM Subsystem ------------------------------------
.EQU adpcm_mode_reg,			0ah		; rb1r2		ADPCM Mode Control
.EQU adpcm_state_reg,			0bh		; rb1r3		ADPCM State Control

;=================================== DMA SUBSYSTEM =====================================
;---------------------------------- Common Registers -----------------------------------
.EQU dma_status_reg,			10h		; rb2r0		DMA Status/Control
.EQU dma_addr_lo,				13h		; rb2r3		DMA Current Address Low
.EQU dma_addr_hi,				14h		; rb2r4		DMA Current Address High
.EQU dma_timing_control,		17h		; rb2r7		DMA Timing Control

;---------------------------------- 8-bit DMA Channel ----------------------------------
.EQU dma8_block_len_lo,			0eh		; rb1r6		8-bit DMA Block Length (Low)
.EQU dma8_block_len_hi,			0fh		; rb1r7		8-bit DMA Block Length (High)
.EQU dma8_xfer_len_lo,			11h		; rb2r1		8-bit DMA Active Transfer Length (Low)
.EQU dma8_xfer_len_hi,			12h		; rb2r2		8-bit DMA Active Transfer Length (High)
.EQU dma8_config_temp,			2ch		; 2ch		8-bit DMA Temporary storage
.EQU dma8_autoreinit_en,		64h		; 2ch.4		8-bit DMA auto-reinit enable
.EQU dma8_timing_override,		65h		; 2ch.5		8-bit DMA timing override

.EQU dma8_start_pending,		18h		; 23h.0 	8-bit DMA transfer start pending
.EQU dma8_autoreinit_pause,		1ah		; 23h.2		8-bit DMA auto-reinit paused state
.EQU dma8_active,				21h		; 24h.1		8-bit DMA transfer in progress
.EQU dma8_mode,					22h		; 24h.2		8-bit DMA mode
.EQU dma8_ch1_enable,			0a5h	; p2.5		8-bit DMA enable (1=Enable, 0=Disable)

.EQU acc_dma8_start_pending,	0e0h	; acc.0		8-bit DMA start pending
.EQU acc_dma8_mode_active,		0e2h	; acc.2		8-bit DMA Active?
.EQU acc_dma8_autoreinit,		0e4h	; acc.4		8-bit DMA auto-reinit toggle
.EQU acc_dma8_mode_select,		0e6h	; acc.6		8-bit DMA mode select
.EQU group_4_dma8_pause,		0a1h	; p2.1		8-bit DMA channel 1 paused

;--------------------------------- 16-bit DMA Channel ----------------------------------
.EQU dma16_len_temp_lo,			0ch		; rb1r4		16-bit DMA Length Temp Storage (Low)
.EQU dma16_len_temp_hi,			0dh		; rb1r5		16-bit DMA Length Temp Storage (High)
.EQU dma16_block_size_lo,		15h		; rb2r5		16-bit DMA Block Size (Low)
.EQU dma16_block_size_hi,		16h		; rb2r6		16-bit DMA Block Size (High)
.EQU dma16_config_temp,			2dh		; 2dh		16-bit DMA Temporary storage
.EQU dma16_autoreinit_en,		6ch		; 2dh.4		16-bit DMA auto-reinit enable
.EQU dma16_timing_override,		6dh		; 2dh.5		16-bit DMA alternate addressing

.EQU dma16_start_pending,		19h		; 23h.1 	16-bit DMA transfer start pending
.EQU dma16_autoreinit_pause,	1bh		; 23h.3		16-bit DMA auto-reinit paused state
.EQU dma16_active,				23h		; 24h.3		16-bit DMA transfer in progress
.EQU dma16_mode,				24h		; 24h.4		16-bit DMA mode
.EQU dma16_ch1_enable,			0a4h	; p2.4		16-bit DMA enable (1=Enable, 0=Disable)

.EQU acc_dma16_start_pending,	0e1h	; acc.1		16-bit DMA start pending
.EQU acc_dma16_autoreinit,		0e5h	; acc.5		16-bit DMA auto-reinit toggle
.EQU acc_dma16_mode_select,		0e7h	; acc.7		16-bit DMA mode select
.EQU group_4_dma16_pause,		0a2h	; p2.2		16-bit DMA channel 1 paused

;----------------------------------- Timer Subsystem -----------------------------------
.EQU timer0_counter,			18h		; rb3r0		Timer 0 Counter Storage
.EQU timer0_tlow,				19h		; rb3r1		Timer 0 Low Byte
.EQU timer0_thigh,				1ah		; rb3r2		Timer 0 High Byte
.EQU timer0_auto_reload_en,		1eh		; 23h.6		Timer 0 auto-reload enable

;=============================== PORT PIN DEFINITIONS ==================================
;---------------------------------- Port 1 (90h) ---------------------------------------
.EQU pin_host_data_rdy,			90h		; p1.0		Host Data Ready
.EQU pin_dsp_data_rdy,			91h		; p1.1		DSP Data Ready
.EQU pin_dsp_busy,				92h		; p1.2		DSP Busy Flag
.EQU pin_unused_p13,			93h		; p1.3		Unused (No Interaction)
.EQU pin_coldboot_done,			94h		; p1.4		Cold Boot Complete Flag
.EQU pin_dma_req,				95h		; p1.5		DMA Request Handshake
.EQU pin_midi_irq,				96h		; p1.6		MIDI IRQ Status
.EQU pin_timer0_toggle,			97h		; p1.7		Timer 0 Pulse Toggle

;---------------------------------- Port 2 (a0h) ---------------------------------------
.EQU pin_periph_dis,			0a6h	; p2.6		Disable external peripherals
.EQU pin_midi_pwr,				0a7h	; p2.7		MIDI Interface Enable

;=============================== DSP CORE REGISTERS ====================================
.EQU command_byte,				20h		;			Current DSP Command Byte (Host→DSP)
.EQU rem_xfer_len_lo,			21h		;			Remaining Transfer Length Low
.EQU rem_xfer_len_hi,			22h		;			Remaining Transfer Length High

;---------------------------------- Status System --------------------------------------
.EQU status_reg,				23h		;			Status Register (Bitmask)

;---------------------------------- Control System -------------------------------------
.EQU auxiliary_reg,				24h		;			Auxiliary Register (Bitmask)
;---------------------------------- Identification System ------------------------------
.EQU dsp_dma_id0,				25h		;			DSP/DMA Identification Byte 0
.EQU dsp_dma_id1,				26h		;			DSP/DMA Identification Byte 1

.EQU vector_lo,					29h		;			Interrupt Vector Low Byte

;---------------------------------- Command System -------------------------------------
.EQU command_reg,				30h		;			Command Register (Bitmask)

;----------------------------------- Warm Boot System ----------------------------------
.EQU warmboot_magic1,			31h		;			Warm Boot Signature Byte 1
.EQU warmboot_magic2,			32h		;			Warm Boot Signature Byte 2

.EQU mute_enable,				1ch		; 23h.4		Mute control (0 = muted, 1 = unmuted)
.EQU midi_active,				1dh		; 23h.5		MIDI subsystem active
.EQU dma_timing_status,			1fh		; 23h.7		DMA Timing status

.EQU host_cmd_pending,			20h		; 24h.0		Host Command Pending
.EQU midi_timestamp_en,			25h		; 24h.5		MIDI timestamp counter enable

;=============================== ADVANCED CONTROLLERS ==================================
;----------------------------------- DMA Configuration ---------------------------------
.EQU dma_control_temp,			2eh		; 2eh		DMA Temporary storage
.EQU dma_safety_override_en,	0a3h	; p2.3		DMA timing safety override
.EQU diagnostic_flag,			7dh		; 2fh.5		Diagnostic flag (challenge/resp)

;----------------------------------- CSP Subsystem -------------------------------------
.EQU csp_program_id_lo,			08h		; rb1r0		DMA Command Parameter 0
.EQU csp_program_id_hi,			09h		; rb1r1		DMA Command Parameter 1

.EQU csp_data_port,				80h		; 			CSP Data/Command port
.EQU csp_status_port,			81h		; 			CSP Status/Handshake port
.EQU csp_control_port,			82h		; 			CSP Control port
.EQU csp_program_port,			83h		; 			CSP Program upload port

.EQU csp_lock_count,					2bh		;			Interrupt Vector High Byte

;============================= INTERRUPT VECTOR TABLE ============================
;-------------------- Vector Offsets for Critical Hardware Events ----------------
.org 0
RESET:					ljmp	start
int0_vector:			ljmp	int0_main_handler
						.db		66h,46h,56h,66h,46h
tr0_vector:				ljmp	tr0_main_handler
						.db		66h,46h,66h,56h,56h
int1_vector:			ljmp	int1_main_handler

;=========================== INTERRUPT HANDLERS ==================================
;---------------------- Primary Audio Interrupt Handler --------------------------
; Real-time DAC Output Controller for:
;   - ADPCM Decoding (2/2.6/4-bit)
;   - Digital Silence Generation
;   - DMA Buffer Underflow Prevention
;---------------------------------------------------------------------------------
int0_main_handler:
		setb	pin_dsp_busy
		push	acc
		push	dpl
		push	dph
		push	isr_temp_storage
		mov		dptr,#int0_main_table
		mov		a,adpcm_state_reg
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

int0_main_table:
	.db int0_none_handler		- int0_main_table ; 0
	.db int0_dac_silence		- int0_main_table ; 1
	.db int0_dma_dac_adpcm2		- int0_main_table ; 2
	.db int0_dma_dac_adpcm2_6	- int0_main_table ; 3
	.db int0_dma_dac_adpcm4		- int0_main_table ; 4
	.db int0_midi_handler		- int0_main_table ; 5
	.db int0_none_handler		- int0_main_table ; 6
	.db int0_none_handler		- int0_main_table ; 7
	.db int0_none_handler		- int0_main_table ; 8
	.db int0_none_handler		- int0_main_table ; 9
	.db int0_none_handler		- int0_main_table ; 10
	.db int0_none_handler		- int0_main_table ; 11
	.db int0_none_handler		- int0_main_table ; 12
	.db int0_none_handler		- int0_main_table ; 13
	.db int0_none_handler		- int0_main_table ; 14

;------------------------------- Int0 Group Handlers -----------------------------
int0_dac_silence:		ljmp	vector_dac_silence		; DAC playback of silence.
int0_dma_dac_adpcm2:	ljmp	vector_dma_dac_adpcm2	; DAC playback, 2bit ADPCM
int0_dma_dac_adpcm2_6:	ljmp	vector_dma_dac_adpcm2_6	; DAC playback, 2.6bit ADPCM
int0_dma_dac_adpcm4:	ljmp	vector_dma_dac_adpcm4	; DAC playback, 4bit ADPCM
int0_midi_handler:		ljmp	vector_midi_handler		; MIDI Playback

int0_none_handler:
		clr		pin_dsp_busy
		pop		isr_temp_storage
		pop		dph
		pop		dpl
		pop		acc
		reti	

;------------------------------- INT1 Handler ------------------------------------
; Initializes 8-bit/16-bit DMA Transfers
;---------------------------------------------------------------------------------
int1_main_handler:
		clr		pin_dsp_busy
		push	acc
		push	dpl
		push	dph
		push	isr_temp_storage
		mov		r0,#6
		movx	a,@r0
		jnb		acc_dma8_start_pending,X0065
		lcall	vector_dma8_playback
X0065:	mov		r0,#6
		movx	a,@r0
		jnb		acc_dma16_start_pending,X006e
		lcall	vector_dma16_playback
X006e:	pop		isr_temp_storage
		pop		dph
		pop		dpl
		pop		acc
		reti

;------------------------------- Timer0 Handler ----------------------------------
; Manages:
;   - MIDI Event Timestamping (24-bit counter)
;   - DSP Clock Domain Synchronization
;   - Auto-Reload Timer Configuration
;---------------------------------------------------------------------------------
tr0_main_handler:
		jb		midi_timestamp_en,midi_timestamp_int
		jnb		timer0_auto_reload_en,X0086
		mov		tl0,timer0_tlow
		mov		th0,timer0_thigh
		ljmp	X008a

X0086:	clr		et0
		clr		tr0
X008a:	clr		pin_timer0_toggle
		setb	pin_timer0_toggle
		reti	

;------------------------------- MIDI Timestamp Counter --------------------------
; Handles 24-bit timestamp counter for MIDI synchronization
; Uses registers:
;   r5 = Counter LSB
;   r6 = Counter Middle
;   r7 = Counter MSB
;---------------------------------------------------------------------------------
midi_timestamp_int:
		inc		r5
		cjne	r5,#0,X0098
		inc		r6
		cjne	r6,#0,X0098
		inc		r7
X0098:	mov		tl0,#2fh
		mov		th0,#0f8h
		reti

;------------------------------- 8-bit DMA Transfer Controller -------------------
; Manages 8-bit DMA data transfers including auto-init/single-cycle modes
; Handles register setup, buffer underflow checks, and CSP control signaling
;---------------------------------------------------------------------------------
vector_dma8_playback:
		jb		dma8_active,X00f7
		jnb		dma8_mode,X00bd
		mov		r0,#7
X00a7:	jb		pin_dsp_data_rdy,X00ae
		movx	a,@r0
		jb		acc_dma8_start_pending,X00a7
X00ae:	mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	X0111

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
		lcall	X0a3e
		mov		r0,#6
		setb	dma8_ch1_enable
		mov		warmboot_magic1,#0
		mov		warmboot_magic2,#0
		jnb		dma16_start_pending,X00ec
		lcall	dma16_start
		clr		dma16_start_pending
		ljmp	vector_dma8_playback_end

X00ec:	jnb		dma8_start_pending,vector_dma8_playback_end
		lcall	dma8_start
		clr		dma8_start_pending
		ljmp	vector_dma8_playback_end

X00f7:	clr		dma8_mode
		clr		dma8_active
		mov		a,dma8_xfer_len_lo
		mov		r0,#0bh
		movx	@r0,a
		mov		a,dma8_xfer_len_hi
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
X0111:	mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
vector_dma8_playback_end:
		ret	

;------------------------------- 16-bit DMA Transfer Controller ------------------
; Controls 16-bit DMA transfers with dual-channel addressing
; Manages high/low byte sequencing and transfer state machines
;---------------------------------------------------------------------------------
vector_dma16_playback:
		jb		dma16_active,X016a
		jnb		dma16_mode,X0137
		mov		r0,#7
X0122:	jb		pin_dsp_data_rdy,X0129
		movx	a,@r0
		jb		acc_dma16_start_pending,X0122
X0129:	mov		r0,#10h
		movx	a,@r0
		anl		a,#0
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	X0183

X0137:	mov		r0,#10h
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
		lcall	X0a3e
		mov		r0,#6
		setb	dma16_ch1_enable
		jnb		dma16_autoreinit_pause,X015f
		lcall	dma16_start
		clr		dma16_autoreinit_pause
		ljmp	vector_dma16_playback_end

X015f:	jnb		dma8_autoreinit_pause,vector_dma16_playback_end
		lcall	dma8_start
		clr		dma8_autoreinit_pause
		ljmp	vector_dma16_playback_end

X016a:	clr		dma16_mode
		clr		dma16_active
		mov		a,dma16_block_size_lo
		mov		r0,#13h
		movx	@r0,a
		mov		a,dma16_block_size_hi
		mov		r0,#14h
		movx	@r0,a
		mov		r0,#10h
		movx	a,@r0
		anl		a,#0
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
X0183:	mov		r0,#10h
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
vector_dma16_playback_end:
		ret	

;------------------------------- 2-bit ADPCM Decoder -----------------------------
; Decodes 4 samples/byte 2-bit ADPCM audio.
; Manages sample counters, DMA underflow, and Creative reference sample handling.
;---------------------------------------------------------------------------------
vector_dma_dac_adpcm2:
		jnb		pin_dsp_data_rdy,vector_adpcm2_byte_available
		setb	host_cmd_pending
		ljmp	vector_dma_dac_adpcm2_end

vector_adpcm2_byte_available:
		dec		r3
		cjne	r3,#0,vector_dma_dac_adpcm2_shiftin
		clr		a
		cjne	a,rem_xfer_len_lo,vector_adpcm2_get_data_lo
		cjne	a,rem_xfer_len_hi,vector_adpcm2_get_data_hi
		jb		dma8_active,X0204
		jb		dma8_mode,X01c5
		clr		dma8_active
		clr		dma8_mode
		clr		ex0
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		setb	dma8_ch1_enable
		lcall	X0a3e
		ljmp	vector_dma_dac_adpcm2_end

vector_dma_dac_adpcm2_shiftin:
		ljmp	vector_adpcm_2_decode

X01c5:	mov		rem_xfer_len_lo,dma8_block_len_lo
		mov		rem_xfer_len_hi,dma8_block_len_hi
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X01d1:	movx	a,@r0
		jnb		acc_dma8_mode_select,X01d1
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

X0204:	clr		dma8_mode
		clr		dma8_active
		mov		rem_xfer_len_lo,dma8_xfer_len_lo
		mov		rem_xfer_len_hi,dma8_xfer_len_hi
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X0214:	movx	a,@r0
		jnb		acc_dma8_mode_select,X0214
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
		dec		rem_xfer_len_hi
vector_adpcm2_get_data_lo:
		dec		rem_xfer_len_lo
		mov		r3,#4
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X0200:	movx	a,@r0
		jnb		acc_dma8_mode_select,X0200
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
vector_adpcm_2_decode:
		lcall	adpcm_2_decode
vector_dma_dac_adpcm2_end:
		clr		pin_dsp_busy
		pop		isr_temp_storage
		pop		dph
		pop		dpl
		pop		acc
		reti	

;------------------------------- 4-bit ADPCM Decoder -----------------------------
; Processes 2 samples/byte 4-bit ADPCM streams.
; Implements sample extraction, DMA request signaling, and step size adaptation.
;---------------------------------------------------------------------------------
vector_dma_dac_adpcm4:
		jnb		pin_dsp_data_rdy,vector_adpcm4_byte_available
		setb	host_cmd_pending
		ljmp	vector_dma_dac_adpcm4_end

vector_adpcm4_byte_available:
		dec		r3
		cjne	r3,#0,vector_dma_dac_adpcm4_shiftin
		clr		a
		cjne	a,rem_xfer_len_lo,vector_adpcm4_get_data_lo
		cjne	a,rem_xfer_len_hi,vector_adpcm4_get_data_hi
		jb		dma8_active,X02ad
		jb		dma8_mode,X026e
		clr		dma8_active
		clr		dma8_mode
		clr		ex0
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		setb	dma8_ch1_enable
		lcall	X0a3e
		ljmp	vector_dma_dac_adpcm4_end

vector_dma_dac_adpcm4_shiftin:
		ljmp	vector_adpcm_4_decode

X026e:	mov		rem_xfer_len_lo,dma8_block_len_lo
		mov		rem_xfer_len_hi,dma8_block_len_hi
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X027a:	movx	a,@r0
		jnb		acc_dma8_mode_select,X027a
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

X02ad:	clr		dma8_mode
		clr		dma8_active
		mov		rem_xfer_len_lo,dma8_xfer_len_lo
		mov		rem_xfer_len_hi,dma8_xfer_len_hi
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X02bd:	movx	a,@r0
		jnb		acc_dma8_mode_select,X02bd
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
		dec		rem_xfer_len_hi
vector_adpcm4_get_data_lo:
		dec		rem_xfer_len_lo
		mov		r3,#2
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X029f:	movx	a,@r0
		jnb		acc_dma8_mode_select,X029f
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
vector_adpcm_4_decode:
		lcall	adpcm_4_decode
vector_dma_dac_adpcm4_end:
		clr		pin_dsp_busy
		pop		isr_temp_storage
		pop		dph
		pop		dpl
		pop		acc
		reti	

;------------------------------- 2.6-bit ADPCM Decoder ---------------------------
; Handles Creative's proprietary 3 samples/byte 2.6-bit format.
; Includes special shift patterns and hybrid step size adjustments.
;---------------------------------------------------------------------------------
vector_dma_dac_adpcm2_6:
		jnb		pin_dsp_data_rdy,X02e6
		setb	host_cmd_pending
		ljmp	vector_dma_dac_adpcm2_6_end

X02e6:	dec		r3
		cjne	r3,#0,vector_dma_dac_adpcm2_6_shiftin
		clr	a
		cjne	a,rem_xfer_len_lo,X0317
		cjne	a,rem_xfer_len_hi,X0315
		jb		dma8_active,X0354
		jb		dma8_mode,X032f
		clr		dma8_active
		clr		dma8_mode
		clr		ex0
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		lcall	X0a3e
		ljmp	vector_dma_dac_adpcm2_6_end

vector_dma_dac_adpcm2_6_shiftin:
		ljmp	vector_adpcm_2_6_decode

X032f:	mov		rem_xfer_len_lo,dma8_block_len_lo
		mov		rem_xfer_len_hi,dma8_block_len_hi
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X033b:	movx	a,@r0
		jnb		acc_dma8_mode_select,X033b
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

X0354:	clr		dma8_mode
		clr		dma8_active
		mov		rem_xfer_len_lo,dma8_xfer_len_lo
		mov		rem_xfer_len_hi,dma8_xfer_len_hi
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X0364:	movx	a,@r0
		jnb		acc_dma8_mode_select,X0364
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

X0315:	dec		rem_xfer_len_hi
X0317:	dec		rem_xfer_len_lo
		mov		r3,#3
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X0321:	movx	a,@r0
		jnb		acc_dma8_mode_select,X0321
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
vector_adpcm_2_6_decode:
		lcall	adpcm_2_6_decode
vector_dma_dac_adpcm2_6_end:
		clr		pin_dsp_busy
		pop		isr_temp_storage
		pop		dph
		pop		dpl
		pop		acc
		reti	

;------------------------------- Digital Silence Generator -----------------------
; Outputs DC offset (80h) during DMA underflow or explicit silence commands.
; Safely halts DMA engine and prevents buffer underrun artifacts.
;---------------------------------------------------------------------------------
vector_dac_silence:
		jnb		pin_dsp_data_rdy,vector_dac_silence_byte_available
		setb	host_cmd_pending
		ljmp	vector_dac_silence_end

vector_dac_silence_byte_available:
		clr		a
		cjne	a,rem_xfer_len_lo,vector_dac_silence_get_data_lo
		cjne	a,rem_xfer_len_hi,vector_dac_silence_get_data_hi
		clr		ex0
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		setb	dma8_ch1_enable
		lcall	X0a3e
		ljmp	vector_dac_silence_end

vector_dac_silence_get_data_hi:
		dec		rem_xfer_len_hi
vector_dac_silence_get_data_lo:
		dec		rem_xfer_len_lo
vector_dac_silence_end:
		clr		pin_dsp_busy
		pop		isr_temp_storage
		pop		dph
		pop		dpl
		pop		acc
		reti	

;------------------------------- MIDI Stream Processor ---------------------------
; Manages MIDI data streaming from ROM table to output port.
; Implements circular buffer with timestamp support for event synchronization.
;---------------------------------------------------------------------------------
vector_midi_handler:
		mov		dptr,#int0_midi_data
		mov		a,r7
		movc	a,@a+dptr
		cjne	a,#0,X03c8
		mov		r7,#0
		clr		a
		movc	a,@a+dptr
X03c8:	mov		r0,#19h
		movx	@r0,a
		inc		r7
		clr		pin_dsp_busy
		pop		isr_temp_storage
		pop		dph
		pop		dpl
		pop		acc
		reti	

;============================= SYSTEM INITIALIZATION MANAGER =====================
;------------------------------- System Boot Manager -----------------------------
; Handles cold/warm boot detection and core system initialization
; - Sets safety locks (DSP busy, interrupt disable) during bring-up
; - Configures processor stack, serial COM, and timer defaults
; - Maintains warm boot state via signature (34h/12h) validation
;---------------------------------------------------------------------------------
start:	
		setb	pin_dsp_busy
		clr		ea
		setb	pin_timer0_toggle
		setb	dma8_ch1_enable
		setb	dma16_ch1_enable
		clr		pin_coldboot_done
		clr		pin_periph_dis
		mov		sp,#init_stack
		clr		pin_dma_req
		mov		scon,#init_scon
		mov		th1,#init_timer1_byte_hi
		mov		tl1,#init_timer1_byte_lo
		mov		tmod,#init_tmod
		mov		pcon,#init_pcon
		setb	tr1
		setb	ren
		setb	it0
		setb	it1
		mov		a,#34h
		cjne	a,warmboot_magic1,cold_boot
		mov		a,#12h
		cjne	a,warmboot_magic2,cold_boot
		mov		warmboot_magic1,#0
		mov		warmboot_magic2,#0
		ljmp	warm_boot

;------------------------------- Cold Start Initializer --------------------------
; Full hardware state initialization - used on first power-up or hard reset
; - Programs DMA controller defaults (60h mode, 7FFh block size)
; - Sets DSP identification signature (AAh/96h) and clears status flags
; - Initializes CSP control registers and peripheral I/O states
;---------------------------------------------------------------------------------
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
		mov		dma8_block_len_lo,#0ffh
		mov		dma8_block_len_hi,#7
		mov		status_reg,#0

;------------------------------- Warm State Restorer -----------------------------
; Partial reset preserving operational context during soft reboots
; - Retains DMA config/MIDI buffers while resetting command pipeline
; - Reinitializes host communication channels and timer controls
; - Maintains CSP enable states during firmware updates
;---------------------------------------------------------------------------------
warm_boot:
		mov		adpcm_state_reg,#0
		mov		dma8_config_temp,#0
		mov		dma16_config_temp,#0
		mov		csp_lock_count,#0
		mov		auxiliary_reg,#0
		mov		37h,#38h
		setb	pin_midi_pwr
		clr		dma_safety_override_en
		clr		group_4_dma8_pause
		clr		group_4_dma16_pause
		setb	ea
		mov		a,#0aah
X047f:	jb		pin_host_data_rdy,X047f
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a

;============================= HOST COMMAND PROCESSOR ============================
;------------------------------- Main Command Scheduler --------------------------
; Central loop managing host/DSP command execution priority
; 1. Services MIDI subsystem when active (midi_active MIDI active flag)
; 2. Monitors host command mailbox (port 0) for new instructions
; 3. Implements CSP initialization safeguards during idle periods
;---------------------------------------------------------------------------------
check_cmd:
		jb		host_cmd_pending,X049d

wait_for_cmd:
		clr		pin_dsp_busy
		jb		midi_active,X0495
		jnb		pin_midi_irq,X0498
		lcall	midi_uart_init
X0495:	lcall	midi_io_handler
X0498:	setb	pin_dsp_busy
		jnb		pin_dsp_data_rdy,wait_for_cmd
X049d:	clr		host_cmd_pending
		mov		command_reg,command_byte
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		command_byte,a
		swap	a
		anl		a,#0fh
		mov		dptr,#table_major_cmds
		movc	a,@a+dptr
		clr		pin_dsp_busy
		jmp		@a+dptr

		sjmp	check_cmd

; ----------------------------------------------------
; Index | Command | Handler
; ------|---------|-----------------------------------
;   0   |  00h    | vector_cmdg_csp				(12h)
;   1   |  10h    | vector_cmdg_dac1			(15h)
;   2   |  20h    | vector_cmdg_rec				(1eh)
;   3   |  30h    | vector_cmdg_midi			(21h)
;   4   |  40h    | vector_cmdg_setup			(27h)
;   5   |  50h    | vector_cmdg_none			(10h)
;   6   |  60h    | vector_cmdg_none			(10h)
;   7   |  70h    | vector_cmdg_dac2			(18h)
; ---------------------------------------------------
;   8   |  80h    | vector_cmdg_silence			(2ah)
;   9   |  90h    | vector_cmdg_hs				(1bh)
;  10   |  A0h    | vector_cmdg_none			(10h)
;  11   |  B0h    | vector_cmd_dma16			(36h)
;  12   |  C0h    | vector_cmd_dma8				(33h)
;  13   |  D0h    | vector_cmdg_misc			(30h)
;  14   |  E0h    | vector_cmdg_ident			(2dh)
;  15   |  F0h    | vector_cmdg_aux				(24h)
; ----------------------------------------------------
table_major_cmds:
	.db vector_cmdg_csp			- table_major_cmds ; 00h
	.db vector_cmdg_dac1		- table_major_cmds ; 10h
	.db vector_cmdg_rec			- table_major_cmds ; 20h
	.db vector_cmdg_midi		- table_major_cmds ; 30h
	.db vector_cmdg_setup		- table_major_cmds ; 40h
	.db vector_cmdg_none		- table_major_cmds ; 50h
	.db vector_cmdg_none		- table_major_cmds ; 60h
	.db vector_cmdg_dac2		- table_major_cmds ; 70h
	.db vector_cmdg_silence		- table_major_cmds ; 80h
	.db vector_cmdg_hs			- table_major_cmds ; 90h
	.db vector_cmdg_none		- table_major_cmds ; A0h
	.db vector_cmd_dma16		- table_major_cmds ; B0h
	.db vector_cmd_dma8			- table_major_cmds ; C0h
	.db vector_cmdg_misc		- table_major_cmds ; D0h
	.db vector_cmdg_ident		- table_major_cmds ; E0h
	.db vector_cmdg_aux			- table_major_cmds ; F0h

;------------------------------- Command Group Handlers --------------------------
vector_cmdg_none:		sjmp check_cmd			; Groups 5,6,A (Invalid)
vector_cmdg_csp:		ljmp cmdg_csp			; Group 0: CSP commands
vector_cmdg_dac1:		ljmp cmdg_dma_dac1		; Group 1: Primary DMA audio
vector_cmdg_dac2:		ljmp cmdg_dma_dac2		; Group 7: Secondary DMA audio 
vector_cmdg_hs:			ljmp cmdg_hs			; Group 9: High-speed transfers
vector_cmdg_rec:		ljmp cmdg_rec			; Group 2: Recording control
vector_cmdg_midi:      ljmp cmdg_midi			; Group 3: MIDI operations
vector_cmdg_aux:		ljmp cmdg_aux			; Group F: Auxiliary commands
vector_cmdg_setup:		ljmp cmdg_setup			; Group 4: DSP configuration
vector_cmdg_silence:	ljmp cmdg_silence		; Group 8: Silence generation
vector_cmdg_ident:		ljmp cmdg_ident			; Group E: DSP identification
vector_cmdg_misc:		ljmp cmdg_misc			; Group D: Miscellaneous
vector_cmd_dma8:		ljmp cmd_dma8			; Group C: 8-bit DMA control
vector_cmd_dma16:		ljmp cmd_dma16			; Group B: 16-bit DMA control
;---------------------------------------------------------------------------------

;============================= HOST-DRIVEN DMA CONFIGURATOR ======================  
;------------------------------- 8-bit DMA Command Handler ----------------------- 
; Handles 8-bit DMA mode setup and transfers
; Command structure: [1D][Mode][Param1][Param2]
;---------------------------------------------------------------------------------
cmd_dma8:
		lcall	X0a26
		mov		r0,#4
		movx	a,@r0
		anl		a,#0f0h
		jnb		command_byte_3,X050c
		orl		a,#5
		mov		dma_control_temp,a
		mov		r0,#16h
		movx	a,@r0
		orl		a,#1
		movx	@r0,a
		anl		a,#0feh
		movx	@r0,a
		mov		r0,#8
		movx	a,@r0
		orl		a,#40h
		movx	@r0,a
		anl		a,#0bfh
		movx	@r0,a
		setb	dma16_start_pending
		ljmp	X0512

X050c:	orl		a,#4
		mov		dma_control_temp,a
		mov		r0,#0eh
		movx	a,@r0
		orl		a,#1
		movx	@r0,a
		anl		a,#0feh
		movx	@r0,a
		setb	dma8_start_pending
X0512:	jnb		command_byte_2,X051a
		setb	dma8_mode
		ljmp	X0535

X051a:	jnb		dma8_mode,X0535
		clr		dma8_mode
		lcall	dsp_data_read
		lcall	dsp_data_read
		mov		dma8_xfer_len_lo,a
		lcall	dsp_data_read
		mov		dma8_xfer_len_hi,a
		setb	dma8_active
		clr		dma8_ch1_enable
		setb	ex1
		ljmp	X05ab

X0535:	jnb		command_byte_1,X0547
		jb		command_byte_3,X0541
		mov		r0,#0eh
		mov		a,#1
		movx	@r0,a
		clr		a
		movx	@r0,a
		ljmp	X0556

X0541:	mov		r0,#16h
		mov		a,#1
		movx	@r0,a
		clr		a
		movx	@r0,a
		ljmp	X0556

X0547:	jb		command_byte_3,X0550
		lcall	dma8_start
		ljmp	X0556

X0550:	lcall	dma16_start
		ljmp	X0556

X0556:	jnb		command_byte_0,X0559
X0559:	lcall	dsp_data_read
		mov		dma8_config_temp,a
		mov		a,dma_control_temp
		clr		acc_dma8_autoreinit
		jnb		dma8_autoreinit_en,X0567
		setb	acc_dma8_autoreinit
X0567:	setb	acc_dma8_mode_select
		jnb		dma8_timing_override,X056e
		clr		acc_dma8_mode_select
X056e:	mov		r0,#4
		movx	@r0,a
		lcall	dsp_data_read
		mov		dma8_block_len_lo,a
		mov		r0,#0bh
		movx	@r0,a
		lcall	dsp_data_read
		mov		dma8_block_len_hi,a
		mov		r0,#0ch
		movx	@r0,a
		setb	dma_safety_override_en
		setb	ex1
		clr		dma8_ch1_enable
		clr		ea
		mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		nop	
		nop	
		setb	pin_dma_req
		clr		pin_dma_req
		setb	ea
X05ab:	ljmp	check_cmd

;------------------------------- 16-bit DMA Command Handler ----------------------
; Manages 16-bit DMA transfers for high-resolution audio
; Command structure: [2D][Mode][AddressHi][AddressLo][LengthHi][LengthLo]
;---------------------------------------------------------------------------------
cmd_dma16:
		lcall	X0a26
		mov		r0,#4
		movx	a,@r0
		anl		a,#0f0h
		jnb		command_byte_3,X05c2
		orl		a,#4
		mov		dma_control_temp,a
		mov		r0,#16h
		movx	a,@r0
		orl		a,#1
		movx	@r0,a
		anl		a,#0feh
		movx	@r0,a
		mov		r0,#10h
		movx	a,@r0
		orl		a,#40h
		movx	@r0,a
		anl		a,#0bfh
		movx	@r0,a
		setb	dma16_autoreinit_pause
		ljmp	X05c8

X05c2:	orl		a,#5
		mov		dma_control_temp,a
		mov		r0,#0eh
		movx	a,@r0
		orl		a,#1
		movx	@r0,a
		anl		a,#0feh
		movx	@r0,a
		setb	dma8_autoreinit_pause
X05c8:	jnb		command_byte_2,X05d0
		setb	dma16_mode
		ljmp	X05eb

X05d0:	jnb		dma16_mode,X05eb
		clr		dma16_mode
		lcall	dsp_data_read
		lcall	dsp_data_read
		mov		dma16_block_size_lo,a
		lcall	dsp_data_read
		mov		dma16_block_size_hi,a
		setb	dma16_active
		clr		dma16_ch1_enable
		setb	ex1
		ljmp	X0655

X05eb:	jnb		command_byte_1,X05fd
		jb		command_byte_3,X05f7
		mov		r0,#0eh
		mov		a,#1
		movx	@r0,a
		clr		a
		movx	@r0,a
		ljmp	X060c

X05f7:	mov		r0,#16h
		mov		a,#1
		movx	@r0,a
		clr		a
		movx	@r0,a
		ljmp	X060c

X05fd:	jb		command_byte_3,X0606
		lcall	dma8_start
		ljmp	X060c

X0606:	lcall	dma16_start
		ljmp	X060c

X060c:	jnb		command_byte_0,X060f
X060f:	lcall	dsp_data_read
		mov		dma16_config_temp,a
		mov		a,dma_control_temp
		clr		acc_dma16_autoreinit
		jnb		dma16_autoreinit_en,X061d
		setb	acc_dma16_autoreinit
X061d:	setb	acc_dma16_mode_select
		jnb		dma16_timing_override,X0624
		clr		acc_dma16_mode_select
X0624:	mov		r0,#4
		movx	@r0,a
		lcall	dsp_data_read
		mov		dma16_len_temp_lo,a
		mov		r0,#13h
		movx	@r0,a
		lcall	dsp_data_read
		mov		dma16_len_temp_hi,a
		mov		r0,#14h
		movx	@r0,a
		setb	dma_safety_override_en
		setb	ex1
		clr		dma16_ch1_enable
		mov		r0,#10h
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
X0655:	ljmp	check_cmd

;============================== CSP COMMAND HANDLER ==========================
;------------------------------- Group 0: CSP Control -------------------------
; Processes status/configuration commands (00h-0Fh)
; Uses jump table at table_csp_cmds for subcommand dispatch
;---------------------------------------------------------------------------------
cmdg_csp:
		mov		dptr,#table_csp_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

; ----------------------------------------------------
; Index | Command | Handler
; ------|---------|-----------------------------------
;   0   |  00h    | cmd_0_none					(75h)
;   1   |  01h    | cmd_csp_upload				(0f8h)
;   2   |  02h    | cmd_csp_init				(10h)
;   3   |  03h    | cmd_csp_read_data			(43h)
;   4   |  04h    | cmd_csp_control_mode		(4ch)
;   5   |  05h    | cmd_csp_dual_write			(34h)
;   6   |  06h    | cmd_csp_lock_inc			(55h)
;   7   |  07h    | cmd_csp_lock_dec			(5ah)
; ---------------------------------------------------
;   8   |  08h    | cmd_csp_version				(6ch)
;   9   |  09h    | cmd_csp_program_id			(91h)
;  10   |  0Ah    | cmd_csp_program_lock		(67h)
;  11   |  0Bh    | cmd_csp_block_write			(9dh)
;  12   |  0Ch    | cmd_csp_block_read			(0c8h)
;  13   |  0Dh    | cmd_0_none					(75h)
;  14   |  0Eh    | cmd_xbus_write				(78h)
;  15   |  0Fh    | cmd_xbus_read				(86h)
; ----------------------------------------------------
table_csp_cmds:
	.db cmd_0_none				- table_csp_cmds ; 00h
	.db cmd_csp_upload			- table_csp_cmds ; 01h
	.db cmd_csp_init			- table_csp_cmds ; 02h
	.db cmd_csp_read_data		- table_csp_cmds ; 03h
	.db cmd_csp_control_mode	- table_csp_cmds ; 04h
	.db cmd_csp_dual_write		- table_csp_cmds ; 05h
	.db cmd_csp_lock_inc		- table_csp_cmds ; 06h
	.db cmd_csp_lock_dec		- table_csp_cmds ; 07h
	.db cmd_csp_version			- table_csp_cmds ; 08h
	.db cmd_csp_program_id		- table_csp_cmds ; 09h
	.db cmd_csp_program_lock	- table_csp_cmds ; 0Ah
	.db cmd_csp_block_write		- table_csp_cmds ; 0Bh
	.db cmd_csp_block_read		- table_csp_cmds ; 0Ch
	.db cmd_0_none				- table_csp_cmds ; 0Dh
	.db cmd_xbus_write			- table_csp_cmds ; 0Eh
	.db cmd_xbus_read			- table_csp_cmds ; 0Fh

;=============================== CSP PORT CONFIGURATION ==============================
;------------------------------- [02h] CSP Initialize ------------------------------
; Sets up CSP communication ports with handshake
; Uses ports 80h (data), 81h (status), F2h signature
;---------------------------------------------------------------------------------
cmd_csp_init:
		lcall	dsp_data_read
		mov		r0,#csp_data_port
		movx	@r0,a
		mov		a,#0f2h
		mov		dma_control_temp,a
		mov		r0,#csp_status_port
		movx	@r0,a
csp_init_wait:
		mov		r0,#csp_data_port
		movx	a,@r0
		jb		pin_dsp_data_rdy,csp_init_done
		cjne	a,dma_control_temp,csp_init_wait
		mov		r0,#10h
		movx	a,@r0
		anl		a,#0
		orl		a,#csp_data_port
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
csp_init_done:
		ljmp	cmdg_0_exit

;------------------------------- [05h] CSP Dual Write -------------------------------
; Writes to both CSP data and status ports
; Input: Byte1 → 80h (data), Byte2 → 81h (status)
;---------------------------------------------------------------------------------
cmd_csp_dual_write:
		lcall	dsp_data_read
		mov		r0,#csp_data_port
		movx	@r0,a
		lcall	dsp_data_read
		mov		r0,#csp_status_port
		movx	@r0,a
		ljmp	cmdg_0_exit

;=============================== CSP PORT OPERATIONS ================================
;------------------------------- [03h] CSP Read Data --------------------------------
; Reads current value from CSP data port (80h)
; Output: Returns byte from CSP data port
;---------------------------------------------------------------------------------
cmd_csp_read_data:
		mov		r0,#csp_data_port
		movx	a,@r0
		lcall	dsp_data_write
		ljmp	cmdg_0_exit

;------------------------------- [04h] CSP Set Mode ---------------------------------
; Configures CSP operation mode
; Input: Control byte → 82h (control port)
;---------------------------------------------------------------------------------
cmd_csp_control_mode:
		lcall	dsp_data_read
		mov		r0,#csp_control_port
		movx	@r0,a
		ljmp	cmdg_0_exit

;=============================== CSP LOCK MANAGEMENT ================================
;------------------------------- [06h] CSP Lock Increment ---------------------------
; Increases program lock count - prevents uploads
; Modifies: csp_lock_count (8-bit, no overflow check)
;---------------------------------------------------------------------------------
cmd_csp_lock_inc:
		inc		csp_lock_count
		ljmp	cmdg_0_exit

;------------------------------- [07h] CSP Lock Decrement ---------------------------
; Decreases program lock count - enable uploads
; Failsafe: Won't decrement below 00h
;---------------------------------------------------------------------------------
cmd_csp_lock_dec:
		mov		a,csp_lock_count
		cjne	a,#0,csp_dec_valid
		ljmp	cmdg_0_exit

csp_dec_valid:
		dec		csp_lock_count
		ljmp	cmdg_0_exit

;------------------------------- [0Ah] CSP Get Lock Count ---------------------------
; Output: Current lock count value
;---------------------------------------------------------------------------------
cmd_csp_program_lock:
		mov		a,csp_lock_count
		lcall	dsp_data_write

;=============================== CSP VERSION CONTROL ================================
;------------------------------- [08h] CSP Get Version ------------------------------
; Reads CSP chip version from X-Bus
; Output: Returns version byte from fixed X-Bus location
;---------------------------------------------------------------------------------
cmd_csp_version:
		mov		r0,#csp_control_port
		movx	a,@r0
		lcall	dsp_data_write
		ljmp	cmdg_0_exit

;=============================== INVALID COMMANDS ================================
;------------------------------- [00h/0Dh] No Operation --------------------------
; Placeholder for unimplemented commands
;---------------------------------------------------------------------------------
cmd_0_none:
		ljmp	wait_for_cmd

;=============================== X-BUS OPERATIONS ===================================
;------------------------------- [0Eh] X-Bus Write ----------------------------------
; Writes to any X-Bus address
; Input: [Address][Value] → Full bus access
; Security: No validation performed
;---------------------------------------------------------------------------------
cmd_xbus_write:
		lcall	dsp_data_read
		mov		b,a
		lcall	dsp_data_read
		mov		r0,b
		movx	@r0,a
		ljmp	wait_for_cmd

;------------------------------- [0Fh] X-Bus Read -----------------------------------
; Reads from any X-Bus address
; Input: [Address] → Returns value
;---------------------------------------------------------------------------------
cmd_xbus_read:
		lcall	dsp_data_read
		mov		r0,a
		movx	a,@r0
		lcall	dsp_data_write
cmdg_0_exit:
		ljmp	wait_for_cmd

;=============================== CSP PROGRAM ID ACCESS ==============================
;------------------------------- [09h] Get CSP Program ID --------------------------
; Output: [Program_ID_Low][Program_ID_High] 
; Returns last 2 bytes of uploaded CSP program
;---------------------------------------------------------------------------------
cmd_csp_program_id:
		mov		a,csp_program_id_lo
		lcall	dsp_data_write
		mov		a,csp_program_id_hi
		lcall	dsp_data_write
		sjmp	cmdg_0_exit

;=============================== CSP BLOCK TRANSFERS ================================
;------------------------------- [0Bh] CSP Block Write ------------------------------
; Sends data block to CSP program 
; Input: [Length][Data_Pairs...] → (Low,High) words
; Uses C0h handshake protocol on status port
;---------------------------------------------------------------------------------
cmd_csp_block_write:
		lcall	dsp_data_read
		mov		rem_xfer_len_lo,a
		mov		r0,#csp_data_port
		movx	@r0,a
		mov		a,#0c0h
		mov		dma_control_temp,a
		mov		r0,#csp_status_port
		movx	@r0,a
csp_block_write_wait:
		mov		r0,#csp_data_port
		movx	a,@r0
		cjne	a,dma_control_temp,csp_block_write_wait
csp_block_write_loop:
		lcall	dsp_data_read
		mov		r0,#csp_data_port
		movx	@r0,a
		lcall	dsp_data_read
		mov		r0,#csp_status_port
		movx	@r0,a
		clr		a
		cjne	a,rem_xfer_len_lo,csp_block_write_next
		sjmp	cmdg_0_exit

csp_block_write_next:
		dec		rem_xfer_len_lo
		sjmp	csp_block_write_loop

;------------------------------- [0Ch] CSP Block Read -------------------------------
; Receives data block from CSP program
; Input: [Length] → Returns [Data_Pairs...] (Low,High)
; Uses C1h handshake protocol on status port
;---------------------------------------------------------------------------------
cmd_csp_block_read:
		lcall	dsp_data_read
		mov		rem_xfer_len_lo,a
		mov		r0,#csp_data_port
		movx	@r0,a
		mov		a,#0c1h
		mov		dma_control_temp,a
		mov		r0,#csp_status_port
		movx	@r0,a
csp_block_read_wait:
		mov		r0,#csp_data_port
		movx	a,@r0
		cjne	a,dma_control_temp,csp_block_read_wait
		mov		a,dma_control_temp
		mov		r0,#csp_status_port
		movx	@r0,a
csp_block_read_loop:
		mov		r0,#csp_data_port
		movx	a,@r0
		lcall	dsp_data_write
		mov		r0,#csp_data_port
		movx	a,@r0
		lcall	dsp_data_write
		clr		a
		cjne	a,rem_xfer_len_lo,csp_block_read_next
		sjmp	cmdg_0_exit

csp_block_read_next:
		dec		rem_xfer_len_lo
		sjmp	csp_block_read_loop

;=============================== CSP PROGRAM MANAGEMENT =============================
;------------------------------- [01h] CSP Upload Program ---------------------------
; Uploads new CSP program with checksum
; Input: [Length][Checksum][Program ID] → 83h (program port)
; Security: Lock count must be 0, uses AA/FF status codes
;---------------------------------------------------------------------------------
cmd_csp_upload:
		mov		a,csp_lock_count
		cjne	a,#0,cmdg_0_exit
		lcall	dsp_data_write
		mov		a,#0
		mov		33h,a
		mov		34h,a
		mov		r0,#csp_data_port
		movx	@r0,a
		mov		r0,#csp_status_port
		movx	@r0,a
		lcall	dsp_data_read
		clr		c
		subb	a,#4
		mov		rem_xfer_len_lo,a
		lcall	dsp_data_read
		jnc		csp_upload_calc_len
		dec		a
csp_upload_calc_len:
		mov		rem_xfer_len_hi,a
		mov		a,#8ch
		mov		r0,#csp_control_port
		movx	@r0,a
		mov		a,#8ah
		mov		r0,#csp_control_port
		movx	@r0,a
csp_upload_loop:
		lcall	dsp_data_read
		mov		r0,#csp_program_port
		movx	@r0,a
		add		a,33h
		mov		33h,a
		jnc		csp_upload_next
		inc		34h
csp_upload_next:
		clr		a
		cjne	a,rem_xfer_len_lo,csp_upload_dec_lo
		cjne	a,rem_xfer_len_hi,csp_upload_dec_hi
		lcall	dsp_data_read
		mov		35h,a
		lcall	dsp_data_read
		mov		36h,a
		mov		a,#0
		mov		r0,#csp_control_port
		movx	@r0,a
		mov		a,#70h
		mov		r0,#csp_control_port
		movx	@r0,a
		mov		a,33h
		cjne	a,35h,csp_upload_fail
		mov		a,34h
		cjne	a,36h,csp_upload_fail
		mov		r0,#csp_data_port
		movx	a,@r0
		cjne	a,#0aah,csp_upload_fail_code
		mov		a,#0
		ljmp	csp_upload_fail_code

csp_upload_fail:
		mov		a,#0ffh
csp_upload_fail_code:
		lcall	dsp_data_write
		lcall	dsp_data_read
		mov		csp_program_id_lo,a
		lcall	dsp_data_read
		mov		csp_program_id_hi,a
		ljmp	cmdg_0_exit

csp_upload_dec_hi:
		dec		rem_xfer_len_hi
csp_upload_dec_lo:
		dec		rem_xfer_len_lo
		sjmp	csp_upload_loop

;============================= DSP RUNTIME CONFIGURATION =========================
;------------- Group 4: Samplerate, DMA Timing, and Peripheral Control -----------
; Handles DSP configuration via command byte [3:0]
; Uses jump table at table_setup_cmds
;---------------------------------------------------------------------------------
cmdg_setup:
		mov		dptr,#table_setup_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

; ----------------------------------------------------
; Index | Command | Handler
; ------|---------|-----------------------------------
;   0   |  40h    | cmd_set_time_constant		(6fh)
;   1   |  41h    | cmd_set_output_samplerate	(82h)
;   2   |  42h    | cmd_set_input_samplerate	(82h)
;   3   |  43h    | cmd_4_none					(24h)
;   4   |  44h    | cmd_pause_dma_8bit			(10h)
;   5   |  45h    | cmd_continue_dma_8bit		(15h)
;   6   |  46h    | cmd_pause_dma_16bit			(1ah)
;   7   |  47h    | cmd_continue_dma_16bit		(1fh)
; ---------------------------------------------------
;   8   |  48h    | cmd_set_dma_block_size		(9fh)
;   9   |  49h    | cmd_4_none					(24h)
;  10   |  4Ah    | cmd_4_none					(24h)
;  11   |  4Bh    | cmd_4_none					(24h)
;  12   |  4Ch    | cmd_dsp_store_data			(51h)
;  13   |  4Dh    | cmd_dsp_process_data		(60h)
;  14   |  4Eh    | cmd_set_timer_count			(27h)
;  15   |  4Fh    | cmd_control_timer			(2ch)
; ----------------------------------------------------
table_setup_cmds:
	.db cmd_set_time_constant		- table_setup_cmds ; 40h
	.db cmd_set_output_samplerate	- table_setup_cmds ; 41h
	.db cmd_set_input_samplerate	- table_setup_cmds ; 42h
	.db cmd_4_none					- table_setup_cmds ; 43h
	.db cmd_pause_dma_8bit			- table_setup_cmds ; 44h
	.db cmd_continue_dma_8bit		- table_setup_cmds ; 45h
	.db cmd_pause_dma_16bit			- table_setup_cmds ; 46h
	.db cmd_continue_dma_16bit		- table_setup_cmds ; 47h
	.db cmd_set_dma_block_size		- table_setup_cmds ; 48h
	.db cmd_4_none					- table_setup_cmds ; 49h
	.db cmd_4_none					- table_setup_cmds ; 4Ah
	.db cmd_4_none					- table_setup_cmds ; 4Bh
	.db cmd_dsp_store_data			- table_setup_cmds ; 4Ch
	.db cmd_dsp_process_data		- table_setup_cmds ; 4Dh
	.db cmd_set_timer_count			- table_setup_cmds ; 4Eh
	.db cmd_control_timer			- table_setup_cmds ; 4Fh

;============================= DMA FLOW CONTROL ==================================
;------------------------------- Pause/Resume 8-bit DMA -------------------------
; [44h] Pause 8-bit DMA (Index 4)
; Halts auto-initialized 8-bit transfers
;---------------------------------------------------------------------------------
cmd_pause_dma_8bit:
		setb	group_4_dma8_pause
		ljmp	cmdg_4_exit

;---------------------------------------------------------------------------------
; [45h] Resume 8-bit DMA (Index 5)
; Restarts paused 8-bit transfers  
;---------------------------------------------------------------------------------
cmd_continue_dma_8bit:
		clr		group_4_dma8_pause
		ljmp	cmdg_4_exit

;------------------------------- Pause/Resume 16-bit DMA ------------------------
; [46h] Pause 16-bit DMA (Index 6)
; Stops 16-bit auto-init transfers
;---------------------------------------------------------------------------------
cmd_pause_dma_16bit:
		setb	group_4_dma16_pause
		ljmp	cmdg_4_exit

;---------------------------------------------------------------------------------
; [47h] Resume 16-bit DMA (Index 7)  
; Restarts 16-bit transfers
;---------------------------------------------------------------------------------
cmd_continue_dma_16bit:
		clr		group_4_dma16_pause
		ljmp	cmdg_4_exit

;---------------------------------------------------------------------------------
; [43h, 49h, 4Ah, 4Bh] Invalid Commands
;---------------------------------------------------------------------------------
cmd_4_none:
		ljmp	wait_for_cmd

;============================= TIMER MANAGEMENT ==================================
;------------------------------- Timer Configuration -----------------------------
; [4Eh] Set Timer Count (Index 14)
; Programs Timer 0 with 16-bit inverted value
; Input: Two bytes (timer low/high via dsp_data_read)
; Affects: TL0/TH0, timer0_tlow/timer0_thigh (stored reload values)
;---------------------------------------------------------------------------------
cmd_set_timer_count:
		clr		timer0_auto_reload_en
		ljmp	X0820

;---------------------------------------------------------------------------------
; [4Fh] Control Timer (Index 15)
; Starts/Stops Timer 0 based on state
; Affects: TR0 (timer run), ET0 (timer int), timer0_auto_reload_en (enable flag)
;---------------------------------------------------------------------------------
cmd_control_timer:
		jnb		timer0_auto_reload_en,X081e
		clr		timer0_auto_reload_en
		clr		tr0
		clr		et0
		ljmp	cmdg_4_exit

X081e:	setb	timer0_auto_reload_en
X0820:	lcall	dsp_data_read
		cpl		a
		mov		tl0,a
		mov		timer0_tlow,a
		lcall	dsp_data_read
		cpl		a
		mov		th0,a
		mov		timer0_thigh,a
		setb	et0
		setb	tr0
		ljmp	cmdg_4_exit

;============================= DSP REGISTER ACCESS ===============================
; [4Ch] Store Data (Index 12)
; Writes to internal DSP registers 1Bh-1Eh
; Input: [0-3][value] (register index + data)
;---------------------------------------------------------------------------------
cmd_dsp_store_data:
		lcall	dsp_data_read
		anl		a,#3
		add		a,#1bh
		mov		r0,a
		lcall	dsp_data_read
		movx	@r0,a
		ljmp	cmdg_4_exit

;---------------------------------------------------------------------------------
; [4Dh] Process Data (Index 13)  
; Reads from DSP registers 1Bh-1Eh
; Input: [0-3] (register index)
; Output: Register value via dsp_data_write
;---------------------------------------------------------------------------------
cmd_dsp_process_data:
		lcall	dsp_data_read
		anl		a,#3
		add		a,#1bh
		mov		r0,a
		mov		a,@r0
		lcall	dsp_data_write
		ljmp	cmdg_4_exit

;============================ SAMPLERATE MANAGEMENT ==============================
; [40h] Set Time Constant (Index 0)
; Configures playback rate via time constant
; Input: 00h-EAh (0-234 dec) → 5kHz-45kHz
; Uses samplerate_table for hardware mapping
;---------------------------------------------------------------------------------
cmd_set_time_constant:
		lcall	dsp_data_read
		cjne	a,#0ebh,X085b
X085b:	jc		X085f
		mov		a,#0ebh
X085f:	lcall	convert_samplerate
		lcall	X0a0e
		ljmp	cmdg_4_exit

;---------------------------------------------------------------------------------
; [41h/42h] Set Samplerate (Index 1-2)
; Direct 16-bit samplerate programming
; Input: Big-endian 16-bit rate (playback/record)
; Affects: dma_addr_lo/dma_addr_hi (active rate registers)
;---------------------------------------------------------------------------------
cmd_set_input_samplerate:
cmd_set_output_samplerate:
		jnb		pin_dsp_data_rdy,cmd_set_input_samplerate
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		dma_addr_hi,a
X0872:	jnb		pin_dsp_data_rdy,X0872
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		dma_addr_lo,a
		lcall	X09a7
		lcall	X0a0e
		ljmp	cmdg_4_exit

;---------------------------------------------------------------------------------
; [48h] Set DMA Block Size (Index 8)
; Configures transfer block size
; Input: 16-bit block size
; Affects: dma8_block_len_lo/hi registers
;---------------------------------------------------------------------------------
cmd_set_dma_block_size:
		lcall	dsp_data_read
		mov		dma8_block_len_lo,a
		lcall	dsp_data_read
		mov		dma8_block_len_hi,a
		ljmp	cmdg_4_exit

cmdg_4_exit:
		ljmp	wait_for_cmd

;============================ HARDWARE CALIBRATION ===============================
;------------------------------- Samplerate Conversion --------------------------
; Converts time constant to hardware register value
; Uses: (17h * samplerate) ÷ 256
; Input: A=00h-EAh, Output: Mapped via samplerate_table
;---------------------------------------------------------------------------------
convert_samplerate:
		mov		dptr,#samplerate_table
		movc	a,@a+dptr
		ret	

;------------------------------- Samplerate Table -------------------------------
; Time Constant → Samplerate Register Mapping
; 256-entry table covering 5kHz-45kHz samplerates
; Special values: 0FFh = 45.32kHz, 0EBh = Max Valid Input
; Table has an error near the bottom, 0c8h instead of 64h.
;--------------------------------------------------------------------------------
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

;------------------------------- Samplerate Calibration -------------------------
; Calculates DMA timing parameters from samplerate
; Input: dma_addr_lo (low byte), dma_addr_hi (high byte)
; Output: dma_timing_control/timer0_counter = Calibrated timing value
; Affects: A, B, R0, dma_timing_control, timer0_counter
; Operation: Performs (17h * samplerate) ÷ 256
;--------------------------------------------------------------------------------
X09a7:
		mov		a,dma_addr_hi
		cjne	a,#0b1h,X09b1
		mov		a,#0ffh
		ljmp	X0a0d

X09b1:	jc		X09ba
		mov		a,#0ffh
		ljmp	X0a0d

X09ba:	mov		a,dma_addr_hi
		clr		c
		subb	a,#13h
		jnc		X09ca
		mov		a,#1ch
		ljmp	X0a0d

X09ca:	mov		a,#17h
		mov		b,dma_addr_hi
		mul		ab
		mov		timer0_counter,b
		mov		dma_timing_control,a
		mov		a,#17h
		mov		b,dma_addr_lo
		mul		ab
		xch		a,b
		add		a,dma_timing_control
		mov		dma_timing_control,a
		mov		a,timer0_counter
		addc	a,#0
		mov		a,timer0_counter					; Error, shouldnt be here.
		rrc		a
		mov		timer0_counter,a
		mov		a,dma_timing_control
		rrc		a
		mov		dma_timing_control,a
		mov		a,timer0_counter
		rrc		a
		mov		timer0_counter,a
		mov		a,dma_timing_control
		rrc		a
		mov		dma_timing_control,a
		mov		a,timer0_counter
		rrc		a
		mov		timer0_counter,a
		mov		a,dma_timing_control
		rrc		a
		mov		dma_timing_control,a
		mov		a,timer0_counter
		rrc		a
		mov		timer0_counter,a
		mov		a,dma_timing_control
		rrc		a
		addc	a,#0
		mov		dma_timing_control,a
X0a0d:	ret	

;------------------------------- DMA Controller Update ---------------------------
; Programs DMA controller register 09h with calculated value
; Input: A = Value to program
; Affects: R0, 37h, dma_timing_status flag
; Behavior: Uses dma16_ch1_enable to select DMA bank
;---------------------------------------------------------------------------------
X0a0e:
		mov		r0,#9
		mov		37h,a
		cjne	a,#0f8h,X0a1c
X0a1c:	jnc		X0a23
		setb	dma_timing_status
		ljmp	X0a25

X0a23:	clr		dma_timing_status
X0a25:	ret	

;--------------------- DMA TRANSFER RATE ENFORCEMENT ------------------------------
; Ensures Valid Samplerate ↔ Clock Cycle Alignment:
;   - Rejects Rates > 45.32kHz (Forces F8h if <5Ah)
;   - Triggers pin_dma_timing_fault Warning LED on Marginal Rates?
;   - Bypassed in Auto-Initialized Modes
;---------------------------------------------------------------------------------
X0a26:
		mov		r0,#9
		mov		a,37h
		movx	@r0,a
		ret	

;---------------------------------------------------------------------------------
; X0a3e: Emergency rate limiter
; Applies safe value when dma_timing_status (unsafe flag) set
;---------------------------------------------------------------------------------
X0a3e:
		jnb		dma_timing_status,X0a49
		mov		r0,#9
		mov		a,#0f8h
		movx	@r0,a
X0a49:	ret	

;============================ AUXILIARY COMMANDS =================================
;------------------------------- Group F Handler --------------------------------
; Processes F0h-FFh via table_aux_cmds jump table
; Index: command_byte[3:0]
;---------------------------------------------------------------------------------
cmdg_aux:
		mov		dptr,#table_aux_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

; ----------------------------------------------------
; Index | Command | Handler
; ------|---------|-----------------------------------
;   0   |  F0h    | cmd_init_dma				(81h)
;   1   |  F1h    | cmd_f_none					(41h)
;   2   |  F2h    | cmd_reset_control_dma8		(44h)
;   3   |  F3h    | cmd_reset_control_dma16		(53h)
;   4   |  F4h    | cmd_dsp_identify			(61h)
;   5   |  F5h    | cmd_f_none					(41h)
;   6   |  F6h    | cmd_f_none					(41h)
;   7   |  F7h    | cmd_f_none					(41h)
; ---------------------------------------------------
;   8   |  F8h    | cmd_mailbox_reset_or_diag	(6eh)
;   9   |  F9h    | cmd_internal_ram_peek		(10h)
;  10   |  FAh    | cmd_internal_ram_poke		(1Bh)
;  11   |  FBh    | cmd_dsp_status				(31h)
;  12   |  FCh    | cmd_dsp_auxiliary_status	(39h)
;  13   |  FDh    | cmd_dsp_command_status		(29h)
;  14   |  FEh    | cmd_f_none					(41h)
;  15   |  FFh    | cmd_f_none					(41h)
; ----------------------------------------------------
table_aux_cmds:
	.db cmd_init_dma				- table_aux_cmds ; F0h
	.db cmd_f_none					- table_aux_cmds ; F1h
	.db cmd_reset_control_dma8		- table_aux_cmds ; F2h
	.db cmd_reset_control_dma16		- table_aux_cmds ; F3h
	.db cmd_dsp_identify			- table_aux_cmds ; F4h
	.db cmd_f_none					- table_aux_cmds ; F5h
	.db cmd_f_none					- table_aux_cmds ; F6h
	.db cmd_f_none					- table_aux_cmds ; F7h
	.db cmd_mailbox_reset_or_diag	- table_aux_cmds ; F8h
	.db cmd_internal_ram_peek		- table_aux_cmds ; F9h
	.db cmd_internal_ram_poke		- table_aux_cmds ; FAh
	.db cmd_dsp_status				- table_aux_cmds ; FBh
	.db cmd_dsp_auxiliary_status	- table_aux_cmds ; FCh
	.db cmd_dsp_command_status		- table_aux_cmds ; FDh
	.db cmd_f_none					- table_aux_cmds ; FEh
	.db cmd_f_none					- table_aux_cmds ; FFh

;============================= MEMORY ACCESS COMMANDS ==============================
;------------------------------- Internal RAM Peek ---------------------------------
; [F9h] Internal RAM Peek (Group F Index: 9)
; Reads a byte from DSP internal RAM at the host-specified address.
; Input:  Host sends 1-byte address (00h-FFh).
; Output: Returns RAM content at specified address.
; Affects: R0, A
;-----------------------------------------------------------------------------------
cmd_internal_ram_peek:
		lcall	dsp_data_read
		mov		r0,a
		mov		a,@r0
		lcall	dsp_data_write
		ljmp	cmdg_f_exit

;------------------------------- Internal RAM Poke ---------------------------------
; [FAh] Internal RAM Poke (Group F Index: 10)
; Writes a byte to DSP internal RAM at specified address.
; Input:  [Address][Value] (2 bytes from host)
; Affects: R0, B, A
;-----------------------------------------------------------------------------------
cmd_internal_ram_poke:
		lcall	dsp_data_read
		mov		b,a
		lcall	dsp_data_read
		mov		r0,b
		mov		@r0,a
		ljmp	cmdg_f_exit

;============================= STATUS REPORTING COMMANDS ===========================
;------------------------------- DSP Command Status -------------------------------
; [FDh] Command Status (Group F Index: 13)
; Returns last processed command byte from register 30h.
;-----------------------------------------------------------------------------------
cmd_dsp_command_status:
		mov		a,command_reg
		lcall	dsp_data_write
		ljmp	cmdg_f_exit

;------------------------------- DSP Status Report ---------------------------------
; [FBh] Status Report (Group F Index: 11)
; Returns contents of DSP status register (23h).
;-----------------------------------------------------------------------------------
cmd_dsp_status:
		mov		a,status_reg
		lcall	dsp_data_write
		ljmp	cmdg_f_exit

;------------------------------- Auxiliary Status Report --------------------------
; [FCh] Aux Status Report (Group F Index: 12)
; Returns contents of auxiliary status register (24h).
;-----------------------------------------------------------------------------------
cmd_dsp_auxiliary_status:
		mov		a,auxiliary_reg
		lcall	dsp_data_write
		ljmp	cmdg_f_exit

;============================= INVALID COMMAND HANDLING ============================
;------------------------------- Group F Invalid Commands --------------------------
; [F1h/F5h-F7h/FEh/FFh] Reserved Commands (Group F Indexes: 1,5-7,14-15)
; Handles unimplemented/reserved commands in Group F.
; Effect: Immediate exit to command loop
;-----------------------------------------------------------------------------------
cmd_f_none:
		ljmp	cmdg_f_exit

;============================= DMA CONTROL COMMANDS ================================
;------------------------------- Reset 8-bit DMA Control --------------------------
; [F2h] Reset 8-bit DMA (Group F Index: 2)
; Resets 8-bit DMA control register (Port 8).
; Operation:
;   - Pulses high bit (80h) on port 8
;   - Clears auto-initialization state
; Affects: Port 8 control register
;-----------------------------------------------------------------------------------
cmd_reset_control_dma8:
		mov		r0,#8
		movx	a,@r0
		anl		a,#3
		movx	@r0,a
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	cmdg_f_exit

;------------------------------- Reset 16-bit DMA Control -------------------------
; [F3h] Reset 16-bit DMA (Group F Index: 3)
; Resets 16-bit DMA control register (Port 10h).
; Operation:
;   - Pulses high bit (80h) on port 10h
;   - Clears dual-channel state
; Affects: Port 10h control register
;-----------------------------------------------------------------------------------
cmd_reset_control_dma16:
		mov		r0,#10h
		movx	a,@r0
		anl		a,#0
		orl		a,#80h
		movx	@r0,a
		anl		a,#7fh
		movx	@r0,a
		ljmp	cmdg_f_exit

;============================= IDENTIFICATION COMMANDS =============================
;------------------------------- DSP Identification -------------------------------
; [F4h] DSP Identify (Group F Index: 4)
; Sends fixed identification sequence (A4h,6Fh).
; Used for firmware validation.
; Output: 0A4h, 06Fh
;-----------------------------------------------------------------------------------
cmd_dsp_identify:
		mov		a,#75h
		lcall	dsp_data_write
		mov		a,#92h
		lcall	dsp_data_write
		ljmp	cmdg_f_exit

;============================= MAILBOX MANAGEMENT COMMANDS =========================
;------------------------------- Mailbox Reset/Diagnostic -------------------------
; [F8h] Mailbox Control (Group F Index: 8)
; Two modes based on command_byte bit 2:
;   1. command_byte[2]=0: Reset host mailbox (port 0)
;   2. command_byte[2]=1: Execute diagnostic routine (X1233)
; Affects: Port 0 or CSP diagnostic subsystem
;-----------------------------------------------------------------------------------
cmd_mailbox_reset_or_diag:
		jb		command_byte_2,X0a85
		mov		a,#0
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
		ljmp	cmdg_f_exit

X0a85:	lcall	X1233
		ljmp	cmdg_f_exit

;============================= DMA INITIALIZATION COMMANDS =========================
;------------------------------- Initialize DMA Subsystem -------------------------
; [F0h] DMA/Interrupt Init (Group F Index: 0)
; Configures DMA subsystem and interrupts:
;   - Sets default sample rate (5Ah)
;   - Programs DMA control register (Port 4)
;   - Enables INT0 for command processing
; Affects: adpcm_state_reg, adpcm_mode_reg, Port 4, EX0
;-----------------------------------------------------------------------------------
cmd_init_dma:
		mov		a,#5ah
		lcall	X0a0e
		lcall	X0a26
		mov		adpcm_state_reg,#5
		mov		adpcm_mode_reg,#0
		mov		a,#60h
		mov		r0,#4
		movx	@r0,a
		setb	ex0
		ljmp	cmdg_f_exit

;============================= COMMON EXIT HANDLER =================================
;------------------------------- Group F Command Exit -----------------------------
; Common cleanup for all Group F commands:
;   - Clears DSP busy flag
;   - Returns to main command loop
;-----------------------------------------------------------------------------------
cmdg_f_exit:
		clr		pin_dsp_busy
		ljmp	check_cmd

;============================= MIDI SYSTEM DATA =====================================
int0_midi_data:
		.db	7fh,26h,1,26h,80h,0d9h,0ffh,0d9h
		.db	0

;============================= MIDI COMMAND PROCESSING ==============================
;------------------------------- Group 3: MIDI Operations --------------------------
; Processes MIDI-related commands:
; - Bit 3: MIDI Host→UART Write (38h)
; - Bit 2: MIDI Polled I/O (34h-37h)
; Preserves state via warm boot signatures 34h/12h
;-----------------------------------------------------------------------------------
cmdg_midi:
		jb		command_byte_3,cmd_midi_host_write
		jnb		command_byte_2,cmd_midi_read_write_poll
		mov		warmboot_magic1,#34h
		mov		warmboot_magic2,#12h
		ljmp	cmd_midi_read_write_poll

;------------------------------- MIDI Host Write ------------------------------------
; [38h] MIDI Host→UART Transfer
; Writes host data to MIDI output buffer:
; 1. Waits for transmitter ready (TI flag)
; 2. Reads byte from host
; 3. Writes to SBUF for UART transmission
;-----------------------------------------------------------------------------------
cmd_midi_host_write:
		jnb		ti,cmd_midi_host_write
		clr		ti
		lcall	dsp_data_read
		mov		sbuf,a
		ljmp	check_cmd

;============================= MIDI POLLED I/O SYSTEM ===============================
;------------------------------- Timestamped MIDI I/O ------------------------------
; [34h-37h] MIDI Polled I/O with Timestamp Support
; Features:
; - command_byte[1]: Enables 24-bit timestamp counter (uses Timer 0)
; - command_byte[2]: I/O direction (0=Read, 1=Write)
; Buffer: 128-byte circular buffer at 40h-C0h
; Timestamp: 24-bit counter in R5(LSB), R6, R7(MSB)
;-----------------------------------------------------------------------------------
cmd_midi_read_write_poll:
		jnb		command_byte_1,skip_midi_timestamp_setup
		mov		tmod,#rem_xfer_len_lo
		setb	midi_timestamp_en
		mov		tl0,#2fh
		mov		th0,#0f8h
		mov		r5,#0
		mov		r6,#0
		mov		r7,#0
		setb	et0
		setb	tr0
skip_midi_timestamp_setup:
		mov		a,sbuf
		clr		ri
		mov		r1,#midi_buffer_pt_write
		mov		r2,#midi_buffer_pt_read
		mov		r4,#midi_buffer_size
		ljmp	midi_check_for_input_data

;------------------------------- MIDI Polling Loop ----------------------------------
; Core MIDI I/O processing loop:
; 1. Checks transmitter ready status
; 2. Processes host commands
; 3. Maintains circular buffer
; Exit Conditions:
; - Host command received
; - Buffer flushed to host
;-----------------------------------------------------------------------------------
midi_poll_loop:
		jnb		ti,midi_check_for_input_data
		jnb		pin_dsp_data_rdy,midi_check_for_input_data
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		jb		command_byte_2,midi_write_poll
		clr		et0
		clr		tr0
		mov		warmboot_magic1,#0
		mov		warmboot_magic2,#0
		clr		midi_timestamp_en
		ljmp	check_cmd

;------------------------------- MIDI Byte Transmission ----------------------------
midi_write_poll:
		clr		ti
		mov		sbuf,a
midi_check_for_input_data:
		jb		ri,midi_has_input_data
		cjne	r4,#midi_buffer_size,midi_buffer_status_check
		sjmp	midi_poll_loop

midi_buffer_status_check:
		jnb		pin_host_data_rdy,midi_flush_buffer_to_host
		sjmp	midi_poll_loop

;------------------------------- MIDI Receive Handler ------------------------------
midi_has_input_data:
		jnb		command_byte_1,midi_read_no_timestamp
		clr		tr0
		mov		a,r5
		lcall	midi_buffer_store_data
		mov		a,r6
		lcall	midi_buffer_store_data
		mov		a,r7
		lcall	midi_buffer_store_data
		setb	tr0
midi_read_no_timestamp:
		mov		a,sbuf
		lcall	midi_buffer_store_data
		clr		ri
		sjmp	midi_poll_loop
		
		; Impossible to be called?
		cjne	r4,#midi_buffer_size,X0b42
		ljmp	midi_nowrap_readbuffer

X0b42:	mov		@r1,a
		inc		r1
		dec		r4
		cjne	r1,#midi_buffer_end,midi_flush_buffer_to_host
		mov		r1,#midi_buffer_pt_write

;------------------------------- Buffer Flush Routine ------------------------------
midi_flush_buffer_to_host:
		mov		a,r2
		mov		r0,a
		mov		a,@r0
		inc		r2
		inc		r4
		cjne	r2,#midi_buffer_end,midi_nowrap_readbuffer
		mov		r2,#midi_buffer_pt_read
midi_nowrap_readbuffer:
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
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
		sjmp	midi_poll_loop

;------------------------------- Buffer Write Operation ----------------------------
midi_buffer_store_data:
		cjne	r4,#0,midi_store_read_data_to_buffer
		ljmp	midi_ready_to_receive_more

midi_store_read_data_to_buffer:
		mov		@r1,a
		inc		r1
		dec		r4
		cjne	r1,#midi_buffer_end,midi_ready_to_receive_more
		mov		r1,#midi_buffer_pt_write
midi_ready_to_receive_more:
		ret	

;============================= MIDI UART INITIALIZATION ============================
;------------------------------- MIDI UART Setup -----------------------------------
; Initializes MIDI UART communication subsystem
; Operations:
;   - Programs UART control register (Port 2) with 0FEh
;   - Clears receive interrupt flag (RI)
;   - Initializes circular buffer pointers (40h-C0h range)
;   - Sets warm boot signature (34h/12h) for state recovery
; Affects:
;   - R0, R1, R2, R4
;   - Warm boot signatures (31h/32h)
;   - Status flag midi_active (MIDI active)
;-----------------------------------------------------------------------------------
midi_uart_init:	
		mov		r0,#2
		mov		a,#0feh
		movx	@r0,a
		setb	midi_active
		mov		a,sbuf
		clr		ri
		mov		r1,#midi_buffer_pt_write
		mov		r2,#midi_buffer_pt_read
		mov		r4,#midi_buffer_size
		mov		warmboot_magic1,#34h
		mov		warmboot_magic2,#12h
		ret	

;============================= MIDI I/O MANAGEMENT =================================
;------------------------------- MIDI I/O Handler ----------------------------------
; Manages MIDI data transmission and reception with state recovery
; Features:
;   - Checks for warm boot signature 52h/86h in registers 38h/39h
;   - Maintains 128-byte circular buffer at 40h-C0h
;   - Handles both interrupt-driven and polled I/O
;-----------------------------------------------------------------------------------
midi_io_handler:
		clr		pin_dsp_busy
		jb		pin_dsp_data_rdy,X0c09
		jnb		pin_midi_irq,X0bfe
		jb		ri,X0c12
		cjne	r4,#midi_buffer_size,midi_buffer_process
X0bea:	jnb		ti,midi_io_handler
		mov		r0,#2
		movx	a,@r0
		setb	pin_dsp_busy
		jnb		acc_dma8_mode_select,midi_io_handler
		mov		r0,#1
		movx	a,@r0
		clr		ti
		mov		sbuf,a
		sjmp	midi_io_handler

X0bfe:	clr		midi_active
		mov		warmboot_magic1,#0
		mov		warmboot_magic2,#0
X0c09:	ret	

;============================= MIDI BUFFER MANAGEMENT ==============================
;------------------------------- Buffer Processing ---------------------------------
; Manages 128-byte circular buffer for MIDI I/O
; Register Usage:
;   R1 - Write pointer (40h-C0h)
;   R2 - Read pointer (40h-C0h)
;   R4 - Free space counter (80h=empty, 00h=full)
;-----------------------------------------------------------------------------------
midi_buffer_process:
		mov		r0,#2
		movx	a,@r0
		jb		acc_dma16_mode_select,X0c1b
		sjmp	X0bea

X0c12:	mov		a,sbuf
		lcall	midi_buffer_store_data
		clr		ri
		sjmp	X0bea

		; Impossible to be called?
		cjne	r4,#midi_buffer_size,X0bd6
		ljmp	X0c25

X0bd6:	mov		@r1,a
		inc		r1
		dec		r4
		cjne	r1,#midi_buffer_end,X0c1b
		mov		r1,#midi_buffer_pt_write
X0c1b:	mov		a,r2
		mov		r0,a
		mov		a,@r0
		inc		r2
		inc		r4
		cjne	r2,#midi_buffer_end,X0c25
		mov		r2,#midi_buffer_pt_read
X0c25:	mov		r0,#2
		movx	@r0,a
		sjmp	X0bea

;============================= RECORDING COMMANDS ==================================
;------------------------------- Group 2: Recording Control -----------------------
; Handles DMA audio recording modes:
; - command_byte[3]: Auto-initialize recording
; - command_byte[2]: Single-cycle recording
; - Default: Direct recording
;-----------------------------------------------------------------------------------
cmdg_rec:
		clr		dma_safety_override_en
		jb		command_byte_3,dma_rec_autoinit
		jb		command_byte_2,dma_rec_normal
		ljmp	dma_rec_direct

;------------------------------- Auto-Init DMA Recording --------------------------
; Initializes looping DMA recording with pre-defined block size
; Configuration:
;   - Uses 8-bit DMA mode
;   - Sets transfer length from dma_blk_len registers
;   - Programs DMA controller for auto-reinitialize
;-----------------------------------------------------------------------------------
dma_rec_autoinit:
		lcall	X0a26
		setb	dma8_mode
		mov		a,dma8_block_len_lo
		mov		rem_xfer_len_lo,a
		mov		r0,#0bh
		movx	@r0,a
		mov		a,dma8_block_len_hi
		mov		rem_xfer_len_hi,a
		mov		r0,#0ch
		movx	@r0,a
		ljmp	X0cd4

;------------------------------- Normal DMA Recording -----------------------------
; Configures single-cycle DMA recording from host
; Flow:
;   1. Wait for host parameters
;   2. Set transfer length
;   3. Enable DMA mode
;-----------------------------------------------------------------------------------
dma_rec_normal:
		lcall	X0a26
		jb		dma8_ch1_enable,X0cba
X0c95:	jnb		pin_dsp_data_rdy,X0c95
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		dma8_xfer_len_lo,a
X0c9f:	jnb		pin_dsp_data_rdy,X0c9f
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		dma8_xfer_len_hi,a
		setb	dma8_active
		ljmp	X0d1d

X0cba:	jnb		pin_dsp_data_rdy,X0cba
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		rem_xfer_len_lo,a
		mov		r0,#0bh
		movx	@r0,a
X0cc7:	jnb		pin_dsp_data_rdy,X0cc7
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		rem_xfer_len_hi,a
		mov		r0,#0ch
		movx	@r0,a
X0cd4:	setb	dma16_start_pending
		mov		adpcm_mode_reg,#5
		lcall	dma_update_control_register
		mov		r0,#8
		movx	a,@r0
		orl		a,#40h
		movx	@r0,a
		anl		a,#0bfh
		movx	@r0,a
		clr		dma8_ch1_enable
		setb	ex1
		clr		ea
		mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		nop	
		nop	
		setb	pin_dma_req
		clr		pin_dma_req

		setb	ea
		ljmp	check_cmd

;------------------------------- DMA Rec Direct ------------------------------------
; Immediately reads a sample from the microphone input and returns it as a byte.
;-----------------------------------------------------------------------------------
dma_rec_direct:
		mov		a,#61h
		mov		r0,#4
		movx	@r0,a
		mov		r0,#17h
X0d0e:	movx	a,@r0
		jnb		acc_dma16_mode_select,X0d0e
		mov		r0,#1bh
		movx	a,@r0
X0d15:	jb		pin_host_data_rdy,X0d15
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
X0d1d:	ljmp	check_cmd

;============================= HIGH-SPEED DMA COMMANDS =============================
;------------------------------- Group 9: High-Speed Modes -------------------------
; Manages high-speed DMA operations:
; - command_byte[3]: Recording mode
; - command_byte[0]: Bit depth selection
; Features:
;   - Auto-initialized transfers
;   - Warm boot signature preservation
;   - Dual 8/16-bit mode support
;-----------------------------------------------------------------------------------
cmdg_hs:
		lcall	X0a26
		clr		dma_safety_override_en
		jnb		command_byte_3,hs_dma_playback
		mov		adpcm_mode_reg,#5
		setb	dma16_start_pending
		mov		r0,#8
		movx	a,@r0
		orl		a,#40h
		movx	@r0,a
		anl		a,#0bfh
		movx	@r0,a
		jb		command_byte_1,hs_dma_record_exit
		setb	dma8_mode
		ljmp	hs_dma_continuous

hs_dma_record_exit:
		clr		dma8_mode
		ljmp	hs_dma_continuous

;-----------------------------------------------------------------------------------
; Starts high speed DMA playback mode
;-----------------------------------------------------------------------------------
hs_dma_playback:
		mov		adpcm_mode_reg,#4
		setb	dma8_start_pending
		jb		command_byte_1,hs_dma_playback_exit
		setb	dma8_mode
		ljmp	hs_dma_continuous

hs_dma_playback_exit:
		clr		dma8_mode
hs_dma_continuous:
		mov		a,dma8_block_len_lo
		mov		r0,#0bh
		movx	@r0,a
		mov		a,dma8_block_len_hi
		mov		r0,#0ch
		movx	@r0,a
		mov		warmboot_magic1,#34h
		mov		warmboot_magic2,#12h
		clr		dma8_ch1_enable
		lcall	dma_update_control_register
		setb	ex1
		clr		ea
		mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		nop	
		nop	
		setb	pin_dma_req
		clr		pin_dma_req
		setb	ea
		ljmp	check_cmd

;============================= PRIMARY AUDIO PLAYBACK ==============================
;------------------------------- Group 1: Main Audio Output ------------------------
; Manages primary DMA audio playback:
; - command_byte[3]: Auto-initialized playback
; - command_byte[2]: Normal DMA transfer
; - Default: Direct DAC output
; Supports 2-bit ADPCM compressed audio
;-----------------------------------------------------------------------------------
cmdg_dma_dac1:
		clr		dma_safety_override_en
		jb		command_byte_3,dma_dac1_autoinit
		jb		command_byte_2,dma_dac1_normal
		ljmp	dma_dac1_direct

;------------------------------- Auto-Init Playback --------------------------------
; Configures looping playback with predefined block size
; Features:
;   - Uses 8-bit DMA mode
;   - Automatic buffer reinitialization
;   - Preloaded block size from dma_blk_len
;-----------------------------------------------------------------------------------
dma_dac1_autoinit:
		lcall	X0a26
		setb	dma8_mode
		mov		a,dma8_block_len_lo
		mov		rem_xfer_len_lo,a
		mov		r0,#0bh
		movx	@r0,a
		mov		a,dma8_block_len_hi
		mov		rem_xfer_len_hi,a
		mov		r0,#0ch
		movx	@r0,a
		ljmp	X0dfd

;------------------------------- Normal DMA Playback -------------------------------
; Configures single-cycle audio transfer
; Flow:
;   1. Validate DMA timing parameters
;   2. Get transfer length from host
;   3. Configure DMA engine
;-----------------------------------------------------------------------------------
dma_dac1_normal:
		lcall	X0a26
		jnb		dma8_mode,X0ddf
		jnb		command_byte_1,X0dce
		clr		ex0
X0dce:	lcall	dsp_data_read
		mov		dma8_xfer_len_lo,a
		lcall	dsp_data_read
		mov		dma8_xfer_len_hi,a
		setb	dma8_active
		setb	ex0
		ljmp	X0e27

X0ddf:	clr		dma8_active
		lcall	dsp_data_read
		mov		rem_xfer_len_lo,a
		mov		r0,#0bh
		movx	@r0,a
		lcall	dsp_data_read
		mov		rem_xfer_len_hi,a
		mov		r0,#0ch
		movx	@r0,a
X0dfd:	jb		command_byte_1,dma_dac1_adpcm_use_2bit
		setb	dma8_start_pending
		mov		adpcm_mode_reg,#4
		lcall	dma_update_control_register
		clr		dma8_ch1_enable
		setb	ex1
		clr		ea
		mov		r0,#8
		mov		a,#4
		movx	@r0,a
		mov		a,#0
		movx	@r0,a
		nop	
		nop	
		setb	pin_dma_req
		clr		pin_dma_req
		setb	ea
X0e27:	ljmp	check_cmd

;============================= ADPCM COMPRESSION HANDLING ==========================
;------------------------------- 2-bit ADPCM Encoding ------------------------------
; Configures 2-bit ADPCM compression for audio output
; Features:
;   - command_byte[0]: Reference sample control
;   - Uses circular buffer at 40h-C0h
;   - 4 samples per byte (2 bits per sample)
;-----------------------------------------------------------------------------------
dma_dac1_adpcm_use_2bit:
		clr		dma8_ch1_enable
		mov		adpcm_state_reg,#2
		mov		adpcm_mode_reg,#2
		lcall	dma_update_control_register
		lcall	dma_arm_channel
		jb		command_byte_0,dma_dac1_reference
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X0e41:	movx	a,@r0
		jnb		acc_dma8_mode_select,X0e41
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
		mov		r3,#4
		ljmp	X0e63

;------------------------------- Reference Sample Handling -------------------------
; Initializes ADPCM decoding with reference sample
; Operation:
;   - Triggers DMA request for reference byte
;   - Sets initial sample counter (r3=1)
;-----------------------------------------------------------------------------------
dma_dac1_reference:
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X0e54:	movx	a,@r0
		jnb		acc_dma8_mode_select,X0e54
		mov		r0,#1fh
		movx	a,@r0
		mov		r2,a
		mov		r0,#19h
		movx	@r0,a
		mov		r5,#1
		mov		r3,#1
X0e63:	setb	ex0
		ljmp	check_cmd

;============================= DIRECT DAC OUTPUT HANDLING ===========================
;------------------------------- Immediate DAC Loading -----------------------------
; Bypasses DMA to directly load DAC with host-provided sample
; Operation:
;   - Programs control register for direct mode
;   - Waits for host data and writes to DAC register
;-----------------------------------------------------------------------------------
dma_dac1_direct:
		mov		a,#60h
		mov		r0,#4
		movx	@r0,a
X0e6d:	jnb		pin_dsp_data_rdy,X0e6d
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		mov		r0,#19h
		movx	@r0,a
		ljmp	check_cmd

;============================= 16-BIT ADPCM PLAYBACK HANDLING =======================
;------------------------------- Group 7: 16-bit ADPCM DMA --------------------------
; Handles secondary DMA playback commands for 16-bit ADPCM audio
; Modes:
;   - Auto-initialize DMA playback (command_byte[3])
;   - Single-cycle DMA playback (command_byte[2])
;-----------------------------------------------------------------------------------
cmdg_dma_dac2:
		lcall	X0a26
		clr		dma_safety_override_en
		jb		command_byte_3,dma_dac2_adpcm_autoinit
		jb		command_byte_2,dma_dac2_adpcm

;------------------------------- Auto-Init 8-bit ADPCM ------------------------------
; Configures looping 8-bit ADPCM playback
; Configuration:
;   - Sets dma8_mode flag
;   - Uses predefined block size from dma_blk_len registers
;-----------------------------------------------------------------------------------
dma_dac2_adpcm_autoinit:
		setb	dma8_mode
		mov		rem_xfer_len_lo,dma8_block_len_lo
		mov		rem_xfer_len_hi,dma8_block_len_hi
		ljmp	X0eb8

;------------------------------- Single-Cycle ADPCM Transfer ------------------------
; Handles one-time ADPCM playback
; Flow:
;   1. Reads transfer length from host
;   2. Enables non-looping DMA mode
;-----------------------------------------------------------------------------------
dma_dac2_adpcm:
		jb		dma8_mode,X0e97
		ljmp	X0eaa

X0e97:	clr		ex0
		lcall	dsp_data_read
		mov		dma8_xfer_len_lo,a
		lcall	dsp_data_read
		mov		dma8_xfer_len_hi,a
		setb	dma8_active
		setb	ex0
		ljmp	check_cmd

;------------------------------- Non-Auto-Init Configuration -----------------------
; Sets up non-looping DMA parameters
; Operation:
;   - Receives transfer length from host
;   - Disables auto-init mode
;-----------------------------------------------------------------------------------
X0eaa:	clr		dma8_active
		lcall	dsp_data_read
		mov		rem_xfer_len_lo,a
		lcall	dsp_data_read
		mov		rem_xfer_len_hi,a
		setb	pin_dsp_busy
X0eb8:	clr		dma8_ch1_enable
		jnb		command_byte_1,dma_dac2_adpcm_use_4bit
		mov		adpcm_state_reg,#3
		ljmp	dma_dac2_adpcm_use_2_6bit

;============================= ADPCM MODE SELECTION ================================
;------------------------------- 4-bit ADPCM Mode ----------------------------------
; Configures decoder for 4-bit ADPCM (2 samples/byte)
;-----------------------------------------------------------------------------------
dma_dac2_adpcm_use_4bit:
		mov		adpcm_state_reg,#4

;------------------------------- 2.6-bit ADPCM Mode ---------------------------------
; Configures decoder for proprietary 2.6-bit ADPCM (3 samples/byte)
;-----------------------------------------------------------------------------------
dma_dac2_adpcm_use_2_6bit:
		mov		adpcm_mode_reg,#2
		lcall	dma_update_control_register
		lcall	dma_arm_channel
		jnb		command_byte_0,dma_dac2_no_reference
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X0ed8:	movx	a,@r0
		jnb		acc_dma8_mode_select,X0ed8
		mov		r0,#1fh
		movx	a,@r0
		mov		r2,a
		mov		r0,#19h
		movx	@r0,a
		mov		r5,#1
		mov		r3,#1
		ljmp	X0f02

;------------------------------- No Reference Sample Handling -----------------------
; Starts ADPCM decoding without reference sample
; Operation:
;   - Gets first data byte directly
;   - Sets sample counter based on compression mode
;-----------------------------------------------------------------------------------
dma_dac2_no_reference:
		setb	pin_dma_req
		clr		pin_dma_req
		mov		r0,#0fh
X0ef0:	movx	a,@r0
		jnb		acc_dma8_mode_select,X0ef0
		mov		r0,#1fh
		movx	a,@r0
		mov		r6,a
		jnb		command_byte_1,dac_no_ref_adpcm4
		mov		r3,#3
		ljmp	X0f02

dac_no_ref_adpcm4:
		mov		r3,#4
X0f02:	setb	ex0
		ljmp	check_cmd

;=============================== SILENCE GENERATION ================================
;------------------------------- Command Group 8: DAC Silence ----------------------
; Generates digital silence output
; Configuration:
;   - Sets silence mode in control register
;   - Receives duration parameters from host
;-----------------------------------------------------------------------------------
cmdg_silence:
		lcall	X0a26
		clr		dma8_ch1_enable
		lcall	dsp_data_read
		mov		rem_xfer_len_lo,a
		lcall	dsp_data_read
		mov		rem_xfer_len_hi,a
		mov		adpcm_state_reg,#1
		mov		adpcm_mode_reg,#2
		lcall	dma_update_control_register
		setb	ex0
		ljmp	check_cmd

;=============================== MISCELLANEOUS COMMANDS ============================
;------------------------------- Command Group D: System Control -------------------
; Handles various system control commands
; Uses jump table at table_misc_cmds for subcommand dispatch
;-----------------------------------------------------------------------------------
cmdg_misc:
		mov		dptr,#table_misc_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

; ----------------------------------------------------
; Index | Command | Handler
; ------|---------|-----------------------------------
;   0   |  D0h    | cmd_pause_dma8				(13h)
;   1   |  D1h    | cmd_speaker_on				(0b7h)
;   2   |  D2h    | cmd_d_none					(10h)
;   3   |  D3h    | cmd_speaker_off				(0bch)
;   4   |  D4h    | cmd_resume_dma8				(4bh)
;   5   |  D5h    | cmd_pause_dma16				(39h)
;   6   |  D6h    | cmd_resume_dma16			(6ah)
;   7   |  D7h    | cmd_d_none					(10h)
; ---------------------------------------------------
;   8   |  D8h    | cmd_speaker_status			(8ch)
;   9   |  D9h    | cmd_exit_autoinit_dma16		(0a8h)
;  10   |  DAh    | cmd_exit_autoinit_dma8		(0a3h)
;  11   |  DBh    | cmd_d_none					(10h)
;  12   |  DCh    | cmd_dsp_challenge_response		(0adh)
;  13   |  DDh    | cmd_dsp_clear_challenge			(0b2h)
;  14   |  DEh    | cmd_set_start_dma8			(7ah)
;  15   |  DFh    | cmd_clear_start_dma8		(83h)
; ----------------------------------------------------
table_misc_cmds:
	.db cmd_pause_dma8				- table_misc_cmds ; D0h
	.db cmd_speaker_on				- table_misc_cmds ; D1h
	.db cmd_d_none					- table_misc_cmds ; D2h
	.db cmd_speaker_off				- table_misc_cmds ; D3h
	.db cmd_resume_dma8				- table_misc_cmds ; D4h
	.db cmd_pause_dma16				- table_misc_cmds ; D5h
	.db cmd_resume_dma16			- table_misc_cmds ; D6h
	.db cmd_d_none					- table_misc_cmds ; D7h
	.db cmd_speaker_status			- table_misc_cmds ; D8h
	.db cmd_exit_autoinit_dma16		- table_misc_cmds ; D9h
	.db cmd_exit_autoinit_dma8		- table_misc_cmds ; DAh
	.db cmd_d_none					- table_misc_cmds ; DBh
	.db cmd_dsp_clear_challenge			- table_misc_cmds ; DCh
	.db cmd_dsp_challenge_response		- table_misc_cmds ; DDh
	.db cmd_set_start_dma8			- table_misc_cmds ; DEh
	.db cmd_clear_start_dma8		- table_misc_cmds ; DFh

;-----------------------------------------------------------------------------------
; 10h: invalid command D2, D7, DB
;-----------------------------------------------------------------------------------
cmd_d_none:
		ljmp	cmdg_d_exit

;------------------------------- Halt 8-bit DMA (D0h) ------------------------------
; Stops active 8-bit DMA transfers
; Operation:
;   1. Disables interrupt ex0
;   2. Resets DMA controller registers
;   3. Applies safety timing delay
;-----------------------------------------------------------------------------------
cmd_pause_dma8:
		lcall	X0a3e
		setb	dma8_ch1_enable
		mov		r0,#4
		movx	a,@r0
		jb		acc_dma8_mode_active,X0f9c
		clr		ex0
		ljmp	cmdg_d_exit

X0f9c:	mov		r0,#8
		movx	a,@r0
		anl		a,#0e7h
		orl		a,#42h
		movx	@r0,a
		mov		dma_control_temp,#dma8_config_temp
X0fa7:	djnz	dma_control_temp,X0fa7
		anl		a,#0a7h
		movx	@r0,a
		clr		ex1
		ljmp	cmdg_d_exit

;------------------------------- Halt 16-bit DMA (D5h) -----------------------------
; Stops active 16-bit DMA transfers
; Operation:
;   1. Modifies DMA control register 10h
;   2. Sets safety flag dma16_ch1_paused
;-----------------------------------------------------------------------------------
cmd_pause_dma16:
		lcall	X0a3e
		mov		r0,#10h
		movx	a,@r0
		anl		a,#0e7h
		orl		a,#2
		movx	@r0,a
		clr		ex1
		setb	dma16_ch1_enable
		ljmp	cmdg_d_exit

;------------------------------- Resume 8-bit DMA (D4h) ----------------------------
; Restarts paused 8-bit DMA transfers
; Operation:
;   1. Reinitializes DMA parameters
;   2. Restores block size registers
;-----------------------------------------------------------------------------------
cmd_resume_dma8:
		lcall	X0a26
		clr		dma8_ch1_enable
		mov		r0,#4
		movx	a,@r0
		jb		acc_dma8_mode_active,X0fdd
		setb	ex0
		ljmp	cmdg_d_exit

X0fdd:	mov		r0,#8
		movx	a,@r0
		anl		a,#0e5h
		movx	@r0,a
		setb	pin_dma_req
		clr		pin_dma_req
		setb	ex1
		ljmp	cmdg_d_exit

;------------------------------- Resume 16-bit DMA (D6h) ---------------------------
; Restarts paused 16-bit DMA transfers
; Operation:
;   1. Clears safety flag dma16_ch1_enable
;   2. Reconfigures DMA control register 10h
;-----------------------------------------------------------------------------------
cmd_resume_dma16:
		lcall	X0a26
		mov		r0,#10h
		movx	a,@r0
		anl		a,#0e5h
		movx	@r0,a
		setb	ex1
		clr		dma16_ch1_enable
		ljmp	cmdg_d_exit

;============================= CONTROL REGISTER OPERATIONS =========================
;------------------------------- Set 8-bit DMA Start Pending (DEh) ----------------
cmd_set_start_dma8:
		mov		r0,#5
		movx	a,@r0
		setb	acc_dma8_start_pending
		movx	@r0,a
		ljmp	cmdg_d_exit

;------------------------------- Clear 8-bit DMA Start Pending (DFh) --------------
cmd_clear_start_dma8:
		mov		r0,#5
		movx	a,@r0
		clr		acc_dma8_start_pending
		movx	@r0,a
		ljmp	cmdg_d_exit

;============================= SPEAKER CONTROL COMMANDS ============================
;------------------------------- Speaker Status Report (D8h) -----------------------
; Reports current speaker state via host port
; Output:
;   FFh = Speaker enabled (mute off)
;   00h = Speaker disabled (mute on)
;-----------------------------------------------------------------------------------
cmd_speaker_status:
		jb		command_byte_1,cmd_exit_autoinit_dma8
		jb		mute_enable,X0f68
		clr		a
		ljmp	X0f6a

X0f68:	mov		a,#0ffh
X0f6a:	jb		pin_host_data_rdy,X0f6a
		mov		r0,#0
		nop	
		nop	
		; Send speaker status. FFh=enabled, 00h=disabled
		movx	@r0,a
		ljmp	cmdg_d_exit

;============================= DMA MODE MANAGEMENT =================================
;------------------------------- Exit 8-bit Auto-Init Mode (DAh) -------------------
; Disables 8-bit auto-initialized DMA transfers
; Affects: dma8_mode flag (22h)
;-----------------------------------------------------------------------------------
cmd_exit_autoinit_dma8:
		clr		dma8_mode
		ljmp	cmdg_d_exit

;------------------------------- Exit 16-bit Auto-Init Mode (D9h) ------------------
; Disables 16-bit auto-initialized DMA transfers
; Affects: dma16_mode flag (24h)
;-----------------------------------------------------------------------------------
cmd_exit_autoinit_dma16:
		clr		dma16_mode
		ljmp	cmdg_d_exit

;------------------------------- Clear and Exit (DDh) ------------------------------
; Resets diagnostic flags and warm boot signatures
; Affects:
;   - Clears warm boot magic bytes (38h/39h)
;   - Resets diagnostic flag diagnostic_flag
;-----------------------------------------------------------------------------------
cmd_dsp_clear_challenge:
		clr		pin_midi_pwr
		ljmp	cmdg_d_exit

;------------------------------- Check and Set Flag (DCh) --------------------------
; Establishes host-DSP challenge/response protocol
; Operation:
;   1. Sets challenge bytes 38h=52h/39h=86h
;   2. Waits for host to send 01h confirmation
;   3. Sets diagnostic flag diagnostic_flag on success
;-----------------------------------------------------------------------------------
cmd_dsp_challenge_response:
		setb	pin_midi_pwr
		ljmp	cmdg_d_exit

;------------------------------- Enable Speaker Output (D1h) -----------------------
; Activates analog audio output
; Operation: Sets mute_enable flag (1Ch)
;-----------------------------------------------------------------------------------
cmd_speaker_on:
		setb	mute_enable
		ljmp	cmdg_d_exit

;------------------------------- Disable Speaker Output (D3h) ----------------------
; Activates analog audio output
; Operation: Sets mute_enable flag (1Ch)
;-----------------------------------------------------------------------------------
cmd_speaker_off:
		clr		mute_enable

;============================= COMMAND GROUP EXIT HANDLER ==========================
;------------------------------- Group D Cleanup -----------------------------------
; Common exit routine for all Group D commands:
;   1. Clears DSP busy flag
;   2. Re-enables interrupts
;   3. Returns to main command loop
;-----------------------------------------------------------------------------------
cmdg_d_exit:
		clr		pin_dsp_busy
		ljmp	check_cmd

;============================= DSP IDENTIFICATION HANDLERS =========================
;------------------------------- Command Group E: Identification -------------------
; Handles DSP identification commands via jump table
;-----------------------------------------------------------------------------------
cmdg_ident:
		mov		dptr,#table_ident_cmds
		mov		a,command_byte
		anl		a,#0fh
		movc	a,@a+dptr
		jmp		@a+dptr

; -------------------------------------------------
; Index | Command | Handler
; ------|---------|--------------------------------
;   0   |  E0h    | cmd_invert_bits          (13h)
;   1   |  E1h    | cmd_dsp_version          (56h)
;   2   |  E2h    | cmd_dsp_dma_id           (2dh)
;   3   |  E3h    | cmd_dsp_copyright        (71h)
;   4   |  E4h    | cmd_write_test_reg       (25h)
;   5   |  E5h    | cmd_e_none               (10h)
;   6   |  E6h    | cmd_e_none               (10h)
;   7   |  E7h    | cmd_e_none               (10h)
; ------------------------------------------------
;   8   |  E8h    | cmd_read_test_reg        (1dh)
;   9   |  E9h    | cmd_e_none               (10h)
;  10   |  EAh    | cmd_e_none               (10h)
;  11   |  EBh    | cmd_e_none               (10h)
;  12   |  ECh    | cmd_e_none               (10h)
;  13   |  EDh    | cmd_e_none               (10h)
;  14   |  EEh    | cmd_e_none               (10h)
;  15   |  EFh    | cmd_e_none               (10h)
; -------------------------------------------------
table_ident_cmds:
	.db cmd_invert_bits			- table_ident_cmds ; E0h
	.db cmd_dsp_version			- table_ident_cmds ; E1h
	.db cmd_dsp_dma_id			- table_ident_cmds ; E2h
	.db cmd_dsp_copyright		- table_ident_cmds ; E3h
	.db cmd_write_test_reg		- table_ident_cmds ; E4h
	.db cmd_e_none				- table_ident_cmds ; E5h
	.db cmd_e_none				- table_ident_cmds ; E6h
	.db cmd_e_none				- table_ident_cmds ; E7h
	.db cmd_read_test_reg		- table_ident_cmds ; E8h
	.db cmd_e_none				- table_ident_cmds ; E9h
	.db cmd_e_none				- table_ident_cmds ; EAh
	.db cmd_e_none				- table_ident_cmds ; EBh
	.db cmd_e_none				- table_ident_cmds ; ECh
	.db cmd_e_none				- table_ident_cmds ; EDh
	.db cmd_e_none				- table_ident_cmds ; EEh
	.db cmd_e_none				- table_ident_cmds ; EFh

;-----------------------------------------------------------------------------------
; 10h: command E5, E6, E7, E9, EA, EB, EC, ED, EE, EF
; ;-----------------------------------------------------------------------------------
cmd_e_none:
		ljmp	cmdg_e_exit

;------------------------------- Command E0: Invert Bits ---------------------------
; Inverts bits of received data byte and echoes back
;-----------------------------------------------------------------------------------
cmd_invert_bits:
		lcall	dsp_data_read
		cpl		a
		lcall	dsp_data_write
		ljmp	cmdg_e_exit

;------------------------------- Command E8: Read Test Register --------------------
; Returns contents of test register 2Ah to host
;-----------------------------------------------------------------------------------
cmd_read_test_reg:
		mov		a,2ah
		lcall	dsp_data_write
		ljmp	cmdg_e_exit

;------------------------------- Command E4: Write Test Register -------------------
; Writes value to test register 2Ah
;-----------------------------------------------------------------------------------
cmd_write_test_reg:
		lcall	dsp_data_read
		mov		2ah,a
		ljmp	cmdg_e_exit

;------------------------------- Command E2: Firmware Validation -------------------
; Performs challenge/response authentication using DSP ID registers
;-----------------------------------------------------------------------------------
cmd_dsp_dma_id:
		mov		adpcm_mode_reg,#3
		lcall	dma_update_control_register
		lcall	dsp_data_read
		xrl		a,dsp_dma_id1
		add		a,dsp_dma_id0
		mov		dsp_dma_id0,a
		mov		a,dsp_dma_id1
		rr		a
		rr		a
		mov		dsp_dma_id1,a
		mov		a,dsp_dma_id0
		mov		r0,#1dh
		movx	@r0,a
		clr		dma8_ch1_enable
		setb	pin_dma_req
		clr		pin_dma_req
X10b5:	jb		pin_host_data_rdy,X10b5
		nop	
		setb	dma8_ch1_enable
		ljmp	cmdg_e_exit

;------------------------------- Command E1: DSP Version Report --------------------
; Transmits DSP firmware version (major/minor) to host
;-----------------------------------------------------------------------------------
cmd_dsp_version:
		; Locate dsp version number
		mov		dptr,#dsp_version
		clr		a
		movc	a,@a+dptr
		; Transmit major version number
X10c3:	jb		pin_host_data_rdy,X10c3
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
		mov		a,#1
		movc	a,@a+dptr
		; Transmit minor version number
X10ce:	jb		pin_host_data_rdy,X10ce
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
		ljmp	cmdg_e_exit

;------------------------------- Command E3: Copyright Notice ----------------------
; Streams copyright string to host
;-----------------------------------------------------------------------------------
cmd_dsp_copyright:
		mov		dptr,#dsp_copyright
		clr		a
X10dd:	mov		b,a
		movc	a,@a+dptr
		lcall	dsp_data_write
		jz		cmdg_e_exit
		mov		a,b
		inc		a
		sjmp	X10dd

;------------------------------- Group E Exit Handler ------------------------------
; Common cleanup for Group E commands
;-----------------------------------------------------------------------------------
cmdg_e_exit:
		clr		pin_dsp_busy
		ljmp	wait_for_cmd

;================================ ADPCM DECODERS ===================================
;------------------------------- ADPCM 2-bit Decode Routine ------------------------
; Processes 2-bit ADPCM compressed audio samples
; Register Usage:
;   r2 = Output sample | r3 = Remaining samples | r5 = Step size | r6 = Input byte
;-----------------------------------------------------------------------------------
adpcm_2_decode:
		mov		a,r6
		rlc		a
		jc		adpcm_2_decode_negative
		rlc		a
		mov		r6,a
		mov		a,r5
		jc		X1107
		rrc		a
		mov		r5,a
		jnz		X10ff
		inc		r5
		sjmp	adpcm_2_output

X10ff:	add		a,r2
		jnc		X1104
		; 4.04 uses: mov a,0ffh (which is incorrect)
		mov		a,0ffh
X1104:	mov		r2,a
		sjmp	adpcm_2_output

X1107:	clr		c
		rrc		a
		add		a,r5
		add		a,r2
		jnc		X110f
		mov		a,#0ffh
X110f:	mov		r2,a
		cjne	r5,#20h,X1115
		sjmp	adpcm_2_output

X1115:	mov		a,r5
		add		a,r5
		mov		r5,a
		sjmp	adpcm_2_output

adpcm_2_decode_negative:
		rlc		a
		mov		r6,a
		mov		a,r5
		jc		X112f
		rrc		a
		mov		r5,a
		jnz		X1126
		inc		r5
		sjmp	adpcm_2_output

X1126:	xch		a,r2
		clr		c
		subb	a,r2
		jnc		X112c
		clr		a
X112c:	mov		r2,a
		sjmp	adpcm_2_output

X112f:	clr		c
		rrc		a
		add		a,r5
		xch		a,r2
		clr		c
		subb	a,r2
		jnc		X1138
		clr		a
X1138:	mov		r2,a
		cjne	r5,#20h,X113e
		sjmp	adpcm_2_output

X113e:	mov		a,r5
		add		a,r5
		mov		r5,a
adpcm_2_output:
		mov		a,r2
		mov		r0,#19h
		movx	@r0,a
		ret	

;------------------------------- ADPCM 4-bit Decode Routine ------------------------
; Processes 4-bit ADPCM compressed audio samples
; Register Usage:
;   r2 = Output sample | r3 = Remaining samples | r5 = Step size | r6 = Input byte
;-----------------------------------------------------------------------------------
adpcm_4_decode:
		mov		a,r5
		clr		c
		rrc		a
		mov		27h,a
		mov		a,r6
		mov		dma_status_reg,a
		swap	a
		mov		r6,a
		anl		a,#7
		mov		28h,a
		mov		b,r5
		mul		ab
		add		a,27h
		mov		vector_lo,a
		mov		a,dma_status_reg
		rlc		a
		jc		X116a
		mov		a,vector_lo
		add		a,r2
		jnc		X1171
		mov		a,#0ffh
		ljmp	X1171

X116a:	mov		a,r2
		clr		c
		subb	a,vector_lo
		jnc		X1171
		clr		a
X1171:	mov		r2,a
		mov		a,28h
		jz		X1185
		clr		c
		subb	a,#5
		jc		adpcm_4_output
		mov		a,r5
		rl		a
		cjne	a,#10h,X118b
		mov		a,#8
		ljmp	X118b

X1185:	mov		a,27h
		jnz		X118b
		mov		a,#1

X118b:	mov		r5,a
adpcm_4_output:
		mov		a,r2
		mov		r0,#19h
		movx	@r0,a
		ret	

;------------------------------- ADPCM 2.6-bit Decode Routine ----------------------
; Processes 2.6-bit ADPCM compressed audio samples
; Register Usage:
;   r2 = Output sample | r3 = Remaining samples | r5 = Step size | r6 = Input byte
;-----------------------------------------------------------------------------------
adpcm_2_6_decode:
		mov		a,r5
		clr		c
		rrc		a
		mov		27h,a
		mov		a,r6
		mov		dma_status_reg,a
		rl		a
		rl		a
		cjne	r3,#1,X11a3
		anl		a,#1
		ljmp	X11a4

X11a3:	rl		a
X11a4:	mov		r6,a
		anl		a,#3
		mov		28h,a
		mov		b,r5
		mul		ab
		add		a,27h
		mov		vector_lo,a
		mov		a,dma_status_reg
		rlc		a
		jc		X11bf
		mov		a,vector_lo
		add		a,r2
		jnc		X11c6
		mov		a,#0ffh
		ljmp	X11c6

X11bf:	mov		a,r2
		clr		c
		subb	a,vector_lo
		jnc		X11c6
		clr		a
X11c6:	mov		r2,a
		mov		a,28h
		jz		X11d9
		cjne	a,#3,adpcm_2_6_output
		cjne	r5,#10h,X11d4
		ljmp	adpcm_2_6_output

X11d4:	mov		a,r5
		rl		a
		ljmp	X11df

X11d9:	mov		a,27h
		jnz		X11df
		mov		a,#1
X11df:	mov		r5,a
adpcm_2_6_output:
		mov		a,r2
		mov		r0,#19h
		movx	@r0,a
		ret

;=============================== DMA CONTROL UTILITIES =============================
;------------------------------- Update Shared Control Register --------------------
; Modifies external register 4 to set DMA/operation control flags
; Input: adpcm_mode_reg - Configuration flags (lower 4 bits)
;-----------------------------------------------------------------------------------
dma_update_control_register:
		push	acc
		mov		r0,#4
		movx	a,@r0
		anl		a,#0f0h
		orl		a,adpcm_mode_reg
		mov		adpcm_mode_reg,a
		movx	@r0,a
		pop		acc
		ret	

;------------------------------- Arm DMA Channel -----------------------------------
; Prepares DMA channel for data transfer
;-----------------------------------------------------------------------------------
dma_arm_channel:
		mov		r0,#0eh
		mov		a,#7
		movx	@r0,a
		mov		a,#4
		movx	@r0,a
		ret	

;=============================== HOST I/O ROUTINES =================================
;------------------------------- DSP Input Data ------------------------------------
; Waits for host data and reads from port 0
;-----------------------------------------------------------------------------------
dsp_data_read:
		jnb		pin_dsp_data_rdy,dsp_data_read
		mov		r0,#0
		nop	
		nop	
		movx	a,@r0
		ret	

;------------------------------- DSP Output Data -----------------------------------
; Waits for host readiness and writes to port 0
;-----------------------------------------------------------------------------------
dsp_data_write:
		jb		pin_host_data_rdy,dsp_data_write
		mov		r0,#0
		nop	
		nop	
		movx	@r0,a
		ret	

;=============================== DMA TRANSFER MANAGEMENT ===========================
;------------------------------- Start 8-bit DMA Transfer --------------------------
; Initializes 8-bit DMA transfer by configuring control registers
;-----------------------------------------------------------------------------------
dma8_start:
		mov		r0,#0eh
		mov		a,#5
		movx	@r0,a
		mov		a,#4
		movx	@r0,a
		ret	

;------------------------------- Start 16-bit DMA Transfer -------------------------
; Initializes 16-bit DMA transfer by configuring control registers
;-----------------------------------------------------------------------------------
dma16_start:
		mov		r0,#16h
		mov		a,#5
		movx	@r0,a
		mov		a,#4
		movx	@r0,a
		ret	

;------------------------------- Unimplemented CSP Diagnostics ---------------------
; Placeholder for CSP diagnostic code (non-functional in this firmware)
;-----------------------------------------------------------------------------------
X1233:
		mov		a,#0
		mov		r0,#csp_data_port
		movx	@r0,a
		mov		r0,#csp_status_port
		movx	@r0,a
		mov		rem_xfer_len_lo,#0bbh
		mov		rem_xfer_len_hi,#3
		mov		a,#8ch
		mov		r0,#csp_control_port
		movx	@r0,a
		mov		a,#8ah
		mov		r0,#csp_control_port
		movx	@r0,a
		mov		dptr,#asp_code
X124e:	mov		a,#0
		movc	a,@a+dptr
		mov		r0,#csp_program_port
		movx	@r0,a
		cjne	a,rem_xfer_len_lo,X1269
		cjne	a,rem_xfer_len_hi,X1267
		mov		a,#0
		mov		r0,#csp_control_port
		movx	@r0,a
		mov		a,#70h
		mov		r0,#csp_control_port
		movx	@r0,a
		ljmp	X126e

X1267:	dec		rem_xfer_len_hi
X1269:	dec		rem_xfer_len_lo
		inc		dptr
		sjmp	X124e

X126e:	ret

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
		.db	4,4

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
		.db	0c4h,0b0h,0aeh,0b0h,0b2h
