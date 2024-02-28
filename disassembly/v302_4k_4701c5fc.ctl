; 2eh		warmboot_magic1
; 2fh 		warmboot_magic2
; 24h.0		cmd_avail
; 24h.1		dma_mode_on
; 24h.2		dma_autoinit_on
; 24h.4		autoinit_exit
; 24h.5 	high_speed
; 23h.7		mode_dma_dac

; 
; p2.6		pin_dav_pc
; p2.7		pin_dav_dsp
; int0		pin_irequest
; t0		pin_dma_enablel
; t1		pin_drequest
; p1		port_dac_out
; 20h.0		command_byte_0
; 20h.1		command_byte_1
; 20h.2		command_byte_2
; 20h.3		command_byte_3
; rb3r0		time_constant
; rb3r5		dma_blk_len_lo
; rb3r6		dma_blk_len_hi
; 21h		len_left_lo
; 22h		len_left_hi
; 23h		status_register

c 0000-1fff

l 0000 RESET
l 034d start

b 0003-000a

l 000b int0_vector

l 0031 hs_int
l 0021 midi_timestamp_int

l 0066 get_adc_sample

l 009c vector_dma_dac_8
l 00f5 vector_dma_dac_8_end

l 00fe vector_dma_dac_adpcm2
l 0172 vector_dma_dac_adpcm2_shiftin
l 0175 vector_dma_dac_adpcm2_end

l 017e vector_dma_dac_adpcm4
l 01f2 vector_dma_dac_adpcm4_shiftin
l 01f5 vector_dma_dac_adpcm4_end

l 01fe vector_dma_dac_adpcm2_6
l 0272 vector_dma_dac_adpcm2_6_shiftin
l 0275 vector_dma_dac_adpcm2_6_end

l 027e vector_dac_silence
l 02a0 vector_dac_silence_end

l 02a9 vector_dma_adc
l 0309 vector_dma_adc_end

l 0312 vector_cmd_ram_playback
l 0328 vector_cmd_ram_playback_end

l 0331 vector_sine

l 039a cold_boot
l 03c1 warm_boot

l 03d6 check_cmd
l 03d9 wait_for_cmd
l 03f5 dispatch_cmd
l 03fa table_major_cmds
b 03fa-040a

# 040b 11h: command group 1
l 040b cmdg_dac
# 040e 14h: command group 7
l 040e cmdg_dac2
# 0411 17h: command group 9
l 0411 cmdg_hs
# 0414 1ah: command group 2
l 0414 cmdg_adc
# 0419 1fh: command group 3
l 0419 cmdg_midi
# 0427 2dh: command group F
l 0427 cmdg_aux
# 042f Command group 4: Setup
l 042f cmdg_setup
# 0437 3dh: command group 5
l 0437 cmdg_ram_playback
# 043f 45h: command group 8
l 043f cmdg_silence
# 0447 4dh: command group E
l 0447 cmdg_ident

# 0459 Command group 0: status
l 0459 cmdg_status
l 045b cmd_halt
l 046d continue_dma_op

# 0472 Command group 4: Setup
l 0472 cmdg_setup_e
l 0482 cmd_set_dma_block_size

l 0491 cmdg_something

# 04ac 55h: command groups 6, A, B, C, and D are unimplemented.
l 04ac cmdg_invalid

# 04b1 Command group F: Auxiliary commands
l 04b1 cmdg_aux_e

# 04c0 Command F2: Forced host PC interrupt
l 04c0 cmd_force_interrupt

# 04c7 Command F8: Test the internal SRAM from 7Fh to 00h.
l 04c7 cmd_sram_test
l 04cb sram_test_loop1
l 04db sram_test_end
l 04d5 sram_test_loop2

# 04e0 Command F4: Perform ROM checksum
l 04e0 cmd_checksum

l 04e7 csum_loop
l 04f6 csum_not_done
l 04f9 csum_done

# 0503 Command F1: Get auxiliary DSP status
l 0503 cmd_aux_status

# 050c Command F0: Generates sine wave
l 050c cmd_sine_gen
l 0511 gen_sine_loop

l 0535 sine_table
b 0535-0574

# 0575 Command group 3: MIDI commands
l 0575 do_midi_cmd

