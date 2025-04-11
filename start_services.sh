#!/bin/bash
set -e

# Название общей сети
NETWORK="my-network"

# Создание общей сети (если ещё не создана)
if ! docker network inspect "$NETWORK" > /dev/null 2>&1; then
  echo "Создаю сеть $NETWORK..."
  docker network create "$NETWORK"
else
  echo "Сеть $NETWORK уже существует."
fi

echo "Сборка образов..."

# 1) Сборка образа для nginx-main
docker build -f Dockerfile -t nginx-main-image .

# 2) Сборка образа для apache-php
docker build -f Dockerfile.apache -t apache-php-image .

# 3) Сборка образа для cpu-service (находимся в директории cpu_server)
(
  cd cpu_server
  docker build -f Dockerfile -t cpu-service-image .
)

echo "Запуск контейнеров..."

# Запускаем apache-php
docker run -d \
  --name apache-php \
  --network "$NETWORK" \
  --restart always \
  -v "$(pwd)/nginx/html/info.php:/var/www/html/info.php" \
  apache-php-image

# Запускаем nginx-red (красная страница)
docker run -d \
  --name nginx-red \
  --network "$NETWORK" \
  --restart always \
  -v "$(pwd)/nginx/red:/usr/share/nginx/html" \
  nginx:latest

# Запускаем nginx-blue (синяя страница)
docker run -d \
  --name nginx-blue \
  --network "$NETWORK" \
  --restart always \
  -v "$(pwd)/nginx/blue:/usr/share/nginx/html" \
  nginx:latest

# Запускаем cpu-service
docker run -d \
  --name cpu-service \
  --network "$NETWORK" \
  --restart always \
  --expose 9000 \
  cpu-service-image

# Запускаем nginx-secondpage
docker run -d \
  --name nginx-secondpage \
  --network "$NETWORK" \
  --restart always \
  -v "$(pwd)/nginx_secondpage/conf.d:/etc/nginx/conf.d" \
  -v "$(pwd)/nginx_secondpage/html:/usr/share/nginx/html" \
  -p 8081:80 \
  nginx:latest

# Запускаем nginx-main (зависит от остальных контейнеров, запускаем его последним)
docker run -d \
  --name nginx-main \
  --network "$NETWORK" \
  --restart always \
  -v "$(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro" \
  -v "$(pwd)/nginx/conf.d:/etc/nginx/conf.d" \
  -v "$(pwd)/nginx/html:/usr/share/nginx/html" \
  -p 80:80 \
  -p 443:443 \
  nginx-main-image

echo "Все сервисы запущены."
