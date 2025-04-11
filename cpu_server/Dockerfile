FROM python:3.11-alpine

# Устанавливаем необходимые пакеты для компиляции psutil
RUN apk add --no-cache gcc musl-dev linux-headers

WORKDIR /app
COPY cpu.py .

# Устанавливаем psutil, теперь сборка пройдёт успешно
RUN pip install --no-cache-dir psutil

EXPOSE 9000
CMD ["python", "cpu.py"]

