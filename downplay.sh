#!/bin/bash
# downplay.sh
# Version 1.0
# Script Author: Tay Kratzer tay@cimitra.com
# This script uses long variable names to make them self-documenting
# This script is free as in free to anyone, free to change, etc.
# This script was made to download and/or play sound files
# The script can keep and rename sound files if desired
# Sound files are retrieved from a URL

# ------------------------------------------ #
# MAKE CHANGES IN THIS AREA TO MATCH YOUR LINUX SYSTEM
#These are the players on a Raspberry Pi 
#Change these variables to match the players on your Linux host
# Raspberry Pi
# Plays MP3s and WAV
MP3_PLAYER="omxplayer"
WAV_PLAYER="aplay"

# ChromeOS
# Plays WAV
#WAV_PLAYER="aplay"

# MacOS
# Plays MP3s
#MP3_PLAYER="afplay" 


# Change the AUDIO_FILES location to your own preference 

AUDIO_FILES="/cimitra/audio/"
declare -i ALLOW_MP3S_AND_WAVS_TO_PLAY_SIMULTANEOUSLY=1

# ------------------------------------------ #



declare -i PLAY_DOWNLOADED_FILE_IMMEDIATELY=0
declare -i SAVE_FILE=0
declare -i PARAMETERS_PASSED=0
declare -i RUN_FUNCTION=0

# <The while/getopts routine allow for passing variables to the script>

while getopts "f:n:psr:a:b:c:" opt;do
case ${opt} in
a) FUNCTION_ARGURMENT_ONE=$OPTARG
;;
b) FUNCTION_ARGURMENT_TWO=$OPTARG
;;
c) FUNCTION_ARGURMENT_THREE=$OPTARG
;;
f) FILE_URL=$OPTARG
FILE_NAME=`basename ${FILE_URL}`
PARAMETERS_PASSED=1
;;
n) NEW_FILE_NAME=$OPTARG
SAVE_FILE=1
PARAMETERS_PASSED=1
;;
p) 
PLAY_DOWNLOADED_FILE_IMMEDIATELY=1
PARAMETERS_PASSED=1
;;
r)
PARAMETERS_PASSED=1
FUNCTION_TO_RUN=$OPTARG
RUN_FUNCTION=1
;;
s)
PARAMETERS_PASSED=1
RUN_FUNCTION=1
FUNCTION_TO_RUN="stop_play"
;;
esac 
done



sudo mkdir -p ${AUDIO_FILES} 2> /dev/null

function stop_mp3_player()
{

declare -i PLAYER_IN_MEMORY=`ps -eaf | grep -v "grep" | grep -c "${MP3_PLAYER}"`

while [ ${PLAYER_IN_MEMORY} -gt 0 ]
do
        
        PLAYER_PID=`ps -eaf | grep -v "grep" | grep "${MP3_PLAYER}" | tail -1 | awk '{print $2}'`
        echo "Stop MP3 Player ${PLAYER_PID}"
	sudo kill -9 ${PLAYER_PID}
        RETVAL=$?
	sleep 1
	PLAYER_IN_MEMORY=`ps -eaf | grep -v "grep" | grep -c "${MP3_PLAYER}"`
done

}


function stop_wav_player()
{

declare -i PLAYER_IN_MEMORY=`ps -eaf | grep -v "grep" | grep -c "${WAV_PLAYER}"`

while [ ${PLAYER_IN_MEMORY} -gt 0 ]
do
        
        PLAYER_PID=`ps -eaf | grep -v "grep" | grep "${WAV_PLAYER}" | tail -1 | awk '{print $2}'`
	echo "Stop WAV Player ${PLAYER_PID}"
	sudo kill -9 ${PLAYER_PID}
        RETVAL=$?
	sleep 1
	PLAYER_IN_MEMORY=`ps -eaf | grep -v "grep" | grep -c "${WAV_PLAYER}"`
done

}





function stop_player()
{
AUDIO_FILE_TYPE=$1

case ${AUDIO_FILE_TYPE} in
mp3)

	if [ $ALLOW_MP3S_AND_WAVS_TO_PLAY_SIMULTANEOUSLY -eq 1 ]
	then
		stop_mp3_player
	else
		stop_wav_player
		stop_mp3_player
	fi
;;


