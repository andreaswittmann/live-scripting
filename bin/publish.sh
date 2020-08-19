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
        echo "    publish - publish or update the website."
        echo "    mycopy - copy the publishing dir to all sub-folders."
        echo "  -d <directory>"
        echo "    directory - This is the publishing directory that should be linked. "
        echo "  -L <Loglevel>, sets the log level of this script.:"
        echo "    DEBUG - set logging to the finest level."
        echo "    INFO - set logging to info, which is the default."
        echo "    WARN - set logging to warn."
        echo "    DEBUG - set logging to debug."
        echo "Example:"
        echo "    $0 -c mycopy -d /var/www/html/orgweb/styles -L DEBUG"
        echo "    $0 -c mycopy -d /var/www/html/orgweb/styles"
        echo "    $0 -c publish -L DEBUG "
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


cmd02(){
  log_info "cmd02 called!"

}

### publish the projet
publish()
{
    log_debug "Function publish called."
    # publish-project t will build all the HTML files.
    log_info "running org-publish for orgweb"
    cd ~/org/live-scripting
    /snap/bin/emacs --batch --load publish-project.el --eval '(setq org-use-sub-superscripts nil )' --eval '(org-publish "orgweb" t)'

    # create the lunr index
    log_info "Createing lunr search indes"
    cd ~/lunr
    node build_index_orgweb.js
    cp lunr_index.js /var/www/html/orgweb/

    # update sitemap in index.org
    ### Extract relevant part from sitemap
    # Take only the body part
    # Take only the div bloceks
    # Cut away the first two lines
    # Cut away the last line
    cat /var/www/html/orgweb/sitemap.html  |\
        perl -ne 'print if /<body>/../<\/body>/' |\
        perl -ne 'print if /<div id=\"content\">/../<\/div>/' |\
        perl -ne 'print if ! ( $. <= 2)' |\
        perl -ne 'print if ! eof' > /tmp/sitemap.txt
    ### Insert it into index.org
    cat ~/org/index.org.template 
    cp ~/org/index.org.template ~/org/index.org
    echo "#+BEGIN_EXPORT html" >> ~/org/index.org
    cat /tmp/sitemap.txt  >> ~/org/index.org
    echo "#+END_EXPORT" >> ~/org/index.org

    # publish only index.org again which was modified.
    log_info "running org-publish for orgweb-index"
    cd ~/org/live-scripting
    /snap/bin/emacs --batch --load publish-project.el --eval '(org-publish "orgweb-index" t)'

    # sync to S3
    log_info "Syncing website to aws s3"
    export AWS_PROFILE=anwi-gmbh
    cd /var/www/html/orgweb
	  #aws s3 sync /var/www/html/orgweb s3://live-scripting --delete 
	  aws s3 sync /var/www/html/orgweb s3://orgweb --delete 
}

### copy the input folder to all levels below
mycopy()
{
    log_debug "Funktion mycopy() called, with ARGUMENT: " $1
    log_debug "Funktion mycopy() called, with PUBLISHING_DIR: " $PUBLISHING_DIR
    # We want to start the find in the web root. This is one dir before the styles directory.
    # E.g. /var/www/html/orgweg
    WEB_ROOT=$(dirname $PUBLISHING_DIR)
    ## clean all links first
    log_debug "Deleting Links: " $(find $WEB_ROOT -type l)
    find ${WEB_ROOT} -type l -exec rm {} \;

    # The styles folder is required in all dirs containing html files.
    DIR_LIST=$(find $WEB_ROOT -name "*.html")
    # strip of filename and remove dublicates
    DIR_LIST=$(echo $DIR_LIST | xargs -n1 | xargs dirname | sort -u | xargs)

    echo $DIR_LIST
    for i in $DIR_LIST; do
        mycopy_helper $PUBLISHING_DIR $i
    done
 
}
### Helper Function that copies the SOURCE_DIR to the TARGET_DIR using rsync.
mycopy_helper()
{
    export SOURCE_DIR=$1 # e.g. /var/www/html/orgweb/styles
    export TARGET_DIR=$2 # e.g /var/www/html/orgweb/live-scripting
    LINK_NAME=$(basename $TARGET_DIR) # e.g. styles
    log_debug "Funktion mycopy_helper() called, with TARGET_DIR: " $TARGET_DIR
    log_debug "Funktion mycopy_helper() called, with SOURCE_DIR: " $SOURCE_DIR
    log_debug "Funktion mycopy_helper() called, with LINK_NAME: " $LINK_NAME

    ### Don't copy into self. i.e. don't make SOURCE_DIR the TARGET_DIR
    OMIT_DIR=$(dirname $SOURCE_DIR)
    log_debug "Funktion mycopy_helper() called, with OMIT_DIR: " $OMIT_DIR

    cd $OMIT_DIR
    if [[ "$OMIT_DIR" != "$TARGET_DIR" ]]; then
        # create symbolic links
        log_debug "pwd " $(pwd)
        log_info "Executing: rsync -av --delete " $SOURCE_DIR $TARGET_DIR
        #rsync -av --delete --dry-run  $SOURCE_DIR $TARGET_DIR
        rsync -av --delete  $SOURCE_DIR $TARGET_DIR
    else
        log_warn "Target and Source are equal, preventing copy to self! "
    fi

}
### Helper Function that makes relatives links. TARGET_DIR must be sub-path of SOURCE_DIR
### This function creates relative symlinks to the TARGET_DIR
mycopy_helper_symlinks()
{
    export TARGET_DIR=$1 # e.g. /var/www/html/orgweb/styles
    export SOURCE_DIR=$2 # e.g /var/www/html/orgweb/live-scripting
    LINK_NAME=$(basename $TARGET_DIR) # e.g. styles
    log_debug "Funktion mycopy_helper() called, with TARGET_DIR: " $1
    log_debug "Funktion mycopy_helper() called, with TARGET_DIR: " $TARGET_DIR
    log_debug "Funktion mycopy_helper() called, with SOURCE_DIR: " $2
    log_debug "Funktion mycopy_helper() called, with SOURCE_DIR: " $SOURCE_DIR
    log_debug "Funktion mycopy_helper() called, with LINK_NAME: " $LINK_NAME

    ### Don't create link to itself.
    OMIT_DIR=$(dirname $TARGET_DIR)
    cd $OMIT_DIR
    if [[ "$OMIT_DIR" != "$SOURCE_DIR" ]]; then
        log_info "cd   $SOURCE_DIR"
        cd $SOURCE_DIR
        # convert absolute path in relative path
        # e.g /var/www/html/orgweb/styles becomes ../../styles  if we are 2 levels deeper down in the directory
        TARGET_DIR=$(realpath --relative-to=. $OMIT_DIR)/$LINK_NAME
        cd $SOURCE_DIR
        # create symbolic links
        log_info "pwd " $(pwd)
        log_info "Executing: ln -s " $TARGET_DIR $LINK_NAME
        ln -s $TARGET_DIR $LINK_NAME
    else
        log_warn "Target and Source are equal, preventing link loop! "
    fi
    log_debug "Restting Vars!"
    export TARGET_DIR=
    export SOURCE_DIR=

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
          mycopy|publish|cmd02|mytest)
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
  publish)
    publish
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
