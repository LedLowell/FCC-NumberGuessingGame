#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo -e "\n~~~~Number Guessing Game~~~~\n"
GET_USERNAME() {
if [[ -z $1 ]]
then
#Ask username
echo "Enter your username:"
else
echo "$1"
fi
read USERNAME
#If username is empty
if [[ -z $USERNAME ]]
then
GET_USERNAME "Please enter a valid username:"
fi
}
GET_USERNAME
#Get user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
#If not found
if [[ -z $USER_ID ]]
then
#Insert username and get new user_id
INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
#Output new user salute
echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
#Get user data
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) from games WHERE user_id=$USER_ID")
BEST_GAME=$($PSQL "SELECT MIN(attempts) from games WHERE user_id=$USER_ID")
#Output user salute
echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
#Create secret number
SECRET_NUMBER=$(( RANDOM % 1000 ))
echo $SECRET_NUMBER
ATTEMPTS=1
GUESS_NUMBER(){
if [[ -z $1 ]]
then
echo -e "\nGuess the secret number between 1 and 1000:"
elif [[ $1 == "invalid" ]]
then
echo -e "\nThat is not an integer, guess again:"
else
#Add attempt
(( ATTEMPTS++ ))
echo -e "\n$1"
fi
#Ask to input secret number
read INPUT_NUMBER
#If input is not a number
if [[ ! $INPUT_NUMBER =~ ^[0-9]+$ ]]
then
GUESS_NUMBER "invalid"
else
#If input is higher or lower than secret number
if [[ $INPUT_NUMBER -lt $SECRET_NUMBER ]]
then
GUESS_NUMBER "It's higher than that, guess again:"
elif [[ $INPUT_NUMBER -gt $SECRET_NUMBER ]]
then
GUESS_NUMBER "It's lower than that, guess again:"
else
#If input is secret number
#Insert game info into database
INSERT_GAME_INFO_RESULT=$($PSQL "INSERT INTO games(user_id, attempts) VALUES($USER_ID, $ATTEMPTS)")
#Output game final info
echo -e "\nYou guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUMBER. Nice job!"
fi
fi
}
GUESS_NUMBER
