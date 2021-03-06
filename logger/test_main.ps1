﻿################################################################################
# This software is released under the MIT License see LICENSE.txt
# Filename : test_main.ps1
# Overview : test script for logger.ps1
# HowToUse : powershell -file test_main.ps1
#-------------------------------------------------------------------------------
# Author: Isaac Factory (sir.isaac.factory@icloud.com)
# Repository: https://github.com/SirIsaacFactory/PowerShellLibs
# Date: 2021/02/09
# Code version: v1.00
################################################################################

################################################################################
# Define variables
################################################################################
${shelldir}   = (Split-Path -Path ${MyInvocation}.MyCommand.Path -Parent)
${logbase}    = [System.IO.Path]::GetFileNameWithoutExtension(${MyInvocation}.MyCommand.Path)
${logfile}    = Join-Path -Path ${shelldir} -ChildPath "${logbase}.log"
${normal_end} = ${True}
${error_end}  = ${False}


################################################################################
# Initialise
################################################################################
. ${shelldir}\logger.ps1
${logger} = New-Object Logger
${logger}.SetDebugLevel()
# ${ret} = ${logger}.CreateLogFile(${logfile})
${ret} = ${logger}.OpenLogFile(${logfile})


################################################################################
# Define displayArgs
################################################################################
function displayArgs([array]${cmdOptions}) {
    ${logger}.debug("start")

    ${logger}.info("The command-line options are as below:")
    foreach(${opt} in ${cmdOptions}) {
        ${logger}.info("${opt}")
    }

    ${logger}.debug("end")
}

################################################################################
# Define main
################################################################################
function main([array]${cmdOptions}) {
    ${logger}.debug("start")

    ${optCount} = ${cmdOptions}.Length
    if(${optCount} -eq 0) {
        ${logger}.error("There are no command-line options.")
        return ${error_end}
    } else {
        ${logger}.info("The number of command-line options is ${optCount}.")
    }

    displayArgs -cmdOptions ${cmdOPtions}

    
    ${logger}.debug("end")
    return ${normal_end}
}

################################################################################
# Execute main
################################################################################
${ret} = main -cmdOptions ${args}
exit ${ret}