# 0584 Command 38: MIDI write poll.
l 0584 cmd_midi_write_poll
# 0594 Commands 34 to 37: MIDI read/write poll 
l 0594 cmd_midi_read_write_poll
l 05ac skip_midi_timestamp_setup
l 05b9 midi_main_loop
l 05db midi_write_poll
l 05df midi_check_for_input_data
l 05ec midi_has_input_data
l 061d midi_read_no_timestamp
l 05f7 midi_write_r5
l 05ff midi_nowrap_writebuffer
l 0605 midi_write_r6
l 0613 midi_write_r7
l 0624 midi_store_read_data_to_buffer
l 062c midi_ready_to_receive_more
l 0636 midi_space_in_buffer
l 063e midi_flush_buffer_to_host
l 0646 midi_nowrap_readbuffer
l 064e midi_skip_interrupt

# 0651 Command group 2: Recording commands
l 0651 cmdg_adc_e
l 065d cmd_adc_autoinit_direct
l 0668 cmd_adc_dma

# 069c Command 20: Direct ADC. This immediately takes one sample and returns it.
l 069c cmd_adc_direct

# 06ab Command group 9: High speed record and playback
l 06ab cmdg_hs_e

# 06d2 Command group 1: Audio playback
l 06d2 cmdg_dac_e
# 06db Command 18h: DMA playback with auto init DMA.
l 06db cmd_dac_autoinit
# 06e6 Command 14h: DMA playback
l 06e6 cmd_dac_dma

# 071d Command 16h: DMA DAC with 2-bit ADPCM.
l 071d cmd_dac_dma_use_adpcm_2
l 0733 cmd_dac_dma_use_reference

# 0751 Command 10h: Direct DAC.
l 0751 cmd_dac_direct

# 075c Command group 7. ADPCM DAC output commands.
l 075c cmdg_dac2_e
# 0762 Command 78: Auto-init DMA ADPCM
l 0762 cmd_dac_autoinit_adpcm
# 076d Command 74: Standard DMA ADPCM
l 076d cmd_dac_adpcm

l 07a4 cmd_dac_adpcm_use_4bit
l 07be dac_no_reference
l 07cf dac_no_ref_adpcm4

# 07e0 Command 80: Generate silence
l 07e0 cmdg_silence_e

# 0800 Command group 5: SRAM playback
l 0800 cmdg_ram_playback_e
l 0809 cmd_ram_load
# 0836 Command 51: Plays back samples stored in SRAM.
l 0836 cmd_ram_playback
# 0854 Command 50: Stops playback of SRAM samples
l 0854 cmd_stop_ram_playback

# 085b Command group D: Miscellaneous commands
l 085b cmdg_misc
# 086d Command D4: Continue DMA operation
l 086d cmd_dma_continue
# 0876 Command D8: Speaker status
l 0876 cmd_spk_stat
# 0889 Command DA: Exit auto-init DMA operation
l 0889 cmd_exit_autoinit
# 088e Command D1: Enable speaker
l 088e cmd_speaker_en_dis

# 0897 Command D3: Disable speaker
l 089a cmdg_misc_exit

l 089d cmd_speaker_on
l 08ab cmd_speaker_off

# 08b6 Command group E: DSP identification
l 08b6 cmd_ident_e

# 08ce Command E8: Read test register
l 08ce cmd_read_test_reg
# 08d7 Command E4: Write test register
l 08d7 cmd_write_test_reg
# 08e0 Command E2: Firmware validation check. Uses challenge/response algorithm.
l 08e0 cmd_dsp_dma_id
# 0909 Command E1: Get DSP version
l 0909 cmd_dsp_version

# 091c ADPCM 2-bit decode routine
l 091c adpcm_2_decode
l 0947 adpcm_2_decode_negative
l 096e adpcm_2_output

# 0971 ADPCM 4-bit decode routine
l 0971 adpcm_4_decode
l 09b7 adpcm_4_output

# 09ba ADPCM 2.6-bit decode routine
l 09ba adpcm_2_6_decode
l 0a09 adpcm_2_6_output

# 0a0b Copyright notice
l 0a0b dsp_copyright
b 0a0b-0a3d

# 0a3e Unused data. Perhaps this was some sort of ADPCM lookup table?
l 0a3e unused_data
b 0a3e-0a6e

# 0a6f Stored DSP version number
l 0a6f dsp_version
b 0a6f-0a70

# 0a71 Padding
b 0a71-1fff