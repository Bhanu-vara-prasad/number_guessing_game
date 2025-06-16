#!/bin/bash
# Step: Add username input and greeting

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Check if username exists in the database
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_DATA ]]
then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user with default values
  INSERT_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL);")
else
  # Existing user
  GAMES_PLAYED=$(echo $USER_DATA | cut -d '|' -f1)
  BEST_GAME=$(echo $USER_DATA | cut -d '|' -f2)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS

  # Check if guess is an integer number
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((GUESS_COUNT++))

  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    # Update games_played count
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';")

# Get current best_game
CURRENT_BEST=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")

# If best_game is NULL or current guess count is less, update best_game
if [[ -z $CURRENT_BEST || $CURRENT_BEST == "NULL" || $GUESS_COUNT -lt $CURRENT_BEST ]]; then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username = '$USERNAME';")
fi

    break
  fi
done
