# DE10_Standard
Base project for technical review progress follow up.

The folder structure of this start up project is layed down as such :

- documents
- tools
- design
- src

The document folder shall group together all necessary material for good understanding
of the project.

The tool directory shall gather all utility scripts, widgets, external tools that may be used.

The design directory is essentially the place where all FPGA designs will be stored.

Finally, the source directory is the place where all C sources shall be kept.

In order to illustrate the capacities of the brand new kit generously provided by Terasic,
I have chosen to enhance the bitcoin mining project that I have been working on for quite
while.

This sketch illustrate the functional design of the project :
![Minning Rig design](https://github.com/BadissDjafar/DE10_Standard/tree/master/documents/Functional_design_new.jpg "Minning Rig design")

Source code organisation
========================

Source code in here shall be built thanks to a standard make file.

*Uboot :*

Uboot is to be set in a different project as it would be to tedious to try an maintain it
within the DE10_Standard Bitcoin mining rig project. Essentially, on the necessary modifications will
be done here. They shall be manually back ported to the repo Uboot Altera Soc

*Linux :*

Linux is to be set in a different project as it would be to tedious to try an maintain it
within the DE10_Standard Bitcoin mining rig project. Essentially, on the necessary modifications will
be done here. They shall be manually back ported to the repo Linux Altera Soc

*Bare metal code for UI :* 

This is almost a project in itself. I intend to use the following features available on the DE10 kit.

 - 7 segments display -> display the overall performance of the mining rig in MHash/sec (runtime).
 - LCD display  -> display netwaork characteristics and statistics.
 - Buttons  -> LCD display control

*Application code for COM :* 
TBD
   
Coding standard/practises
=========================

TBD