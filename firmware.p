.origin 0
.entrypoint INIT

//* CONFIGURATION SECTION */
//*************************/

//* PRU Register and constants */
#define GPIO_DATAIN                     0x138                                   // This is the register for reading data 
#define GPIO0                           0x44E07000                              // The address of the GPIO0 bank
#define GPIO1                           0x4804C000                              // The address of the GPIO1 bank
#define GPIO2                           0x481AC000                              // The address of the GPIO2 bank
#define GPIO3                           0x481AE000                              // The address of the GPIO3 bank
#define PRU1_CONTROL_REGISTER_BASE      0x00024000                              // The base address for all the PRU1 control registers
#define CTPPR0_REGISTER                 PRU1_CONTROL_REGISTER_BASE + 0x28       // The CTPPR0 register for programming C28 and C29 entries
#define SHARED_RAM_ENDSTOPS_ADDR        0x0120

#define GPIO_0_IN       r16
#define GPIO_1_IN       r17
#define GPIO_2_IN       r18
#define GPIO_3_IN       r19

#define GPIO_WORD_LEN	(8)

#define ADC_BASE        0x44e0d000         // base address for ADC_TSC_SS
#define ADC_SYS         0x10               // offset for SYSCONFIG register
#define ADC_STATUS      0x44               // offset for ADCSTAT register
#define ADC_CTRL        0x40               // offset for ADC CTRL
#define ADC_CTRL_WRITE  0x00000004         // writable StepConfig
#define ADC_CTRL_ENABLE 0x00000003         // read-only StepConfig, enable TS_ADC_SS and store ADCCHANID (aka Step_ID_tag)
#define ADC_CLK_DIV     0x4C               // offset for ADC_CLKDIV register (0 for fastest sample) ...divides clock signal
#define ADC_STEP_ENABLE 0x54               // offset for ADC_STEPENABLE
#define ADC_STEP_VAL    0x000001fe         // enables STEP8 (w2) STEP1-STEP7 (w0)
#define ADC_CHG_CONFIG  0x5C               // offset for TS CHARGE config register
#define ADC_CHG_DELAY   0x60               // offset for TS CHARGE delay register
#define ADC_STEPCONFIG1 0x64               // offset for STEPCONFIG1
#define ADC_STEPCONFIG2 0x6C               // offset for STEPCONFIG2
#define ADC_STEPCONFIG3 0x74               // offset for STEPCONFIG3
#define ADC_STEPCONFIG4 0x7C               // offset for STEPCONFIG4
#define ADC_STEPCONFIG5 0x84               // offset for STEPCONFIG5
#define ADC_STEPCONFIG6 0x8C               // offset for STEPCONFIG6
#define ADC_STEPCONFIG7 0x94               // offset for STEPCONFIG7
#define ADC_STEPCONFIG8 0x9C               // offset for STEPCONFIG8
#define ADC_STEPDELAY1  0x68               // offset for STEPDELAY1
#define ADC_STEPDELAY2  0x70               // offset for STEPDELAY2
#define ADC_STEPDELAY3  0x78               // offset for STEPDELAY3
#define ADC_STEPDELAY4  0x80               // offset for STEPDELAY4
#define ADC_STEPDELAY5  0x88               // offset for STEPDELAY5
#define ADC_STEPDELAY6  0x90               // offset for STEPDELAY6
#define ADC_STEPDELAY7  0x98               // offset for STEPDELAY7
#define ADC_STEPDELAY8  0xA0               // offset for STEPDELAY8
#define ADC_CHAN1_CFG   0x00000000         // one-shot, no average, enable SEL_INP Channel 1 for STEPCONFIG1
#define ADC_CHAN2_CFG   0x00080000         // one-shot, no average, enable SEL_INP Channel 2 for STEPCONFIG2
#define ADC_CHAN3_CFG   0x00100000         // one-shot, no average, enable SEL_INP Channel 3 for STEPCONFIG3
#define ADC_CHAN4_CFG   0x00180000         // one-shot, no average, enable SEL_INP Channel 4 for STEPCONFIG4
#define ADC_CHAN5_CFG   0x00200000         // one-shot, no average, enable SEL_INP Channel 5 for STEPCONFIG5
#define ADC_CHAN6_CFG   0x00280000         // one-shot, no average, enable SEL_INP Channel 6 for STEPCONFIG6
#define ADC_CHAN7_CFG   0x00300000         // one-shot, no average, enable SEL_INP Channel 7 for STEPCONFIG7
#define ADC_CHAN8_CFG   0x00380000         // one-shot, no average, enable SEL_INP Channel 8 for STEPCONFIG8
#define ADC_FIFO0THRESH 0xE8               // offset for FIFO0THRESHOLD 
#define ADC_FIFOTHRESH  0x0000003F         // program to (value-1) samples before generating CPU interrupt
#define ADC_FIFO0DATA   ADC_BASE + 0x0100  // address of FIFO0DATA
#define ADC_FIFO0COUNT  0xE4               // offset for FIFO0COUNT

