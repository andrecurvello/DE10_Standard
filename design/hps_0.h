#ifndef _ALTERA_HPS_0_H_
#define _ALTERA_HPS_0_H_

/*
 * This file was automatically generated by the swinfo2header utility.
 * 
 * Created from SOPC Builder system 'DE10_Standard_Bitcoin_Design' in
 * file './DE10_Standard_Bitcoin_Design.sopcinfo'.
 */

/*
 * This file contains macros for module 'hps_0' and devices
 * connected to the following masters:
 *   h2f_axi_master
 *   h2f_lw_axi_master
 * 
 * Do not include this header file and another header file created for a
 * different module or master group at the same time.
 * Doing so may result in duplicate macro names.
 * Instead, use the system header file which has macros with unique names.
 */

/*
 * Macros for device 'BMC_0', class 'BMC'
 * The macros are prefixed with 'BMC_0_'.
 * The prefix is the slave descriptor.
 */
#define BMC_0_COMPONENT_TYPE BMC
#define BMC_0_COMPONENT_NAME BMC_0
#define BMC_0_BASE 0x0
#define BMC_0_SPAN 64
#define BMC_0_END 0x3f

/*
 * Macros for device 'SEG7_0', class 'SEG7'
 * The macros are prefixed with 'SEG7_0_'.
 * The prefix is the slave descriptor.
 */
#define SEG7_0_COMPONENT_TYPE SEG7
#define SEG7_0_COMPONENT_NAME SEG7_0
#define SEG7_0_BASE 0x0
#define SEG7_0_SPAN 8
#define SEG7_0_END 0x7

/*
 * Macros for device 'Register_256_0', class 'Register_256'
 * The macros are prefixed with 'REGISTER_256_0_'.
 * The prefix is the slave descriptor.
 */
#define REGISTER_256_0_COMPONENT_TYPE Register_256
#define REGISTER_256_0_COMPONENT_NAME Register_256_0
#define REGISTER_256_0_BASE 0x200
#define REGISTER_256_0_SPAN 32
#define REGISTER_256_0_END 0x21f

/*
 * Macros for device 'sysid_qsys', class 'altera_avalon_sysid_qsys'
 * The macros are prefixed with 'SYSID_QSYS_'.
 * The prefix is the slave descriptor.
 */
#define SYSID_QSYS_COMPONENT_TYPE altera_avalon_sysid_qsys
#define SYSID_QSYS_COMPONENT_NAME sysid_qsys
#define SYSID_QSYS_BASE 0x10000
#define SYSID_QSYS_SPAN 8
#define SYSID_QSYS_END 0x10007
#define SYSID_QSYS_ID 2899645186
#define SYSID_QSYS_TIMESTAMP 1505996721

/*
 * Macros for device 'button_pio', class 'altera_avalon_pio'
 * The macros are prefixed with 'BUTTON_PIO_'.
 * The prefix is the slave descriptor.
 */
#define BUTTON_PIO_COMPONENT_TYPE altera_avalon_pio
#define BUTTON_PIO_COMPONENT_NAME button_pio
#define BUTTON_PIO_BASE 0x100c0
#define BUTTON_PIO_SPAN 16
#define BUTTON_PIO_END 0x100cf
#define BUTTON_PIO_IRQ 1
#define BUTTON_PIO_BIT_CLEARING_EDGE_REGISTER 1
#define BUTTON_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BUTTON_PIO_CAPTURE 1
#define BUTTON_PIO_DATA_WIDTH 4
#define BUTTON_PIO_DO_TEST_BENCH_WIRING 0
#define BUTTON_PIO_DRIVEN_SIM_VALUE 0
#define BUTTON_PIO_EDGE_TYPE FALLING
#define BUTTON_PIO_FREQ 50000000
#define BUTTON_PIO_HAS_IN 1
#define BUTTON_PIO_HAS_OUT 0
#define BUTTON_PIO_HAS_TRI 0
#define BUTTON_PIO_IRQ_TYPE EDGE
#define BUTTON_PIO_RESET_VALUE 0

/*
 * Macros for device 'ILC', class 'interrupt_latency_counter'
 * The macros are prefixed with 'ILC_'.
 * The prefix is the slave descriptor.
 */
#define ILC_COMPONENT_TYPE interrupt_latency_counter
#define ILC_COMPONENT_NAME ILC
#define ILC_BASE 0x30000
#define ILC_SPAN 256
#define ILC_END 0x300ff


#endif /* _ALTERA_HPS_0_H_ */