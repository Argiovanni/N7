
SRC = clkUnit.vhd \
      ctrlUnit.vhd \
      diviseurClk.vhd \
      echoUnit.vhd \
      RxUnit.vhd \
      TxUnit.vhd \
      UART.vhd \
      ControlRecep.vhd \
      Counter16.vhd \
      UART_FPGA_N4.vhd \
      testRxUnit.vhd \
      testRxUnit_stopErr.vhd \
      testRxUnit_parErr.vhd \
      testRxUnit_readErr.vhd

TEST = testRxUnit
# duration (to adjust if necessary)
TIME = 2200ns
PLOT = output

# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF  = UART_FPGA_N4_DDR.ucf
