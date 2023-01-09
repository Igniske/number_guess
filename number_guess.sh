#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_game -t --no-align -c"
SECRET_NUM=$(( $RANDOM % 1001  ))
WIN=0
GUESSES_NUM=1
echo $SECRET_NUM
echo "Enter your username:"
read USERNAME
if [[ -z $USERNAME ]]
  then
  echo "Enter a valid username"
  exit
fi
  

SEARCH_USER=$($PSQL "SELECT username FROM username WHERE username = '$USERNAME'")

if [[ -z $SEARCH_USER ]]
  then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
  else
  GAMES_PLAYED=$($PSQL "SELECT games_player FROM username WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM username WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

GAME_START() {
  while [ $WIN == 0 ]
  do
    read RESPONSE
    if  [[  "$RESPONSE" =~ [a-z] ]]
      then
      echo "That is not an integer, guess again:"
      elif [[ $RESPONSE < $SECRET_NUM ]]
      then
      echo "It's higher than that, guess again:"
      GUESSES_NUM=$(($GUESSES_NUM + 1))
      elif [[ $RESPONSE > $SECRET_NUM ]]
      then
      echo "It's lower than that, guess again:"
      GUESSES_NUM=$(($GUESSES_NUM + 1))
      elif [[ $RESPONSE == $SECRET_NUM ]]
      then
      echo "You guessed it in $GUESSES_NUM tries. The secret number was $SECRET_NUM. Nice job!"
      WIN=1
      if [[ -z $SEARCH_USER ]]
        then
        SAVE_USER=$($PSQL "INSERT INTO username(username, games_player, best_game) VALUES ('$USERNAME', $WIN, $GUESSES_NUM)")
        else
        REGISTERED_WINS=$($PSQL "SELECT games_player FROM username WHERE username='$SEARCH_USER'")
        WIN=$(($REGISTERED_WINS + 1))
        REGISTERED_BEST=$($PSQL "SELECT best_game FROM username WHERE username='$SEARCH_USER'")
        if [[ $GUESSES_NUM < $REGISTERED_BEST ]]
          then
          REGISTERED_BEST=$GUESSES_NUM
          fi
        CHANGE_USER=$($PSQL "UPDATE username SET games_player=$WIN ,best_game=$REGISTERED_BEST WHERE username='$SEARCH_USER'")
        fi
    fi
  done
}

GAME_START
