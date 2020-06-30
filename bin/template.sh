#!/bin/bash
#==============================================================================
#
# Template Skript zur Erstellung weitere Skripte.
# Dieses Skript demonstriert die Verwendung von lib_logging.sh
# Es werden folgende Merkmale implementiert:
#   -Logging Framework mit:
#      + Log Level DEBUG, INFO, WARN, ERROR
#      + Loging auf die Kommandozeile und ins Logfile
#      + Ueberlaufschutz für Logfile
#   -Parameter Parsen mit getopts
#   -Usage Messages, Beschreiung des Programms
#   -Ausgage der Laufzeit am Ende des Progamms
#
# ---------------------------------------------------------------------------
# 15.07.2015 Anddreas Wittmann        Initial Version
# ---------------------------------------------------------------------------
#==============================================================================




#
# - sourcen der Shell-Lib
#

. ${WLST_LIB_SHELL_LIB_DIR}/include_all.ksh



show_usage()
{
        echo "USAGE: $0 -c <Command> -L <Loglevel>"
        echo "  [This is just a template. Insert your usage here.]"
        echo "Options:"
        echo "  -c <Command>, command are:"
        echo "    mytest - test function for this script."
        echo "  -L <Loglevel>, sets the log level of this script.:"
        echo "    DEBUG - set logging to the finest level."
        echo "    INFO - set logging to info, which is the default."
        echo "    WARN - set logging to warn."
        echo "    ERROR - set logging to error."
        echo "Example:"
        echo "    $0 -c mytest -L DEBUG"
}
    




#==============================================================================
# Functions of this Script
#==============================================================================


################################################################################
# - test function to demonstrate logging framework.
#   REPLACE THIS FUNCTION WITH YOUR CODE!
#
# - parameters
#     none
#
# - return code
#   - 0: ok
#   - 1: failed

################################################################################
mytest()
{
  log_info "mytest: Funktion mytest() called, testing this script!"
  log_debug "mytest: Dies ist ein DEBUG Logeintrag von: " $0
  log_info "mytest: Dies ist ein INFO Logeintrag von: " $0
  log_warn "mytest: Dies ist ein WARN Logeintrag von: " $0
  log_error "mytest: Dies ist ein ERROR Logeintrag von: " $0
  return 0
}




################################################################################
# - placeholder function.
#   REPLACE THIS FUNCTION WITH YOUR CODE!
#
# - parameters
#     none
#
# - return code
#   - 0: ok
#   - 1: failed

################################################################################

cmd01()
{
  log_info "cmd01 called!"
  return 0

}

cmd02()
{
  log_info "cmd02 called!"
  return 0
}


#==============================================================================
# Main Section
#===========================================================================

# Initialize Logging
LOG_RETAIN_NUM_LINES=1000000
LOG_FILE=${LOG_PATH}/$(basename $0).log
LOG_LEVEL="INFO"
logsetup

# Optionen auswerten
if (( ${#} != 0 )); then
  while getopts ":c:L:" OPTION
  do
    case ${OPTION} in
      c)
        # command: depending on the command choose the action, which is evalutated later.
        case ${OPTARG} in
          cmd01|cmd02|mytest)
            ACTION=${OPTARG}
            ;;
          *)
            # - falsches Argument --> usage anzeigen
            show_usage
            ;;
        esac
        ;; #command
      L)
        # Loglevel 
        # We initialize the LOG_LEVEL
        set_LOG_LEVEL ${OPTARG} 
        if [ $? != 0 ] ; then
          # In case of invalid log levels we warn the user.
          # Valid options are defined in lib_logging.sh. 
          log_warn "Wrong log level: ${OPTARG}, valid options are ${LOG_LEVEL_LIST}! Defaulting to INFO."
          set_LOG_LEVEL "INFO";          
        fi
        ;;
      *)
        show_usage
        ;;
    esac
  done
else
  show_usage
fi

# Optionen und zugehoerige Argumente shiften
shift $((${OPTIND} - 1))

# es sind keine Argumente erlaubt, die nicht zu einer Option gehoeren
if (( ${#} != 0 )); then
  show_usage
fi

# Execute command.
case ${ACTION} in
  cmd01)
    cmd01
    ;;
  cmd02)
    cmd02
    ;;
  mytest)
    mytest
    ;;
esac


# Calculate Execution Time (bash built-in) and tell where the logfile is.
log_info "Execution Time: ${SECONDS} seconds"
log_info "Log File: ${LOG_FILE}"
