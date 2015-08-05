#include <sys/mman.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>

#include "prussdrv.h"
#include "pruss_intc_mapping.h"
#include "__prussdrv.h"
#include "SensorDataLog.h"

#define PRU_NUM1		1
#define PRU_NUM0		0

#define RAM2_BEGIN		AM33XX_DATARAM0_PHYS_BASE + 0x00012000
#define GPIO_WORD_LEN	8  // in bytes
#define ADC_STORE_LEN	(9 * sizeof(unsigned int))
#define ADC_REGISTERS	7

typedef struct sADC_values {
	uint32_t AIN0;
	uint32_t AIN1;
	uint32_t AIN2;
	uint32_t AIN3;
	uint32_t AIN4;
	uint32_t AIN5;
	uint32_t AIN6;
	//uint32_t AIN7;
}sADC_values;


static sADC_values ADC_Values;

int main(int argc, const char * argv[])
{
	printf("starting up...\n");
	SensorDataLog sensors;
	sensors.startThread(&sensors);

	gSensorLog->LogMsgArgs(DATA, "AIN0, AIN1, AIN2, AIN3, AIN4, AIN5, AIN6");

	/* ddr adc */
	int mem_fd;
	uint8_t *ddr_adc_mem;

	/* open the device */
	printf("opening dev/mem...\n");

	mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
	if (mem_fd < 0) {
		gSensorLog->LogMsgArgs(ERROR, "Failed to open /dev/mem %d: %s", errno, strerror(errno));
	}

	printf("adc mmap location %x...\n", RAM2_BEGIN);

	// adc memory map
	ddr_adc_mem = (uint8_t*)mmap(0, ADC_STORE_LEN, PROT_READ, MAP_SHARED, mem_fd, RAM2_BEGIN);
	if (NULL == ddr_adc_mem) {
		gSensorLog->LogMsgArgs(ERROR, "Failed to map adc device %d: %s", errno, strerror(errno));
		close(mem_fd);
	}

	printf("starting pru bin...\n");
        
	unsigned int ret;
	tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
	/* Initialize the PRU */
	prussdrv_init ();
	/* Open PRU Interrupt */
	ret = prussdrv_open(PRU_EVTOUT_0);
	if (ret)
	{
		printf( "prussdrv_open failed!\n");
		return -1;
	}
	/* Open PRU sync Interrupt */
	ret = prussdrv_open(PRU_EVTOUT_1);
	if (ret)
	{
		printf("prussdrv_open failed (sync interrupt)!\n");
		return -1;
	}

	/* Get the interrupt initialized */
	prussdrv_pruintc_init(&pruss_intc_initdata);

	void* pru_data_mem;
	prussdrv_map_prumem (PRUSS0_PRU1_DATARAM, &pru_data_mem);

	unsigned int * pru_data_int = (unsigned int *) pru_data_mem;
	
	ret = prussdrv_exec_program (PRU_NUM1, "/root/pru_test/firmware.bin");
	printf("returned from pru 1 start...\n");

	if (ret != 0) {
		gSensorLog->LogMsgArgs(WARNING, "Could not execute endstop firmware on PRU1 [%u]", ret);
	}

	printf("return code %u\n", ret);

	while(1) {

		printf("ddr_adc_mem check: %u\n", ddr_adc_mem);
		if (!ddr_adc_mem) {
			gSensorLog->LogMsgArgs(ERROR, "ddr_adc_mem is NULL.");
			return -1;
		}

        printf("Waiting for PRU interrupt command.\n");
        prussdrv_pru_wait_event (PRU_EVTOUT_1, 5000);
        printf("PRU completed transfer.\n");
        prussdrv_pru_clear_event (PRU_EVTOUT_1, PRU1_ARM_INTERRUPT);

		printf("defining variables...\n");

		uint32_t temp, upper, lower;
		

		for (int i = 0; i < ADC_REGISTERS; i++) {
			//printf("reading AIN%d and AIN%d\n", 2*i+1, 2*i);
			printf("reading AIN%d ", i);
			temp = pru_data_int[i];

			//upper = (temp & 0x0FFF0000) >> 16;
			lower = temp;//(temp & 0x00000FFF);
			
			//printf("upper %u lower %u\n", upper, lower);
			printf(" value '%08x'\n", lower);

			switch (i) {
			//case 0:
			//	ADC_Values.AIN1 = upper;
			//	ADC_Values.AIN0 = lower;
			//	break;
			//case 1:
			//	ADC_Values.AIN3 = upper;
			//	ADC_Values.AIN2 = lower;
			//	break;
			//case 2:
			//	ADC_Values.AIN5 = upper;
			//	ADC_Values.AIN4 = lower;
			//	break;
			//case 3:
			//	ADC_Values.AIN7 = 0;
			//	ADC_Values.AIN6 = lower;
			//	break;

			case 0:
				ADC_Values.AIN0 = lower;
				break;
			case 1:
				ADC_Values.AIN1 = lower;
				break;
			case 2:
				ADC_Values.AIN2 = lower;
				break;
			case 3:
				ADC_Values.AIN3 = lower;
				break;
			case 4:
				ADC_Values.AIN4 = lower;
				break;
			case 5:
				ADC_Values.AIN5 = lower;
				break;
			case 6:
				ADC_Values.AIN6 = lower;
				break;
			}

		}

		gSensorLog->LogMsgArgs(DATA, "%x, %x, %x, %x, %x, %x, %x"//"%u, %u, %u, %u, %u, %u, %u"
					, ADC_Values.AIN0
					, ADC_Values.AIN1
					, ADC_Values.AIN2
					, ADC_Values.AIN3
					, ADC_Values.AIN4
					, ADC_Values.AIN5
					, ADC_Values.AIN6);

		usleep(500000);
	}

	return 0;
}
