## About PRU test
* author: Hans Hony
* notes: adapted from several online sources, trial and error

This is a sensor data log to read ADC on BeagleBoneBlack (BBB) - how awesome is that?
It uses the Programmable Real-time Unit (PRU) as the assembly interface to the TSC_ADC_SS (touch screen adc subsystem)

So... I just saved you hours of datasheet work... you're welcome. ;)

It logs ADC values to local DRAM in PRU1 and interrupts CPU when data is available
I also left the slower /dev/mem shared RAM access code in the comments of main... if you want to go that route for whatever reason...

#### Setup:

     apt-get install -y cmake
     cd pru_test
     mkdir build & cd build
     cmake ..

#### Build:

First, build the firmware for PRU.

     cd pru_test
     make firmware

Then build everything.

     cd pru_test/build
     make

#### Run once: (requires root)

Before you can successsully run. First setup the device tree overlay.

     cd pru_test/device_tree
     ./bb-overlay.sh

#### Run app: (after above)

After the device tree is up. Run the application.

     cd pru_test/build
     ./main


Next: 

* Get coffee and enjoy.
* Log defaults to /tmp/pru_test.log
* You can set the logging level in SensorDataLog.cpp
