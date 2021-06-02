################################################################################
# This software is released under the MIT License see LICENSE.txt
# Filename : logger.ps1
# Overview : Display log/Write log to a file.
# HowToUse : Import
#              when logger.ps1 is located to functions folder
#              ${shelldir}=(Split-Path -Path ${MyInvocation}.MyCommand.Path -Parent)
#              ${functionsdir}=(Join-Path -Path ${shelldir} -ChildPath "functions")
#              . ${functionsdir}\logger.ps1
#            Initialise
#              ${logger} = New-Object Logger
#            Log output configuration
#              when you use the debug level:
#                ${logger}.SetDebugLevel()
#              if you need a log file:
#                clear log file before write
#                  ${ret} = ${logger}.CreateLogfile(${logfile})
#                not clear log file before write
#                  ${ret} = ${logger}.OpenLogfile(${logfile})
#            Log output
#              ${logger}.debug("debug level message")
#              ${logger}.info("info level message")
#              ${logger}.warning("warning level message")
#              ${logger}.error("error level message")
#              ${logger}.critical("critical level message")
#-------------------------------------------------------------------------------
# Author: Isaac Factory (sir.isaac.factory@icloud.com)
# Repository: https://github.com/SirIsaacFactory/PowerShellLibs
# Date: 2021/02/09
# Code version: v1.00
################################################################################

################################################################################
# Class Definition
################################################################################
class logger {
    # version
    [string]${VERSION} = "v1.00"

    # return value
    [int]${NORMAL_END} = ${True}
    [int]${ERROR_END}  = ${False}

    # loglevel
    [int]${DEBUG_LEVEL}    = 0
    [int]${INFO_LEVEL}     = 1
    [int]${WARNING_LEVEL}  = 2
    [int]${ERROR_LEVEL}    = 3
    [int]${CRITICAL_LEVEL} = 4
    [int]${loglevel}       = [int]${INFO_LEVEL}

    # loglabel
    [string]${LABEL_DEBUG}    = "[debug]   "
    [string]${LABEL_INFO}     = "[info]    "
    [string]${LABEL_WARNING}  = "[warning] "
    [string]${LABEL_ERROR}    = "[error]   "
    [string]${LABEL_CRITICAL} = "[critical]"
    [string]${loglabel}       = [string]${LABEL_INFO}

    # logfile
    [string]${LOGFILE} = ""

    ############################################################################
    # Set loglevel
    ############################################################################
    [void]SetDebugLevel() {
        ${this}.loglevel = ${this}.DEBUG_LEVEL
    }
    [void]SetInfoLevel() {
        ${this}.loglevel = ${this}.INFO_LEVEL
    }
    [void]SetWarningLevel() {
        ${this}.loglevel = ${this}.WARNING_LEVEL
    }
    [void]SetErrorLevel() {
        ${this}.loglevel = ${this}.ERROR_LEVEL
    }
    [void]SetCriticalLevel() {
        ${this}.loglevel = ${this}.CRITICAL_LEVEL
    }
    [int]GetLogLevel() {
        return ${this}.loglevel
    }

    ############################################################################
    # Create logfile
    ############################################################################
    [int]CreateLogFile([string]${logfilepath}) {

        # check log directory existence
        ${logdir}=(Split-Path -Path ${logfilepath} -Parent)
        if(-not(Test-Path -Path ${logdir})) {
            ${this}.error("[${logdir}] directory does not exist.")
            ${this}.debug("end")
            return ${this}.ERROR_END
        }

        # create logfile
        try{
            New-Item -Path ${logfilepath} -ItemType File -Force -ErrorAction Stop
        } catch {
            ${this}.error("Failed to create logfile.")
            return ${this}.ERROR_END
        }

        # check whether the logfile exists
        if(-not(Test-Path -Path ${logfilepath} -PathType Leaf)) {
            ${this}.error("Failed to create logfile.")
            return ${this}.ERROR_END
        }

        # set LOGFILE
        ${this}.LOGFILE=${logfilepath}

        return ${this}.NORMAL_END
    }

    ############################################################################
    # open logfile
    ############################################################################
    [int]OpenLogFile([string]${logfilepath}) {

        # check log directory existence
        ${logdir}=(Split-Path -Path ${logfilepath} -Parent)
        if(-not(Test-Path -Path ${logdir})) {
            ${this}.error("[${logdir}] directory does not exist.")
            ${this}.debug("end")
            return ${this}.ERROR_END
        }

        # set LOGFILE
        ${this}.LOGFILE=${logfilepath}

        return ${this}.NORMAL_END
    }

    ############################################################################
    # output log message
    ############################################################################
    [void]debug([string]${logmsg}) {
        ${this}.outputLog(${this}.DEBUG_LEVEL, ${logmsg})
    }

    [void]info([string]${logmsg}) {
        ${this}.outputLog(${this}.INFO_LEVEL , ${logmsg})
    }

    [void]warning([string]${logmsg}) {
        ${this}.outputLog(${this}.WARNING_LEVEL , ${logmsg})
    }

    [void]error([string]${logmsg}) {
        ${this}.outputLog(${this}.ERROR_LEVEL , ${logmsg})
    }

    [void]critical([string]${logmsg}) {
        ${this}.outputLog(${this}.CRITICAL_LEVEL , ${logmsg})
    }

    ############################################################################
    # output log
    ############################################################################
    [void]outputLog([int]${level}, [string]${logmsg}) {
        if(${level} -ge ${this}.loglevel) {
            ${current_time} = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")
            switch(${level}) {
                ${this}.DEBUG_LEVEL    { ${this}.loglabel = ${this}.LABEL_DEBUG    }
                ${this}.INFO_LEVEL     { ${this}.loglabel = ${this}.LABEL_INFO     }
                ${this}.WARNING_LEVEL  { ${this}.loglabel = ${this}.LABEL_WARNING  }
                ${this}.ERROR_LEVEL    { ${this}.loglabel = ${this}.LABEL_ERROR    }
                ${this}.CRITICAL_LEVEL { ${this}.loglabel = ${this}.LABEL_CRITICAL }
            }

            # get caller information
            ${callstack}=(Get-PSCallStack)
            ${callstack}=${callstack}[2]

            # get script name
            ${callerscript_fullpath}=[string]${callstack}.ScriptName
            ${callerscript}=Split-Path -Path ${callerscript_fullpath} -Leaf

            # get script line
            ${callerline}=[string]${callstack}.ScriptLineNumber

            # get function name
            ${callerfunction}=[string]${callstack}.FunctionName

            # display message
            [System.Console]::WriteLine(
                ${current_time}   + "," + 
                ${this}.loglabel  + "," +
                ${callerscript}   + "," + 
                ${callerfunction} + "," +
                ${callerline}     + "," +
                ${logmsg}
            )

            # write message to the logfile
            if(-not(${this}.LOGFILE -eq "")) {
                [System.IO.File]::AppendAllText(
                    ${this}.LOGFILE,
                    ${current_time}   + "," + 
                    ${this}.loglabel  + "," +
                    ${callerscript}   + "," +
                    ${callerfunction} + "," +
                    ${callerline}     + "," +
                    ${logmsg}         +
                    "`r`n"
                )
            }
        }
    }
}
