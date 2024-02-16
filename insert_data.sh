#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
 
#echo $($PSQL "TRUNCATE TABLE games, teams");

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  if [[ "$YEAR" != "year" || "$ROUND" != "round" ||  "$WINNER" != "winner" || "$OPPONENT" != "opponent" || "$WINNER_GOALS" != "winner_goals" || "$OPPONENT_GOALS" != "opponent_goals" ]]
  then
    WINNER_DATA=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    if [[ "$WINNER_DATA" ]]
    then
      echo Team already exists in the database.
    else 
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if  [[ $INSERT_WINNER != 'INSERT 0 1' ]]
      then
        echo Failed to insert team.
      else 
        echo Inserted team $WINNER
      fi
    fi

    OPPONENT_DATA=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    if [[ "$OPPONENT_DATA" ]]
    then
      echo Team already exists in the database.
    else 
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if  [[ $INSERT_OPPONENT != 'INSERT 0 1' ]]
      then
        echo Failed to insert team.
      else 
        echo Inserted team $OPPONENT
      fi
    fi

    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    GAME_DATA=$($PSQL "SELECT year, round, winner_id, opponent_id, winner_goals, opponent_goals from games WHERE year = $YEAR AND round = '$ROUND' AND winner_id = $WINNER_ID AND opponent_id = $OPPONENT_ID AND winner_goals = $WINNER_GOALS AND opponent_goals = $OPPONENT_GOALS")
    if [[ "$GAME_DATA" ]]
    then
      echo Game already exists in the database. 
    else
      INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME != 'INSERT 0 1' ]]
      then
        echo Failed to insert game.
      else 
        echo Inserted game: $YEAR, $ROUND, $WINNER VS $OPPONENT score $WINNER_GOALS-$OPPONENT_GOALS
      fi
    fi
  fi
done
