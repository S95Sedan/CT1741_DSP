Original Creative 4.13 Firmware:<br>
```v413-8k_e22e9001.asm```

---

Patched Creative 4.13 Firmware:<br>
```v413-8k_b1a727d9_patch5.asm:```
- Fixed hanging note bug
- Fixed PSW bug in ExtInt0/ExtInt1 interrupt handlers
- Fixed ADPCM decoding typo

---
# Fixes:<br>
### Hanging note bugfix:<br>
#### (int0_handler + int1_handler)<br>
Not needed ```lines 89-90```<br>
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

### ExtInt0/ExtInt1<br>
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
    reti
```
to 
```
    ljmp	X008c
```
### ADPCM fix<br>
Change ```line 3001```<br>
```
mov	a,0ffh
```
to
```
mov	a,#0ffh
```
