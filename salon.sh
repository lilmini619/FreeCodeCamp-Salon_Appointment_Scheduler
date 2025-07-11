#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nIt's my Hurrr Salon"
echo -e "\nPlease type a valid number and press enter."

MAIN_MENU() {
  #check if first argument is present
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #function to retrieve list of services
  SERVICES_AND_ID=$($PSQL "SELECT * FROM services ORDER BY service_id")
  
  #display list of services -> b/c it's multiple lines, must use while read
  #variable needs to be in quotations or else it will output as a single line...interesting
  #comma-delimited, BAR is used to label the separator between names and service_IDs
  echo "$SERVICES_AND_ID" | while read NAME BAR SERVICE_ID
  do
    echo -e "$SERVICE_ID) $NAME"
  done


  #ask for service
  read SERVICE_ID_SELECTED
 
  case $SERVICE_ID_SELECTED in  #provide code instructions depending on what user selects
  1|2|3) APPOINTMENTS ;; #ask users for input if they select a valid service
  *) MAIN_MENU "Please press a valid number and then press 'Enter.'" ;; #show same list of services if you pick a service that doesn't exist
  esac
}

APPOINTMENTS() {
  echo -e "\nWhat is your phone number? (Please type your phone number and press enter)"
  read CUSTOMER_PHONE
  
  #check if customer exists
  GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #if no customer exists
  if [[ -z $GET_CUSTOMER_NAME ]]
  then
    #get customer name
    echo -e "\nWhat is your name? (Please type your name and press enter)"
    read CUSTOMER_NAME
    #add customer name and phone number
    ADD_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
    #get customer service time
    echo -e "\nWhat is your desired appointment time? (Please type a time and press enter)"
    read SERVICE_TIME
    #add service time
    ADD_SERVICE_TIME=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME', $GET_CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  #if customer does exist
  else
    #what is their service time
    echo -e "\nWhat is your desired appointment time? (Please type a time and press enter)"
    read SERVICE_TIME
    GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    ADD_SERVICE_TIME=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME',$GET_CUSTOMER_ID,$SERVICE_ID_SELECTED)")
  fi

  GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a$GET_SERVICE_NAME at $SERVICE_TIME,$GET_CUSTOMER_NAME."
  #why is there an extra gap between 'a' and $GET_SERVICE_NAME?
}

MAIN_MENU #why do we have to call the function? why does this have to be at the end?