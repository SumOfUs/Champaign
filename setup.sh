#!/bin/bash
docker-compose build
docker-compose run web rake db:migrate
docker-compose run web rake champaign:seed_liquid
docker-compose run web rake db:seed
docker-compose up