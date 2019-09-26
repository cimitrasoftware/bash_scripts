#!/bin/bash

declare -i SEARCH_FUNCTION=0
declare -i REMOVE_FUNCTION=0
declare -i LAST_NAME_SEARCH=0
declare -i FIRST_NAME_SEARCH=0
declare -i SEARCH_RECORD_FUNCTION=0
declare -i DELETE_FUNCTION=0
declare -i ACTIVATE_FUNCTION=0
declare -i DEACTIVATE_FUNCTION=0
declare -i CARD_QUERY_FUNCTION=0
declare -i PASSWORD_GET=0
declare -i PASSWORD_UPDATE=0


while getopts "sl:f:r:daecp:gu" opt; do
  case $opt in
    l) LAST_NAME_SEARCH_STRING="$OPTARG"
       LAST_NAME_SEARCH=1
       let SEARCH_FUNCTION=SEARCH_FUNCTION+1
    ;;
    f) FIRST_NAME_SEARCH_STRING="$OPTARG"
       FIRST_NAME_SEARCH=1
       let SEARCH_FUNCTION=SEARCH_FUNCTION+1
    ;;
    r) RECORD_NUMBER="$OPTARG"
    ;;
    p) PASSWORD_IN="$OPTARG"
    ;;
    s) SEARCH_RECORD_FUNCTION=1
    ;;
    d) 	DELETE_FUNCTION=1
    ;;
    a)  ACTIVATE_FUNCTION=1
    ;;
    e)  DEACTIVATE_FUNCTION=1
    ;;
    c)  CARD_QUERY_FUNCTION=1
    ;;
    g)  PASSWORD_GET=1
    ;;
    u)  PASSWORD_UPDATE=1
    ;;




  esac
done




DB_NAME="employees"
DB_USER="root"
DB_PASSWORD="passnotell123"
DB_TABLE="employees"
TMP_DIR="/tmp"
TMP_FILE="${TMP_DIR}/$$.txt.${RANDOM}.tmp"
TMP_FILE_TWO="${TMP_DIR}/$$.txt.${RANDOM}.${RANDOM}.tmp"

function search_record()
{
mysql -u root -ppassnotell123 employees -e "SELECT emp_no,first_name,last_name INTO OUTFILE '${TMP_FILE}' FROM employees WHERE emp_no = '${RECORD_NUMBER}'";
echo "----------------------------------"
echo ""
cat ${TMP_FILE}
echo ""
echo "----------------------------------"

rm ${TMP_FILE} 2> /dev/null
}

function delete_record()
{
mysql -u root -ppassnotell123 employees -e "SELECT emp_no,first_name,last_name INTO OUTFILE '${TMP_FILE}' FROM employees WHERE emp_no = '${RECORD_NUMBER}'";

declare -i USER_DELETED=`grep -c "${RECORD_NUMBER}" ${TMP_FILE}`
if [ $USER_DELETED -eq 1 ]
then
echo "----------------------------------"
mysql -u root -ppassnotell123 employees -e "DELETE FROM employees WHERE emp_no = '${RECORD_NUMBER}'";
echo "User Deleted"
echo ""
cat ${TMP_FILE}
echo "----------------------------------"
else
echo "----------------------------------"
echo "Requested User Not Found"
echo "----------------------------------"
fi
rm ${TMP_FILE} 2> /dev/null

}


function search()
{

if [ $LAST_NAME_SEARCH -eq 1 ]
then

   if [ $FIRST_NAME_SEARCH -eq 1 ]
   then
      mysql -u root -ppassnotell123 employees -e "SELECT emp_no,first_name,last_name INTO OUTFILE '${TMP_FILE}' FROM employees WHERE last_name LIKE '${LAST_NAME_SEARCH_STRING}%' AND first_name LIKE '${FIRST_NAME_SEARCH_STRING}%'";
   else
      mysql -u root -ppassnotell123 employees -e "SELECT emp_no,first_name,last_name INTO OUTFILE '${TMP_FILE}' FROM employees WHERE last_name LIKE '${LAST_NAME_SEARCH_STRING}%'";
   fi

else
   mysql -u root -ppassnotell123 employees -e "SELECT emp_no,first_name,last_name INTO OUTFILE '${TMP_FILE}' FROM employees WHERE first_name LIKE '${FIRST_NAME_SEARCH_STRING}%'";
fi
echo "----------------------------------"
echo ""
cat ${TMP_FILE}
echo ""
echo "----------------------------------"

rm ${TMP_FILE} 2> /dev/null
}

