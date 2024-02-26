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
l 043b warm_boot							; x
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


l 0889 convert_samplerate
l 088e samplerate_table
b 088e-0979

l 0461 check_cmd							; x
l 0464 wait_for_cmd							; x
;l 048f dispatch_cmd
l 048f table_major_cmds						; x
b 048f-049e

# 049f 10h: invalid command group 5, 6, A
l 049f vector_cmdg_none
# 04a1 12h: command group 0: Status
l 04a1 vector_cmdg_status
# 04a4 15h: command group 1: Audio playback - First
l 04a4 vector_cmdg_dac1
# 04a7 18h: command group 7: Audio playback - Second
l 04a7 vector_cmdg_dac2
# 04aa 1bh: command group 9: High speed
l 04aa vector_cmdg_hs
# 04ad 1eh: command group 2: Recording?
l 04ad vector_cmdg_rec
# 04b0 21h: command group 3: MIDI commands
l 04b0 vector_cmdg_midi
# 04b3 24h: command group F: Auxiliary commands
l 04b3 vector_cmdg_aux
# 04b6 27h: command group 4: Setup
l 04b6 vector_cmdg_setup
# 04b9 2ah: command group 8: Generate silence
l 04b9 vector_cmdg_silence
# 04bc 2dh: command group E: DSP identification
l 04bc vector_cmdg_ident
# 04bf 30h: command group D: Miscellaneous commands
l 04bf vector_cmdg_misc
# 04c2 33h: command group C: Program 8-bit DMA mode digitized sound I/O
l 04c2 vector_cmd_dma8
# 04c5 36h: command group B: Program 16-bit DMA mode digitized sound I/O
l 04c5 vector_cmd_dma16

l 04c8 cmd_dma8
l 058f cmd_dma16

; -------------------------
l 064c cmdg_status
l 0655 table_status_cmds
b 0655-0664

# 0665 10h: command 02
l 0665 cmd_02
# 0689 34h: command 05
l 0689 cmd_05
# 0698 43h: command 03
l 0698 cmd_03
# 06a1 4ch: command 04
l 06a1 cmd_04
# 06aa 55h: command 06
l 06aa cmd_06
# 06af 5ah: command 07
l 06af cmd_07
# 06b7 67h: command 0A
l 06b7 cmd_0A
# 06bc 6ch: command 08
l 06bc cmd_08
# 06ca 75h: command 00, 0D
l 06ca cmd_0_none
# 06cd 78h: command 0E
l 06cd cmd_0E
# 06db 86h: command 0F
l 06db cmd_0F
# 06e6 91h: command 09
l 06e6 cmd_09
# 06f2 9dh: command 0B
l 06f2 cmd_0B
# 071d 0c8h: command 0C
l 071d cmd_0C
# 074d 0f8h: command 01
l 074d cmd_01

; -------------------------

l 07d1 cmdg_setup
l 07da table_setup_cmds
b 07da-07e9

# 07ea 10h: command 44
l 07ea cmd_44
# 07ef 15h: command 45
l 07ef cmd_45
# 07f4 1ah: command 46
l 07f4 cmd_46
# 07f9 1fh: command 47
l 07f9 cmd_47
# 07fe 24h: invalid command 49, 4A, 4B
l 07fe cmd_4_none
# 0801 27h: command 4E
l 0801 cmd_4E
# 0806 2ch: command 4F
l 0806 cmd_4F
# 082b 51h: command 4C
l 082b cmd_4C
# 083a 60h: command 4D
l 083a cmd_4D
# 0849 6fh: command 40: DSP time constant
l 0849 cmd_40
# 085c 82h: command 41, 42
l 085c cmd_41
;# 0956 9fh: command 43
;l 0956 cmd_43
# 0879 0c0h: command 48: DSP block transfer size.
l 0879 cmd_48

; -------------------------

l 09fd cmdg_aux
l 0a06 table_aux_cmds
b 0a06-0a15

# 0a16 10h: command F9: Internal RAM peek function
l 0a16 cmd_F9
# 0a21 1bh: command FA: Internal RAM poke function
l 0a21 cmd_FA
# 0a2f 29h: command FD
l 0a2f cmd_FD
# 0a37 31h: command FB
l 0a37 cmd_FB
# 0a3f 39h: command FC
l 0a3f cmd_FC
# 0a47 41h: invalid command F1, F5, F6, F7, FE, FG
l 0a47 cmd_f_none
# 0a4a 44h: command F2
l 0a4a cmd_F2
# 0a59 53h: command F3
l 0a59 cmd_F3
# 0a67 61h: command F4
l 0a67 cmd_F4
# 0a74 6eh: command F8
l 0a74 cmd_F8
# 0a87 7eh: command F0
l 0a87 cmd_F0

# 0a9f Command: Group F Exit
l 0a9f group_F_exit

; -------------------------

l 0aa4 int0_op5_data
b 0aa4-0aac

