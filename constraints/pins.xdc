## 클록 50 MHz
set_property PACKAGE_PIN B6 [get_ports clk_50mhz]
create_clock -period 20.000 -name clk_50mhz [get_ports clk_50mhz]

## 리셋: 키패드 SW_1 (누르면 1)
set_property PACKAGE_PIN K4 [get_ports rst_p]

## UART 출력: 보드 USB-UART TX -> PC
set_property PACKAGE_PIN F6 [get_ports uart_txd]

## LED1~8 (LED1 = MSB)
set_property PACKAGE_PIN L4 [get_ports {led[7]}]
set_property PACKAGE_PIN M4 [get_ports {led[6]}]
set_property PACKAGE_PIN M2 [get_ports {led[5]}]
set_property PACKAGE_PIN N7 [get_ports {led[4]}]
set_property PACKAGE_PIN M7 [get_ports {led[3]}]
set_property PACKAGE_PIN M3 [get_ports {led[2]}]
set_property PACKAGE_PIN M1 [get_ports {led[1]}]
set_property PACKAGE_PIN N5 [get_ports {led[0]}]

## SPI 입력: 확장 GPIO PORT A (제조사 S7 핀맵 BDIO00~02)
## MCU PB3 -> BDIO00, MCU PA7 -> BDIO01, MCU PB6 -> BDIO02
set_property PACKAGE_PIN F8 [get_ports spi_sck]
set_property PACKAGE_PIN E8 [get_ports spi_mosi]
set_property PACKAGE_PIN A7 [get_ports spi_cs_n]

## 전압 기준
set_property IOSTANDARD LVCMOS33 [get_ports *]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]