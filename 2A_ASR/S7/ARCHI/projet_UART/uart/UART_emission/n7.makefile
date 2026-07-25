
SRC = clkUnit.vhd \
      ctrlUnit.vhd \
      diviseurClk.vhd \
      echoUnit.vhd \
      RxUnit.vhd \
      TxUnit.vhd \
      UART.vhd \
      UART_FPGA_N4.vhd


# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF  = UART_FPGA_N4_DDR.ucf
