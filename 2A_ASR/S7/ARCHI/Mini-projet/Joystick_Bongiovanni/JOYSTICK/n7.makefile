
SRC = ../ER_1OCTET/er_1octet.vhd \
      All7Segments.vhd    \
      dec7seg.vhd         \
      diviseurClk.vhd  \
      MasterJoystick.vhd  \
      Nexys4Joystick.vhd


# for synthesis:
UNIT = Nexys4Joystick
ARCH = synthesis
UCF  = Nexys4Joystick_DDR.ucf