function activate()
{
mysql -u root -ppassnotell123 employees -e "UPDATE employees SET access_card_no = 1 WHERE emp_no = ${RECORD_NUMBER};"
echo "----------------------------------"
echo "User Access Card Status: [ACTIVATED]"
echo "----------------------------------"
}

function deactivate()
{
mysql -u root -ppassnotell123 employees -e "UPDATE employees SET access_card_no = 0 WHERE emp_no = ${RECORD_NUMBER};"
echo "----------------------------------"
echo "User Access Card Status: (DEACTIVATED)"
echo "----------------------------------"
}

function card_query()
{
rm ${TMP_FILE} 2> /dev/null

mysql -u root -ppassnotell123 employees -e "SELECT access_card_no INTO OUTFILE '${TMP_FILE}' FROM employees WHERE emp_no = '${RECORD_NUMBER}'";

declare -i FILE_CONTENT_STATUS=`wc -m  ${TMP_FILE} | awk '{printf $1}' | head -1`

if [ ${FILE_CONTENT_STATUS} -eq 0 ]
then
echo "Error: Invalid Employee Number"
rm ${TMP_FILE} 2> /dev/null
return 1
fi

declare -i FILE_CONTENT_VALUE=`cat ${TMP_FILE}`
rm ${TMP_FILE} 2> /dev/null


mysql -u root -ppassnotell123 employees -e "SELECT first_name,last_name INTO OUTFILE '${TMP_FILE_TWO}' FROM employees WHERE emp_no = '${RECORD_NUMBER}'";

EMPLOYEE_NAME=`cat ${TMP_FILE_TWO}`
rm ${TMP_FILE_TWO} 2> /dev/null

if [ ${FILE_CONTENT_VALUE} -eq 0 ]
then
echo "----------------------------------"
echo "User: ${EMPLOYEE_NAME} | Access Card Status: (DEACTIVATED)"
echo "----------------------------------"

else
echo "----------------------------------"
echo "User: ${EMPLOYEE_NAME} | Access Card Status: [ACTIVATED]"
echo "----------------------------------"
fi

}

function password_update()
{
mysql -u root -ppassnotell123 employees -e "UPDATE employees SET gender = ${PASSWORD_IN} WHERE emp_no = ${RECORD_NUMBER};"
echo "----------------------------------"
echo "User Password Updated"
echo "----------------------------------"
}

function password_query()
{
rm ${TMP_FILE} 2> /dev/null

mysql -u root -ppassnotell123 employees -e "SELECT gender INTO OUTFILE '${TMP_FILE}' FROM employees WHERE emp_no = '${RECORD_NUMBER}'";

declare -i FILE_CONTENT_STATUS=`wc -m  ${TMP_FILE} | awk '{printf $1}' | head -1`

if [ ${FILE_CONTENT_STATUS} -eq 0 ]
then
echo "Error: Invalid Employee Number"
rm ${TMP_FILE} 2> /dev/null
return 1
fi

declare -i FILE_CONTENT_VALUE=`cat ${TMP_FILE}`
rm ${TMP_FILE} 2> /dev/null


mysql -u root -ppassnotell123 employees -e "SELECT first_name,last_name INTO OUTFILE '${TMP_FILE_TWO}' FROM employees WHERE emp_no = '${RECORD_NUMBER}'";

EMPLOYEE_NAME=`cat ${TMP_FILE_TWO}`
rm ${TMP_FILE_TWO} 2> /dev/null

echo "----------------------------------"
echo "User: ${EMPLOYEE_NAME} | Password: ${FILE_CONTENT_VALUE}"
echo "----------------------------------"


}




if [ $SEARCH_FUNCTION -gt 0 ]
then
search
fi


if [ $SEARCH_RECORD_FUNCTION -eq 1 ]
then
search_record
fi

if [ $DELETE_FUNCTION -eq 1 ]
then
delete_record
fi

if [ $ACTIVATE_FUNCTION -eq 1 ]
then
card_query
activate
fi

if [ $DEACTIVATE_FUNCTION -eq 1 ]
then
card_query
deactivate
fi

if [ $CARD_QUERY_FUNCTION -eq 1 ]
then
card_query
fi

if [ $PASSWORD_GET -eq 1 ]
then
password_query
fi

if [ $PASSWORD_UPDATE -eq 1 ]
then
password_update
fi







