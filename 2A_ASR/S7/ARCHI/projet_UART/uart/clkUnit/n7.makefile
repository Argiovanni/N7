
SRC = clkUnit.vhd             \
      testClkUnit.vhd \
      diviseurClk1Hz.vhd \
      Nexys4.vhd

# for simulation:
TEST = testClkUnit
# duration (to adjust if necessary)
TIME = 2000ns
PLOT = output

# for synthesis:
UNIT = Nexys4
ARCH = synthesis
UCF  = Nexys4_DDR.ucf
