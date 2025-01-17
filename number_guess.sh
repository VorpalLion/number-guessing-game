#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"

SECRET_NUMBER=$((1 + RANDOM % 1000))

echo "Enter your username:"
read GET_USERNAME

# check if username already exits
USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$GET_USERNAME'")

# if doesn't exist
if [[ -z $USERNAME ]]
then
  USERNAME=$GET_USERNAME

  # insert new user
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  GAMES_PLAYED=0
  BEST_GAME=0

  # print welcoming message
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # get username info
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  
  # print welcome back message
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=0
NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

GAMES_PLAYED=$((GAMES_PLAYED + 1))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")

# check if input is a number
while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
done

while [[ $GUESS != $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [[ "$GUESS" -lt "$SECRET_NUMBER" ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
  elif [[ "$GUESS" -gt "$SECRET_NUMBER" ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
  fi 
done

if [[ "$BEST_GAME" -gt "$NUMBER_OF_GUESSES" || "$BEST_GAME" = 0 ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

