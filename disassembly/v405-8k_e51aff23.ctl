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
;r 23 status_register				; 23h			x
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
l 03c5 start								; x
l 0402 cold_boot							; x
l 043e warm_boot							; x
l 0003 int0_vector
l 0016 int0_handler
b 0006-000A
l 000B timer0_vector
l 0077 timer0_handler
l 008f midi_timestamp_int					; x
b 000E-0012
l 0013 int1_vector
l 0052 int1_handler

l 009f vector_dma8_playback
l 0116 vector_dma8_playback_end
l 0117 vector_dma16_playback
l 0185 vector_dma16_playback_end

l 0029 int0_table
b 0029-0037
l 0047 int0_op_none_handler

l 003b int0_dma_dac_adpcm2					; int0_op2_vector
l 0186 vector_dma_dac_adpcm2				; int0_op2_handler
l 018e vector_adpcm2_byte_available
l 020c vector_adpcm2_get_data_lo
l 020a vector_adpcm2_get_data_hi
l 0221 vector_dma_dac_adpcm2_end
l 01b9 vector_dma_dac_adpcm2_shiftin

l 003e int0_dma_dac_adpcm4					; int0_op4_vector
l 022c vector_dma_dac_adpcm4				; int0_op4_handler
l 0234 vector_adpcm4_byte_available
l 02b2 vector_adpcm4_get_data_lo
l 02b0 vector_adpcm4_get_data_hi
l 02c7 vector_dma_dac_adpcm4_end
l 025f vector_dma_dac_adpcm4_shiftin

l 0041 int0_dma_dac_adpcm2_6				; int0_op3_vector
l 02d2 vector_dma_dac_adpcm2_6				; int0_op3_handler
l 035b vector_adpcm2_6_byte_available
l 038c vector_adpcm2_6_get_data_lo
l 038a vector_adpcm2_6_get_data_hi
l 036b vector_dma_dac_adpcm2_6_end
l 0303 vector_dma_dac_adpcm2_6_shiftin

l 0038 int0_dac_silence						; int0_op1_vector
l 0376 vector_dac_silence					; int0_op1_handler
l 037e vector_dac_silence_byte_available
l 039d vector_dac_silence_get_data_lo
l 039b vector_dac_silence_get_data_hi
l 039f vector_dac_silence_end

l 0044 int0_op5_vector						; vector_cmd_ram_playback?
l 03aa int0_op5_handler


l 088d convert_samplerate
l 0892 samplerate_table
b 0892-097d

l 0461 check_cmd							; x
l 0464 wait_for_cmd							; x
l 048e dispatch_cmd
l 0499 table_major_cmds						; x
b 0499-04a8

# 04a9 10h: invalid command group 5, 6, A
l 04a9 vector_cmdg_none
# 04ab 12h: command group 0: Status
l 04ab vector_cmdg_status
# 04ae 15h: command group 1: Audio playback - First
l 04ae vector_cmdg_dac1
# 04b1 18h: command group 7: Audio playback - Second
l 04b1 vector_cmdg_dac2
# 04b4 1bh: command group 9: High speed
l 04b4 vector_cmdg_hs
# 04b7 1eh: command group 2: Recording?
l 04b7 vector_cmdg_rec
# 04ba 21h: command group 3: MIDI commands
l 04ba vector_cmdg_midi
# 04bd 24h: command group F: Auxiliary commands
l 04bd vector_cmdg_aux
# 04c0 27h: command group 4: Setup
l 04c0 vector_cmdg_setup
# 04c3 2ah: command group 8: Generate silence
l 04c3 vector_cmdg_silence
# 04c6 2dh: command group E: DSP identification
l 04c6 vector_cmdg_ident
# 04c9 30h: command group D: Miscellaneous commands
l 04c9 vector_cmdg_misc
# 04cc 33h: command group C: Program 8-bit DMA mode digitized sound I/O
l 04cc vector_cmd_dma8
# 04cf 36h: command group B: Program 16-bit DMA mode digitized sound I/O
l 04cf vector_cmd_dma16

l 04d2 cmd_dma8
l 0591 cmd_dma16

; -------------------------
l 0650 cmdg_status
l 0659 table_status_cmds
b 0659-0668

