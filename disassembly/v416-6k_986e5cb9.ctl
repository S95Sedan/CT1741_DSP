;r 2a test_reg						; 2ah			x
;r ram_samples_x2, 10h
;r ram_pb_count, 11h
;r ram_pb_count2, 12h
;r ram_pb_unused, 13h
;r ram_loops2, 14h
;r ram_loops, 15h
;r ram_pb_unused2, 16h
;r rb2r7, 17h
;r time_constant, 18h
;r rb3r1, 19h
;r ram_smps_left, 1ah
r 0e dma_blk_len_lo					; rb1r6			x
r 0f dma_blk_len_hi					; rb1r7			x
r 11 length_low						; 11h
r 12 length_high					; 12h
r 20 command_byte
r 21 len_left_lo					; 21h			x
r 22 len_left_hi					; 22h			x
r 23 status_register				; 23h			x
r 25 dsp_dma_id0					; 25h			x
r 26 dsp_dma_id1					; 26h			x
r 29 vector_low						; 29h			x
r 2b vector_high					; 2bh			x
r 31 warmboot_magic1				; 31h			x
r 32 warmboot_magic2				; 32h			x

m 00 command_byte_0					;				x
m 01 command_byte_1					;				x
m 02 command_byte_2					;				x
m 03 command_byte_3					;				x

m 1c pin_mute_en					; 23h.4			x

m 20 cmd_avail						; 24h.0			x
m 21 dma_mode_on					; 24h.1			?
m 22 dma_8bit_mode					; 24h.2			x
m 24 dma_16bit_mode					; 24h.4			x
m 25 midi_timestamp					; 24h.5			?

k 90 pin_dav_pc						; p1.0			x
k 91 pin_dav_dsp					; p1.1			x
k 92 pin_dsp_busy					; p1.2			x
;k 93 pin_dac_3						; p1.3
;k 94 pin_dac_4						; p1.4
k 95 pin_drequest					; p1.5			x
;k 96 pin_dac_6						; p1.6
;k 97 pin_dac_7						; p1.7
;k a5 pin_adc_comp
;k b2 pin_irequest
;k b4 pin_dma_enablel
;k a4 rd							; ?
;k a5 wr							; ?
;k a7 ea							; ?

; -------------------------

c 0000-1fff

l 0000 RESET								; x
l 03D7 start								; x
l 0416 cold_boot							; x
l 045c warm_boot							; x
l 0003 int0_vector
l 0016 int0_handler
b 0006-000A
l 000B timer0_vector
l 0077 timer0_handler
l 008f midi_timestamp_int					; x
b 000E-0012
l 0013 int1_vector
l 0052 int1_handler

l 0029 int0_table
b 0029-0037
l 0047 int0_op_none_handler

l 003B int0_dma_dac_adpcm2					; int0_op2_vector
l 018C vector_dma_dac_adpcm2				; int0_op2_handler
l 022a vector_dma_dac_adpcm2_end
l 01c2 vector_dma_dac_adpcm2_shiftin

l 0041 int0_dma_dac_adpcm4					; int0_op4_vector
l 0235 vector_dma_dac_adpcm4				; int0_op4_handler
l 02d3 vector_dma_dac_adpcm4_end
l 026b vector_dma_dac_adpcm4_shiftin

l 003E int0_dma_dac_adpcm2_6				; int0_op3_vector
l 02DE vector_dma_dac_adpcm2_6				; int0_op3_handler
l 037a vector_dma_dac_adpcm2_6_end
l 0312 vector_dma_dac_adpcm2_6_shiftin
; -----

l 0038 int0_dac_silence						; int0_op1_vector
l 0385 vector_dac_silence					; int0_op1_handler
l 03b1 vector_dac_silence_end

l 0044 int0_op5_vector						; vector_cmd_ram_playback?
l 03BC int0_op5_handler
l 0AEE int0_op5_data
b 0AEE-0AF6

l 08B6 convert_samplerate
l 08BB samplerate_table
b 08BB-09A6

l 0487 check_cmd							; x
l 048a wait_for_cmd							; x
l 04b4 dispatch_cmd
l 04bf table_major_cmds						; x
b 04bf-04ce

