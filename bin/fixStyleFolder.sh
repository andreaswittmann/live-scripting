#!/bin/bash
#==============================================================================
#
# Template Skript zur Erstellung weitere Skripte
# Es werden folgende Merkmale implementiert:
#   -Logging Framework mit:
#      + Log Level DEBUG, INFO, WARN, ERROR
#      + Loging auf die Kommandozeile und ins Logfile
#      + ‹berlaufschutz f¸r Logfile
#   -Parameter Parsen mit getopts
#   -Usage Messages, Beschreiung des Programms
#   -Ausgage der Laufzeit am Ende des Progamms
#
# ---------------------------------------------------------------------------
# 15.07.2015 Anddreas Wittmann        Initial Version
# ---------------------------------------------------------------------------
#==============================================================================



show_usage()
{
        echo "USAGE: $0 -c <Command> -L <Loglevel>"
        echo "  [This is just a template. Insert your usage here.]"
        echo "Options:"
        echo "  -c <Command>, command are:"
        echo "    mytest - test function for this script."
        echo "    mycopy - copy the publishing dir to all subfolders."
        echo "  -d <directory>"
        echo "    directory - This is the publishing directory"
        echo "  -L <Loglevel>, sets the log level of this script.:"
        echo "    DEBUG - set logging to the finest level."
        echo "    INFO - set logging to info, which is the default."
        echo "    WARN - set logging to warn."
        echo "    DEBUG - set logging to debug."
        echo "Example:"
        echo "    $0 -c mytest -L DEBUG"
}
    
#==============================================================================
# LOGGING FRAMEWORK
#==============================================================================

# Set LOGFILE to the full path of your desired logfile; make sure
# you have write permissions there. Set RETAIN_NUM_LINES to the
# maximum number of lines that should be retained at the beginning
# of your program execution.
# Execute 'logsetup' once at the beginning of your script, then
# Available Log-Levels are DEBUG=0, INFO=1 (Default), WARNING=2, ERROR=3
# use one of the function log_debug, log_info, log_warn, log_error
# Loglevel can be set at the command line

#LOGFILE=$0.$(date +"%Y%m%d_%H%M%S").log;
LOGFILE=$0.log; 
RETAIN_NUM_LINES=100000

# LOGLEVELS: DEBUG=0, INFO=1, WARNING=2, ERROR=3 , we are setting the default to INFO
LOG_LEVEL=1

function logsetup {
    
    TMP=$(tail -n $RETAIN_NUM_LINES $LOGFILE 2>/dev/null) && echo "${TMP}" > $LOGFILE
    exec > >(tee -a $LOGFILE)
    exec 2>&1
}

function log_debug {
  if  [[ $LOG_LEVEL -le 0 ]]; then
    cur_date=$(date +"%d.%m.%Y %H:%M:%S"); echo "[${cur_date}][DEBUG]: $*"
  fi
}

function log_info {
  if  [[ $LOG_LEVEL -le 1 ]]; then
    cur_date=$(date +"%d.%m.%Y %H:%M:%S"); echo "[${cur_date}][INFO ]: $*"
  fi
}

function log_warn {
  if  [[ $LOG_LEVEL -le 2 ]]; then
    cur_date=$(date +"%d.%m.%Y %H:%M:%S"); echo "[${cur_date}][WARN ]: $*"
  fi
}

function log_error {
  if  [[ $LOG_LEVEL -le 3 ]]; then
    cur_date=$(date +"%d.%m.%Y %H:%M:%S"); echo "[${cur_date}][ERROR]: $*"
  fi
}

### test this script
mytest()
{
  log_info "Funktion test() called, testing this script!"
  log_debug "Dies ist ein DEBUG Logeintrag von: " $0
  log_info "Dies ist ein INFO Logeintrag von: " $0
  log_warn "Dies ist ein WARN Logeintrag von: " $0
  log_error "Dies ist ein ERROR Logeintrag von: " $0
  log_info "PUBLISHING_DIR ist:  " $PUBLISHING_DIR
}

#==============================================================================
# Functions of this Script
#==============================================================================

cmd01(){
  log_info "cmd01 called!"

}

cmd02(){
  log_info "cmd02 called!"

}

### copy the input folder to all levels below
mycopy()
{
    log_info "Funktion mycopy() called, with ARGUMENT: " $1
    log_info "Funktion mycopy() called, with PUBLISHING_DIR: " $PUBLISHING_DIR
    DIR_LIST=$(find $(dirname $PUBLISHING_DIR) -name "*.html")
    # strip of filename and remove dublicates
    DIR_LIST=$(echo $DIR_LIST | xargs -n1 | xargs dirname | sort -u | xargs)

    for i in $DIR_LIST; do
        mycopy_helper $PUBLISHING_DIR $i
    done
    #echo $DIR_LIST
 
}
### Helper Function that takes first argument dir and copies it to second dir.
mycopy_helper()
{
    TARGET_DIR=$1 # e.g. /var/www/html/orgweb/styles
    SOURCE_DIR=$2 # e.g /var/www/html/orgweb/live-scripting
    LINK_NAME=$(basename $TARGET_DIR) # e.g. styles
    log_info "Funktion mycopy_helper() called, with TARGET_DIR: " $TARGET_DIR
    log_info "Funktion mycopy_helper() called, with SOURCE_DIR: " $SOURCE_DIR
    log_info "Funktion mycopy_helper() called, with LINK_NAME: " $LINK_NAME

    ### Don't create link to itself.
    OMIT_DIR=$(dirname $TARGET_DIR)
    if [[ "$OMIT_DIR" != "$SOURCE_DIR" ]]; then
        cd $SOURCE_DIR
        log_info "Executing: ln -s " $LINK_NAME $TARGET_DIR
        ln -s $TARGET_DIR $LINK_NAME
    else
        log_warn "Target and Source are equal, preventing link loop! "
    fi
}


#==============================================================================
# Main Section
#===========================================================================

logsetup

# Optionen auswerten
if (( ${#} != 0 )); then
  while getopts ":c:d:L:" OPTION
  do
    case ${OPTION} in
      c)
        # command: depending on the command choose the action, which is evalutated later.
        case ${OPTARG} in
          mycopy|cmd01|cmd02|mytest)
            ACTION=${OPTARG}
            ;;
          *)
            # - falsches Argument --> usage anzeigen
            show_usage
            ;;
        esac
        ;; #command
      d)
        # directory
        export PUBLISHING_DIR=${OPTARG}
        ;;
      L)
        # Loglevel 
        case ${OPTARG} in
          DEBUG)
            LOG_LEVEL=0
            ;;
          INFO)
            LOG_LEVEL=1
            ;;
          WARN)
            LOG_LEVEL=2
            ;;
          ERROR)
            LOG_LEVEL=3
            ;;
          *)
            # Wrong log level, warn user and default to info
            log_warn "Wrong log level: ${OPTARG}, valid options are DEBUG, INFO, WARN, ERROR! Defaulting to INFO."
            LOG_LEVEL=1
            ;;
        esac # Loglevel
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
shift $(($OPTIND - 1))

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
  mycopy)
      mycopy $PUBLISHING_DIR
      ;;
esac



# Calculate Execution Time (bash built-in) and tell where the logfile is.
log_info "Execution Time: $SECONDS seconds"
log_info "Log File: $LOGFILE"
sleep 0.1