#define ADC_REG	        r20
#define ADC_CNT	        r21
#define ADC_READ        r22
#define ADC_VALU        r23
#define ADC_CHAN        r24
#define ADC_TEMP        r25
#define ADC_MEM         r26

// Refer to this mapping in the file - pruss_intc_mapping.h
#define PRU0_PRU1_INTERRUPT     17
#define PRU1_PRU0_INTERRUPT     18
#define PRU0_ARM_INTERRUPT      19
#define PRU1_ARM_INTERRUPT      20
#define ARM_PRU0_INTERRUPT      21
#define ARM_PRU1_INTERRUPT      22

#define CONST_PRUDRAM   C24
#define CONST_L3RAM     C30
#define CONST_DDR       C31

#define CTBIR_0         0x22020    // Address for the Constant table Programmable Pointer Register 0(CTPPR_0)
#define CTBIR_1         0x22024

//Memory map in shared RAM:
//0x0120:       start address    

.macro KICK_ADC
    MOV  ADC_TEMP, ADC_STEP_VAL
    SBBO ADC_TEMP, ADC_REG, ADC_STEP_ENABLE, 4  // enable STEP1 through STEP7
    MOV  ADC_CNT, 0x00000000
    MOV  ADC_MEM, 0x00000000
.endm

INIT:
    LBCO r0, C4, 4, 4              // Load the PRU-ICSS SYSCFG register (4 bytes) into R0
    CLR  r0, r0, 4                 // Clear bit 4 in reg 0 (copy of SYSCFG). This enables OCP master ports needed to access all OMAP peripherals
    SBCO r0, C4, 4, 4              // Load back the modified SYSCFG register    
    
//    MOV  r0, SHARED_RAM_ENDSTOPS_ADDR           // Set the C28 address for shared ram, C29 is set to 0
//    MOV  r1, CTPPR0_REGISTER
//    SBBO r0, r1, 0, 4

    // Configure the block index register for PRU0 by setting c24_blk_index[7:0] and
    // c25_blk_index[7:0] field to 0x00 and 0x00, respectively.  This will make C24 point
    // to 0x00000000 (PRU0 DRAM) and C25 point to 0x00002000 (PRU1 DRAM).
    MOV  r0, 0x00000000
    MOV  r1, CTBIR_0
    SBBO r0, r1, 0, 4

    // Setup ADC
    MOV  ADC_REG, ADC_BASE                      // set address to 0x44e0d000
    MOV  ADC_TEMP, 0x00000000 
    SBBO ADC_TEMP, ADC_REG, ADC_SYS, 4          // force idle mode in SYSCONFIG

    MOV  ADC_TEMP, ADC_BASE + ADC_STATUS        // check if ADC is idle
