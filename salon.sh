#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\nWelcome to the salon, please select a service:\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi
SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")

echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED';")
SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/\<./\U&/g')
case $SERVICE_ID_SELECTED in
  1|2|3) REGISTRATION;;
  *) MAIN_MENU "Please select a valid service:";;
esac 
}
REGISTRATION() {
  echo -e "Registration form for $SERVICE_NAME_FORMATTED\n"
  echo -e "Please enter your phone number:\n"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';") 
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/\<./\U&/g')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "Please enter your name:\n"
      read CUSTOMER_NAME
      echo -e "Please enter appointment time\n"
      read SERVICE_TIME
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      REGISTRATION_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) values('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');")
      echo "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    else
      echo -e "Please enter appointment time\n"
      read SERVICE_TIME
      REGISTRATION_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) values('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');")
      echo "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

MAIN_MENU