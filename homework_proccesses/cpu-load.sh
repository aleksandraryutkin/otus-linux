#!/bin/bash

echo "Запуск процесса с приоритетом 10..."
time nice -n 10 dd if=/dev/urandom of=/dev/null bs=4096 count=100000 &
pid1=$!

echo "Запуск процесса с приоритетом 19..."
time nice -n 19 dd if=/dev/urandom of=/dev/null bs=4096 count=100000 &
pid2=$!

# Ожидание завершения обоих процессов
wait $pid1
wait $pid2

echo "Оба процесса завершены."
