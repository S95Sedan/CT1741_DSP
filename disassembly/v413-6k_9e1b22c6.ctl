c 0000-1fff

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
;r length_low						; 1bh
;r length_high						; 1ch
r 0e dma_blk_len_lo					; rb1r6			x
r 0f dma_blk_len_hi					; rb1r7			x
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

m 00 command_byte_0
m 01 command_byte_1
m 02 command_byte_2
m 03 command_byte_3
m 1c pin_mute_en					; 23h.4			x
;m 22 dma_autoinit_on				; 24h.2			?
m 25 midi_timestamp					; 24h.5			?

; Most not checked/compared to other dsp code.
k 90 pin_dav_pc						; p1.0			?
k 91 pin_dav_dsp					; p1.1			x
k 92 pin_dsp_busy					; p1.2			?
;k 93 pin_dac_3						; p1.3
;k 94 pin_dac_4						; p1.4
k 95 pin_drequest					; p1.5			?
;k 96 pin_dac_6						; p1.6
;k 97 pin_dac_7						; p1.7
;k a0 pin_mute_en
;k a5 pin_adc_comp
;k a6 pin_dav_pc
;k a7 pin_dav_dsp
;k b2 pin_irequest
;k b3 pin_dsp_busy
;k b4 pin_dma_enablel
;k b5 pin_drequest
;k a4 rd							; ?
;k a5 wr							; ?
;k a7 ea							; ?


l 0000 reset_vector
l 0485 reset_handler
l 04ce cold_boot					; x
l 050f warm_boot					; x
l 0003 int0_vector
l 0016 int0_handler
b 0006-000A
l 000B timer0_vector
l 0095 timer0_handler
l 00ba midi_timestamp_int			; x
b 000E-0012
l 0013 int1_vector
l 0066 int1_handler

l 0033 int0_table
b 0033-0041
l 0051 int0_op_none_handler

; ----- Might be in a different order?
l 0045 vector_dma_dac_adpcm2		; int0_op2_vector
l 01B7 dma_dac_adpcm2				; int0_op2_handler
l 0270 vector_dma_dac_adpcm2_end
l 01ed vector_dma_dac_adpcm2_shiftin

l 004B vector_dma_dac_adpcm4		; int0_op4_vector
l 0285 dma_dac_adpcm4				; int0_op4_handler
l 033e vector_dma_dac_adpcm4_end
l 02bb vector_dma_dac_adpcm4_shiftin

l 0048 vector_dma_dac_adpcm2_6		; int0_op3_vector
l 0353 dma_dac_adpcm2_6				; int0_op3_handler
l 040a vector_dma_dac_adpcm2_6_end
l 0387 vector_dma_dac_adpcm2_6_shiftin
; -----

l 0042 dac_silence_vector			; int0_op1_vector
l 041F dac_silence					; int0_op1_handler
l 044b dac_silence_end	

l 004E int0_op5_vector				; vector_cmd_ram_playback?
l 0460 int0_op5_handler
l 0BC3 int0_op5_data
b 0BC3-0BCB

l 0987 convert_samplerate
l 098c samplerate_table
b 098c-0a77

l 053a check_cmd					; x
l 053d wait_for_cmd					; x
l 057b dispatch_cmd
l 0590 table_major_cmds				; x
b 0590-059f

# 05a0 10h: invalid command group 5, 6, A
l 05a0 cmd_NONE
# 05a2 12h: command group 0
l 0729 cmdg_status_e
# 05a5 15h: command group 1
l 0e93 cmdg_dac_e
# 05a8 18h: command group 7
l 0f8a cmdg_dac2_e
# 05ab 1bh: command group 9
l 0e1d cmdg_hs_e
# 05ae 1eh: command group 2
l 0d5f cmdg_adc_e
# 05b1 21h: command group 3
l 0bcc cmdg_midi_e
# 05b4 24h: command group F
l 0b15 cmdg_aux_e
# 05b7 27h: command group 4
l 08ae cmdg_setup_e
# 05ba 2ah: command group 8
l 1032 cmdg_silence_e
# 05bd 2dh: command group E
l 117e cmdg_ident_e
# 05c0 30h: command group D
l 104f cmdg_speaker_e
# 05c3 33h: command group C
l 05C9 cmdg_dma8_e
# 05c6 36h: command group B
l 067f cmdg_dma16_e

