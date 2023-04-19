`define BAUD_RATE_BPS   9600
`define CLK_MHZ         50 
`define PARITY          1     //0: disable, 1: enable
`define PARITY_TYPE     1 //0:even; 1: odd
`define STOP_SIZE       1
`define BYTE_SIZE       8
`define BAUD_CNT_MAX  `CLK_MHZ * 10**6/`BAUD_RATE_BPS - 1
`define BAUD_CNT_CENTER  (`BAUD_CNT_MAX)/2
`define BIT_CNT_MAX `BYTE_SIZE + `PARITY + `STOP_SIZE
`define BIT_CNT_MAX_PLUS_ONE `BYTE_SIZE + `PARITY + `STOP_SIZE + 1
`define RX_BIT_CNT_MAX  `BYTE_SIZE + `PARITY
`define SIM             


