@echo off
docker compose --progress quiet -f "%~dp0..\docker-compose.yml" run --rm node npx %*
