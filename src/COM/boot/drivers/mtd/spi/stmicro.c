/*
 * (C) Copyright 2000-2002
 * Wolfgang Denk, DENX Software Engineering, wd@denx.de.
 *
 * Copyright 2008, Network Appliance Inc.
 * Jason McMullan <mcmullan@netapp.com>
 *
 * Copyright (C) 2004-2007 Freescale Semiconductor, Inc.
 * TsiChung Liew (Tsi-Chung.Liew@freescale.com)
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <common.h>
#include <malloc.h>
#include <spi_flash.h>

#include "spi_flash_internal.h"

/* M25Pxx-specific commands */
#define CMD_M25PXX_RES		0xab	/* Release from DP, and Read Signature */

#define CMD_N25QXX_RVCR		0x85
/* Read volatile configuration register */
#define CMD_N25QXX_WVCR		0x81
/* Write volatile configuration register */

#define VCR_XIP_SHIFT			(0x03)
#define VCR_XIP_MASK			(0x08)
#define VCR_DUMMY_CLK_CYCLES_SHIFT	(0x04)
#define VCR_DUMMY_CLK_CYCLES_MASK	(0xF0)

struct stmicro_spi_flash_params {
	u16 id;
	u16 pages_per_sector;
	u16 nr_sectors;
	const char *name;
};

static const struct stmicro_spi_flash_params stmicro_spi_flash_table[] = {
	{
		.id = 0x2011,
		.pages_per_sector = 128,
		.nr_sectors = 4,
		.name = "M25P10",
	},
	{
		.id = 0x2015,
		.pages_per_sector = 256,
		.nr_sectors = 32,
		.name = "M25P16",
	},
	{
		.id = 0x2012,
		.pages_per_sector = 256,
		.nr_sectors = 4,
		.name = "M25P20",
	},
	{
		.id = 0x2016,
		.pages_per_sector = 256,
		.nr_sectors = 64,
		.name = "M25P32",
	},
	{
		.id = 0x2013,
		.pages_per_sector = 256,
		.nr_sectors = 8,
		.name = "M25P40",
	},
	{
		.id = 0x2017,
		.pages_per_sector = 256,
		.nr_sectors = 128,
		.name = "M25P64",
	},
	{
		.id = 0x2014,
		.pages_per_sector = 256,
		.nr_sectors = 16,
		.name = "M25P80",
	},
	{
		.id = 0x2018,
		.pages_per_sector = 1024,
		.nr_sectors = 64,
		.name = "M25P128",
	},

	/* Numonyx */
	{
		.id = 0xba16,
		.pages_per_sector = 256,
		.nr_sectors = 64,
		.name = "N25Q32",
	},
	{
		.id = 0xbb16,
		.pages_per_sector = 256,
		.nr_sectors = 64,
		.name = "N25Q32A",
	},
	{
		.id = 0xba17,
		.pages_per_sector = 256,
		.nr_sectors = 128,
		.name = "N25Q64",
	},
	{
		.id = 0xba17,
		.pages_per_sector = 256,
		.nr_sectors = 128,
		.name = "N25Q64A",
	},
	{
		.id = 0xba18,
		.pages_per_sector = 256,
		.nr_sectors = 256,
		.name = "N25Q128",
	},
	{
		.id = 0xbb18,
		.pages_per_sector = 256,
		.nr_sectors = 256,
		.name = "N25Q128A",
	},
	{
		.id = 0xba19,
		.pages_per_sector = 256,
		.nr_sectors = 512,
		.name = "N25Q256",
	},
	{
		.id = 0xbb19,
		.pages_per_sector = 256,
		.nr_sectors = 512,
		.name = "N25Q256A",
	},
};

static int stmicro_set_vcr(struct spi_flash *flash, u8 clk_cycles, u8 xip)
{
	u8 cmd;
	u8 resp;
	int ret;

	ret = spi_flash_cmd_write_enable(flash);
	if (ret < 0) {
		debug("SF: enabling write failed\n");
		return ret;
	}

	ret = spi_flash_cmd(flash->spi, CMD_N25QXX_RVCR, (void *) &resp,
		sizeof(resp));
	if (ret < 0) {
		debug("SF: read volatile config register failed.\n");
		return ret;
	}

	resp &= ~VCR_DUMMY_CLK_CYCLES_MASK;
	resp |=  (clk_cycles << VCR_DUMMY_CLK_CYCLES_SHIFT) &
			VCR_DUMMY_CLK_CYCLES_MASK;

	if (xip)
		resp |= VCR_XIP_MASK;
	else
		resp &= ~VCR_XIP_MASK;

	cmd = CMD_N25QXX_WVCR;
	ret = spi_flash_cmd_write(flash->spi, &cmd, sizeof(cmd), &resp,
		sizeof(resp));
	if (ret) {
		debug("SF: fail to write vcr register\n");
		return ret;
	}

	return 0;
}

struct spi_flash *spi_flash_probe_stmicro(struct spi_slave *spi, u8 * idcode)
{
	const struct stmicro_spi_flash_params *params;
	struct spi_flash *flash;
	unsigned int i;
	u16 id;

	if (idcode[0] == 0xff) {
		i = spi_flash_cmd(spi, CMD_M25PXX_RES,
				  idcode, 4);
		if (i)
			return NULL;
		if ((idcode[3] & 0xf0) == 0x10) {
			idcode[0] = 0x20;
			idcode[1] = 0x20;
			idcode[2] = idcode[3] + 1;
		} else
			return NULL;
	}

	id = ((idcode[1] << 8) | idcode[2]);

	for (i = 0; i < ARRAY_SIZE(stmicro_spi_flash_table); i++) {
		params = &stmicro_spi_flash_table[i];
		if (params->id == id) {
			break;
		}
	}

	if (i == ARRAY_SIZE(stmicro_spi_flash_table)) {
		debug("SF: Unsupported STMicro ID %04x\n", id);
		return NULL;
	}

	flash = malloc(sizeof(*flash));
	if (!flash) {
		debug("SF: Failed to allocate memory\n");
		return NULL;
	}

	flash->spi = spi;
	flash->name = params->name;

	flash->write = spi_flash_cmd_write_multi;
	flash->erase = spi_flash_cmd_erase;
	flash->read = spi_flash_cmd_read_fast;
	flash->page_size = 256;
	flash->sector_size = 256 * params->pages_per_sector;
	flash->size = flash->sector_size * params->nr_sectors;

	/*
	 * Numonyx flash have default 15 dummy clocks. Set dummy clocks to 8
	 * and XIP off.
	 */
	if (((id & 0xFF00) == 0xBA00) || ((id & 0xFF00) == 0xBB00))
		stmicro_set_vcr(flash, 8, 0);

	return flash;
}