# 0669 10h: command 02
l 0669 cmd_02
# 068d 34h: command 05
l 068d cmd_05
# 069c 43h: command 03
l 069c cmd_03
# 06a5 4ch: command 04
l 06a5 cmd_04
# 06ae 55h: command 06
l 06ae cmd_06
# 06b3 5ah: command 07
l 06b3 cmd_07
# 06c0 67h: command 0A
l 06c0 cmd_0A
# 06c5 6ch: command 08
l 06c5 cmd_08
# 06ce 75h: command 00, 0D
l 06ce cmd_0_none
# 06d1 78h: command 0E
l 06d1 cmd_0E
# 06df 86h: command 0F
l 06df cmd_0F
# 06ea 91h: command 09
l 06ea cmd_09
# 06f6 9dh: command 0B
l 06f6 cmd_0B
# 0721 0c8h: command 0C
l 0721 cmd_0C
# 0751 0f8h: command 01
l 0751 cmd_01

; -------------------------

l 07d5 cmdg_setup
l 07de table_setup_cmds
b 07de-07ed

# 07ee 10h: command 44
l 07ee cmd_44
# 07f3 15h: command 45
l 07f3 cmd_45
# 07f8 1ah: command 46
l 07f8 cmd_46
# 07fd 1fh: command 47
l 07fd cmd_47
# 0802 24h: invalid command 49, 4A, 4B
l 0802 cmd_4_none
# 0805 27h: command 4E
l 0805 cmd_4E
# 080a 2ch: command 4F
l 080a cmd_4F
# 082f 51h: command 4C
l 082f cmd_4C
# 083e 60h: command 4D
l 083e cmd_4D
# 084d 6fh: command 40: DSP time constant
l 084d cmd_40
# 0860 82h: command 41, 42
l 0860 cmd_41
;# 0956 9fh: command 43
;l 0956 cmd_43
# 087d 0c0h: command 48: DSP block transfer size.
l 087d cmd_48

; -------------------------

l 0a01 cmdg_aux
l 0a0a table_aux_cmds
b 0a0a-0a19

# 0a1a 10h: command F9: Internal RAM peek function
l 0a1a cmd_F9
# 0a25 1bh: command FA: Internal RAM poke function
l 0a25 cmd_FA
# 0a33 29h: command FD
l 0a33 cmd_FD
# 0a3b 31h: command FB
l 0a3b cmd_FB
# 0a43 39h: command FC
l 0a43 cmd_FC
# 0a4b 41h: invalid command F1, F5, F6, F7, FE, FG
l 0a4b cmd_f_none
# 0a4e 44h: command F2
l 0a4e cmd_F2
# 0a5d 53h: command F3
l 0a5d cmd_F3
# 0a6b 61h: command F4
l 0a6b cmd_F4
# 0a78 6eh: command F8
l 0a78 cmd_F8
# 0a8b 7eh: command F0
l 0a8b cmd_F0

# 0aa3 Command: Group F Exit
l 0aa3 group_F_exit

; -------------------------

l 0aa8 int0_op5_data
b 0aa8-0ab0

l 0ac0 cmd_midi_write_poll
l 0acd cmd_midi_read_write_poll
l 0ae5 skip_midi_timestamp_setup
l 0b13 midi_check_for_input_data
l 0af2 midi_main_loop
l 0b0f midi_write_poll
l 0b20 midi_has_input_data
l 0b33 midi_read_no_timestamp
l 0b4a midi_flush_buffer_to_host
l 0b54 midi_nowrap_readbuffer
l 0b68 midi_skip_interrupt
l 0b6a midi_store_read_data
l 0b70 midi_store_read_data_to_buffer
l 0b78 midi_ready_to_receive_more

l 0ab1 cmdg_midi

l 0bed cmdg_rec
l 0bf8 dma_rec_autoinit
l 0c0e dma_rec_normal
l 0c86 dma_rec_direct

l 0c9f cmdg_hs
l 0cc0 hs_dma_record_exit
l 0cc5 hs_dma_playback
l 0cd5 hs_dma_playback_exit
l 0cd7 hs_dma_continuous

