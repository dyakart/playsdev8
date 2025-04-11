#!/bin/bash
# Определяем базовый каталог относительно расположения скрипта
BASE_DIR=$(cd "$(dirname "$0")" && pwd)

# Убедимся, что необходимый каталог для логов существует
mkdir -p "$BASE_DIR/logs"

# Пути к файлам логов относительно BASE_DIR
NGINX_LOG="$BASE_DIR/nginx/logs/access.log"   # лог NGINX (смонтированный в контейнере)
OFFSET_FILE="$BASE_DIR/logs/.offset"            # временный файл для хранения смещения

FILE1="$BASE_DIR/logs/file1.log"   # основной лог, обновляется каждые 5 сек
FILE2="$BASE_DIR/logs/file2.log"   # лог очисток
FILE3="$BASE_DIR/logs/file3.log"   # лог с HTTP-кодами 5xx
FILE4="$BASE_DIR/logs/file4.log"   # лог с HTTP-кодами 4xx

# Лимит размера FILE1: 300 кБ (примерно 307200 байт)
SIZE_LIMIT=307200

# Убедимся, что файлы существуют (если их нет — создаем)
touch "$FILE1" "$FILE2" "$FILE3" "$FILE4"

# Инициализируем файл смещения, если его еще нет
if [ ! -f "$OFFSET_FILE" ]; then
    echo "0" > "$OFFSET_FILE"
fi

while true; do
    # Считываем предыдущее смещение
    OFFSET=$(cat "$OFFSET_FILE")
    
    # Определяем текущий размер файла логов NGINX
    CURRENT_SIZE=$(stat -c%s "$NGINX_LOG")
    
    # Если лог-файл был перезаписан, сбрасываем смещение
    if [ "$CURRENT_SIZE" -lt "$OFFSET" ]; then
        OFFSET=0
    fi

    # Читаем новые строки, начиная с последнего смещения
    NEW_LOGS=$(tail -c +$((OFFSET + 1)) "$NGINX_LOG")
    
    # Обновляем смещение: текущий размер файла
    echo "$CURRENT_SIZE" > "$OFFSET_FILE"
    
    # Если появились новые записи, обрабатываем их
    if [ -n "$NEW_LOGS" ]; then
        # Дописываем новые записи в FILE1
        echo "$NEW_LOGS" >> "$FILE1"
        
        # Фильтруем записи с кодами 5xx (предполагается, что статус находится в 9-м поле)
        echo "$NEW_LOGS" | awk '$9 ~ /^5[0-9][0-9]$/' >> "$FILE3"
        
        # Фильтруем записи с кодами 4xx (используем sed)
        echo "$NEW_LOGS" | sed -n '/ [4][0-9]\{2\} /p' >> "$FILE4"
    fi
    
    # Проверяем размер FILE1
    FILE1_SIZE=$(stat -c%s "$FILE1")
    if [ "$FILE1_SIZE" -gt "$SIZE_LIMIT" ]; then
        # Подсчитываем число строк в FILE1 как число удаленных записей
        LINE_COUNT=$(wc -l < "$FILE1")
        # Получаем текущую дату и время
        CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")
        # Записываем отчет об очистке в FILE2
        echo "[$CURRENT_DATE] Очищен file1.log, удалено строк: $LINE_COUNT (было ${FILE1_SIZE} байт)" >> "$FILE2"
        # Очищаем FILE1
        > "$FILE1"
    fi
    
    sleep 5
done
