cmake_minimum_required(VERSION 2.8)
list(APPEND CMAKE_CXX_FLAGS "-pthread -std=c++0x -D__DEBUG -D__cplusplus=201103L -D__GXX_EXPERIMENTAL_CXX0X__=1 -O0 -D_GLIBCXX_USE_NANOSLEEP -g3 -Wall -fmessage-length=0 ${CMAKE_CXX_FLAGS} -g -ftest-coverage -fprofile-arcs")
add_executable(main main.cpp __prussdrv.h  pruss_intc_mapping.h prussdrv.h prussdrv.c SensorDataLog.h SensorDataLog.cpp)

