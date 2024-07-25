#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~"



SERVICES_MENU(){
    SERVICES=$($PSQL "select service_id, name from services order by service_id")
    if [[ $1 ]]
    then
      echo -e "\n$1"
    fi
    echo -e "What would you like today?"
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME" 
    done
    read SERVICE_ID_SELECTED
    SERVICE_ID_S=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_S ]]
    then
      SERVICES_MENU "Please enter a valid option"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
      echo -e "What time would you like your cut,$CUSTOMER_NAME?"
      read SERVICE_TIME
      INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
      then
        SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
        echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
}

SERVICES_MENU