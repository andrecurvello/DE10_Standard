
#ifndef _PRELOADER_PINMUX_CONFIG_H_
#define _PRELOADER_PINMUX_CONFIG_H_

/*
 * State of enabling for which IP connected out through the muxing.
 * Value 1 mean the IP connection is muxed out
 */
#define CONFIG_HPS_EMAC0		(0)
#define CONFIG_HPS_EMAC1		(1)
#define CONFIG_HPS_USB0			(0)
#define CONFIG_HPS_USB1			(1)
#define CONFIG_HPS_NAND			(0)
#define CONFIG_HPS_SDMMC		(1)
#define CONFIG_HPS_QSPI			(1)
#define CONFIG_HPS_UART0		(1)
#define CONFIG_HPS_UART1		(0)
#define CONFIG_HPS_TRACE		(1)
#define CONFIG_HPS_I2C0			(1)
#define CONFIG_HPS_I2C1			(0)
#define CONFIG_HPS_I2C2			(0)
#define CONFIG_HPS_I2C3			(0)
#define CONFIG_HPS_SPIM0		(1)
#define CONFIG_HPS_SPIM1		(0)
#define CONFIG_HPS_SPIS0		(0)
#define CONFIG_HPS_SPIS1		(0)
#define CONFIG_HPS_CAN0			(1)
#define CONFIG_HPS_CAN1			(0)

/* IP attribute value (which affected by pin muxing configuration) */
#define CONFIG_HPS_SDMMC_BUSWIDTH	(4)

/* 1 if the pins are connected out */
#define CONFIG_HPS_QSPI_CS0		(1)
#define CONFIG_HPS_QSPI_CS1		(0)
#define CONFIG_HPS_QSPI_CS2		(0)
#define CONFIG_HPS_QSPI_CS3		(0)

/* UART */
/* 1 means the pin is mux out or available */
#define CONFIG_HPS_UART0_TX		(1)
#define CONFIG_HPS_UART0_RX		(1)
#define CONFIG_HPS_UART0_CTS		(0)
#define CONFIG_HPS_UART0_RTS		(0)
#define CONFIG_HPS_UART1_TX		(0)
#define CONFIG_HPS_UART1_RX		(0)
#define CONFIG_HPS_UART1_CTS		(0)
#define CONFIG_HPS_UART1_RTS		(0)

/* Pin mux data */
#define CONFIG_HPS_PINMUX_NUM		(207)

#endif /* _PRELOADER_PINMUX_CONFIG_H_ */