# 04cf 10h: invalid command group 5, 6, A
l 04cf vector_cmdg_none
# 04d1 12h: command group 0: Status
l 0658 vector_cmdg_status
# 04d4 15h: command group 1: Audio playback - First
l 0d96 vector_cmdg_dac1
# 04d7 18h: command group 7: Audio playback - Second
l 0e7b vector_cmdg_dac2
# 04da 1bh: command group 9: High speed
l 0d20 vector_cmdg_hs
# 04dd 1eh: command group 2: Recording?
l 0c62 vector_cmdg_rec
# 04e0 21h: command group 3: MIDI commands
l 0af7 vector_cmdg_midi
# 04e3 24h: command group F: Auxiliary commands
l 0a4a vector_cmdg_aux
# 04e6 27h: command group 4: Setup
l 07dd vector_cmdg_setup
# 04e9 2ah: command group 8: Generate silence
l 0f07 vector_cmdg_silence
# 04ec 2dh: command group E: DSP identification
l 105F vector_cmdg_ident
# 04ef 30h: command group D: Miscellaneous commands
l 0f24 vector_cmdg_misc
# 04f2 33h: command group C: Program 8-bit DMA mode digitized sound I/O
l 04f8 vector_cmd_dma8
# 04f5 36h: command group B: Program 16-bit DMA mode digitized sound I/O
l 05ae vector_cmd_dma16

; -------------------------
l 0b06 cmd_midi_write_poll
l 0b13 cmd_midi_read_write_poll
l 0b2b skip_midi_timestamp_setup
l 0b59 midi_check_for_input_data
l 0b38 midi_main_loop
l 0b55 midi_write_poll
l 0b66 midi_has_input_data
l 0b79 midi_read_no_timestamp
l 0b82 midi_flush_buffer_to_host
l 0b8c midi_nowrap_readbuffer
l 0ba0 midi_skip_interrupt
l 0ba2 midi_store_read_data
l 0ba8 midi_store_read_data_to_buffer
l 0bb0 midi_ready_to_receive_more

l 0c6d dma_rec_autoinit
l 0c8f dma_rec_normal
l 0d07 dma_rec_direct

l 0d41 hs_dma_record_exit
l 0d46 hs_dma_playback
l 0d56 hs_dma_playback_exit
l 0d58 hs_dma_continuous

l 0da1 cmd_dac_autoinit
l 0dc3 cmd_dac_dma

l 0e2a dma_dac1_adpcm_use_2bit
l 0e4e dma_dac1_reference
l 0e68 cmd_dac_direct

l 0e86 cmd_dac_autoinit_adpcm
l 0e91 cmd_dac_adpcm

l 0ec3 cmd_dac_adpcm_use_4bit
l 0ec6 dma_dac2_adpcm_use_2_6bit
l 0eea dac_no_reference
l 0f00 dac_no_ref_adpcm4

; -------------------------
l 0661 table_status_cmds
b 0661-0670

# 0671 10h: command 02
l 0671 cmd_02
# 0695 34h: command 05
l 0695 cmd_05
# 06A4 43h: command 03
l 06A4 cmd_03
# 06AD 4ch: command 04
l 06AD cmd_04
# 06B6 55h: command 06
l 06B6 cmd_06
# 06BB 5ah: command 07
l 06BB cmd_07
# 06C8 67h: command 0A
l 06C8 cmd_0A
# 06CD 6ch: command 08
l 06CD cmd_08
# 06D6 75h: command 00, 0D
l 06D6 cmd_0_none
# 06D9 78h: command 0E
l 06D9 cmd_0E
# 06E7 86h: command 0F
l 06E7 cmd_0F
# 06F2 91h: command 09
l 06F2 cmd_09
# 06FE 9dh: command 0B
l 06FE cmd_0B
# 0729 0c8h: command 0C
l 0729 cmd_0C
# 0759 0f8h: command 01
l 0759 cmd_01

; -------------------------
l 07E6 table_setup_cmds
b 07E6-07F5

# 07F6 10h: command 44
l 07F6 cmd_44
# 07FB 15h: command 45
l 07FB cmd_45
# 0800 1ah: command 46
l 0800 cmd_46
# 0805 1fh: command 47
l 0805 cmd_47
# 080a 24h: invalid command 49, 4A, 4B
l 080a cmd_4_none
# 080D 27h: command 4E
l 080D cmd_4E
# 0812 2ch: command 4F
l 0812 cmd_4F
# 0837 51h: command 4C
l 0837 cmd_4C
# 0846 60h: command 4D
l 0846 cmd_4D
# 0855 6fh: command 40: DSP time constant
l 0855 cmd_40
# 0868 82h: command 41, 42
l 0868 cmd_41
# 0885 9fh: command 43
l 0885 cmd_43
# 08A6 0c0h: command 48: DSP block transfer size.
l 08A6 cmd_48

