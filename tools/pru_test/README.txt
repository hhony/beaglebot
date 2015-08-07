@author Hans Hony
@notes: adapted from several online sources, trial and error

This is a sensor data log to read ADC on BeagleBoneBlack (BBB) - how awesome is that?
It uses the Programmable Real-time Unit (PRU) as the assembly interface to the TSC_ADC_SS (touch screen adc subsystem)

So... I just saved you hours of datasheet work... you're welcome. ;)

It logs ADC values to local DRAM in PRU1 and interrupts CPU when data is available
I also left the slower /dev/mem shared RAM access code in the comments of main... if you want to go that route for whatever reason...

#############################
## Setup:
#############################

$: apt-get install -y cmake
$: cd pru_test
$: mkdir build & cd build
$: cmake ..



#############################
## Build:
#############################

$: cd pru_test
$: make firmware

$: cd pru_test/build
$: make



#############################
## Run once: (requires root)
#############################

$: cd pru_test/device_tree
$: ./bb-overlay.sh



#############################
## Run app: (after above)
#############################

$: cd pru_test/build
$: ./main


Get coffee and enjoy.
Log defaults to /tmp/pru_test.log
You can set the logging level in SensorDataLog.cpp


