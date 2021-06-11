#!/bin/bash

echo "Running Release Tasks"

if [ "$RUN_DB_MIGRATIONS_DURING_RELEASE" == "true" ]; then
  echo "Running db migrations"
  bundle exec rails db:migrate
fi

echo "Done running release-tasks.sh for fid"