cmake_minimum_required(VERSION 2.8)

if((CMAKE_SYSTEM_NAME MATCHES "Darwin") AND (APPLE))
     list(APPEND CMAKE_CXX_FLAGS "-std=c++0x -stdlib=libc++ -D__DEBUG -D__cplusplus=201103L -D__GXX_EXPERIMENTAL_CXX0X__=1 -O0 -D_GLIBCXX_USE_NANOSLEEP -g3 -Wall -fmessage-length=0 ${CMAKE_CXX_FLAGS} -g -ftest-coverage -fprofile-arcs")
elseif((CMAKE_SYSTEM_NAME MATCHES "Linux") AND (UNIX))
     list(APPEND CMAKE_CXX_FLAGS "-std=c++0x -pthread -D__DEBUG -D__cplusplus=201103L -D__GXX_EXPERIMENTAL_CXX0X__=1 -O0 -D_GLIBCXX_USE_NANOSLEEP -g3 -Wall -fmessage-length=0 ${CMAKE_CXX_FLAGS} -g -ftest-coverage -fprofile-arcs")
endif()

add_executable(main main.cpp __prussdrv.h  pruss_intc_mapping.h prussdrv.h prussdrv.c SensorDataLog.h SensorDataLog.cpp)