; -------------------------
l 0A53 table_aux_cmds
b 0A53-0A62

# 0A63 10h: command F9
l 0A63 cmd_F9
# 0A6E 1bh: command FA
l 0A6E cmd_FA
# 0A7C 29h: command FD
l 0A7C cmd_FD
# 0A84 31h: command FB
l 0A84 cmd_FB
# 0A8C 39h: command FC
l 0A8C cmd_FC
# 0A94 41h: invalid command F1, F5, F6, F7, FE, FG
l 0A94 cmd_f_none
# 0A97 44h: command F2
l 0A97 cmd_F2
# 0AA6 53h: command F3
l 0AA6 cmd_F3
# 0AB4 61h: command F4
l 0AB4 cmd_F4
# 0AC1 6eh: command F8
l 0AC1 cmd_F8
# 0AD1 7eh: command F0
l 0AD1 cmd_F0

# 0ae9 Command: Group F Exit
l 0ae9 group_F_exit
; -------------------------

# 0f07 2ah: Command group 8: Generate silence

; -------------------------
l 0F2D table_d_cmds
b 0F2D-0F3C

# 0F3D 10h: invalid command DB
# 0F4C 13h: command DE (undocumented)
l 0F4C cmd_undoc_de
# 0F55 1ch: command DF (undocumented)
l 0F55 cmd_undoc_df
# 0F5E 25h: Command D8: Speaker status
l 0F5E cmd_spk_stat
# 0F75 3ch: Command D1: Enable speaker
l 0F75 cmd_speaker_on
# 0F7A 41h: Command D3: Disable speaker
l 0F7A cmd_speaker_off
# 0F7F 46h: Command DA: Exit 8-bit DMA mode
l 0F7F cmd_exit_autoinit8
# 0F84 4bh: Command D9: Exit 16-bit DMA mode
l 0F84 cmd_exit_autoinit16
# 0F89 50h: Command D0: Pause 8-bit DMA mode
l 0F89 cmd_dma8_pause
# 0FB8 7fh: Command D5: Pause 16-bit DMA mode
l 0FB8 cmd_dma16_pause
# 0FCD 94h: Command D4: Continue 8-bit DMA mode
l 0FCD cmd_dma8_resume
# 1019 0e0h: Command D6: Continue 16-bit DMA mode
l 1019 cmd_dma16_resume
# 104E 0f2h: command D2
l 104E cmd_D2
# 1053 0f2h: command D7
l 1053 cmd_D7
# 102B 0f2h: command DD
l 102B cmd_DD
# 1036 0fdh: command DC
l 1036 cmd_DC

# 1058 10h: Command: Group D Exit
l 1058 cmdg_d_exit

; -------------------------
l 1068 table_ident_cmds
b 1068-1077

# 1078 10h: command E5, E6, E7, E9, EA, EB, EC, ED, EE, EF
# 107B 13h: Command E0: Invert Bits
l 107B cmd_invert_bits
# 1085 1dh: Command E8: Read test register
l 1085 cmd_read_test_reg
# 108D 25h: Command E4: Write test register
l 108D cmd_write_test_reg
# 1095 2dh: Command E2: Firmware validation check. Uses challenge/response algorithm.
l 1095 cmd_dsp_dma_id
# 10BE 56h: Command E1: Get DSP version
l 10BE cmd_dsp_version
# 10D9 71h: Command E3: Get Copyright Notice
l 10D9 cmd_dsp_copyright

# 10EA 10h: Command: Group E Exit
l 10EA cmdg_e_exit

; -------------------------
# 10ef ADPCM 2-bit decode routine
l 10ef adpcm_2_decode
l 111a adpcm_2_decode_negative
l 1141 adpcm_2_output

# 1146 ADPCM 4-bit decode routine
l 1146 adpcm_4_decode
l 118c adpcm_4_output

# 1191 ADPCM 2.6-bit decode routine
l 1191 adpcm_2_6_decode
l 11e0 adpcm_2_6_output

l 11fd dsp_input_data
l 1206 dsp_output_data

l 126F asp_code
b 126F-162A

l 162B dsp_copyright
b 162B-1657

l 1658 dsp_version
b 1658-1659

l 165A unused
b 165A-1FFF