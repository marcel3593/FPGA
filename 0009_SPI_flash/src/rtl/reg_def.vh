//SPI_CNTL
`define SPI_CNTL                   0
`define SPI_CNTL_SPIE__SHIFT       7
`define SPI_CNTL_SPTE__SHIFT       5
`define SPI_CNTL_MSTR__SHIFT       4
`define SPI_CNTL_CPOL__SHIFT       3
`define SPI_CNTL_CPHA__SHIFT       2
`define SPI_CNTL_LSBFE__SHIFT      0

//SPI_STATUS
`define SPI_STATUS 1
`define SPI_STATUS_SPIF__SHIFT     7
`define SPI_STATUS_SPTEF__SHIFT    5

//SPI_DATA
`define SPI_READ_DATA 2
`define SPI_WRITE_DATA 3

`define SPI_CNTL_INIT                   8'b00000000
`define SPI_STATUS_INIT                 8'b00100000
`define SPI_READ_DATA_INIT              8'b00000000
`define SPI_WRITE_DATA_INIT             8'b00000000


//`define SIM