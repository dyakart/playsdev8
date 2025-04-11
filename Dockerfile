# Используем официальный Alpine-образ
FROM nginx:alpine

# Устанавливаем модуль image_filter
RUN apk add --no-cache nginx-mod-http-image-filter
