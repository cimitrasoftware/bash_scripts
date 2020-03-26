#!/bin/bash
# VERBOSE MODE ON = 1
#--------------------
declare -i VERBOSE=1
#--------------------

# This is a file for communicating between PowerShell and Bash
IO_FILE="/mnt/c/linwin/io.txt"

# Convert the file from a DOS ASCII file to a Linux ASCII file
sed -i 's/.$//' ${IO_FILE}

# This is the function for properly exiting the Bash script
function CALL_EXIT()
{
# Get the first parameter passed to the function assign it to "EXIT_CODE"
EXIT_CODE=$1

if [ $EXIT_CODE == 0 ]
then
echo "0" > ${IO_FILE}
else
echo "1" > ${IO_FILE}
fi

if [ $VERBOSE -eq 1 ]
then

	if [ $EXIT_CODE == 0 ]
	then
	echo "Success"
	else
	echo "Failed"
	fi
fi

exit $EXIT_CODE
}

# This is the main function
function main()
{

SERVER_ADDRESS="bogus"
SERVER_PORT="bogus"

# Read in the contents of the IO_FILE
source ${IO_FILE}

# Test to see if a "SERVER_ADDRESS" variable is in the IO_FILE
if [ $SERVER_ADDRESS == "bogus" ]
then
CALL_EXIT "1"
fi

# Test to see if a "SERVER_PORT" variable is in the IO_FILE
if [ $SERVER_PORT == "bogus" ]
then
CALL_EXIT "1"
fi

if [ $VERBOSE -eq 1 ]
then
echo "Server Address: ${SERVER_ADDRESS}"
echo "Server Port: ${SERVER_PORT}"
fi

# I found this gem on the Internet :)
cat < /dev/tcp/${SERVER_ADDRESS}/${SERVER_PORT} & 

# Get the PID of the "cat" command 
CONNECTION_PROCESS=$!

# See if the "cat" command remains in memory few at least a few seconds 
declare -i CONNECTION_PROCESS_WORKED=`ps -aux | grep "${CONNECTION_PROCESS}" | grep -c "cat"`

if [ $CONNECTION_PROCESS_WORKED -gt 0 ]
then
CALL_EXIT 0
else
CALL_EXIT 1
fi
}

# Call the main function
main
