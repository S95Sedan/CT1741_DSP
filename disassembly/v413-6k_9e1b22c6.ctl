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
l 0485 start								; x
l 04ce cold_boot							; x
l 050f warm_boot							; x
l 0003 int0_vector
l 0016 int0_handler
b 0006-000A
l 000B timer0_vector
l 0095 timer0_handler
l 00ba midi_timestamp_int					; x
b 000E-0012
l 0013 int1_vector
l 0066 int1_handler

l 0033 int0_table
b 0033-0041
l 0051 int0_op_none_handler

l 0045 int0_dma_dac_adpcm2					; int0_op2_vector
l 01B7 vector_dma_dac_adpcm2				; int0_op2_handler
l 0270 vector_dma_dac_adpcm2_end
l 01ed vector_dma_dac_adpcm2_shiftin

l 004B int0_dma_dac_adpcm4					; int0_op4_vector
l 0285 vector_dma_dac_adpcm4				; int0_op4_handler
l 033e vector_dma_dac_adpcm4_end
l 02bb vector_dma_dac_adpcm4_shiftin

l 0048 int0_dma_dac_adpcm2_6				; int0_op3_vector
l 0353 vector_dma_dac_adpcm2_6				; int0_op3_handler
l 040a vector_dma_dac_adpcm2_6_end
l 0387 vector_dma_dac_adpcm2_6_shiftin

l 0042 int0_dac_silence						; int0_op1_vector
l 041F vector_dac_silence					; int0_op1_handler
l 044b vector_dac_silence_end

l 004E int0_op5_vector						; vector_cmd_ram_playback?
l 0460 int0_op5_handler
l 0BC3 int0_op5_data
b 0bc3-0bcb

l 0987 convert_samplerate
l 098c samplerate_table
b 098c-0a77

l 053a check_cmd							; x
l 053d wait_for_cmd							; x
l 057b dispatch_cmd
l 0590 table_major_cmds						; x
b 0590-059f

# 05a0 10h: invalid command group 5, 6, A
l 05a0 vector_cmdg_none
# 05a2 12h: command group 0: Status
l 0729 vector_cmdg_status
# 05a5 15h: command group 1: Audio playback - First
l 0e93 vector_cmdg_dac1
# 05a8 18h: command group 7: Audio playback - Second
l 0f8a vector_cmdg_dac2
# 05ab 1bh: command group 9: High speed
l 0e1d vector_cmdg_hs
# 05ae 1eh: command group 2: Recording?
l 0d5f vector_cmdg_rec
# 05b1 21h: command group 3: MIDI commands
l 0bcc vector_cmdg_midi
# 05b4 24h: command group F: Auxiliary commands
l 0b15 vector_cmdg_aux
# 05b7 27h: command group 4: Setup
l 08ae vector_cmdg_setup
# 05ba 2ah: command group 8: Generate silence
l 1032 vector_cmdg_silence
# 05bd 2dh: command group E: DSP identification
l 117e vector_cmdg_ident
# 05c0 30h: command group D: Miscellaneous commands
l 104f vector_cmdg_misc
# 05c3 33h: command group C: Program 8-bit DMA mode digitized sound I/O
l 05C9 vector_cmd_dma8
# 05c6 36h: command group B: Program 16-bit DMA mode digitized sound I/O
l 067f vector_cmd_dma16

; -------------------------
l 0bdb cmd_midi_write_poll
l 0be8 cmd_midi_read_write_poll
l 0c00 skip_midi_timestamp_setup
l 0c2e midi_check_for_input_data
l 0c0d midi_main_loop
l 0c2a midi_write_poll
l 0c3b midi_has_input_data
l 0c4e midi_read_no_timestamp
l 0c57 midi_flush_buffer_to_host
l 0c61 midi_nowrap_readbuffer
l 0c75 midi_skip_interrupt
l 0c77 midi_store_read_data
l 0c7d midi_store_read_data_to_buffer
l 0c85 midi_ready_to_receive_more

l 0d6a dma_rec_autoinit
l 0d8c dma_rec_normal
l 0e04 dma_rec_direct

l 0e3e hs_dma_record_exit
l 0e43 hs_dma_playback
l 0e53 hs_dma_playback_exit
l 0e55 hs_dma_continuous

l 0e9e cmd_dac_autoinit
l 0ec0 cmd_dac_dma

l 0f27 dma_dac1_adpcm_use_2bit
l 0f54 dma_dac1_reference
l 0f77 cmd_dac_direct

l 0f95 cmd_dac_autoinit_adpcm
l 0fa0 cmd_dac_adpcm

l 0fdc cmd_dac_adpcm_use_4bit
l 0fdf dma_dac2_adpcm_use_2_6bit
l 100c dac_no_reference
l 102b dac_no_ref_adpcm4

; -------------------------
l 0732 table_status_cmds
b 0732-0741

# 0742 10h: command 02
l 0742 cmd_02
# 0766 34h: command 05
l 0766 cmd_05
# 0775 43h: command 03
l 0775 cmd_03
# 077e 4ch: command 04
l 077e cmd_04
# 0787 55h: command 06
l 0787 cmd_06
# 078c 5ah: command 07
l 078c cmd_07
# 0799 67h: command 0A
l 0799 cmd_0A
# 079e 6ch: command 08
l 079e cmd_08
# 07a7 75h: command 00, 0D
l 07a7 cmd_0_none
# 07aa 78h: command 0E
l 07aa cmd_0E
# 07b8 86h: command 0F
l 07b8 cmd_0F
# 07c3 91h: command 09
l 07c3 cmd_09
# 07cf 9dh: command 0B
l 07cf cmd_0B
# 07fa 0c8h: command 0C
l 07fa cmd_0C
# 082a 0f8h: command 01
l 082a cmd_01