; ----- Needs verify -----
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

l 0d6a cmd_adc_autoinit
l 0d8c cmd_adc_dma
l 0e04 cmd_adc_direct

l 0e9e cmd_dac_autoinit
l 0ec0 cmd_dac_dma
l 0f77 cmd_dac_direct

l 0f95 cmd_dac_autoinit_adpcm
l 0fa0 cmd_dac_adpcm

l 0fdc cmd_dac_adpcm_use_4bit
l 100c dac_no_reference
l 102b dac_no_ref_adpcm4

; -----

b 0732-0741
l 082A cmd_01
l 0742 cmd_02
l 0775 cmd_03
l 077E cmd_04
l 0766 cmd_05
l 0787 cmd_06
l 078C cmd_07
l 079E cmd_08
l 07C3 cmd_09
l 0799 cmd_0A
l 07CF cmd_0B
l 07FA cmd_0C
l 07AA cmd_0E
l 07B8 cmd_0F

b 08B7-08C6
l 0926 cmd_40
l 0939 cmd_41
l 0956 cmd_43
l 08C7 cmd_44
l 08CC cmd_45
l 08D1 cmd_46
l 08D6 cmd_47
l 0977 cmd_48
l 0908 cmd_4C
l 0917 cmd_4D
l 08DE cmd_4E
l 08E3 cmd_4F

b 0B1E-0B2D
l 0B9C cmd_F0
l 0BB4 cmd_F1
l 0B62 cmd_F2
l 0B71 cmd_F3
l 0B7F cmd_F4
l 0B8C cmd_F8
l 0B2E cmd_F9
l 0B39 cmd_FA
l 0B4F cmd_FB
l 0B57 cmd_FC
l 0B47 cmd_FD

l 1058 table_d_cmds
b 1058-1067
# 1068 10h: invalid command D2, D7, DB
# 106b 13h: command DE (undocumented)
l 106b cmd_undoc_de
# 1074 1ch: command DF (undocumented)
l 1074 cmd_undoc_df
# 107d 25h: command D8
l 107d cmd_spk_stat
# 1094 3ch: command D1
l 1094 cmd_speaker_on
# 1099 41h: command D3
l 1099 cmd_speaker_off
# 109e 46h: command DA
l 109e cmd_exit_autoinit8
# 10a3 4bh: command D9
l 10a3 cmd_exit_autoinit16
# 10a8 5ah: command D0
l 10a8 cmd_dma8_pause
# 10d7 83h: command D5
l 10d7 cmd_dma16_pause
# 10ec 9eh: command D4
l 10ec cmd_dma8_continue

l 1138 cmd_D6
l 114a cmd_DD
l 1155 cmd_DC

l 116d cmdg_d_exit

l 1187 table_e_cmds
b 1187-1196
# 1197 10h: command E5, E6, E7, E9, EA, EB, EC, ED, EE, EF
# 119a 13h: command E0 (undocumented)
l 119a cmd_invert_bits
# 11a4 1dh: command E8 (undocumented)
l 11a4 cmd_read_test_reg
# 11ac 25h: command E4 (undocumented)
l 11ac cmd_write_test_reg
# 11b4 2dh: command E2 (undocumented)
l 11b4 cmd_dsp_dma_id
# 11e6 56h: command E1
l 11e6 cmd_dsp_version
# 1201 71h: command E3 (undocumented)
l 1201 cmd_dsp_copyright
l 1212 cmdg_e_exit

l 13a1 asp_code
b 13a1-175c

l 132f input_dsp_data				; ?
l 1338 output_dsp_data				; ?

l 175d copyright_notice
b 175d-1789

l 178a dsp_version
b 178a-178b

l 178c unused
b 178c-1fff