l 0d15 cmdg_dma_dac1
l 0d20 dma_dac1_autoinit
l 0d36 dma_dac1_normal
l 0ddb dma_dac1_direct
l 0d9d dma_dac1_adpcm_use_2bit
l 0dc1 dma_dac1_reference

l 0dee cmdg_dma_dac2
l 0df9 dma_dac2_adpcm_autoinit
l 0e04 dma_dac2_adpcm
l 0e36 dma_dac2_adpcm_use_4bit
l 0e39 dma_dac2_adpcm_use_2_6bit
l 0e5d dma_dac2_no_reference
l 0e73 dac_no_ref_adpcm4

# 0e7a 2ah: Command group 8: Generate silence
l 0e7a cmdg_silence

; -------------------------

# 0e97 Command group D: Mviscellaneous commands
l 0e97 cmdg_misc
l 0ea0 table_misc_cmds
b 0ea0-0eaf

# 0eb0 10h: invalid command D2, D7, DB
l 0eb0 cmd_d_none
# 0eb3 13h: command DE (undocumented)
l 0eb3 cmd_undoc_de
# 0ebc 1ch: command DF (undocumented)
l 0ebc cmd_undoc_df
# 0ec5 25h: Command D8: Speaker status
l 0ec5 cmd_spk_stat
# 0edc 3ch: Command D1: Enable speaker
l 0edc cmd_speaker_on
# 0ee1 41h: Command D3: Disable speaker
l 0ee1 cmd_speaker_off
# 0ee6 46h: Command DA: Exit 8-bit DMA mode
l 0ee6 cmd_exit_autoinit8
# 0eeb 4bh: Command D9: Exit 16-bit DMA mode
l 0eeb cmd_exit_autoinit16
# 0ef0 0f2h: command DD?
l 0ef0 cmd_DD
# 0ef5 0fdh: command DC
l 0ef5 cmd_DC
# 0efa 50h: Command D0: Pause 8-bit DMA mode
l 0efa cmd_dma8_pause
# 0f23 7fh: Command D5: Pause 16-bit DMA mode
l 0f23 cmd_dma16_pause
# 0f3e 94h: Command D4: Continue 8-bit DMA mode
l 0f3e cmd_dma8_resume
# 0f84 0e0h: Command D6: Continue 16-bit DMA mode
l 0f84 cmd_dma16_resume

# 0fbf 10h: Command: Group D Exit
l 0fbf cmdg_d_exit

; -------------------------

l 0fc6 cmdg_ident
l 0fcf table_ident_cmds
b 0fcf-0fde

# 0fdf 10h: command E5, E6, E7, E9, EA, EB, EC, ED, EE, EF
l 0fdf cmd_e_none
# 0fe2 13h: Command E0: Invert Bits
l 0fe2 cmd_invert_bits
# 0fec 1dh: Command E8: Read test register
l 0fec cmd_read_test_reg
# 0ff4 25h: Command E4: Write test register
l 0ff4 cmd_write_test_reg
# 0ffc 2dh: Command E2: Firmware validation check. Uses challenge/response algorithm.
l 0ffc cmd_dsp_dma_id
# 1025 56h: Command E1: Get DSP version
l 1025 cmd_dsp_version
# 1040 71h: Command E3: Get Copyright Notice
l 1040 cmd_dsp_copyright

# 1051 10h: Command: Group E Exit
l 1051 cmdg_e_exit

; -------------------------
# 1056 ADPCM 2-bit decode routine
l 1056 adpcm_2_decode
l 1081 adpcm_2_decode_negative
l 10a8 adpcm_2_output

# 10ad ADPCM 4-bit decode routine
l 10ad adpcm_4_decode
l 10f3 adpcm_4_output

# 10f8 ADPCM 2.6-bit decode routine
l 10f8 adpcm_2_6_decode
l 1147 adpcm_2_6_output

l 1164 dsp_input_data
l 116d dsp_output_data

# 119a Unimplemented CSP Diagnostics Routine

# 11d6 CSP Chip Data?
l 11d6 asp_code
b 11d6-1591

# 1592 Copyright notice
l 1592 dsp_copyright
b 1592-15be

# 15bf DSP version number
l 15bf dsp_version
b 15bf-15c0

# 15c1 Unused data?
l 15c1 unused
b 15c1-1fff