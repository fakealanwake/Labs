#!/bin/bash

# Справка
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat << EOF
Использование: $0 <суффикс> <выходной_файл>

Скрипт для поиска неисполняемых файлов с заданным суффиксом, размер которых
кратен размеру блока файловой системы.

Аргументы:
  суффикс           Суффикс файлов для поиска (например, .txt, .log, .sh)
  выходной_файл     Имя файла для сохранения результатов

Опции:
  -h, --help        Показать эту справку и выйти

Примеры:
  $0 .txt result.txt
  $0 .log logs.txt
EOF
    exit 0
fi


if [ $# -ne 2 ]; then
    echo "Ошибка: неверное количество аргументов"
    echo "Использование: $0 <суффикс> <выходной_файл>"
    echo "Для справки: $0 --help"
    exit 1
fi

SUFFIX="$1"
OUTPUT_FILE="$2"


BLOCK_SIZE=$(stat -f -c %S . 2>/dev/null)

if [ -z "$BLOCK_SIZE" ] || [ "$BLOCK_SIZE" -le 0 ]; then
    echo "Ошибка: не удалось определить размер блока файловой системы"
    exit 1
fi

echo "Размер блока файловой системы: $BLOCK_SIZE байт"


> "$OUTPUT_FILE"


find . -type f -name "*$SUFFIX" -not -executable | while read -r file; do
    size=$(stat -c%s "$file" 2>/dev/null)
    
    if [ "$size" -ne 0 ] && [ $((size % BLOCK_SIZE)) -eq 0 ]; then
        echo "$file $size" >> "$OUTPUT_FILE"
    fi
done

# Подсчёт результатов
count=$(wc -l < "$OUTPUT_FILE")
echo "Готово. Найдено файлов: $count"
