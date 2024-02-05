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
l 03D7 reset_handler
l 0416 cold_boot					; x
l 045c warm_boot					; x
l 0003 int0_vector
l 0016 int0_handler
b 0006-000A
l 000B timer0_vector
l 0077 timer0_handler
l 008f midi_timestamp_int			; x
b 000E-0012
l 0013 int1_vector
l 0052 int1_handler

l 0029 int0_table
b 0029-0037
l 0047 int0_op_none_handler

; ----- Might be in a different order?
l 003B vector_dma_dac_adpcm2		; int0_op2_vector
l 018C dma_dac_adpcm2				; int0_op2_handler
l 022a vector_dma_dac_adpcm2_end
l 01c2 vector_dma_dac_adpcm2_shiftin

l 0041 vector_dma_dac_adpcm4		; int0_op4_vector
l 0235 dma_dac_adpcm4				; int0_op4_handler
l 02d3 vector_dma_dac_adpcm4_end
l 026b vector_dma_dac_adpcm4_shiftin

l 003E vector_dma_dac_adpcm2_6		; int0_op3_vector
l 02DE dma_dac_adpcm2_6				; int0_op3_handler
l 037a vector_dma_dac_adpcm2_6_end
l 0312 vector_dma_dac_adpcm2_6_shiftin
; -----

l 0038 dac_silence_vector			; int0_op1_vector
l 0385 dac_silence					; int0_op1_handler
l 03b1 dac_silence_end		

l 0044 int0_op5_vector				; vector_cmd_ram_playback?
l 03BC int0_op5_handler
l 0AEE int0_op5_data
b 0AEE-0AF6

l 08B6 convert_samplerate
l 08BB samplerate_table
b 08BB-09A6

l 0487 check_cmd					; x
l 048a wait_for_cmd					; x
l 04b4 dispatch_cmd
l 04bf table_major_cmds				; x
b 04bf-04ce

# 04cf 10h: invalid command group 5, 6, A
l 04cf cmd_NONE
# 04d1 12h: command group 0
l 0658 cmdg_status_e
# 04d4 15h: command group 1
l 0d96 cmdg_dac_e
# 04d7 18h: command group 7
l 0e7b cmdg_dac2_e
# 04da 1bh: command group 9
l 0d20 cmdg_hs_e
# 04dd 1eh: command group 2
l 0c62 cmdg_adc_e
# 04e0 21h: command group 3
l 0af7 cmdg_midi_e
# 04e3 24h: command group F
l 0a4a cmdg_aux_e
# 04e6 27h: command group 4
l 07dd cmdg_setup_e
# 04e9 2ah: command group 8
l 0f07 cmdg_silence_e
# 04ec 2dh: command group E
l 105F cmdg_ident_e
# 04ef 30h: command group D
l 0f24 cmdg_speaker_e
# 04f2 33h: command group C
l 04f8 cmdg_dma8_e
# 04f5 36h: command group B
l 05ae cmdg_dma16_e

; ----- Needs verify -----
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

l 0c6d cmd_adc_autoinit
l 0c8f cmd_adc_dma
l 0d07 cmd_adc_direct

l 0da1 cmd_dac_autoinit
l 0dc3 cmd_dac_dma
l 0e68 cmd_dac_direct

l 0e86 cmd_dac_autoinit_adpcm
l 0e91 cmd_dac_adpcm

l 0ec3 cmd_dac_adpcm_use_4bit
l 0eea dac_no_reference
l 0f00 dac_no_ref_adpcm4

; -----

b 0661-0670
l 0759 cmd_01
l 0671 cmd_02
l 06A4 cmd_03
l 06AD cmd_04
l 0695 cmd_05
l 06B6 cmd_06
l 06BB cmd_07
l 06CD cmd_08
l 06F2 cmd_09
l 06C8 cmd_0A
l 06FE cmd_0B
l 0729 cmd_0C
l 06D9 cmd_0E
l 06E7 cmd_0F

b 07E6-07F5
l 0855 cmd_40
l 0868 cmd_41
l 0885 cmd_43
l 07F6 cmd_44
l 07FB cmd_45
l 0800 cmd_46
l 0805 cmd_47
l 08A6 cmd_48
l 0837 cmd_4C
l 0846 cmd_4D
l 080D cmd_4E
l 0812 cmd_4F

b 0A53-0A62
l 0AD1 cmd_F0
l 0AE9 cmd_F1
l 0A97 cmd_F2
l 0AA6 cmd_F3
l 0AB4 cmd_F4
l 0AC1 cmd_F8
l 0A63 cmd_F9
l 0A6E cmd_FA
l 0A84 cmd_FB
l 0A8C cmd_FC
l 0A7C cmd_FD

l 0F2D table_d_cmds
b 0F2D-0F3C
# 0F3D 10h: invalid command D2, D7, DB
# 0F4C 13h: command DE (undocumented)
l 0F4C cmd_undoc_de
# 0F55 1ch: command DF (undocumented)
l 0F55 cmd_undoc_df
# 0F5E 25h: command D8
l 0F5E cmd_spk_stat
# 0F75 3ch: command D1
l 0F75 cmd_speaker_on
# 0F7A 41h: command D3
l 0F7A cmd_speaker_off
# 0F7F 46h: command DA
l 0F7F cmd_exit_autoinit8
# 0F84 4bh: command D9
l 0F84 cmd_exit_autoinit16
# 0F89 5ah: command D0
l 0F89 cmd_dma8_pause
# 0FB8 83h: command D5
l 0FB8 cmd_dma16_pause
# 0FCD 9eh: command D4
l 0FCD cmd_dma8_continue

l 1019 cmd_D6
l 102B cmd_DD
l 1036 cmd_DC
l 104E cmd_D2
l 1053 cmd_D7

l 1058 cmdg_d_exit

l 1068 table_e_cmds
b 1068-1077
# 1078 10h: command E5, E6, E7, E9, EA, EB, EC, ED, EE, EF
# 107B 13h: command E0 (undocumented)
l 107B cmd_invert_bits
# 1085 1dh: command E8 (undocumented)
l 1085 cmd_read_test_reg
# 108D 25h: command E4 (undocumented)
l 108D cmd_write_test_reg
# 1095 2dh: command E2 (undocumented)
l 1095 cmd_dsp_dma_id
# 10BE 56h: command E1
l 10BE cmd_dsp_version
# 10D9 71h: command E3 (undocumented)
l 10D9 cmd_dsp_copyright
l 10EA cmdg_e_exit

l 126F asp_code
b 126F-162A

l 11fd input_dsp_data				; ?
l 1206 output_dsp_data				; ?

l 162B copyright_notice
b 162B-1657

l 1658 dsp_version
b 1658-1659

l 165A unused
b 165A-1FFF