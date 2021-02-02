################################################################################
# This software is released under the MIT License see LICENSE.txt
# Filename : logger.ps1
# Overview : Dispay log /Write log to file.
# HowToUse : Import
#              when logger.ps1 is located to functions folder
#              ${shelldir}=(Split-Path -Path ${MyInvocation}.MyCommand.Path -Parent)
#              ${functionsdir}=(Join-Path -Path ${shelldir} -ChildPath "functions")
#              . ${functionsdir}\logger.ps1
#            Initialise
#              ${logger} = New-Object Logger
#            LogOutout configuration
#              when you use the debug level:
#                ${logger}.SetLoglevel(${logger}.get_debug_level())
#              if you need a log file:
#                ${ret}=${logger}.CreateLogfile(${logfile})
#            LogOutput
#              ${logger}.debug("debug level message")
#              ${logger}.info("info level message")
#              ${logger}.warning("warning level message")
#              ${logger}.error("error level message")
#              ${logger}.critical("critical level message")
#-------------------------------------------------------------------------------
# Author: Isaac Factory
# Date: 2021/02/01
# Code version: v1.00
################################################################################

################################################################################
# Class Definition
################################################################################
class logger {
    # version
    [string]${VERSION} = "v1.00"

    # return value
    [int]${NORMAL_END} = 0
    [int]${ERROR_END}  = 1

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

    # return loglevel
    [int]debug_level()    { return ${this}.DEBUG_LEVEL    }
    [int]info_level()     { return ${this}.INFO_LEVEL     }
    [int]warning_level()  { return ${this}.WARNING_LEVEL  }
    [int]error_level()    { return ${this}.ERROR_LEVEL    }
    [int]critical_level() { return ${this}.CRITICAL_LEVEL }


    ############################################################################
    # set loglevel
    ############################################################################
    SetLoglevel(${level}) {
        ${this}.loglevel = ${level}
    }


    ############################################################################
    # create logfile
    ############################################################################
    [int]CreateLogfile([string]${logfilepath}) {
        ${this}.debug("start")

        # check log directory existence
        ${logdir}=(Split-Path -Path ${logfilepath} -Parent)
        if(-not(Test-Path -Path ${logdir})) {
            ${this}.error("[${logdir}] directory does not exist.")
            ${this}.debug("end")
            return ${this}.ERROR_END
        } else {
            ${this}.debug("[${logdir}] directory exists.")
        }

        # create logfile
        try{
            New-Item -Path ${logfilepath} -ItemType File -Force -ErrorAction Stop
        } catch {
            ${this}.error("Failed to create logfile.")
            ${this}.debug("end")
            return ${this}.ERROR_END
        }

        # check whether the logfile exists
        if(-not(Test-Path -Path ${logfilepath} -PathType Leaf)) {
            ${this}.error("Failed to create logfile.")
            ${this}.debug("end")
            return ${this}.ERROR_END
        }

        # set LOGFILE
        ${this}.LOGFILE=${logfilepath}
        ${this}.debug("LOGFILE = " + ${this}.LOGFILE)
        ${this}.debug("end")

        return ${this}.NORMAL_END
    }


    ############################################################################
    # open logfile
    ############################################################################
    [int]OpenLogfile([string]${logfilepath}) {
        ${this}.debug("start")

        # check log file existence
        if(-not(Test-Path -Path ${logfilepath} -PathType Leaf)) {
            ${this}.error("[${logfilepath}] file does not exist.")
            return ${this}.ERROR_END
        } else {
            ${this}.debug("end")
            ${this}.debug("[${logfilepath}] file directory exists.")
        }

        # set LOGFILE
        ${this}.LOGFILE=${logfilepath}
        ${this}.debug("LOGFILE = "+${this}.LOGFILE)
        ${this}.debug("end")

        return ${this}.NORMAL_END
    }


    ############################################################################
    # output log message
    ############################################################################
    [void]debug([string]${logmsg}) {
        ${this}.output_line(${this}.DEBUG_LEVEL, ${logmsg})
    }

    [void]info([string]${logmsg}) {
        ${this}.output_line(${this}.INFO_LEVEL , ${logmsg})
    }

    [void]warning([string]${logmsg}) {
        ${this}.output_line(${this}.WARNING_LEVEL , ${logmsg})
    }

    [void]error([string]${logmsg}) {
        ${this}.output_line(${this}.ERROR_LEVEL , ${logmsg})
    }

    [void]critical([string]${logmsg}) {
        ${this}.output_line(${this}.CRITICAL_LEVEL , ${logmsg})
    }


    ############################################################################
    # output line
    ############################################################################
    [void]output_line([int]${level}, [string]${logmsg}) {
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

            # get Script name
            ${callerscript_fullpath}=[string]${callstack}.ScriptName
            ${callerscript}=Split-Path -Path ${callerscript_fullpath} -Leaf

            # get Script line
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
