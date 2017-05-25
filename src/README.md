Source Code
============

Source code in here shall be built thanks to a standard make file.

__Uboot :__

Uboot is to be set in a different project as it would be to tedious to try an maintain it
within the DE10_Standard Bitcoin mining rig project. Essentially, on the necessary modifications will
be done here. They shall be manually back ported to the repo Uboot Altera Soc

__Linux :__

Linux is to be set in a different project as it would be to tedious to try an maintain it
within the DE10_Standard Bitcoin mining rig project. Essentially, on the necessary modifications will
be done here. They shall be manually back ported to the repo Linux Altera Soc

__Bare metal code for UI :__ 

This is almost a project in itself. I intend to use the following features available on the DE10 kit.

 - 7 segments display -> display the overall performance of the mining rig in MHash/sec (runtime).
 - LCD display  -> display netwaork characteristics and statistics.
 - Buttons  -> LCD display control
   