wav)

	if [ $ALLOW_MP3S_AND_WAVS_TO_PLAY_SIMULTANEOUSLY -eq 1 ]
	then
		stop_wav_player
	else
		stop_mp3_player
		stop_wav_player
	fi
;;

esac
}

function stop_play()
{
stop_player "mp3"
stop_player "wav"
}

function start_mp3_player()
{

MP3_FILE_IN=$1

declare -i MP3_FILE_IN_EXISTS=`test -f ${MP3_FILE_IN}`

if [ ${MP3_FILE_IN_EXISTS} -eq 0 ]
then
	stop_player "mp3"
	sudo ${MP3_PLAYER} ${MP3_FILE_IN}
fi

}

function start_wav_player()
{

WAV_FILE_IN=$1

declare -i WAV_FILE_IN_EXISTS=`test -f ${WAV_FILE_IN}`

if [ ${WAV_FILE_IN_EXISTS} -eq 0 ]
then
	stop_player "wav"
	sudo ${WAV_PLAYER} ${WAV_FILE_IN}
fi

}




if [ $PARAMETERS_PASSED -gt 0 ]
then
:
else
exit 0
fi

function list_audio_files()
{

cd ${AUDIO_FILES}

GOT_IN_AUDIO_FILES=`echo $?`

if [ $GOT_IN_AUDIO_FILES -ne 0 ]
then
echo "[ERROR] Could not access location: ${AUDIO_FILES}"
exit 1
fi
echo "-------------------------------"
ls -1 | nl
echo "-------------------------------"

}

function remove_audio_files_by_number()
{

cd ${AUDIO_FILES}

GOT_IN_AUDIO_FILES=`echo $?`

if [ $GOT_IN_AUDIO_FILES -ne 0 ]
then
echo "[ERROR] Could not access location: ${AUDIO_FILES}"
exit 1
fi



if [ -z "$FUNCTION_ARGURMENT_ONE" ]
then
      echo "Pass -a variable with the file number" 
      exit 1
fi

if [ -n "$FUNCTION_ARGURMENT_ONE" ] && [ "$FUNCTION_ARGURMENT_ONE" -eq "$FUNCTION_ARGURMENT_ONE" ] 2>/dev/null; 
then
:
else
  echo "[ERROR] Pass a file number, you passed: ${FUNCTION_ARGURMENT_ONE}" 
  exit 1
fi

FILE_TO_DELETE=`ls -1 | head -${FUNCTION_ARGURMENT_ONE} | tail -1`
echo "-------------------------------"
sudo rm -v ${FILE_TO_DELETE}
echo "-------------------------------"
list_audio_files
}

