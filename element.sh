#!/bin/bash

PSQL="psql -X --username=postgres --dbname=periodic_table --tuples-only -c"

# Function to retrieve and display element data
display_data() {
  echo "$1" | while read BAR BAR NUMBER BAR SYMBOL BAR NAME BAR WEIGHT BAR MELTING BAR BOILING BAR TYPE; do
    echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $WEIGHT amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
}

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 1
fi

# Determine if input is atomic number, symbol, or name
INPUT=$1
if [[ $INPUT =~ ^[0-9]+$ ]]; then
  # Input is atomic number
  QUERY="SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING (type_id) WHERE atomic_number=$INPUT"
else
  LENGTH=${#INPUT}
  if [[ $LENGTH -le 2 ]]; then
    # Input is atomic symbol
    QUERY="SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING (type_id) WHERE symbol='$INPUT'"
  else
    # Input is element name
    QUERY="SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING (type_id) WHERE name='$INPUT'"
  fi
fi

# Execute query
DATA=$($PSQL "$QUERY")

# Check if data was found
if [[ -z $DATA ]]; then
  echo "I could not find that element in the database."
else
  display_data "$DATA"
fi
