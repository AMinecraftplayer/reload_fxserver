#!/bin/bash
# Edited/Modifyed/Created by OskyEdz
# I've collected some of the best parts of scripts I could find on the topic...
#
# NOTES: 
# This script use "case ... esac with IF THEN ELSE statements" If unsure about "case ... esac" read this: 
# https://www.tutorialspoint.com/unix/case-esac-statement.htm
# With example here from Minecraft...:
# https://minecraft.gamepedia.com/Tutorials/Server_startup_script#Download
# Imortant file structure is to have the varibles in order because the are dependent of eachother...

# Colors t output to terminal (because fancy logging matters a little more)
  WHITE="\033[0;39m"
  RED="\033[1;31m"
  GREEN="\033[1;32m"
  ORANGE="\033[1;33m"
  PURPLE="\033[1;35m"

# Messages to send in-game of FiveM server (In Swedish, cuz Swedish server...use Google translate, that's what I use from French...)
  MSG_180="En storm är påväg, innom 3 minuter kommer staden att blåsa bort!"
  MSG_60="Stormen är vid stadens portar, ni måste fly nu i sista minuten!"
  MSG_30="Hallå !! Om 30 sekunder kommer ni alla att dö om ni inte flyr!"
  MSG_10="Manuell avstägning om 10 sekunder! Skriv följande i F8: quit"

# PATH
  HOME=/home/esx_server               # Home directory of server user
  BUPS=$HOME/backups                  # Dir of backups
  SRV=$HOME/server                    # Dir of server folders
  DATA=$SRV/data                      # Dir of server data folders
  RES=$DATA/resources                 # Dir of server data resources folder 

# Backups
  DAYS_DAILY=14     # Days to wait to remove oldest daily backup
  DAYS_WEEKLY=42    # Days to wait to remove oldest weekly backup
  DAYS_MONTHLY=365  # Days to wait to remove oldest monthly backup
  DAYS_YEARLY=1460  # Days to wait to remove oldest yearly backup

  PCITY=$2  # The PERIODICITY of when to save backups.
  ExcludeDatabases="Database|information_schema|performance_schema|mysql|phpmyadmin" 
  # Specify ALL databases regardless of permission level. Database,information_schema,performance_schema,mysql Are required. And should not be backed up by your game server user.

# Script
  SCRIPT="./reload_fxserver.sh"       # This file
  CONF=$HOME/fxserver_screen.conf     # Configuration file for screens (perhaps moving to this file?)

#SCNAME
  SCNAME=fiveM                          # Just a name for the screen
  SCRN="screen -c $CONF -rL $SCNAME -X" # Standard exection for screens in this script

#OTHER
  DATE="`date '+%Y-%m-%d_%H:%M:%S'`"  # Date of right now
  BOT="\033[1;36m BOT:" # Simply the text "BOT:" in blue that I use before every command  