WAIT_FOR_IDLE:
    QBBS WAIT_FOR_IDLE, ADC_TEMP, 5             // bit 5 should be zero
    
    MOV  ADC_TEMP, ADC_CTRL_WRITE
    SBBO ADC_TEMP, ADC_REG, ADC_CTRL, 4         // set ADC CTRL StepConfig write privileges 
    MOV  ADC_TEMP, 0x00000000
    SBBO ADC_TEMP, ADC_REG, ADC_CLK_DIV, 4      // disable ACD CLKDIV
    
    MOV  ADC_TEMP, 0x00000000
    SBBO ADC_TEMP, ADC_REG, ADC_CHG_CONFIG, 4   // reset TS CHARGE state
    MOV  ADC_TEMP, 0x00000001
    SBBO ADC_TEMP, ADC_REG, ADC_CHG_DELAY, 4    // value must be 1 cycle
    
    MOV  ADC_TEMP, ADC_CHAN1_CFG
    SBBO ADC_TEMP, ADC_REG, ADC_STEPCONFIG1, 4  // load STEPCONFIG1
    MOV  ADC_TEMP, ADC_CHAN2_CFG
    SBBO ADC_TEMP, ADC_REG, ADC_STEPCONFIG2, 4  // load STEPCONFIG2
    MOV  ADC_TEMP, ADC_CHAN3_CFG
    SBBO ADC_TEMP, ADC_REG, ADC_STEPCONFIG3, 4  // load STEPCONFIG3
    MOV  ADC_TEMP, ADC_CHAN4_CFG
    SBBO ADC_TEMP, ADC_REG, ADC_STEPCONFIG4, 4  // load STEPCONFIG4
    MOV  ADC_TEMP, ADC_CHAN5_CFG
    SBBO ADC_TEMP, ADC_REG, ADC_STEPCONFIG5, 4  // load STEPCONFIG5
    MOV  ADC_TEMP, ADC_CHAN6_CFG
    SBBO ADC_TEMP, ADC_REG, ADC_STEPCONFIG6, 4  // load STEPCONFIG6
    MOV  ADC_TEMP, ADC_CHAN7_CFG
    SBBO ADC_TEMP, ADC_REG, ADC_STEPCONFIG7, 4  // load STEPCONFIG7
    MOV  ADC_TEMP, ADC_CHAN8_CFG
    SBBO ADC_TEMP, ADC_REG, ADC_STEPCONFIG8, 4  // load STEPCONFIG8
    
    MOV  ADC_TEMP, 0x00000000
    SBBO ADC_TEMP, ADC_REG, ADC_STEPDELAY1, 4   // no delay
    SBBO ADC_TEMP, ADC_REG, ADC_STEPDELAY2, 4   // no delay
    SBBO ADC_TEMP, ADC_REG, ADC_STEPDELAY3, 4   // no delay
    SBBO ADC_TEMP, ADC_REG, ADC_STEPDELAY4, 4   // no delay
    SBBO ADC_TEMP, ADC_REG, ADC_STEPDELAY5, 4   // no delay
    SBBO ADC_TEMP, ADC_REG, ADC_STEPDELAY6, 4   // no delay
    SBBO ADC_TEMP, ADC_REG, ADC_STEPDELAY7, 4   // no delay
    SBBO ADC_TEMP, ADC_REG, ADC_STEPDELAY8, 4   // no delay
    
    MOV  ADC_TEMP, ADC_FIFOTHRESH
    SBBO ADC_TEMP, ADC_REG, ADC_FIFO0THRESH, 4  // set the number of samples before generating an interrupt
    
    MOV ADC_TEMP, ADC_CTRL_ENABLE
    SBBO ADC_TEMP, ADC_REG, ADC_CTRL, 4         // read-only config, enable TS_ADC_SS and store ADCCHANID
    
    // ADC value init
    MOV ADC_READ, ADC_FIFO0DATA

COLLECT: 


// The ADC FIFO0DATA description from TI datasheet
// _____________________ADC_VALUES__________________
// |31_30_29_28_27_26_25_24_23_22_21_20_19_18_17_16|
// |_____________RESERVED______________|_ADCCHNLID_|
// |15_14_13_12_11_10__9__8__7__6__5__4__3__2__1__0|
// |__RESERVED_|_____________ADCDATA_______________|
//

    KICK_ADC

READ_ADC_VALS:
//    LBBO ADC_VALU, ADC_READ, 0, 4              // copy 4 bytes into ADC_VALU from ADC_READ+0
//    LSR  ADC_CHAN, ADC_VALU, 16	             // shift right: ADC_CHAN = ADC_VALU >> (16 & 0x1f) to remove 0-15 bits
//    AND  ADC_CHAN, ADC_CHAN, 0x0f              // mask byte: ADC_CHAN = (ADC_CHAN & 0x000f) to isolate ADCCHNLID
//    AND  ADC_VALU.b1, ADC_VALU.b1, 0x0f        // mask byte: remove RESERVED from bits 12-15
//    LSL  ADC_CHAN, ADC_CHAN, 12                // shift left: ADC_CHAN = (ADC_CHAN << 12) to put channel in top 4-bit position
//    OR   ADC_VALU.b1, ADC_CHAN.b1, ADC_VALU.b1 // combine 12-bits lower and 4-bits upper
//    OR   ADC_VALU, ADC_CHAN, ADC_VALU          // combine ADCCHANID and ADCDATA into lower 2 bytes 0x<chan><data><data><data>

    //MOV  ADC_VALU, 0xcafebabe
    MOV  r1, 0xcafebabe
    MOV  ADC_TEMP, 0x0000
    SBBO r1, ADC_TEMP, 0, 4

    SUB  ADC_CNT, ADC_CNT, 1                   // count ADC channels minus 1

    // instead of one line of code, pasm compiler makes me use 100
