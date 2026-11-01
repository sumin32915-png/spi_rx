`timescale 1ns/1ps
// 과제10 TB: MCU처럼 Mode 0 마스터를 흉내 내 SPI 바이트를 보내고,
// FPGA가 받은 값(rx_data, LED)과 UART 출력 바이트를 확인한다.
module tb;
    reg clk=0, rst=1;
    always #10 clk = ~clk;                 // 50 MHz
    reg sck=0, cs_n=1, mosi=0;
    wire txd;
    wire [7:0] led;
    localparam CPB = 16;                   // TB용 UART 비트 길이(클록 수)
    localparam SCK_HALF = 640;             // 781.25 kHz의 반주기 640 ns
    spi_rx_uart #(.CLKS_PER_BIT(CPB)) dut(clk, rst, sck, cs_n, mosi, txd, led);

    integer checks = 0;
    reg [7:0] uart_byte;

    task spi_send(input [7:0] b, input integer nbits);
        integer k;
        begin
            cs_n = 0; mosi = b[7];         // CS를 내리면서 MSB 준비
            #(SCK_HALF);
            for (k = 7; k > 7 - nbits; k = k - 1) begin
                sck = 1; #(SCK_HALF);      // 상승 에지: 수신 측이 읽음
                sck = 0;                   // 하강 에지: 다음 비트 준비
                if (k > 0) mosi = b[k-1];
                #(SCK_HALF);
            end
            cs_n = 1; #(4*SCK_HALF);
        end
    endtask

    // UART 수신 모델: 시작 비트 가운데부터 CPB 간격으로 8비트를 읽는다.
    task uart_get(output [7:0] b);
        integer k;
        begin
            @(negedge txd);
            repeat (CPB/2) @(posedge clk);
            for (k = 0; k < 8; k = k + 1) begin
                repeat (CPB) @(posedge clk);
                b[k] = txd;
            end
            repeat (CPB) @(posedge clk);
            if (txd !== 1'b1) $fatal(1, "UART stop bit");
        end
    endtask

    task check_byte(input [7:0] b);
        begin
            fork
                spi_send(b, 8);
                uart_get(uart_byte);
            join
            if (uart_byte !== b || led !== b)
                $fatal(1, "SPI RX expected=%02X uart=%02X led=%02X", b, uart_byte, led);
            checks = checks + 1;
            $display("RX %02X -> UART %02X, LED %02X", b, uart_byte, led);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb);
        repeat (4) @(posedge clk); rst = 0;
        repeat (4) @(posedge clk);
        check_byte(8'h55);
        check_byte(8'hA5);
        check_byte(8'h00);
        check_byte(8'hFF);
        // 3비트만 보내고 CS 해제: 비트 카운터가 초기화되어야 한다.
        spi_send(8'hE0, 3);
        if (dut.u_rx.bit_cnt !== 0) $fatal(1, "bit counter not cleared by CS");
        check_byte(8'h3C);
        $display("PASS SPI RX: 55 A5 00 FF, CS reset, UART echo checks=%0d", checks);
        $finish;
    end
    initial begin #2_000_000; $fatal(1, "timeout"); end
endmodule