## Firmware Assembly Files:<br>

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
```v413-8k_b1a727d9_patch5.asm:```
- Fixed hanging note bug
- Fixed PSW bug in ExtInt0/ExtInt1 interrupt handlers
- Fixed ADPCM decoding typo
---
## Compiling:
Both files can be compiled using AS31 found [Here](https://www.pjrc.com/tech/8051/tools/as31-doc.html)


---
## Firmware Patch5 Fixes:<br>
### Hanging Note fix:<br>
#### (int0_handler + int1_handler)<br>
Remove ```lines 89-90```<br>
```
    pop	acc
    push	acc
```
Move ```lines 91-93```<br>
```
    push	dpl
    push	dph
    push	rb0r0
```

### PSW Fix:<br>
#### (adpcm2 + adpcm4 + adpcm2_6 + dac_silence)<br>
Change ```lines 482-487```<br>
Change ```lines 612-616```<br>
Change ```lines 740-744```<br>
Change ```lines 781-785```<br>
```
    pop	rb0r0
    pop	dph
    pop	dpl
    pop	acc
    pop psw
    reti
```
to 
```
    ljmp	X008c
```
### ADPCM fix:<br>
#### (X1231)
Change ```line 2967```<br>
```
mov	a,0ffh
```
to
```
mov	a,#0ffh
```
