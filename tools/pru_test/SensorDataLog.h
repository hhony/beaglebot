/***********************************************************************
 *
 * Author: Hans Hony
 * Website: github.com/hhony
 * License: GNU GPLv3 http://www.gnu.org/copyleft/gpl.html
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * See <http://www.gnu.org/licenses/>.
 *
 ***********************************************************************/

#ifndef __SensorDataLog_H__
#define __SensorDataLog_H__

#include <thread>
#include <fcntl.h>
#include <unistd.h>

class PathPlanner; // claim that it exists

enum ELogLevel {
	VERBOSE,
	WARNING,
	ERROR,
	DATA
};

class SensorDataLog {
private:

	int fd;                 // file descriptor
	char file_io_path[20];  // file path

	int writeToFile(const char *data, int size);

	bool stop;
	std::thread sensorDataThread;
	void run(void);

public:

	SensorDataLog(void);
	virtual ~SensorDataLog(void);

	void startThread(SensorDataLog *refPP);
	void stopThread(void);

	/**
	 * @brief 	LogMsgArgs takes format and arguments
	 * @details See LogMsg for unformatted string buffering
	 * @param 	level	the log output filter level
	 * @param	data	format followed by data arguments
	 */
	void LogMsgArgs(ELogLevel level, const char *data, ...);

	/**
	 * @brief 	LogMsg buffers string data and writes to file
	 * @details Formats the output string by filter level and writes to file
	 * @param 	level	the log output filter level
	 * @param	data	message to be formatted according to log level
	 */
	void LogMsg(ELogLevel level, const char *data);
};

#define SENSOR_LOG (1) //set to 1 to add debug thread
#if SENSOR_LOG
	extern SensorDataLog *gSensorLog; 					///> runtime thread for debugging sensor data
#endif

#endif // __SensorDataLog_H__