//    QBEQ AIN_7, ADC_CNT, 7
//    QBEQ AIN_6, ADC_CNT, 6
//    QBEQ AIN_5, ADC_CNT, 5
//    QBEQ AIN_4, ADC_CNT, 4
//    QBEQ AIN_3, ADC_CNT, 3
//    QBEQ AIN_2, ADC_CNT, 2
//    QBEQ AIN_1, ADC_CNT, 1
//    QBEQ AIN_0, ADC_CNT, 0

//    SBCO ADC_VALU, C28, 0, 4
//    SBCO ADC_VALU, C28, 4, 4
//    SBCO ADC_VALU, C28, 8, 4
//    SBCO ADC_VALU, C28, 12, 4
//    SBCO ADC_VALU, C28, 16, 4
//    SBCO ADC_VALU, C28, 20, 4
//    SBCO ADC_VALU, C28, 24, 4
  
    MOV  ADC_VALU, 0xbabecafe
    SBCO ADC_VALU, CONST_PRUDRAM, 4, 4  
    MOV  ADC_VALU, 0xdeadbeef
    SBCO ADC_VALU, CONST_PRUDRAM, 8, 4  
    MOV  ADC_VALU, 0xfeedabba
    SBCO ADC_VALU, CONST_PRUDRAM, 12, 4  
    MOV  ADC_VALU, 0xdeafbead
    SBCO ADC_VALU, CONST_PRUDRAM, 16, 4  
    MOV  ADC_VALU, 0xdeedfade
    SBCO ADC_VALU, CONST_PRUDRAM, 20, 4  
    MOV  ADC_VALU, 0xabbadead
    SBCO ADC_VALU, CONST_PRUDRAM, 24, 4  
    JMP TEST // being cautious, if there is a mistake, just skip (so I don't break stuff)

// copy 2 bytes from ADC_VALU to (GPIO_WORD_LEN + n) in C28
//AIN_7:
//    SBCO ADC_VALU, C28, GPIO_WORD_LEN + 14, 2
//    JMP READ_ADC_VALS // loop to read all ADC channels

AIN_6:
    SBBO ADC_VALU, ADC_MEM, 24*8, 4
    //SBCO ADC_VALU, C28, GPIO_WORD_LEN + (24*8), 4
    JMP READ_ADC_VALS // loop to read all ADC channels

AIN_5:
    //SBBO ADC_VALU, ADC_MEM, 20*8, 4
    SBCO ADC_VALU, C28, GPIO_WORD_LEN + (20*8), 4
    JMP READ_ADC_VALS // loop to read all ADC channels

AIN_4:
    //SBBO ADC_VALU, ADC_MEM, 16*8, 4
    SBCO ADC_VALU, C28, GPIO_WORD_LEN + (16*8), 4
    JMP READ_ADC_VALS // loop to read all ADC channels

AIN_3:
    //SBBO ADC_VALU, ADC_MEM, 12*8, 4
    SBCO ADC_VALU, C28, GPIO_WORD_LEN + (12*8), 4
    JMP READ_ADC_VALS // loop to read all ADC channels

AIN_2:
    //SBBO ADC_VALU, ADC_MEM, 8*8, 4
    SBCO ADC_VALU, C28, GPIO_WORD_LEN + (8*8), 4
    JMP READ_ADC_VALS // loop to read all ADC channels

AIN_1:
    //SBBO ADC_VALU, ADC_MEM, 4*8, 4
    SBCO ADC_VALU, C28, GPIO_WORD_LEN + (4*8), 4
    JMP READ_ADC_VALS // loop to read all ADC channels

AIN_0:
    //SBBO ADC_VALU, ADC_MEM, 0, 4
    SBCO ADC_VALU, C28, GPIO_WORD_LEN, 4
    // done reading


TEST:
    // Send notification to Host for program completion
    MOV R31.b0, PRU1_ARM_INTERRUPT+16

    QBA COLLECT

