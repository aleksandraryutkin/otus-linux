#!/bin/bash

date_one_hour_ago=$(date -d "1 hour ago" +%s)
email=[your_email]
output_access_file=./output_access.txt
output_error_file=./output_error.txt
access_log=$(find /var/log/ -type f -name "access*")
error_log=$(find /var/log/ -type f -name "error*")

# Функция для очистки ресурсов
cleanup() {
    echo "Выполнение завершено. Выполняется очистка..."
    # Удаляем файл блокировки и временные файлы
    rm -f /var/lock/my_script.lock $output_access_file $output_error_file
}

# Установка трапа для сигналов завершения
trap cleanup EXIT

# Вывод необходимых строк в файл из access.log
# Читаем строки с конца файла
while IFS= read -r line_access; do
    # Получаем дату и время из строки
    date_str=$(echo "$line_access" | awk '{print $4}')

    # Если строка не пустая
    if [ -n "$date_str" ]; then
        # Извлекаем дату
        date=$(echo "$date_str" | awk -F':' '{print $1}' | sed 's/\[//')

        # Преобразуем дату в понятный формат для утилиты date
        date_to_timestamp=$(awk -F'[/ ]' '{print $3"-"(index("JanFebMarAprMayJunJulAugSepOctNovDec", $2)+2)/3"-"$1}' <<< "$date")

        # Извлекаем время
        date_time=$(echo "$date_str" | awk -F':' '{print $2":"$3":"$4}' | awk '{print $1}')

        # Преобразуем дату и время в числовой формат
        date_timestamp=$(date -d "$date_to_timestamp $date_time" +%s)

        # Проверяем условие
        if [ "$date_timestamp" -gt "$date_one_hour_ago" ]; then
            # Записываем строку в файл
            echo "$line_access" >> $output_access_file
        else
            # Если условие не выполняется, выходим из цикла
            break
        fi
    fi
done < <(tac $access_log)

# Вывод необходимых строк в файл из error.log
# Читаем строки с конца файла
while IFS= read -r line_error; do
    # Извлекаем дату
    date_error=$(echo "$line_error" | awk '{print $1}')

    # Извлекаем время
    date_time_error=$(echo "$line_error" | awk '{print $2}')

    # Преобразуем дату и время в числовой формат
    date_timestamp_error=$(date -d "$date_error $date_time_error" +%s)

    # Проверяем условие
    if [ "$date_timestamp_error" -gt "$date_one_hour_ago" ]; then
        # Записываем строку в файл
        echo "$line_error" >> $output_error_file
    else
        # Если условие не выполняется, выходим из цикла
        break
    fi
done < <(tac $error_log)

# Функция для отправки письма с отчетом
send_report_email() {
    # Получаем список IP адресов с наибольшим количеством запросов за последний час
    top_ips=$(awk '{print $1}' $output_access_file | sort | uniq -c | sort -nr | head -n 10)
    
    # Получаем список URL с наибольшим количеством запросов за последний час
    top_urls=$(awk '{print $7}' $output_access_file | sort | uniq -c | sort -nr | head -n 10)
    
    # Получаем список всех кодов HTTP ответа за последний час
    http_codes=$(awk '{print $9}' $output_access_file | sort | uniq -c | sort -nr)

    # Получаем список ошибок веб-сервера/приложения
    errors=$(tail $output_error_file)

    # Формируем сообщение с отчетом с указанием диапазона даты и времени
    report_message="Report for $(date -d "1 hour ago" "+%d/%b/%Y %H:%M:%S") - $(date "+%d/%b/%Y %H:%M:%S")"
    report_message+="\n\nTop IP addresses:\n$top_ips\n\nTop URLs:\n$top_urls\n\nHTTP response codes:\n$http_codes\n\nErrors:\n$errors"

    # Отправляем письмо на заданную почту
    echo -e "$report_message" | mail -s "Nginx Server Report" $email
}

# Проверяем, запущен ли уже скрипт
if [ -f /var/lock/my_script.lock ]; then
    echo "Script is already running."
    exit 1
fi

# Создаем файл блокировки
touch /var/lock/my_script.lock

# Вызываем функцию отправки отчета
send_report_email