function remove_all_audio_files()
{

cd ${AUDIO_FILES}

GOT_IN_AUDIO_FILES=`echo $?`

if [ $GOT_IN_AUDIO_FILES -ne 0 ]
then
echo "[ERROR] Could not access location: ${AUDIO_FILES}"
exit 1
fi

rm -v ./*.mp3 

rm -v ./*.wav

list_audio_files

}

function main()
{

declare -i GOT_IN_AUDIO_FILES=1

cd ${AUDIO_FILES}

GOT_IN_AUDIO_FILES=`echo $?`

if [ $GOT_IN_AUDIO_FILES -ne 0 ]
then
echo "[ERROR] Could not access location: ${AUDIO_FILES}"
exit 1
fi

if [[ ${FILE_URL} =~ "http" ]]
then
:
else
declare -i AUDIO_FILE_ALREADY_EXISTS=`sudo test -f ${AUDIO_FILES}${FILE_URL} && echo 0 || echo 1`



	if [ $AUDIO_FILE_ALREADY_EXISTS -eq 0 ]
	then
	
		declare -i AUDIO_FILE_IS_MP3=`echo "${FILE_URL}" | grep -c ".mp3"`

		if [ $AUDIO_FILE_IS_MP3 -gt 0 ]
		then
		start_mp3_player "${AUDIO_FILES}${FILE_URL}"
		exit 0
		fi

		declare -i AUDIO_FILE_IS_WAV=`echo "${FILE_URL}" | grep -c ".wav"`

		if [ $AUDIO_FILE_IS_WAV -gt 0 ]
		then
		start_wav_player "${AUDIO_FILES}${FILE_URL}"
		exit 0
		fi

	fi

	declare -i FILE_ALREADY_EXISTS_AS_MP3=`test -f ${AUDIO_FILES}${FILE_URL}.mp3 ; echo $?`

	if [ $FILE_ALREADY_EXISTS_AS_MP3 -eq 0 ]
	then
	start_mp3_player "${AUDIO_FILES}${FILE_URL}.mp3"
	exit 0
	fi

	declare -i FILE_ALREADY_EXISTS_AS_WAV=`test -f ${AUDIO_FILES}${FILE_URL}.wav ; echo $?`
	if [ $FILE_ALREADY_EXISTS_AS_WAV -eq 0 ]
	then
	start_wav_player "${AUDIO_FILES}${FILE_URL}.wav"
	exit 0
	fi

fi


# Make the filename lowercase always
NEW_FILE_NAME=`echo "${NEW_FILE_NAME}" | tr [A-Z] [a-z]`

declare -i NEW_FILE_NAME_CONTAINS_MP3=`echo "${NEW_FILE_NAME}" | grep -c ".mp3"`
declare -i NEW_FILE_NAME_CONTAINS_WAV=`echo "${NEW_FILE_NAME}" | grep -c ".wav"`

# This parses the final name of the file from the URL passed in
AUDIO_FILE_EXTENSION=`basename ${FILE_URL}`

# echo "AUDIO_FILE_EXTENSION = $AUDIO_FILE_EXTENSION"

# Determine if the file is MP3 or WAV
declare -i AUDIO_FILE_EXTENSION_IS_MP3=`echo "${AUDIO_FILE_EXTENSION}" | grep -ic ".mp3"`
declare -i AUDIO_FILE_EXTENSION_IS_WAV=`echo "${AUDIO_FILE_EXTENSION}" | grep -ic ".wav"`

# echo "AUDIO_FILE_EXTENSION_IS_MP3 = $AUDIO_FILE_EXTENSION_IS_MP3"

if [ ${AUDIO_FILE_EXTENSION_IS_MP3} -eq 1 ]
then
	if [ $SAVE_FILE -eq 1 ]
	then

		if [ $NEW_FILE_NAME_CONTAINS_WAV -eq 1 ]
		then
		echo "[ERROR] saving a file that is not an WAV as .wav is not going to work"
		exit 1
		fi
	
	fi

	if [ $SAVE_FILE -eq 1 ]
	then
	# Test and see if the filename has .mp3, if not, append .mp3 to the filename
	[[ ${NEW_FILE_NAME} == *.mp3* ]] || NEW_FILE_NAME=${NEW_FILE_NAME}.mp3
	# Download the MP3 file and save it to the filename specified
	sudo curl ${FILE_URL} -o ${NEW_FILE_NAME}
	list_audio_files
	exit 0
	else
	# Download the MP3 file, play it and then delete it
	sudo curl ${FILE_URL} -o ${FILE_NAME}
	start_mp3_player "${AUDIO_FILES}${FILE_NAME}" && sudo rm ${AUDIO_FILES}${FILE_NAME}
	exit 0
	fi
fi


if [ ${AUDIO_FILE_EXTENSION_IS_WAV} -eq 1 ]
then

	if [ $SAVE_FILE -eq 1 ]
	then

		if [ $NEW_FILE_NAME_CONTAINS_MP3 -eq 1 ]
		then
		echo "[ERROR] saving a file that is not an MP3 as .mp3 is not going to work"
		exit 1
		fi

	fi

	if [ $SAVE_FILE -eq 1 ]
	then
	# Test and see if the filename has .wav, if not, append .wav to the filename
	[[ ${NEW_FILE_NAME} == *.wav* ]] || NEW_FILE_NAME=${NEW_FILE_NAME}.wav
	# Download the WAV file and save it to the filename specified
	sudo curl ${FILE_URL} -o ${NEW_FILE_NAME}
	list_audio_files
	exit 0
	else
	# Download the WAV file, play it and then delete it
	sudo curl ${FILE_URL} -o ${FILE_NAME}
	start_wav_player "${AUDIO_FILES}${FILE_NAME}" && sudo rm ${AUDIO_FILES}${FILE_NAME}
	exit 0
	fi
fi
}







if [ $RUN_FUNCTION -eq 0 ]
then
main
else
${FUNCTION_TO_RUN}
fi
