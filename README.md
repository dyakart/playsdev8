# Playsdev Hackathon — Проект команды №8

Добро пожаловать в репозиторий проекта команды №8 для хакатона от компании Playsdev! В данном проекте мы разворачиваем несколько Docker-контейнеров для нашего приложения, используя собственные образы. Ниже приведены инструкции по сборке, запуску и публикации образов в Docker Hub.

---

## Структура проекта

- **Dockerfiles:**
  - `Dockerfile` — для сборки образа `playsdev-nginx-main`
  - `Dockerfile.apache` — для сборки образа `playsdev-apache-php`
  - `cpu_server/Dockerfile` — для сборки образа `playsdev-cpu-service`

- **Конфигурация Nginx:**
  - `nginx/nginx.conf` — основной файл конфигурации Nginx для сервиса `nginx-main`
  - `nginx/conf.d` — дополнительные конфигурационные файлы для Nginx
  - `nginx/html` — статические файлы для главного веб-сервера
  - `nginx/red` — контент для контейнера `nginx-red` (отдаёт красную страницу)
  - `nginx/blue` — контент для контейнера `nginx-blue` (отдаёт синюю страницу)

- **Дополнительные сервисы:**
  - `nginx_secondpage` — конфигурация и контент для второго Nginx-сервера на порту 8081

---
