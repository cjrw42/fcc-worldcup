#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


 CLEANUP=$($PSQL "truncate table games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNERGOALS OPPONENTGOALS
do
 if [[ $YEAR != year ]]
 then 
  # grab the foreign keys
  WINNING_TEAM_ID=$($PSQL "select team_id from teams where name='$WINNER'")
  if [[ -z $WINNING_TEAM_ID ]]
  then
    # we need to add the team first
    INSERT_TEAM_RESULT=$($PSQL "insert into teams(name) values('$WINNER')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        # get new $WINNING_TEAM_ID
        WINNING_TEAM_ID=$($PSQL "select team_id from teams where name='$WINNER'") 
      fi
    # get new $WINNING_TEAM_ID

  fi 
  OPPONENT_TEAM_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
  if [[ -z $OPPONENT_TEAM_ID ]]
  then
    # we need to add the team first
    INSERT_TEAM_RESULT=$($PSQL "insert into teams(name) values('$OPPONENT')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        # get new $WINNING_TEAM_ID
        OPPONENT_TEAM_ID=$($PSQL "select team_id from teams where name='$OPPONENT'") 
      fi
    fi 
  
  # now we can build the insert string for games table
  RESULT=$($PSQL "insert into games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) values($YEAR, '$ROUND', $WINNING_TEAM_ID, $OPPONENT_TEAM_ID,  $WINNERGOALS, $OPPONENTGOALS)" )
  fi
done 
