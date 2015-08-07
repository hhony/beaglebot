/***********************************************************************
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

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include "SensorDataLog.h"

SensorDataLog *gSensorLog;
static ELogLevel LogLevel = DATA;

#define DFLT_FILE_PERMS 	(S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH)
#define MAX_BUFFER_SIZE		(1024)

static char format_buffer[MAX_BUFFER_SIZE];
static char string_buffer[MAX_BUFFER_SIZE];

SensorDataLog::SensorDataLog() {

	stop = false;
	snprintf(file_io_path, 14, "%s", "/tmp/pru_test.log");

	fd = open(file_io_path, O_CREAT | O_WRONLY | O_SYNC, DFLT_FILE_PERMS );

	LogMsg(VERBOSE, "SensorDataLog: initialization");
}

SensorDataLog::~SensorDataLog() {
}

void SensorDataLog::LogMsgArgs(ELogLevel level, const char *data, ...) {

	// filter incoming messages by global priority
	if (level < LogLevel)
		return;

	// parse arguments
	va_list args;
	va_start(args, data);
	vsnprintf(format_buffer, MAX_BUFFER_SIZE-1, data, args);

	// normalize log message
	LogMsg(level, &format_buffer[0]);
	memset(&format_buffer[0], 0, MAX_BUFFER_SIZE);
}

void SensorDataLog::LogMsg(ELogLevel level, const char *data) {

	// filter incoming messages by global priority
	if (level < LogLevel)
		return;

	// format output log appearance
	switch (level) {
	case VERBOSE:
		snprintf(string_buffer, (7+strlen(data)+2), "[INFO] %s%c", data, '\n');
		break;
	case WARNING:
		snprintf(string_buffer, (10+strlen(data)+2), "[WARNING] %s%c", data, '\n');
		break;
	case ERROR:
		snprintf(string_buffer, (8+strlen(data)+2), "[ERROR] %s%c", data, '\n');
		break;
	default:
		snprintf(string_buffer, (strlen(data)+2), "%s%c", data, '\n');
		break;
	}

	// write output and clean up
	writeToFile(string_buffer, (strlen(string_buffer)+2));
	memset(&string_buffer[0], 0, MAX_BUFFER_SIZE);
}

int SensorDataLog::writeToFile(const char *data, int size) {
	return write(fd, data, size);
}

void SensorDataLog::startThread(SensorDataLog *refPP) {

	LogMsg(VERBOSE, "SensorDataLog: starting");

	// initialize pointer
	gSensorLog = refPP;

	sensorDataThread = std::thread([this]() {
		this->run();
	});
}

void SensorDataLog::stopThread() {
	stop = true;
	if (sensorDataThread.joinable())
		sensorDataThread.join();
}

void SensorDataLog::run() {

	while(!stop) {

		usleep(500000);

	}
}