# -----------------[ Active screen? ]----------------- #
running(){    
  if ! screen -list | grep -q "$SCNAME" # Will not output if your screen is running
  then
    echo -e "$BOT$RED No screen active..."
    echo -e ""
    return 1
  else
    echo -e ""
    return 0
  fi
}
# -----------------[ Start ]----------------- #
start() {
  if ( running ) 
  then 
    echo -e "$BOT$RED FiveM server alread active!"
    echo -e ""
    echo -e "$BOT$PURPLE Stop server first: $ORANGE $SCRIPT stop"
    echo -e "$BOT$WHITE OR"
    echo -e "$BOT$PURPLE Restart server:    $ORANGE $SCRIPT restart"
  sleep 1
  else
    echo -e "$BOT$WHITE Booting FiveM server..."
      screen -c $CONF -dmSL $SCNAME 
    echo -e "$BOT$WHITE $SCNAME screen opend."
  sleep 2
      $SCRN screen bash -c "cd \"$DATA\" && \"$SRV\"/run.sh +exec server.cfg" 
      # Server startup command. Treid to make another variable here but failed to run the server and just open another screen in a screen and bunvh of formatting headace...
  sleep 2
    echo -e "$BOT$GREEN Server has booted!"
    echo -e "$BOT$GREEN Open screen with:$ORANGE screen -r$WHITE"
  sleep 1
  fi
}
# -----------------[ Stop ]------------------ #
stop() {
  if ( running ) 
  then
		echo -e "$BOT$WHITE Stopping FiveM server..."
    messages      # Calling messages function lower down, with configurable messages at the top.
		  $SCRN quit  # Sending Quit to screen 
		echo -e "$BOT$WHITE Server has stopped."
  sleep 1
	else
	  echo -e "$BOT$RED FiveM server is off."
    echo -e ""
    echo -e "$BOT$PURPLE USE: $ORANGE $SCRIPT start$WHITE" 
  sleep 1
	fi
}
# -----------------[ Status ]---------------- #
status() {
	if ( running ) 
  then
	  echo -e "$GREEN [$SCNAME] is active.$WHITE"
	else
	  echo -e "$RED [$SCNAME] is down.$WHITE"
	fi
}
# ----------------[ Restart ]---------------- #
restart() {
	if ( running ) 
  then
	  echo -e "$BOT$WHITE FiveM server is running, stopping..."
  sleep 2
    stop
    logfiles
    start
	else
	  echo -e "$BOT$GREEN FiveM server is off, starting..."
  sleep 5
    logfiles
    start
	fi
}
# ----------------[ Restart Now ]---------------- #
restartnow() {
	if ( running ) 
  then
	  echo -e "$BOT$WHITE FiveM server is already active!"
  sleep 5
    stopnow
    logfiles
    start
	else
	  echo -e "$BOT$GREEN FiveM server is off."
  sleep 5
    logfiles
    start
	fi
}
# -----------------[ Stop Now ]------------------ #
stopnow() {
	if ( running ) 
  then
		echo -e "$BOT$WHITE Stop FiveM server..."
    echo -e "$BOT$WHITE Server will stop NOW."
		  $SCRN quit
		echo -e "$BOT$WHITE Server has stopped."
	sleep 1
  else
	  echo -e "$BOT$RED FiveM server is not active."
    echo -e ""
    echo -e "$BOT$PURPLE USE: $ORANGE $SCRIPT start.$WHITE" 
  sleep 1
	fi
}
# -----------------[ Stop Messages ]------------------ #
messages() {
    echo -e "$BOT$WHITE Server reboots in 3 min... "
		  $SCRN stuff "say $MSG_180
      "; sleep 180
    echo -e "$BOT$WHITE Server reboots in 1 min... "
		  $SCRN stuff "say $MSG_60
      "; sleep 60
    echo -e "$BOT$WHITE Server reboots in 30 sec... "
		  $SCRN stuff "say $MSG_30
      "; sleep 30
}
# ----------------[ Logfiles ]---------------- #
logfiles() {
    echo -e "$BOT$ORANGE Removing old logfiles..."
      find $DATA/log/* -mtime +14 rm {} \; >>/dev/null 2>&1 #14 days
    sleep 1
    echo -e "$BOT$ORANGE Removing old backups (databases and games files)..."
      find $BUPS/daily/* -mtime +$DAYS_DAILY rm {} \; >>/dev/null 2>&1
      find $BUPS/weekly/* -mtime +$DAYS_WEEKLY rm {} \; >>/dev/null 2>&1
      find $BUPS/monthly/* -mtime +$DAYS_MONTHLY rm {} \; >>/dev/null 2>&1
      find $BUPS/yearly/* -mtime +$DAYS_YEARLY rm {} \; >>/dev/null 2>&1
    sleep 1
}
# ----------------[ Backups ]---------------- #
# This part is mostly copy-pasted and works depnding on a thew things:
# ExcludeDatabases - variable set in the begining YOU have to list ALL your databases as this will throw errors if access is denied.
# You have to create .env file seperatly with your database login (You should NOT put login information in this file.)
# 

# Check if argument is passed
backup() {
  if [ -z "$PCITY" ]
  then 
    echo -e "$ORANGE USE:$WHITE $0 $1 {daily|weekly|monthly|yearly|whatever (create a periodicity of your choosing)}"
    exit 1
  fi

# Create backup periode folder
  if [ -d "${BUPS}/${PCITY}" ]
  then
    echo -e "$BOT$WHITE Folder exist."
  else
      mkdir ${BUPS}/${PCITY}
  fi

# Create db backups 
# Get backup users credentials
  source $BUPS/.env
  databases=`mysql -u ${MYSQL_USER} -p${MYSQL_PASS} -e "SHOW DATABASES;" | tr -d "| " | egrep -v $ExcludeDatabases`
    echo -e "$BOT$WHITE Dumping databases to file."

  for db in $databases; do
    if [[ "$db" != _* ]] ; 
    then
      echo -e "$BOT$WHITEDumping database: $db"
        mysqldump -u ${MYSQL_USER} -p${MYSQL_PASS} --databases $db | gzip > ${BUPS}/${PCITY}/${DATE}.$db.sql.gz 
    fi
  done

# Create game server backups
  BUP=${BUPS}/${PCITY}/${DATE}_resources  # cuz lazy..
# Copy game files in resources (to backup folder), then compress with tar to backups folder.
    echo -e "$BOT$WHITE Copying file from server to backup and then tar + gzip..."
      cp -r $RES $BUP && tar -cpzf $BUP.tar.gz $BUP >>/dev/null 2>&1
      rm -r $BUP
    echo -e "$BOT$WHITE All done!$WHITE"
}

#Start-Stop here
# I like this format more, makes it possible to "call" functions from whereever in the script.
 case "$1" in
   start)
     start
     ;;
   stop)
     stop
     ;;
   status)
     status
     ;;
   restart)
     restart
     ;;
   stopnow)
     stopnow
     ;;
   restartnow)
     restartnow
     ;;
    backup)
      logfiles
      backup
     ;;
	*)
    echo -e "$ORANGE USE :$WHITE $0 {start|stop|status|restart|backup [daily|weekly|monthly|yearly|whatever (create a periodicity of your choosing)]}"
    echo -e "$BOT$WHITE You can also use $0 {stopnow|restartnow}  Used for skipping the 3 min stop time.$WHITE"
    exit 1
;;
esac

exit 0
