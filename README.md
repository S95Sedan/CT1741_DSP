# Creative Labs - CT1741 - DSP Firmware

This repository contains the firmware dumps (encrypted/decrypted), assembly/disassembly files and some documents for the Sound Blaster 16 and AWE32 cards produced between 1990 and 2000 which make use of a CT1747 chip to process the DSP instructions.<br>
<br>
- Firnware versions uploaded are the original firmware versions 4.04-4.16 and 4.13 with several patches.<br>
  Which can be found: [Here](https://github.com/S95Sedan/CT1747_DSP/tree/main/firmware)<br>
  Every cards original PLCC44 can be replaced with this firmware and burned onto a 80C52 compatible chip.<br>
  <br>
- The assembly files uploaded are for versions 4.05, 4.13 and 4.16 which return an exact match compared to the original. Included aswell a patched version for 4.13 which has several bugfixes.<br>
  All of them can be found [Here](https://github.com/S95Sedan/CT1747_DSP/tree/main/assembly)<br>
  They can be assembled with AS31, where the original one returns an exact match as like how it was on the card<br>
  <br>
- The disassembly mappings uploaded are for versions 4.05, 4.13 and 4.16 with the same crc32.<br>
  Both can be found [Here](https://github.com/S95Sedan/CT1747_DSP/tree/main/disassembly)<br>
  They can be disassembled with D52 to get a rough output of what the assembly files would look like.<br>
<br>
All the files on here are uploaded for archival and educational purpose, the license for them belongs to Creative Labs.<br>
None of this wouldnt have been possible without the people from MAME, Vogons and Siliconp0rn.<br>
<br>
Full documentation of the dumping process of the remaining chips aswell as hanging note fix here: https://www.vogons.org/viewtopic.php?f=46&t=48732
