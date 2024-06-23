## Firmware Assembly Files:<br>

Original Creative 3.02 Firmware:<br>
```v302_4k_4701c5fc.asm```<br>
<br>
Original Creative 4.04 Firmware:<br>
```v404-8k_49fc3869.asm```<br>
Original Creative 4.05 Firmware:<br>
```v405-8k_e51aff23.asm```<br>
Original Creative 4.13 Firmware:<br>
```v413-8k_e22e9001.asm```<br>
Original Creative 4.16 Firmware:<br>
```v416-6k_986e5cb9.asm```<br>
###### (Files should be properly formatted when loaded in nodepad++)<br>

Patched Creative 4.13 Firmware:<br>
```v413-8k_b34a9a0e_patch5.asm:```
- Fixed hanging note bug
- Fixed PSW bug in ExtInt0/ExtInt1 interrupt handlers
- Fixed ADPCM decoding typo

```v416-6k_32505fc2_patch1.asm:```
- Fixed hanging note bug (fixed by default in 4.16)
- Fixed PSW bug (vector_dma_dac_adpcm, dac_silence)
- Fixed ADPCM decoding typo (fixed by default in 4.16)
- Fixed Code Jumps (vector_dma_dac_adpcm, dac_silence, vector_op5)
- Fixed 'setb it1' in 'start' routine
- Removed X-Bus registers (where possible)
- Removed unused data at the end
- Updated displayed version to 4.17

---
## Compiling:
All of the files can be compiled using AS31 found [Here](https://www.pjrc.com/tech/8051/tools/as31-doc.html)
