#!/bin/bash
set -e

# Массив имён контейнеров, созданных ранее
CONTAINERS=(nginx-main apache-php nginx-red nginx-blue cpu-service nginx-secondpage)

echo "Остановка и удаление контейнеров..."
for container in "${CONTAINERS[@]}"
do
  if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
      echo "Останавливаю контейнер $container ..."
      docker stop "$container"
      echo "Удаляю контейнер $container ..."
      docker rm "$container"
  else
      echo "Контейнер $container не найден."
  fi
done

# Удаление созданной сети, если она существует
NETWORK="my-network"
if docker network ls --format '{{.Name}}' | grep -q "^${NETWORK}$"; then
  echo "Удаляю сеть $NETWORK ..."
  docker network rm "$NETWORK"
else
  echo "Сеть $NETWORK не найдена."
fi

echo "Все контейнеры и сеть успешно остановлены и удалены."
