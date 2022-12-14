#!/bin/bash
docker-compose down
rm -rf master/data/*
rm -rf replicas/*/data/*

# docker pull mysql:8.0.31-debian
docker-compose up -d

until docker exec mysql-master sh -c  "export MYSQL_PWD=master; mysql -u root yating -e 'SHOW TABLES;'"
do
  echo "Waiting for master-db database connection..."
  sleep 4
done

priv_stmt='CREATE USER "yating_replica"@"%" IDENTIFIED BY "yating"; GRANT REPLICATION SLAVE ON *.* TO "yating_replica"@"%"; FLUSH PRIVILEGES;'
docker exec mysql-master sh -c "export MYSQL_PWD=master; mysql -u root -e '$priv_stmt'"


MASTER_STATUS=`docker exec mysql-master sh -c 'export MYSQL_PWD=master; mysql -u root -e "SHOW MASTER STATUS"'`
echo $MASTER_STATUS


until docker exec mysql-replica-1 sh -c "export MYSQL_PWD=slave; mysql -u root yating -e 'SHOW TABLES;'"
do
  echo "Waiting for slave-db-1 database connection..."
  sleep 4
done

until docker exec mysql-replica-2 sh -c "export MYSQL_PWD=slave; mysql -u root yating -e 'SHOW TABLES;'"
do
  echo "Waiting for slave-db-2 database connection..."
  sleep 4
done

CURRENT_LOG=`echo $MASTER_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MASTER_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE REPLICATION SOURCE TO MASTER_HOST='mysql-master',MASTER_USER='yating_replica',MASTER_PASSWORD='yating',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=slave; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
echo $start_slave_cmd
docker exec mysql-replica-1 sh -c "$start_slave_cmd"
docker exec mysql-replica-1 sh -c "export MYSQL_PWD=slave; mysql -u root -e 'SHOW SLAVE STATUS \G'"

docker exec mysql-replica-2 sh -c "$start_slave_cmd"
docker exec mysql-replica-2 sh -c "export MYSQL_PWD=slave; mysql -u root -e 'SHOW SLAVE STATUS \G'"
