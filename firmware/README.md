Original Creative 4.04 Firmware:<br>
```v404-8k_49fc3869.bin```

Original Creative 4.05 Firmware:<br>
```v405-8k_e51aff23.bin```

Original Creative 4.11 Firmware:<br>
```v411-8k_4d75e821.bin```

Original Creative 4.12 Firmware:<br>
```v412-8k_e5d3a248.bin```

Original Creative 4.13 Firmwares:<br>
```v413-6k_9e1b22c6.bin```<br>
```v413-8k_e22e9001.bin```

Original Creative 4.16 Firmwares:<br>
```v416-6k_986e5cb9.bin```<br>
```v416-8k_b15514ef.bin```

---

Patched Creative 4.13 Firmwares:<br>
```v413-8k_4ca3dca8_patch3.bin```
- Fixed hanging note bug

```v413-8k_16a46526_patch4.bin```
- Fixed hanging note bug
- Fixed PSW bug in ExtInt0/ExtInt1 interrupt handlers

```v413-8k_b1a727d9_patch5.bin```
- Fixed hanging note bug
- Fixed PSW bug in ExtInt0/ExtInt1 interrupt handlers
- Fixed ADPCM decoding typo

Custom Creative 4.17 Firmwares:<br>
```v417-8k_35cb9fe9_1.0.bin```
- Fixed hanging note bug
- Fixed PSW bug in ExtInt0/ExtInt1 interrupt handlers
- Fixed ADPCM decoding typo
- Removed Code Jumps (vector_dma_dac_adpcm*, dac_silence, vector_op5)(Needed for duke2 compatibility)
- Fixed 'setb it1' in 'start' routine
- Removed X-Bus registers (where it wouldnt break things)
- Removed unused data at the end
- Updated to a custom firmware - Version 4.17
