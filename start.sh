#!/bin/sh
set -e

echo "waiting for postgres..."
/app/wait-for.sh postgres:5432 -- echo "postgres is up"

echo "start the app"
exec "$@"
