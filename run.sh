#!/bin/sh

# service postgresql reload
sudo /etc/init.d/postgresql start
sudo -u postgres dropdb dblabs
sudo -u postgres psql --command "DROP ROLE dblabs;" 
sudo -u postgres psql --command "CREATE USER dblabs WITH PASSWORD 'dblabs';" 
sudo -u postgres psql --command "ALTER USER dblabs WITH SUPERUSER;"
sudo -u postgres createdb -T template0 -E UTF8 -O dblabs dblabs
sudo -u postgres psql -U dblabs -d dblabs -a -f ./01-2.sql
echo "------------ [OK] Ready ------------"

sudo -u postgres psql -U dblabs -d dblabs -a -f ./RK1.sql