; -------------------------
l 08b7 table_setup_cmds
b 08b7-08c6

# 08c7 10h: command 44
l 08c7 cmd_44
# 08cc 15h: command 45
l 08cc cmd_45
# 08d1 1ah: command 46
l 08d1 cmd_46
# 08d6 1fh: command 47
l 08d6 cmd_47
# 08db 24h: invalid command 49, 4A, 4B
l 08db cmd_4_none
# 08de 27h: command 4E
l 08de cmd_4E
# 08e3 2ch: command 4F
l 08e3 cmd_4F
# 0908 51h: command 4C
l 0908 cmd_4C
# 0917 60h: command 4D
l 0917 cmd_4D
# 0926 6fh: command 40: DSP time constant
l 0926 cmd_40
# 0939 82h: command 41, 42
l 0939 cmd_41
# 0956 9fh: command 43
l 0956 cmd_43
# 0977 0c0h: command 48: DSP block transfer size.
l 0977 cmd_48

; -------------------------
l 0b1e table_aux_cmds
b 0b1e-0b2d

# 0b2e 10h: command F9
l 0b2e cmd_F9
# 0b39 1bh: command FA
l 0b39 cmd_FA
# 0b47 29h: command FD
l 0b47 cmd_FD
# 0b4f 31h: command FB
l 0b4f cmd_FB
# 0b57 39h: command FC
l 0b57 cmd_FC
# 0b5f 41h: invalid command F1, F5, F6, F7, FE, FG
l 0b5f cmd_f_none
# 0b62 44h: command F2
l 0b62 cmd_F2
# 0b71 53h: command F3
l 0b71 cmd_F3
# 0b7f 61h: command F4
l 0b7f cmd_F4
# 0b8c 6eh: command F8
l 0b8c cmd_F8
# 0b9c 7eh: command F0
l 0b9c cmd_F0

# 0bb4 Command: Group F Exit
l 0bb4 group_F_exit
; -------------------------

# 1032 2ah: Command group 8: Generate silence

; -------------------------
l 1058 table_d_cmds
b 1058-1067

# 1068 10h: invalid command D2, D7, DB
# 106b 13h: command DE (undocumented)
l 106b cmd_undoc_de
# 1074 1ch: command DF (undocumented)
l 1074 cmd_undoc_df
# 107d 25h: Command D8: Speaker status
l 107d cmd_spk_stat
# 1094 3ch: Command D1: Enable speaker
l 1094 cmd_speaker_on
# 1099 41h: Command D3: Disable speaker
l 1099 cmd_speaker_off
# 109e 46h: Command DA: Exit 8-bit DMA mode
l 109e cmd_exit_autoinit8
# 10a3 4bh: Command D9: Exit 16-bit DMA mode
l 10a3 cmd_exit_autoinit16
# 10a8 50h: Command D0: Pause 8-bit DMA mode
l 10a8 cmd_dma8_pause
# 10d7 7fh: Command D5: Pause 16-bit DMA mode
l 10d7 cmd_dma16_pause
# 10ec 94h: Command D4: Continue 8-bit DMA mode
l 10ec cmd_dma8_resume
# 1138 0e0h: Command D6: Continue 16-bit DMA mode
l 1138 cmd_dma16_resume
# 114a 0f2h: command DD
l 114a cmd_DD
# 1155 0fdh: command DC
l 1155 cmd_DC

# 116d 10h: Command: Group D Exit
l 116d cmdg_d_exit

; -------------------------
l 1187 table_ident_cmds
b 1187-1196

# 1197 10h: command E5, E6, E7, E9, EA, EB, EC, ED, EE, EF
# 119a 13h: Command E0: Invert Bits
l 119a cmd_invert_bits
# 11a4 1dh: Command E8: Read test register
l 11a4 cmd_read_test_reg
# 11ac 25h: Command E4: Write test register
l 11ac cmd_write_test_reg
# 11b4 2dh: Command E2: Firmware validation check. Uses challenge/response algorithm.
l 11b4 cmd_dsp_dma_id
# 11e6 56h: Command E1: Get DSP version
l 11e6 cmd_dsp_version
# 1201 71h: Command E3: Get Copyright Notice
l 1201 cmd_dsp_copyright

# 1212 10h: Command: Group E Exit
l 1212 cmdg_e_exit

; -------------------------
# 1221 ADPCM 2-bit decode routine
l 1221 adpcm_2_decode
l 124c adpcm_2_decode_negative
l 1273 adpcm_2_output

# 1278 ADPCM 4-bit decode routine
l 1278 adpcm_4_decode
l 12be adpcm_4_output

# 12c3 ADPCM 2.6-bit decode routine
l 12c3 adpcm_2_6_decode
l 1312 adpcm_2_6_output

l 132f dsp_input_data
l 1338 dsp_output_data

l 13a1 asp_code
b 13a1-175c

l 175d dsp_copyright
b 175d-1789

l 178a dsp_version
b 178a-178b

l 178c unused
b 178c-1fff