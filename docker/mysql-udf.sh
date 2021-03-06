#!/bin/bash

set -e

FILE=/root/installdb.sql

wget https://raw.githubusercontent.com/mysqludf/lib_mysqludf_preg/testing/installdb.sql -O $FILE
sed -i 's/USE mysql;//g' $FILE

MYSQL_CMD="mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASSWORD"

until $MYSQL_CMD -e ";"; do
  >&2 echo "MySQL is unavailable - sleeping"
  sleep 1
done

echo "MySQL is available..."

echo "Checking if functions exist..."
exists=`$MYSQL_CMD -N -e "select LIB_MYSQLUDF_PREG_INFO();" 2>/dev/null` || true

# if exists command came back empty
if [[ -z $exists ]]; then
  echo "Adding functions..."
  $MYSQL_CMD deltanyc < $FILE
  echo "UDFs added successfully"
else
  echo "Functions already added"
fi