l 0abc cmd_midi_write_poll
l 0ac9 cmd_midi_read_write_poll
l 0ae1 skip_midi_timestamp_setup
l 0b0f midi_check_for_input_data
l 0aee midi_main_loop
l 0b0b midi_write_poll
l 0b1c midi_has_input_data
l 0b2f midi_read_no_timestamp
l 0b46 midi_flush_buffer_to_host
l 0b50 midi_nowrap_readbuffer
l 0b64 midi_skip_interrupt
l 0b66 midi_store_read_data
l 0b6c midi_store_read_data_to_buffer
l 0b74 midi_ready_to_receive_more

l 0aad cmdg_midi

l 0be6 cmdg_rec
l 0bf1 dma_rec_autoinit
l 0c07 dma_rec_normal
l 0c6a dma_rec_direct

l 0c83 cmdg_hs
l 0ca1 hs_dma_record_exit
l 0ca6 hs_dma_playback
l 0cb3 hs_dma_playback_exit
l 0cb5 hs_dma_continuous

l 0ce1 cmdg_dma_dac1
l 0cec dma_dac1_autoinit
l 0d02 dma_dac1_normal
l 0d92 dma_dac1_direct
l 0d54 dma_dac1_adpcm_use_2bit
l 0d78 dma_dac1_reference

l 0da5 cmdg_dma_dac2
l 0db0 dma_dac2_adpcm_autoinit
l 0dbb dma_dac2_adpcm
l 0ded dma_dac2_adpcm_use_4bit
l 0df0 dma_dac2_adpcm_use_2_6bit
l 0e14 dma_dac2_no_reference
l 0e2a dac_no_ref_adpcm4

# 0e31 2ah: Command group 8: Generate silence
l 0e31 cmdg_silence

; -------------------------

# 0e4e Command group D: Miscellaneous commands
l 0e4e cmdg_misc
l 0e57 table_misc_cmds
b 0e57-0e66

# 0e67 10h: invalid command D2, D7, DB
l 0e67 cmd_d_none
# 0e6a 50h: Command D0: Pause 8-bit DMA mode
l 0e6a cmd_dma8_pause
# 0e90 7fh: Command D5: Pause 16-bit DMA mode
l 0e90 cmd_dma16_pause
# 0ea2 94h: Command D4: Continue 8-bit DMA mode
l 0ea2 cmd_dma8_resume
# 0ec1 0e0h: Command D6: Continue 16-bit DMA mode
l 0ec1 cmd_dma16_resume
# 0ed1 13h: command DE (undocumented)
l 0ed1 cmd_undoc_de
# 0eda 1ch: command DF (undocumented)
l 0eda cmd_undoc_df
# 0ee3 25h: Command D8: Speaker status
l 0ee3 cmd_spk_stat
# 0efa 46h: Command DA: Exit 8-bit DMA mode
l 0efa cmd_exit_autoinit8
# 0eff 4bh: Command D9: Exit 16-bit DMA mode
l 0eff cmd_exit_autoinit16
# 0f04 0f2h: command DD?
l 0f04 cmd_DD
# 0f09 0fdh: command DC
l 0f09 cmd_DC
# 0f0e 3ch: Command D1: Enable speaker
l 0f0e cmd_speaker_on
# 0f13 41h: Command D3: Disable speaker
l 0f13 cmd_speaker_off

# 0f15 10h: Command: Group D Exit
l 0f15 cmdg_d_exit

; -------------------------

l 0f1a cmdg_ident
l 0f23 table_ident_cmds
b 0f23-0f32

# 0f33 10h: command E5, E6, E7, E9, EA, EB, EC, ED, EE, EF
l 0f33 cmd_e_none
# 0f36 13h: Command E0: Invert Bits
l 0f36 cmd_invert_bits
# 0f40 1dh: Command E8: Read test register
l 0f40 cmd_read_test_reg
# 0f48 25h: Command E4: Write test register
l 0f48 cmd_write_test_reg
# 0f50 2dh: Command E2: Firmware validation check. Uses challenge/response algorithm.
l 0f50 cmd_dsp_dma_id
# 0f79 56h: Command E1: Get DSP version
l 0f79 cmd_dsp_version
# 0f94 71h: Command E3: Get Copyright Notice
l 0f94 cmd_dsp_copyright

# 0fa5 10h: Command: Group E Exit
l 0fa5 cmdg_e_exit

; -------------------------
# 0faa ADPCM 2-bit decode routine
l 0faa adpcm_2_decode
l 0fd5 adpcm_2_decode_negative
l 0ffc adpcm_2_output

# 1001 ADPCM 4-bit decode routine
l 1001 adpcm_4_decode
l 1047 adpcm_4_output

# 104c ADPCM 2.6-bit decode routine
l 104c adpcm_2_6_decode
l 109b adpcm_2_6_output

l 10b8 dsp_input_data
l 10c1 dsp_output_data

# 10dc Unimplemented CSP Diagnostics Routine

# 1118 CSP Chip Data?
l 1118 asp_code
b 1118-14d3

# 14d4 Copyright notice
l 14d4 dsp_copyright
b 14d4-1500

# 1501 DSP version number
l 1501 dsp_version
b 1501-1502

# 1503 Unused data?
l 1503 unused
b 1503-1fff