
#include <pinmux_config.h>

/* pin mux configuration data */
unsigned long sys_mgr_init_table[CONFIG_HPS_PINMUX_NUM] = {
	0, /* EMACIO0 - Unused */
	2, /* EMACIO1 - USB */
	2, /* EMACIO2 - USB */
	2, /* EMACIO3 - USB */
	2, /* EMACIO4 - USB */
	2, /* EMACIO5 - USB */
	2, /* EMACIO6 - USB */
	2, /* EMACIO7 - USB */
	2, /* EMACIO8 - USB */
	0, /* EMACIO9 - Unused */
	2, /* EMACIO10 - USB */
	2, /* EMACIO11 - USB */
	2, /* EMACIO12 - USB */
	2, /* EMACIO13 - USB */
	0, /* EMACIO14 - N/A */
	0, /* EMACIO15 - N/A */
	0, /* EMACIO16 - N/A */
	0, /* EMACIO17 - N/A */
	0, /* EMACIO18 - N/A */
	0, /* EMACIO19 - N/A */
	3, /* FLASHIO0 - SDMMC */
	3, /* FLASHIO1 - SDMMC */
	3, /* FLASHIO2 - SDMMC */
	3, /* FLASHIO3 - SDMMC */
	0, /* FLASHIO4 - SDMMC */
	0, /* FLASHIO5 - SDMMC */
	0, /* FLASHIO6 - SDMMC */
	0, /* FLASHIO7 - SDMMC */
	0, /* FLASHIO8 - SDMMC */
	3, /* FLASHIO9 - SDMMC */
	3, /* FLASHIO10 - SDMMC */
	3, /* FLASHIO11 - SDMMC */
	3, /* GENERALIO0 - TRACE */
	3, /* GENERALIO1 - TRACE */
	3, /* GENERALIO2 - TRACE */
	3, /* GENERALIO3 - TRACE  */
	3, /* GENERALIO4 - TRACE  */
	3, /* GENERALIO5 - TRACE  */
	3, /* GENERALIO6 - TRACE  */
	3, /* GENERALIO7 - TRACE  */
	3, /* GENERALIO8 - TRACE  */
	3, /* GENERALIO9 - SPIM0 */
	3, /* GENERALIO10 - SPIM0 */
	3, /* GENERALIO11 - SPIM0 */
	3, /* GENERALIO12 - SPIM0 */
	2, /* GENERALIO13 - CAN0 */
	2, /* GENERALIO14 - CAN0 */
	3, /* GENERALIO15 - I2C0 */
	3, /* GENERALIO16 - I2C0 */
	2, /* GENERALIO17 - UART0 */
	2, /* GENERALIO18 - UART0 */
	0, /* GENERALIO19 - N/A */
	0, /* GENERALIO20 - N/A */
	0, /* GENERALIO21 - N/A */
	0, /* GENERALIO22 - N/A */
	0, /* GENERALIO23 - N/A */
	0, /* GENERALIO24 - N/A */
	0, /* GENERALIO25 - N/A */
	0, /* GENERALIO26 - N/A */
	0, /* GENERALIO27 - N/A */
	0, /* GENERALIO28 - N/A */
	0, /* GENERALIO29 - N/A */
	0, /* GENERALIO30 - N/A */
	0, /* GENERALIO31 - N/A */
	2, /* MIXED1IO0 - EMAC */
	2, /* MIXED1IO1 - EMAC */
	2, /* MIXED1IO2 - EMAC */
	2, /* MIXED1IO3 - EMAC */
	2, /* MIXED1IO4 - EMAC */
	2, /* MIXED1IO5 - EMAC */
	2, /* MIXED1IO6 - EMAC */
	2, /* MIXED1IO7 - EMAC */
	2, /* MIXED1IO8 - EMAC */
	2, /* MIXED1IO9 - EMAC */
	2, /* MIXED1IO10 - EMAC */
	2, /* MIXED1IO11 - EMAC */
	2, /* MIXED1IO12 - EMAC */
	2, /* MIXED1IO13 - EMAC */
	0, /* MIXED1IO14 - Unused */
	3, /* MIXED1IO15 - QSPI */
	3, /* MIXED1IO16 - QSPI */
	3, /* MIXED1IO17 - QSPI */
	3, /* MIXED1IO18 - QSPI */
	3, /* MIXED1IO19 - QSPI */
	3, /* MIXED1IO20 - QSPI */
	0, /* MIXED1IO21 - GPIO */
	0, /* MIXED2IO0 - N/A */
	0, /* MIXED2IO1 - N/A */
	0, /* MIXED2IO2 - N/A */
	0, /* MIXED2IO3 - N/A */
	0, /* MIXED2IO4 - N/A */
	0, /* MIXED2IO5 - N/A */
	0, /* MIXED2IO6 - N/A */
	0, /* MIXED2IO7 - N/A */
	0, /* GPLINMUX48 */
	0, /* GPLINMUX49 */
	0, /* GPLINMUX50 */
	0, /* GPLINMUX51 */
	0, /* GPLINMUX52 */
	0, /* GPLINMUX53 */
	0, /* GPLINMUX54 */
	0, /* GPLINMUX55 */
	0, /* GPLINMUX56 */
	0, /* GPLINMUX57 */
	0, /* GPLINMUX58 */
	0, /* GPLINMUX59 */
	0, /* GPLINMUX60 */
	0, /* GPLINMUX61 */
	0, /* GPLINMUX62 */
	0, /* GPLINMUX63 */
	0, /* GPLINMUX64 */
	0, /* GPLINMUX65 */
	0, /* GPLINMUX66 */
	0, /* GPLINMUX67 */
	0, /* GPLINMUX68 */
	0, /* GPLINMUX69 */
	0, /* GPLINMUX70 */
	1, /* GPLMUX0 */
	1, /* GPLMUX1 */
	1, /* GPLMUX2 */
	1, /* GPLMUX3 */
	1, /* GPLMUX4 */
	1, /* GPLMUX5 */
	1, /* GPLMUX6 */
	1, /* GPLMUX7 */
	1, /* GPLMUX8 */
	1, /* GPLMUX9 */
	1, /* GPLMUX10 */
	1, /* GPLMUX11 */
	1, /* GPLMUX12 */
	1, /* GPLMUX13 */
	1, /* GPLMUX14 */
	1, /* GPLMUX15 */
	1, /* GPLMUX16 */
	1, /* GPLMUX17 */
	1, /* GPLMUX18 */
	1, /* GPLMUX19 */
	1, /* GPLMUX20 */
	1, /* GPLMUX21 */
	1, /* GPLMUX22 */
	1, /* GPLMUX23 */
	1, /* GPLMUX24 */
	1, /* GPLMUX25 */
	1, /* GPLMUX26 */
	1, /* GPLMUX27 */
	1, /* GPLMUX28 */
	1, /* GPLMUX29 */
	1, /* GPLMUX30 */
	1, /* GPLMUX31 */
	1, /* GPLMUX32 */
	1, /* GPLMUX33 */
	1, /* GPLMUX34 */
	1, /* GPLMUX35 */
	1, /* GPLMUX36 */
	1, /* GPLMUX37 */
	1, /* GPLMUX38 */
	1, /* GPLMUX39 */
	1, /* GPLMUX40 */
	1, /* GPLMUX41 */
	1, /* GPLMUX42 */
	1, /* GPLMUX43 */
	1, /* GPLMUX44 */
	1, /* GPLMUX45 */
	1, /* GPLMUX46 */
	1, /* GPLMUX47 */
	1, /* GPLMUX48 */
	1, /* GPLMUX49 */
	1, /* GPLMUX50 */
	1, /* GPLMUX51 */
	1, /* GPLMUX52 */
	1, /* GPLMUX53 */
	1, /* GPLMUX54 */
	1, /* GPLMUX55 */
	1, /* GPLMUX56 */
	1, /* GPLMUX57 */
	1, /* GPLMUX58 */
	1, /* GPLMUX59 */
	1, /* GPLMUX60 */
	1, /* GPLMUX61 */
	1, /* GPLMUX62 */
	1, /* GPLMUX63 */
	1, /* GPLMUX64 */
	1, /* GPLMUX65 */
	1, /* GPLMUX66 */
	1, /* GPLMUX67 */
	1, /* GPLMUX68 */
	1, /* GPLMUX69 */
	1, /* GPLMUX70 */
	0, /* NANDUSEFPGA */
	0, /* UART0USEFPGA */
	0, /* RGMII1USEFPGA */
	0, /* SPIS0USEFPGA */
	0, /* CAN0USEFPGA */
	0, /* I2C0USEFPGA */
	0, /* SDMMCUSEFPGA */
	0, /* QSPIUSEFPGA */
	0, /* SPIS1USEFPGA */
	0, /* RGMII0USEFPGA */
	0, /* UART1USEFPGA */
	0, /* CAN1USEFPGA */
	0, /* USB1USEFPGA */
	0, /* I2C3USEFPGA */
	0, /* I2C2USEFPGA */
	0, /* I2C1USEFPGA */
	0, /* SPIM1USEFPGA */
	0, /* USB0USEFPGA */
	0 /* SPIM0USEFPGA */
};
