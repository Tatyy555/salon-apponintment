#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # Display the menu
  SHOP_MENU=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo -e "$SHOP_MENU"  | while read SERVICE_ID BAR SERVICE
    do
      echo "$SERVICE_ID) $SERVICE"
    done
  
  # If not exist, show main manu
  read SERVICE_ID_SELECTED 
  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SELECTED_SERVICE ]]
    then
    MAIN_MENU "I could not find that service. What would you like today?"
    else
    CUSTOMER_MENU
  fi
}

CUSTOMER_MENU(){
  # Ask for phone number
  echo -e "\nWhat's your phone number?\n"
  read CUSTOMER_PHONE
  CUSTOMER_PHONE_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_PHONE_RESULT ]]
      then
      # Ask for name
      echo -e "\nI don't have a record for that phone number, what's your name?\n"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      RESERVATION
      else
      RESERVATION
    fi
}

RESERVATION(){
    # Ask for reservation
    echo -e "\nWhat time would you like your$SELECTED_SERVICE, $CUSTOMER_NAME?\n"
    read SERVICE_TIME

    # Add to appointments
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    APPOINTMENTS_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME' )")

    # Show the message
    if [[ $APPOINTMENTS_RESULT = "INSERT 0 1" ]]
  
      then
      echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?" 